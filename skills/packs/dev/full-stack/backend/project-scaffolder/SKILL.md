---
name: project-scaffolder
version: 0.2.0
description: Initializes a complete Next.js 14+ project with App Router, Drizzle ORM, Neon PostgreSQL, shadcn/ui, Tremor, Tailwind CSS, TypeScript strict, and Zod. Use when starting a new project or bootstrapping a feature module. Triggers on scaffold, init project, setup, boilerplate, create project.
---

# Project Scaffolder — Next.js Full Stack

Initializes a complete Next.js 14+ project with a production-ready stack.

**Stack:** Next.js 14+ App Router, TypeScript strict, Tailwind CSS, shadcn/ui, Tremor, Drizzle ORM, Neon PostgreSQL, Zod, Vercel

## Quando usare

- Initial project setup
- Creating a new module/feature with the standard structure
- Verifying that the project configuration is correct

**Prerequisito consigliato:** Invocare `research-before-scaffold` PRIMA di questa skill per avere best practice aggiornate. Il Research Brief viene usato per personalizzare template e dipendenze.

## Workflow

### Fase 0: Research Brief (opzionale)

Se disponibile un Research Brief da `research-before-scaffold`:
1. Leggere `docs/wip/research_brief_*.md` piu' recente
2. Applicare le raccomandazioni della sezione "Azioni per Scaffolder"
3. Aggiornare versioni dipendenze se necessario
4. Aggiornare pattern di codice se consigliato

Se non disponibile, procedere con i template standard.

### Fase 1: Init progetto

```bash
# 1. Create Next.js project
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"

# 2. Install core dependencies
cd my-app
npm install drizzle-orm @neondatabase/serverless zod
npm install -D drizzle-kit @types/node

# 3. Install UI dependencies
npx shadcn@latest init
npm install @tremor/react

# 4. Install dev dependencies
npm install -D prettier eslint-config-prettier
```

### Fase 2: Struttura cartelle

```
my-app/
├── src/
│   ├── app/
│   │   ├── layout.tsx              # Root layout con font + metadata
│   │   ├── page.tsx                # Dashboard home
│   │   ├── globals.css             # Tailwind + shadcn theme
│   │   ├── api/
│   │   │   ├── cron/               # Scheduled jobs
│   │   │   ├── webhooks/           # Webhook handlers
│   │   │   └── health/route.ts
│   │   ├── dashboard/
│   │   │   ├── layout.tsx          # Dashboard layout con sidebar
│   │   │   ├── page.tsx            # Overview KPI
│   │   │   ├── contacts/page.tsx
│   │   │   ├── campaigns/page.tsx
│   │   │   ├── organizations/page.tsx
│   │   │   └── sync/page.tsx
│   │   └── (auth)/
│   │       └── login/page.tsx
│   ├── components/
│   │   ├── ui/                     # shadcn/ui components
│   │   ├── dashboard/              # Dashboard-specific components
│   │   └── shared/                 # Shared components
│   ├── lib/
│   │   ├── db/
│   │   │   ├── index.ts            # Drizzle client + Neon connection
│   │   │   ├── schema.ts           # All table definitions
│   │   │   └── migrations/         # Drizzle migrations
│   │   ├── api/                     # External API clients
│   │   ├── validations/            # Zod schemas
│   │   │   ├── contact.ts
│   │   │   ├── campaign.ts
│   │   │   └── organization.ts
│   │   └── utils/
│   │       ├── constants.ts
│   │       └── helpers.ts
│   ├── types/
│   │   └── index.ts                # Shared TypeScript types
│   └── middleware.ts               # Auth + rate limiting
├── drizzle.config.ts               # Drizzle Kit config
├── next.config.ts                  # Next.js config
├── tailwind.config.ts              # Tailwind + Tremor config
├── tsconfig.json                   # TypeScript strict
├── .env.local                      # Local env vars (gitignored)
├── .env.example                    # Template env vars
└── vercel.json                     # Vercel cron config
```

### Fase 3: File di configurazione chiave

#### drizzle.config.ts
```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/lib/db/schema.ts',
  out: './src/lib/db/migrations',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

#### .env.example
```
# Database
DATABASE_URL=postgresql://user:pass@ep-xxx.region.aws.neon.tech/mydb?sslmode=require

# Cron
CRON_SECRET=

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

#### vercel.json
```json
{
  "crons": [
    {
      "path": "/api/cron/sync",
      "schedule": "0 */4 * * *"
    }
  ]
}
```

### Fase 4: Verifiche post-scaffold

Checklist di verifica (ogni punto deve passare):

- [ ] `npm run dev` avvia senza errori
- [ ] `npm run build` completa senza errori
- [ ] `npm run lint` passa senza warning
- [ ] TypeScript strict mode attivo (nessun `any` implicito)
- [ ] shadcn/ui inizializzato (cartella `components/ui/`)
- [ ] Drizzle config punta al database corretto
- [ ] `.env.example` contiene tutte le variabili necessarie
- [ ] `.gitignore` include `.env.local`
- [ ] Struttura cartelle corretta

## Regole

- **TypeScript strict**: `"strict": true` in tsconfig.json, mai `any` esplicito
- **App Router only**: nessun file in `pages/`, tutto in `app/`
- **Server Components default**: `"use client"` solo dove serve interattivita'
- **Zod per validazione**: ogni input esterno (API, form, webhook) validato con Zod
- **Env vars tipizzate**: usare `z.object()` per validare env vars all'avvio
- **No secrets in code**: tutto in `.env.local`, mai hardcoded

## Anti-pattern

- Usare Pages Router
- `any` o `as any` nel codice
- Import circolari tra moduli
- Componenti client senza motivo
- Fetch in componenti client quando server component basta
- `.env.local` committato nel repo

---

**Versione:** 1.1 (aggiornato 2026-03-01: integrazione research-before-scaffold)
**Dipendenze:** Bash tool (npm/npx), Write tool (config files), research-before-scaffold (opzionale, consigliato)
