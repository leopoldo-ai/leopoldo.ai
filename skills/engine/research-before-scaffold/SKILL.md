---
name: research-before-scaffold
description: Esegue ricerca web strutturata sulle best practice correnti PRIMA di scaffoldare un progetto. Analizza pattern Next.js aggiornati, versioni Drizzle ORM, componenti shadcn/ui, server MCP disponibili, e best practice di sicurezza. Produce un Research Brief che alimenta project-scaffolder. Usare PRIMA di project-scaffolder o task-decomposer per decisioni informate. Trigger su research stack, ricerca best practice, aggiornamento template.
---

# Research Before Scaffold — Ricerca Web Prima della Generazione

Meta-skill che esegue ricerca web strutturata per informare lo scaffolding di un progetto con best practice aggiornate.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| Template scaffolder statici che invecchiano | Ricerca live prima di generare |
| Pattern outdated nel codice generato | Verificare stato attuale di framework/librerie |
| Dipendenze con breaking changes non rilevate | Check versioni e changelog recenti |

## Quando invocarla

- **PRIMA di `project-scaffolder`** — obbligatorio per nuovi progetti
- **PRIMA di `task-decomposer`** — opzionale, per decisioni tecniche informate
- **Quando si aggiunge un nuovo modulo/integrazione** al progetto
- **Quando lo stack ha ricevuto aggiornamenti significativi** (major version bump)
- **Periodicamente** — ogni 2-3 mesi per verificare che i template siano aggiornati

## Workflow

### Fase 1: Analisi contesto

1. **Leggere il PRD** o le istruzioni dell'utente per identificare:
   - Tipo di progetto (web app, API, dashboard, etc.)
   - Stack tecnologico (da CLAUDE.md o da input utente)
   - Planned integrations (third-party APIs, services, etc.)
2. **Identificare aree di ricerca** — quali parti dello stack richiedono aggiornamento?
3. **Definire query** specifiche per ogni area

### Fase 2: Ricerca web per area

5 aree di ricerca, ciascuna con 1-2 web search:

| # | Area | Query suggerite |
|---|------|----------------|
| 1 | **Framework patterns** | "Next.js App Router best practices [anno]", "Next.js server actions patterns" |
| 2 | **ORM/Database** | "Drizzle ORM latest features [anno]", "Neon PostgreSQL serverless best practices" |
| 3 | **UI Library** | "shadcn/ui latest components [anno]", "Tremor React dashboard components" |
| 4 | **MCP/Tools** | "Claude MCP servers for [stack]", "developer tools for Next.js" |
| 5 | **Security** | "Next.js security best practices [anno]", "OWASP serverless applications" |

Per ogni area:
- Eseguire WebSearch con query specifica
- Se risultati promettenti, usare WebFetch per leggere la fonte
- Preferire documentazione ufficiale a blog post
- Annotare versioni correnti di ogni dipendenza

### Fase 3: Analisi risultati

Per ogni area, sintetizzare:

- **Cosa e' cambiato** rispetto al template attuale
- **Cosa e' nuovo** (nuove API, nuovi pattern, nuovi tool)
- **Cosa e' deprecato** (API rimosse, pattern sconsigliati)
- **Cosa aggiornare** nel template scaffolder

### Fase 4: Research Brief

Generare il documento strutturato:

```markdown
# Research Brief: [Progetto/Modulo]
**Data:** [YYYY-MM-DD]
**Stack:** [Lista tecnologie]
**Fonti consultate:** [N]

## 1. Framework Patterns

### Novita' rilevanti
- [Finding con link fonte]

### Cambiamenti da applicare allo scaffolder
- [Azione concreta]

## 2. ORM/Database
[Stessa struttura]

## 3. UI Library
[Stessa struttura]

## 4. MCP/Tools Disponibili
[Stessa struttura]

## 5. Security
[Stessa struttura]

## Raccomandazioni per Scaffolder

| # | Area | Azione | Priorita' |
|---|------|--------|-----------|
| 1 | [area] | [cosa modificare nel template] | Alta/Media/Bassa |
```

**Output path:** `docs/wip/research_brief_[topic]_[YYYYMMDD].md`

### Fase 5: Feed al consumer

1. **Salvare** il Research Brief in `docs/wip/`
2. **Comunicare** all'utente le raccomandazioni principali
3. **Passare** il brief come contesto a `project-scaffolder` o `task-decomposer`

## Regole

- **WebSearch obbligatorio** — non basarsi solo su conoscenza interna
- **Verificare le fonti** — preferire documentazione ufficiale (nextjs.org, orm.drizzle.team, ui.shadcn.com, neon.tech)
- **Brief conciso** — max 3-4 pagine, non information overload
- **Citare sempre le fonti** con URL
- **Graceful degradation** — se WebSearch non disponibile, procedere con conoscenza interna e segnalare esplicitamente: "Research basato su conoscenza interna — verificare manualmente le versioni"
- **Non bloccare** — se una sola area non produce risultati, procedere con le altre

## Anti-pattern

- **Ricerca generica** — "best practices web development" e' inutile. Essere specifici per stack
- **Brief di 20 pagine** — information overload, il consumer non lo leggera'
- **Saltare la ricerca** — "conosco gia' lo stack" non e' una giustificazione
- **Non aggiornare** — fare la ricerca e poi ignorare le raccomandazioni
- **Fonti non ufficiali** — preferire docs ufficiali a blog post obsoleti
- **Bloccare su un'area** — se la ricerca su MCP/Tools non produce risultati, andare avanti

## Vincoli tool

Richiede accesso a:
- **WebSearch** — per query di ricerca
- **WebFetch** — per leggere pagine di documentazione

Relevant domains for allowlist (settings.json):
`nextjs.org`, `vercel.com`, `neon.tech`, `orm.drizzle.team`, `ui.shadcn.com`, `www.tremor.so`, `github.com`, `docs.anthropic.com`

---

**Versione:** 1.0 (2026-03-01)
**Tipo:** Meta-skill invocabile
**Dipendenze:** WebSearch tool, WebFetch tool, project-scaffolder (consumer), task-decomposer (consumer opzionale)
