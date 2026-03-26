---
name: queue-background-jobs
description: "Use when implementing background jobs, task queues, or scheduled tasks. Covers BullMQ, Redis queues, retry patterns, and job scheduling. OSS-first: BullMQ + Redis primary. Triggers on: queue, background job, BullMQ, Redis, worker, scheduled task, cron job, retry, job processing."
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

# Queue Background Jobs -- BullMQ and Redis

## Why This Exists

| Problem | Solution |
|---------|----------|
| Long-running tasks block HTTP responses | Background job processing with queues |
| No queue patterns in plugin | BullMQ + Redis patterns |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| BullMQ (OSS) | Inngest |
| Redis (OSS) | Trigger.dev |
| node-cron | AWS SQS |

## Core Workflow

### 1. Setup

```bash
npm install bullmq ioredis
```

```typescript
// lib/queue.ts
import { Queue, Worker } from "bullmq"
import IORedis from "ioredis"

const connection = new IORedis(process.env.REDIS_URL!, { maxRetriesPerRequest: null })

// Define queue
export const emailQueue = new Queue("emails", { connection })

// Add job
await emailQueue.add("welcome", { userId: "123", template: "welcome" }, {
  attempts: 3,
  backoff: { type: "exponential", delay: 1000 }
})

// Worker
const worker = new Worker("emails", async (job) => {
  const { userId, template } = job.data
  await sendEmail(userId, template)
}, { connection, concurrency: 5 })

worker.on("completed", (job) => console.log(`Job ${job.id} completed`))
worker.on("failed", (job, err) => console.error(`Job ${job?.id} failed:`, err))
```

### 2. Scheduled/Recurring Jobs

```typescript
// Cron-like scheduling
await emailQueue.add("weekly-digest", { type: "digest" }, {
  repeat: { pattern: "0 9 * * 1" } // Every Monday at 9am
})
```

## Rules

1. BullMQ for ALL background job needs (Node.js)
2. Redis as the queue backend (fast, reliable)
3. Always set retry with exponential backoff
4. Idempotent job handlers (same job may run twice)
5. Set concurrency limits on workers
6. Monitor failed jobs and alert

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Long tasks in API handlers | Timeout, blocks response | Queue the task, return immediately |
| No retry logic | Transient failures lose jobs | Exponential backoff with max attempts |
| Non-idempotent handlers | Duplicate processing on retry | Design handlers to be safe to re-run |
| No dead letter queue | Failed jobs disappear | Monitor and handle failed jobs |
