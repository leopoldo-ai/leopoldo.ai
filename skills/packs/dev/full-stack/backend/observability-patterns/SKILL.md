---
name: observability-patterns
description: "Use when adding monitoring, logging, tracing, or error tracking to applications. Covers OpenTelemetry, structured logging, distributed tracing, and alerting. OSS-first: OpenTelemetry primary, Sentry/Datadog as aware-of. Triggers on: observability, monitoring, logging, tracing, OpenTelemetry, OTEL, Sentry, metrics, alerts, error tracking, APM."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/getsentry/sentry-for-ai
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/getsentry/sentry-for-ai
license: MIT
upstream:
  url: https://github.com/getsentry/sentry-for-ai
  version: main
  last_checked: 2026-03-24
---

# Observability Patterns -- Monitoring, Logging, and Tracing

## Why This Exists

| Problem | Solution |
|---------|----------|
| No observability guidance in plugin, teams fly blind in prod | Complete monitoring stack patterns |
| Vendor lock-in with Datadog/New Relic | OSS-first with OpenTelemetry |

Adapted from [getsentry/sentry-for-ai](https://github.com/getsentry/sentry-for-ai).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| OpenTelemetry (OTEL) | Datadog |
| Grafana + Loki + Tempo | New Relic |
| Sentry (free tier generous) | PagerDuty |
| Prometheus (metrics) | CloudWatch |

## Three Pillars

| Pillar | What | Tool |
|--------|------|------|
| **Logs** | Event records | Structured logging -> Loki/Elasticsearch |
| **Metrics** | Numeric measurements | Prometheus/OTEL Metrics -> Grafana |
| **Traces** | Request flow across services | OTEL Traces -> Tempo/Jaeger |

## Core Workflow

### 1. OpenTelemetry Setup (Next.js)

```typescript
// instrumentation.ts (Next.js instrumentation hook)
import { NodeSDK } from "@opentelemetry/sdk-node"
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node"
import { OTLPTraceExporter } from "@opentelemetry/exporter-trace-otlp-http"
import { OTLPMetricExporter } from "@opentelemetry/exporter-metrics-otlp-http"
import { PeriodicExportingMetricReader } from "@opentelemetry/sdk-metrics"

export function register() {
  const sdk = new NodeSDK({
    serviceName: "my-app",
    traceExporter: new OTLPTraceExporter({ url: process.env.OTEL_EXPORTER_OTLP_ENDPOINT }),
    metricReader: new PeriodicExportingMetricReader({
      exporter: new OTLPMetricExporter()
    }),
    instrumentations: [getNodeAutoInstrumentations()]
  })
  sdk.start()
}
```

### 2. Structured Logging

```typescript
// lib/logger.ts
import pino from "pino"

export const logger = pino({
  level: process.env.LOG_LEVEL || "info",
  formatters: {
    level: (label) => ({ level: label })
  },
  // Add request context
  mixin: () => ({
    service: "my-app",
    environment: process.env.NODE_ENV
  })
})

// Usage
logger.info({ userId: user.id, action: "login" }, "User logged in")
logger.error({ err, requestId }, "Payment processing failed")
// NEVER: logger.info("User " + userId + " logged in") // unstructured
```

### 3. Sentry Error Tracking

```typescript
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs"

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 0.1,    // 10% of transactions
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0  // 100% on errors
})

// Manual error capture
try {
  await processPayment(order)
} catch (error) {
  Sentry.captureException(error, {
    tags: { feature: "payments" },
    extra: { orderId: order.id }
  })
  throw error
}
```

### 4. Custom Metrics

```typescript
import { metrics } from "@opentelemetry/api"

const meter = metrics.getMeter("my-app")
const requestCounter = meter.createCounter("http_requests_total")
const responseTime = meter.createHistogram("http_response_time_ms")

// In middleware
const start = Date.now()
// ... handle request
requestCounter.add(1, { method: "GET", path: "/api/users", status: 200 })
responseTime.record(Date.now() - start, { path: "/api/users" })
```

### 5. Health Check Endpoint

```typescript
// app/api/health/route.ts
export async function GET() {
  const checks = {
    database: await checkDatabase(),
    redis: await checkRedis(),
    external_api: await checkExternalAPI()
  }

  const healthy = Object.values(checks).every((c) => c.status === "ok")

  return Response.json(
    { status: healthy ? "healthy" : "degraded", checks, timestamp: new Date().toISOString() },
    { status: healthy ? 200 : 503 }
  )
}
```

## Rules

1. OpenTelemetry for ALL new projects (vendor-neutral, portable)
2. Structured logging ALWAYS (JSON, not string concatenation)
3. Use pino for Node.js logging (fastest, structured by default)
4. Sentry for error tracking (generous free tier, great DX)
5. Health check endpoint on every service (/api/health)
6. Sample traces in production (10% default, 100% on errors)
7. Never log sensitive data (passwords, tokens, PII)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| console.log in production | Unstructured, no levels, no context | pino structured logger |
| No error tracking | Bugs discovered by users | Sentry or equivalent |
| Logging PII/secrets | Security/compliance violation | Scrub sensitive data |
| 100% trace sampling | Expensive, storage overload | 10% default, 100% on errors |
| No health checks | Can't detect service degradation | /api/health on every service |
