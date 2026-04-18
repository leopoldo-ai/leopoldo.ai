---
name: ai-integration
description: "Use when adding AI/LLM features to web apps. Covers Vercel AI SDK, Claude API, streaming chat, structured output, and multi-provider patterns. OSS-first: Vercel AI SDK (OSS) and Claude API primary. Triggers on: AI, LLM, chat, streaming, Vercel AI SDK, Claude API, useChat, generateText, generateObject, chatbot, completions."
type: technique
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

# AI Integration -- LLM Features in Web Apps

## Why This Exists

| Problem | Solution |
|---------|----------|
| AI/LLM integration is table stakes in 2026, zero coverage | Complete patterns for chat, completions, structured output |
| Developers build custom streaming from scratch | Vercel AI SDK handles streaming, hooks, and providers |
| Vendor lock-in to single AI provider | Multi-provider patterns with provider-agnostic code |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Alternative) |
|-------------------|----------------------|
| Vercel AI SDK (ai package) | LangChain.js |
| Claude API (@anthropic-ai/sdk) | OpenAI API |
| Zod (structured output) | JSON Schema |

## Core Workflow

### 1. Vercel AI SDK Setup

```bash
npm install ai @ai-sdk/anthropic @ai-sdk/openai zod
```

```typescript
// lib/ai.ts - Provider configuration
import { anthropic } from "@ai-sdk/anthropic"
import { openai } from "@ai-sdk/openai"

// Default to Claude, switchable
export const defaultModel = anthropic("claude-sonnet-4-20250514")
export const fallbackModel = openai("gpt-4o")
```

### 2. Streaming Chat (useChat)

```typescript
// app/api/chat/route.ts
import { streamText } from "ai"
import { defaultModel } from "@/lib/ai"

export async function POST(req: Request) {
  const { messages } = await req.json()

  const result = streamText({
    model: defaultModel,
    system: "You are a helpful assistant.",
    messages,
    maxTokens: 4096,
  })

  return result.toDataStreamResponse()
}
```

```typescript
// components/Chat.tsx
"use client"
import { useChat } from "ai/react"

export function Chat() {
  const { messages, input, handleInputChange, handleSubmit, isLoading } = useChat()

  return (
    <div>
      {messages.map((m) => (
        <div key={m.id} className={m.role === "user" ? "text-right" : "text-left"}>
          {m.content}
        </div>
      ))}
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} disabled={isLoading} />
      </form>
    </div>
  )
}
```

### 3. Structured Output (generateObject)

```typescript
import { generateObject } from "ai"
import { z } from "zod"
import { defaultModel } from "@/lib/ai"

const ProductSchema = z.object({
  name: z.string(),
  description: z.string(),
  price: z.number(),
  category: z.enum(["electronics", "clothing", "food"]),
  tags: z.array(z.string())
})

const { object } = await generateObject({
  model: defaultModel,
  schema: ProductSchema,
  prompt: "Generate a product listing for wireless headphones"
})
// object is fully typed as z.infer<typeof ProductSchema>
```

### 4. Streaming Completion (useCompletion)

```typescript
// For single-turn text generation (not chat)
import { useCompletion } from "ai/react"

function ContentGenerator() {
  const { completion, input, handleInputChange, handleSubmit } = useCompletion({
    api: "/api/complete"
  })

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <input value={input} onChange={handleInputChange} placeholder="Describe..." />
      </form>
      <div>{completion}</div>
    </div>
  )
}
```

### 5. Tool Calling

```typescript
import { streamText, tool } from "ai"
import { z } from "zod"

const result = streamText({
  model: defaultModel,
  messages,
  tools: {
    getWeather: tool({
      description: "Get weather for a location",
      parameters: z.object({ city: z.string() }),
      execute: async ({ city }) => {
        const weather = await fetchWeather(city)
        return weather
      }
    })
  }
})
```

### 6. Error Handling and Rate Limits

```typescript
import { streamText, APICallError } from "ai"

try {
  const result = await streamText({ model: defaultModel, messages })
} catch (error) {
  if (error instanceof APICallError) {
    if (error.statusCode === 429) {
      // Rate limited: implement exponential backoff
      await delay(Math.pow(2, retryCount) * 1000)
    }
    if (error.statusCode === 529) {
      // Overloaded: switch to fallback provider
      const result = await streamText({ model: fallbackModel, messages })
    }
  }
}
```

### 7. Message History Management

```typescript
// Truncate history to stay within token limits
function truncateMessages(messages: Message[], maxTokens: number = 100000) {
  // Keep system message + last N messages
  const system = messages.filter((m) => m.role === "system")
  const conversation = messages.filter((m) => m.role !== "system")

  // Rough estimation: 4 chars per token
  let tokenCount = 0
  const kept = []
  for (let i = conversation.length - 1; i >= 0; i--) {
    tokenCount += conversation[i].content.length / 4
    if (tokenCount > maxTokens) break
    kept.unshift(conversation[i])
  }

  return [...system, ...kept]
}
```

## Rules

1. Vercel AI SDK is the PRIMARY recommendation (OSS, multi-provider, hooks)
2. Claude is the DEFAULT provider. Document OpenAI as alternative.
3. API keys ALWAYS server-side (route handlers), NEVER in client code
4. ALWAYS use streaming for chat UIs (better UX, lower perceived latency)
5. ALWAYS implement error handling for rate limits and API failures
6. Use Zod schemas for structured output (type-safe, validated)
7. Truncate message history to stay within context window limits
8. Implement token counting for cost awareness

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| API keys in client-side code | Security vulnerability, key exposure | Server-side route handlers only |
| Non-streaming responses | Poor UX, long wait times | Always stream for chat |
| No error handling for AI APIs | App crashes on rate limits | Retry with backoff, fallback provider |
| Sending full history every request | Token waste, context overflow | Truncate to relevant window |
| Hardcoding single provider | Vendor lock-in, no fallback | Multi-provider with Vercel AI SDK |
| No token/cost tracking | Surprise bills | Count tokens, set budgets |
