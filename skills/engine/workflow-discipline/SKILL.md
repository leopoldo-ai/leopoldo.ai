---
name: workflow-discipline
description: Protocollo comportamentale universale che si applica a TUTTE le skill del progetto. Definisce le 4 fasi obbligatorie (Plan, Execute, Verify, Self-Improve) e i principi fondamentali. NON e' una skill invocabile direttamente — e' un contratto comportamentale referenziato da ogni skill e dichiarato in CLAUDE.md.
---

# Workflow Discipline — Contratto Comportamentale Universale

Protocollo che definisce il comportamento base di TUTTE le skill del sistema.
**Non si invoca** — si applica automaticamente ad ogni attivita'.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| Skill che agiscono senza pianificare | Fase PLAN obbligatoria |
| Fix dichiarati senza verifica | Fase VERIFY con evidenza |
| Stessi errori ripetuti tra sessioni | Fase SELF-IMPROVE con documentazione |
| Complessita' non richiesta | Principi fondamentali |

## Le 4 Fasi Obbligatorie

### 1. PLAN — Pianificare prima di agire

Per task non-triviali (multi-step, multi-file, decisioni architetturali):

- **Identificare** l'obiettivo e il risultato atteso
- **Valutare** rischi, dipendenze, impatto su altri moduli
- **Scegliere** l'approccio piu' semplice che soddisfa il requisito
- **Non saltare** per "fretta" — 2 minuti di piano risparmiano 20 di rework

> Per task triviali (typo, singola riga, rename): procedere direttamente a EXECUTE.

### 2. EXECUTE — Eseguire con autonomia

- Procedere con confidenza dopo la pianificazione
- Non chiedere conferma ad ogni micro-step — l'utente ha approvato l'approccio
- Usare le skill appropriate (referenziate da `skill-router` o da CLAUDE.md)
- Se bloccato: non forzare. Considerare alternative o chiedere all'utente

### 3. VERIFY — Evidenza prima delle dichiarazioni

Prima di dichiarare qualsiasi risultato:

1. **Eseguire** il comando di verifica (test, build, lint)
2. **Leggere** l'output completo
3. **Confrontare** output con risultato atteso
4. **Solo poi** dichiarare il risultato

> Per la meccanica dettagliata di verifica, vedi `verification-gate`.

**Mai:**
- "Dovrebbe funzionare" senza aver eseguito
- "Probabilmente e' corretto" senza evidenza
- Dichiarare successo basandosi su assunzioni

### 4. SELF-IMPROVE — Imparare dai fallimenti

Dopo ogni correzione dall'utente o fallimento significativo:

1. **Registrare** cosa e' andato storto e perche'
2. **Identificare** quale skill o regola avrebbe dovuto prevenirlo
3. **Documentare** la lezione (tramite `skill-postmortem` per singoli fallimenti)
4. **Proporre** modifica alla skill (tramite `skill-retrospective` a fine sessione)

> Non nascondere i retry. I fallimenti documentati sono preziosi — quelli nascosti si ripetono.

## Principi Fondamentali

### Simplicity First
La soluzione piu' semplice che funziona e' la migliore. Non aggiungere complessita' "per sicurezza", "per il futuro", o "per completezza". Tre righe simili sono meglio di un'astrazione prematura.

### Root Cause Focus
Risolvere la causa, non il sintomo. Non applicare workaround che mascherano il problema. Per la metodologia: vedi `systematic-debugging`.

### Minimal Footprint
Cambiare il minimo necessario. Non toccare file non correlati. Non fare refactoring "while I'm here". Non aggiungere docstring a codice non modificato.

### Demand Elegance
Il codice deve essere pulito, non solo funzionante. Ma eleganza non e' complessita' — e' chiarezza, leggibilita', coerenza con i pattern del progetto.

### Subagent Strategy
Per task paralleli e indipendenti, delegare a subagent. Per task sequenziali con dipendenze, eseguire in serie. Non duplicare lavoro tra agente principale e subagent.

## Applicazione per tipo di skill

| Tipo skill | PLAN | EXECUTE | VERIFY | SELF-IMPROVE |
|-----------|------|---------|--------|-------------|
| **Dev** (nextjs, postgres, api) | Identificare file, pattern, impatto | Scrivere codice, test | `npm test`, `npm run build`, `npm run lint` | LESSONS_LEARNED se test falliscono |
| **Meta** (board, closure-loop, task-decomposer) | Definire scope, iterazioni, soglie | Orchestrare skill, raccogliere output | Verificare output completo, coverage | Friction detection via retrospective |
| **Strategy** (advisor, product-manager) | Chiarire domanda, framework, audience | Analizzare, produrre raccomandazioni | Cross-check con dati, coerenza interna | Feedback utente su utilita' output |
| **Security** (semgrep, audit, guardian) | Scope dell'audit, aree critiche | Eseguire scan, analizzare finding | Nessun false negative su OWASP Top 10 | Aggiornare regole se nuova vulnerabilita' |
| **Reporting** (session, xlsx, docx) | Raccogliere dati sessione/progetto | Formattare report professionale | Dati accurati, nessun finding inventato | Template migliorati se formato inadeguato |

## Anti-pattern

- **Agire senza PLAN** per task non-triviali — "faccio prima cosi'"
- **Dichiarare senza VERIFY** — "dovrebbe essere a posto"
- **Ignorare le correzioni** — non documentare, non proporre fix alla skill
- **Complessita' non richiesta** — helper, utility, astrazione per uso singolo
- **"While I'm here"** — refactoring, docstring, type annotation su codice non toccato
- **Forzare soluzioni** — retry dello stesso approccio invece di cambiare strategia
- **Nascondere fallimenti** — retry silenti senza documentare cosa e' andato storto

---

**Versione:** 1.0 (2026-03-01)
**Tipo:** Protocollo comportamentale universale (non invocabile)
**Referenzia:** verification-gate (VERIFY), systematic-debugging (Root Cause), skill-retrospective + skill-postmortem (SELF-IMPROVE)
