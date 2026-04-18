---
name: research-before-scaffold
description: Use BEFORE project-scaffolder or task-decomposer when informed decisions are needed, or when the user says "research stack", "ricerca best practice", "aggiornamento template". Structured web research on current Next.js patterns, Drizzle ORM versions, shadcn/ui components, available MCP servers, and security best practices. Produces a Research Brief feeding project-scaffolder.
type: discipline
---

# Research Before Scaffold — Ricerca Web Prima della Generazione

Ricerca web strutturata per informare lo scaffolding con best practice aggiornate.

## Quando invocarla

- **PRIMA di `project-scaffolder`** — obbligatorio per nuovi progetti
- **PRIMA di `task-decomposer`** — opzionale, per decisioni tecniche
- **Nuovo modulo/integrazione** al progetto
- **Major version bump** dello stack
- **Periodicamente** — ogni 2-3 mesi per aggiornamento template

## Workflow

### 1. Analisi contesto

Leggere PRD/input utente → tipo progetto, stack, integrazioni pianificate → definire aree e query di ricerca.

### 2. Ricerca per area (5 aree, 1-2 web search ciascuna)

| Area | Query esempio |
|---|---|
| Framework patterns | "Next.js App Router best practices [anno]" |
| ORM/Database | "Drizzle ORM latest features [anno]" |
| UI Library | "shadcn/ui latest components [anno]" |
| MCP/Tools | "Claude MCP servers for [stack]" |
| Security | "Next.js security best practices [anno]" |

Per ogni area: WebSearch → se promettente WebFetch → preferire docs ufficiali → annotare versioni correnti.

### 3. Analisi risultati

Per area: cosa cambiato, cosa nuovo, cosa deprecato, cosa aggiornare nel template.

### 4. Research Brief

Output: `docs/wip/research_brief_[topic]_[YYYYMMDD].md`. Per area: novita' rilevanti (con link fonte), cambiamenti da applicare. Tabella raccomandazioni per scaffolder con priorita'.

### 5. Feed al consumer

Salvare brief → comunicare raccomandazioni → passare come contesto a project-scaffolder/task-decomposer.

## Rules

- **WebSearch obbligatorio** — non basarsi solo su conoscenza interna
- **Verificare fonti** — preferire docs ufficiali (nextjs.org, orm.drizzle.team, ui.shadcn.com)
- **Brief conciso** — max 3-4 pagine
- **Citare URL** sempre
- **Graceful degradation** — se WebSearch non disponibile, procedere con conoscenza interna e segnalare
- **Non bloccare** — area senza risultati → andare avanti

## Anti-pattern

- Ricerca generica ("best practices web development")
- Brief di 20 pagine
- "Conosco gia' lo stack" come giustificazione per saltare
- Fonti non ufficiali (blog obsoleti)
- Bloccarsi su un'area senza risultati

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "Conosco già lo stack" | Conoscenza interna ≠ versioni correnti. WebSearch obbligatorio |
| "Non è cambiato niente" | Verifica, non assumere. 3 mesi = possibili breaking changes |
| "Il brief è un formality" | Il brief guida project-scaffolder. No brief = decisioni sbagliate |
| "Salto perché fretta" | 5 minuti di ricerca risparmiano ore di rework post-scaffold |
| "Una query basta" | 5 aree, 1-2 query ciascuna. Niente scorciatoie |
| "Uso blog e stackoverflow" | Docs ufficiali. Blog possono essere obsoleti |
