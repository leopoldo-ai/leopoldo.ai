# Database

Query and manage the Neon Postgres database via MCP server or psql.

## Available operations

1. **Schema overview**: List all tables with row counts
2. **Client lookup**: Query client registry
3. **Purchase history**: Check pack_purchases and download_log
4. **Metrics**: Query page_views and metrics tables
5. **Scout findings**: Check scout_sources and scout_findings for intelligence data
6. **Jobs**: List scheduled client_jobs and their status

## Rules

- Use the postgres MCP server when available
- Fall back to psql with the Neon connection string
- Never expose raw connection strings in output
- Summarize results in table format
