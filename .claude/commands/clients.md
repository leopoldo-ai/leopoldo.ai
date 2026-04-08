# Clients

Manage the client registry and CRM data in Neon Postgres.

## Operations

1. **List clients**: Query clients table with key fields
2. **Client detail**: Full profile with memory, conversation history, and purchases
3. **Client jobs**: Show scheduled jobs for a specific client
4. **Purchase history**: Purchases and downloads per client
5. **Activity summary**: Recent conversation_history entries

## Rules

- Use postgres MCP server when available
- Respect privacy: never expose OAuth tokens or credentials
- Summarize in structured table format
