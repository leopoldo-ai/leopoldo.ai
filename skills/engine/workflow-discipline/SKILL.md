---
name: workflow-discipline
description: Use for every skill invocation as universal behavioral protocol. The 4 mandatory phases (Plan, Execute, Verify, Self-Improve) and fundamental principles. Not directly invokable; referenced by every skill as a behavioral contract declared in CLAUDE.md.
type: discipline
---

# Workflow Discipline — Contratto Comportamentale Universale

Protocollo che definisce il comportamento base di TUTTE le skill. Non si invoca — si applica automaticamente.

## Le 4 Fasi Obbligatorie

### 1. PLAN — Pianificare prima di agire

Per task non-triviali (multi-step, multi-file, decisioni architetturali):
- Identificare obiettivo e risultato atteso
- Valutare rischi, dipendenze, impatto
- Scegliere l'approccio piu' semplice
- 2 minuti di piano risparmiano 20 di rework

> Task triviali (typo, singola riga): procedere direttamente a EXECUTE.

### 2. EXECUTE — Eseguire con autonomia

- Procedere con confidenza dopo la pianificazione
- Non chiedere conferma ad ogni micro-step
- Se bloccato: considerare alternative o chiedere

### 3. VERIFY — Evidenza prima delle dichiarazioni

1. Eseguire comando di verifica (test, build, lint)
2. Leggere output completo
3. Confrontare con risultato atteso
4. Solo poi dichiarare il risultato

**Mai:** "dovrebbe funzionare", "probabilmente corretto", successo basato su assunzioni.

### 4. SELF-IMPROVE — Imparare dai fallimenti

Dopo correzione/fallimento: registrare cosa e perche' → identificare skill/regola mancante → documentare (skill-postmortem) → proporre modifica (skill-retrospective).

> Non nascondere i retry. Fallimenti documentati sono preziosi.

## Principi Fondamentali

| Principio | Significato |
|---|---|
| **Simplicity First** | Soluzione piu' semplice che funziona. Tre righe simili > astrazione prematura |
| **Root Cause Focus** | Causa, non sintomo. No workaround. Vedi `systematic-debugging` |
| **Minimal Footprint** | Minimo necessario. No refactoring "while I'm here" |
| **Demand Elegance** | Pulito, non solo funzionante. Eleganza = chiarezza, non complessita' |
| **Subagent Strategy** | Task paralleli → subagent. Task sequenziali → in serie |

## Applicazione per tipo

| Tipo | PLAN | VERIFY |
|---|---|---|
| Dev | File, pattern, impatto | `npm test`, `npm run build`, lint |
| Meta | Scope, iterazioni, soglie | Output completo, coverage |
| Strategy | Domanda, framework, audience | Cross-check dati, coerenza |
| Security | Scope audit, aree critiche | No false negative OWASP Top 10 |
| Reporting | Dati sessione/progetto | Dati accurati, nessun finding inventato |

## Anti-pattern

- Agire senza PLAN per task non-triviali
- Dichiarare senza VERIFY
- Ignorare correzioni senza documentare
- Complessita' non richiesta (helper per uso singolo)
- "While I'm here" refactoring
- Forzare stesso approccio invece di cambiare strategia
- Nascondere fallimenti con retry silenti

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "È un task piccolo, salto PLAN" | Triviale = typo/1 riga. Tutto il resto richiede PLAN |
| "Dovrebbe funzionare" | "Dovrebbe" = non hai VERIFICATO. Esegui il comando |
| "Il test passa nell'IDE" | Esegui il comando nel terminale, leggi exit code |
| "Fix ora, documento dopo" | SELF-IMPROVE al momento = SELF-IMPROVE mai |
| "L'utente ha già capito" | Documenta comunque. Altri agenti leggeranno il journal |
| "Solo stavolta skippo VERIFY" | "Solo stavolta" = sempre. Nessuna eccezione |
| "Aggiungo questo refactor mentre ci sono" | Minimal footprint. Apri un task separato |
