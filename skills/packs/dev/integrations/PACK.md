---
name: integrations
version: 1.0.0
description: "Integrations: 3 connector skills for external APIs and MCP servers. CRM, meeting intelligence, and recruiting."
author: leopoldo
license: MIT
skillos_min_version: "0.3.0"
skills:
  - amplemarket-api
  - granola-mcp
  - manatal-api
dependencies:
  packs: ["essentials"]
tags: ["integrations", "api", "mcp", "crm", "recruiting", "meetings"]
---

# Integrations -- Connector Pack

Integration connectors for external APIs and MCP servers. Each skill provides structured access to a third-party service, handling authentication, data mapping, and error handling.

## Target

- Teams using external SaaS tools alongside Claude
- Sales and recruiting workflows
- Meeting intelligence pipelines

## Skills

| Skill | Scope |
|-------|-------|
| `amplemarket-api` | Amplemarket API connector for sales intelligence and outreach automation |
| `granola-mcp` | Granola MCP server connector for meeting transcripts and intelligence |
| `manatal-api` | Manatal API connector for recruiting pipeline and candidate management |
