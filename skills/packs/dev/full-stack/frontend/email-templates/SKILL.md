---
name: email-templates
description: "Use when building transactional emails with React Email and sending via Resend or Nodemailer. Covers email template design, responsive layouts, and delivery. OSS-first: React Email + Nodemailer primary, Resend as simple alternative. Triggers on: email template, React Email, Resend, Nodemailer, transactional email, email design."
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

# Email Templates -- Transactional Emails with React

## Why This Exists

| Problem | Solution |
|---------|----------|
| Email HTML is stuck in 1999 (tables, inline styles) | React Email: build emails with React components |
| No email guidance in plugin, every app sends emails | Complete patterns for templates and delivery |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| React Email (templates) | MJML |
| Nodemailer (sending) | SendGrid |
| Resend (simple API, generous free tier) | Mailgun, Postmark |

## Core Workflow

### 1. React Email Setup

```bash
npm install @react-email/components react-email
npm install resend # or nodemailer
```

### 2. Email Template

```typescript
// emails/welcome.tsx
import { Html, Head, Body, Container, Section, Text, Button, Img, Hr } from "@react-email/components"

interface WelcomeEmailProps {
  name: string
  actionUrl: string
}

export default function WelcomeEmail({ name, actionUrl }: WelcomeEmailProps) {
  return (
    <Html>
      <Head />
      <Body style={{ fontFamily: "Inter, sans-serif", backgroundColor: "#f4f4f5" }}>
        <Container style={{ maxWidth: "600px", margin: "0 auto", padding: "20px" }}>
          <Img src="https://mysite.com/logo.png" width={120} height={40} alt="Logo" />
          <Section style={{ backgroundColor: "#ffffff", borderRadius: "8px", padding: "32px" }}>
            <Text style={{ fontSize: "24px", fontWeight: "bold" }}>Welcome, {name}!</Text>
            <Text style={{ color: "#6b7280" }}>
              Thanks for signing up. Get started by setting up your profile.
            </Text>
            <Button href={actionUrl} style={{
              backgroundColor: "#3A6B55", color: "#ffffff", padding: "12px 24px",
              borderRadius: "6px", textDecoration: "none", display: "inline-block"
            }}>
              Get Started
            </Button>
          </Section>
          <Hr style={{ borderColor: "#e5e7eb", margin: "24px 0" }} />
          <Text style={{ color: "#9ca3af", fontSize: "12px", textAlign: "center" as const }}>
            You received this because you signed up at mysite.com
          </Text>
        </Container>
      </Body>
    </Html>
  )
}
```

### 3. Sending with Resend

```typescript
import { Resend } from "resend"
import WelcomeEmail from "@/emails/welcome"

const resend = new Resend(process.env.RESEND_API_KEY)

await resend.emails.send({
  from: "onboarding@mysite.com",
  to: user.email,
  subject: "Welcome to MySite",
  react: WelcomeEmail({ name: user.name, actionUrl: "https://mysite.com/onboard" })
})
```

### 4. Sending with Nodemailer (OSS, self-hosted)

```typescript
import nodemailer from "nodemailer"
import { render } from "@react-email/render"
import WelcomeEmail from "@/emails/welcome"

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: 587,
  auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS }
})

const html = await render(WelcomeEmail({ name: user.name, actionUrl: "..." }))

await transporter.sendMail({
  from: "noreply@mysite.com",
  to: user.email,
  subject: "Welcome to MySite",
  html
})
```

### 5. Preview and Development

```bash
npx react-email dev # Opens browser preview at localhost:3030
```

## Rules

1. React Email for ALL email templates (component-based, type-safe)
2. Nodemailer for self-hosted SMTP, Resend for simplest setup
3. Inline styles only (email clients strip CSS classes)
4. Max width 600px for email container
5. Always include plain text fallback
6. Test in multiple clients (Gmail, Outlook, Apple Mail)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| HTML string templates | Unmaintainable, no type safety | React Email components |
| CSS classes in emails | Stripped by most email clients | Inline styles only |
| Images without alt text | Broken when images disabled | Always add descriptive alt |
| No unsubscribe link | Legal requirement (CAN-SPAM, GDPR) | Include in every marketing email |
