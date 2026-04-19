# Spec Card: ai-integration

## Identity
- **Pack:** full-stack
- **Sub-pack:** frontend
- **Layer:** userland

## Scope
Integrating AI/LLM capabilities into web applications. Covers streaming chat UIs, AI SDK usage, prompt engineering in apps, and structured output. OSS-first: Vercel AI SDK (OSS) and direct Claude/OpenAI API as primary. No vendor lock-in patterns.

Does NOT cover: RAG systems (covered by rag-architect), AI agent building (different domain), or ML model training.

## Expected Inputs
- User wants to add AI chat, completions, or structured generation to an app
- User mentions Vercel AI SDK, Claude API, OpenAI API, streaming
- User building chatbots, AI assistants, content generation features

## Expected Outputs
- AI SDK setup and streaming UI implementation
- Chat interface patterns with message history
- Structured output with Zod schemas
- Multi-provider support (switch between Claude/OpenAI)
- Cost optimization patterns (caching, token counting)

## Must-Have Features
1. Vercel AI SDK setup (ai package) with Next.js App Router
2. Streaming chat UI with useChat hook
3. Streaming completion with useCompletion hook
4. Claude API direct integration (Anthropic SDK)
5. Structured output with generateObject + Zod schema
6. Multi-provider switching (Claude, OpenAI, local models)
7. Message history management and persistence
8. Error handling and rate limit retry patterns

## Nice-to-Have Features
1. Tool calling / function calling patterns
2. Image input (vision) patterns
3. Token counting and cost estimation
4. Prompt template management
5. OpenAI SDK patterns (premium alternative awareness)

## Anti-Patterns
- Hardcoding API keys in client-side code
- Not streaming (blocking until full response)
- Sending entire conversation history without truncation
- No error handling for rate limits or API failures

## Integration Points
- `nextjs-developer`: Route handlers, server actions for AI endpoints
- `auth-patterns`: Protecting AI endpoints with auth
- `rag-architect`: RAG + AI SDK combination
- `state-management`: Managing chat state

## Success Criteria
- Streaming chat works in Next.js with under 50ms time-to-first-token display
- Can switch between Claude and OpenAI with config change only
- Structured output validates against Zod schema
- Error handling covers: rate limits, network errors, invalid responses

## Key Rules
- Vercel AI SDK is the primary recommendation (OSS, multi-provider)
- Claude API is the recommended default provider
- API keys NEVER in client-side code, always server-side route handlers
- Always use streaming for chat (better UX)
- Always implement token counting for cost awareness
