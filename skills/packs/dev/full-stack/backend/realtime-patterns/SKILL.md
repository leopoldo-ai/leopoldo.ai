---
name: realtime-patterns
description: "Use when building real-time features: WebSocket, Server-Sent Events, or Supabase Realtime. Covers chat, notifications, live updates, and presence. OSS-first: Socket.io and SSE primary. Triggers on: real-time, realtime, WebSocket, Socket.io, SSE, server-sent events, push, live updates, chat, notifications, presence."
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

# Realtime Patterns -- WebSocket, SSE, and Live Updates

## Why This Exists

| Problem | Solution |
|---------|----------|
| Real-time features (chat, notifications) need guidance | WebSocket and SSE patterns |
| Choosing between WebSocket and SSE is confusing | Decision framework based on use case |

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Socket.io (bidirectional) | Pusher |
| Server-Sent Events (unidirectional) | Ably |
| Supabase Realtime | Firebase Realtime |

## Decision Framework

```
Need bidirectional communication (chat, collaboration)?
  -> WebSocket / Socket.io

Need server-to-client push only (notifications, feeds)?
  -> Server-Sent Events (SSE) -- simpler, HTTP-based

Already using Supabase?
  -> Supabase Realtime (built-in, database-triggered)
```

## Core Workflow

### 1. Server-Sent Events (Simplest)

```typescript
// app/api/events/route.ts
export async function GET() {
  const encoder = new TextEncoder()
  const stream = new ReadableStream({
    start(controller) {
      const interval = setInterval(() => {
        const data = JSON.stringify({ time: new Date().toISOString(), type: "heartbeat" })
        controller.enqueue(encoder.encode(`data: ${data}\n\n`))
      }, 5000)

      // Clean up on close
      return () => clearInterval(interval)
    }
  })

  return new Response(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive"
    }
  })
}

// Client
const eventSource = new EventSource("/api/events")
eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data)
  console.log("Received:", data)
}
// Cleanup: eventSource.close()
```

### 2. Socket.io (Bidirectional)

```typescript
// server.ts
import { Server } from "socket.io"

const io = new Server(3001, { cors: { origin: "http://localhost:3000" } })

io.on("connection", (socket) => {
  console.log("Connected:", socket.id)

  socket.on("chat:message", (msg) => {
    io.emit("chat:message", { ...msg, id: crypto.randomUUID(), timestamp: Date.now() })
  })

  socket.on("room:join", (room) => { socket.join(room) })

  socket.on("disconnect", () => { console.log("Disconnected:", socket.id) })
})
```

```typescript
// Client hook
"use client"
import { io, Socket } from "socket.io-client"
import { useEffect, useRef, useState } from "react"

export function useSocket(url: string) {
  const socketRef = useRef<Socket>()
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    socketRef.current = io(url)
    socketRef.current.on("connect", () => setIsConnected(true))
    socketRef.current.on("disconnect", () => setIsConnected(false))
    return () => { socketRef.current?.disconnect() }
  }, [url])

  return { socket: socketRef.current, isConnected }
}
```

## Rules

1. SSE for server-to-client push (simpler, HTTP-based, auto-reconnect)
2. WebSocket/Socket.io for bidirectional (chat, collaboration)
3. Always implement reconnection with exponential backoff
4. Always clean up connections on component unmount
5. Use rooms/channels for targeted messaging (not broadcast)
6. Heartbeat every 30s to detect dead connections

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| WebSocket for notifications | Over-engineered | SSE (simpler, auto-reconnect) |
| No reconnection logic | Connection drops silently | Exponential backoff reconnection |
| Polling instead of push | Wasteful, high latency | SSE or WebSocket |
| No cleanup on unmount | Memory leaks, zombie connections | Close in useEffect cleanup |
