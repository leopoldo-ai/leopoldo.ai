---
name: skill-postmortem
description: Use when significant test failures, build breaks, wrong output, or user corrections require a per-skill post-mortem. Auto-documents significant skill failures with root cause analysis, proposes patches to the involved skill, updates LESSONS_LEARNED.md in its directory. Complements skill-retrospective (session-wide) with per-skill analysis.
type: discipline
---

# Skill Post-Mortem — Analisi e Documentazione dei Fallimenti

Documenta fallimenti in modo strutturato, identifica root cause, propone patch.

**postmortem** = singolo fallimento, root cause, LESSONS_LEARNED.md.
**skill-retrospective** = sessione intera, pattern friction, patch multiple skill.

## Quando invocarla

- Test failure significativo (pattern, non singolo unit test)
- Build break causato da una skill
- Output errato che richiede correzione manuale
- L'utente corregge ("sbagliato", "rifai", "non funziona")
- systematic-debugging risolve issue causato da skill
- Stesso errore per la seconda volta

## Workflow

### 1. Detect

- **Tipo:** test-failure | build-break | wrong-output | user-correction
- **Severity:** Critical (perdita lavoro/security) | High (output completamente errato) | Medium (parzialmente errato)
- **Skill coinvolta** e **fase workflow**

### 2. Analyze — Root Cause

1. Cosa e' successo (fattuale)
2. Cosa ci si aspettava
3. Perche': regola mancante? Template outdated? Documentazione errata? Conflitto tra skill? Input imprevisto?
4. Quale step della skill ha fallito

### 3. Document — LESSONS_LEARNED.md

Creare/aggiornare `skills/[nome-skill]/LESSONS_LEARNED.md`:

Formato entry: data, titolo, tipo, severity, fase, cosa e' successo, root cause, fix applicato, patch proposto (diff + status: Proposto/Applicato/Rifiutato), lezione ("SEMPRE [X]" o "MAI [Y]").

### 4. Patch (per Critical/High)

1. Generare diff concreto per SKILL.md
2. Classificare: `add_rule`, `add_antipattern`, `modify_rule`, `add_step`, `update_reference`
3. Presentare con diff, impatto, rischio
4. **Applicare solo dopo approvazione utente**

### 5. Link

1. skill-changelog: registrare evento
2. skill-retrospective: postmortem usato come input alla prossima retrospective
3. MEMORY.md: aggiornare se rivela convenzione di progetto

## Rules

- **Mai LESSONS_LEARNED senza root cause** — no speculazioni
- **Un fallimento per entry** — non accumulare
- **Append-only** — non sovrascrivere entry
- **Approvazione utente** prima di patch
- **Soglia 3+ ripetizioni** → skill ha problema strutturale, proporre riscrittura
- **Non documentare fallimenti banali** (typo, dimenticanza una tantum)

## Anti-pattern

- Postmortem senza root cause
- Documentare ogni micro-errore
- Patchare senza approvazione
- Non linkare a skill-changelog
- Analisi superficiale ("non copriva il caso" senza identificare QUALE step)
- Colpa all'utente (input ambiguo → skill doveva chiedere chiarimenti)

## Rationalizations — STOP

| Excuse | Reality |
|---|---|
| "L'ho già capito, scrivo dopo" | Dopo = mai. Documenta ora, nel momento |
| "Era un errore una tantum" | Se 2+ occorrenze nel journal, è strutturale |
| "La skill non ha davvero sbagliato" | Se l'utente ha corretto, la skill ha sbagliato qualcosa |
| "L'utente non era chiaro" | Skill doveva chiedere. Il fallimento è della skill |
| "Il patch è ovvio, lo applico" | Solo dopo approvazione esplicita utente. No eccezioni |
| "Skippo LESSONS_LEARNED per gesu task" | Append-only. Nessun fallimento significativo è skippabile |
| "Era colpa di un'altra skill" | Root cause per la TUA skill. L'altra fa il suo postmortem |
