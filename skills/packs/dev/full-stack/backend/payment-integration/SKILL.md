---
name: payment-integration
description: "Use when adding payments, subscriptions, or billing to apps. Covers Stripe, Polar (OSS), checkout flows, webhooks, and subscription management. OSS-first: Polar primary, Stripe as premium standard. Triggers on: payment, Stripe, billing, subscription, checkout, webhook, invoice, Polar, Lemon Squeezy."
metadata:
  author: leopoldo
  source: custom
  created: 2026-03-24
  forge_strategy: build
license: MIT
upstream:
  url: null
  version: null
  last_checked: 2026-03-24
---

# Payment Integration -- Billing and Subscriptions

## Why This Exists

| Problem | Solution |
|---------|----------|
| Every SaaS needs payments, zero coverage in plugin | Complete payment patterns |
| Stripe is powerful but complex | Step-by-step with webhook handling |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Polar (OSS, merchant of record) | Stripe (industry standard) |
| -- | Lemon Squeezy (MoR) |

## Core Workflow

### 1. Stripe Checkout (Most Common)

```typescript
// app/api/checkout/route.ts
import Stripe from "stripe"
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: Request) {
  const { priceId, userId } = await req.json()

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_URL}/pricing`,
    client_reference_id: userId,
    metadata: { userId }
  })

  return Response.json({ url: session.url })
}
```

### 2. Webhook Handler (Critical)

```typescript
// app/api/webhooks/stripe/route.ts
import Stripe from "stripe"
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: Request) {
  const body = await req.text()
  const signature = req.headers.get("stripe-signature")!

  let event: Stripe.Event
  try {
    event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET!)
  } catch {
    return new Response("Invalid signature", { status: 400 })
  }

  switch (event.type) {
    case "checkout.session.completed":
      const session = event.data.object as Stripe.Checkout.Session
      await activateSubscription(session.client_reference_id!, session.subscription as string)
      break
    case "invoice.paid":
      await recordPayment(event.data.object as Stripe.Invoice)
      break
    case "customer.subscription.deleted":
      await cancelSubscription(event.data.object as Stripe.Subscription)
      break
  }

  return new Response("OK")
}
```

### 3. Subscription Management

```typescript
// Check subscription status
async function getUserPlan(userId: string) {
  const sub = await db.query.subscriptions.findFirst({
    where: eq(subscriptions.userId, userId)
  })
  if (!sub) return "free"
  if (sub.status === "active") return sub.plan
  return "free"
}

// Cancel subscription
async function cancelSub(subscriptionId: string) {
  await stripe.subscriptions.update(subscriptionId, { cancel_at_period_end: true })
}
```

## Rules

1. ALWAYS verify webhook signatures (prevent spoofed events)
2. Handle webhooks idempotently (same event may arrive multiple times)
3. Store subscription status in YOUR database (don't query Stripe on every request)
4. Use Checkout Sessions for payment UI (don't build custom forms)
5. Test with Stripe CLI: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
6. Handle ALL relevant webhook events (paid, failed, canceled, updated)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| No webhook signature verification | Spoofed payments | Always verify with constructEvent |
| Querying Stripe for subscription status | Slow, rate limits | Cache in your database, sync via webhooks |
| Custom payment form | PCI compliance burden | Stripe Checkout or Stripe Elements |
| Ignoring failed payments | Silent churn | Handle invoice.payment_failed, send dunning emails |
