---
name: skill-postmortem
description: Auto-documenta i fallimenti significativi durante l'esecuzione delle skill. Genera un post-mortem strutturato con root cause analysis, propone patch alla skill coinvolta, e crea/aggiorna LESSONS_LEARNED.md nella directory della skill. Usare dopo test failure significativi, build break, output errato, o correzione utente. Complementa skill-retrospective (session-wide) con analisi puntuale.
---

# Skill Post-Mortem — Analisi e Documentazione dei Fallimenti

Meta-skill che documenta i fallimenti in modo strutturato, identifica la root cause, e propone patch per prevenire la ricorrenza.

## Differenza con skill-retrospective

| Aspetto | skill-retrospective | skill-postmortem |
|---------|---------------------|------------------|
| **Quando** | Fine sessione | Subito dopo un fallimento |
| **Scope** | Tutta la sessione | Singolo fallimento specifico |
| **Trigger** | Manuale o periodico | Dopo failure detection |
| **Output** | Patches a multiple skill | LESSONS_LEARNED.md + patch a 1 skill |
| **Focus** | Pattern di friction ricorrenti | Root cause analysis puntuale |

**Sono complementari:** postmortem analizza in profondita' il singolo evento; retrospective identifica pattern ricorrenti nella sessione intera.

## Quando invocarla

- **Test failure significativo** — pattern di fallimento, non un singolo unit test
- **Build break** causato da una skill (template errato, dipendenza mancante)
- **Output errato** che richiede correzione manuale dall'utente
- **L'utente corregge** — "non e' corretto", "sbagliato", "rifai", "non funziona"
- **systematic-debugging** o **debugging-wizard** risolvono un issue causato da una skill
- **Pattern ripetuto** — lo stesso errore si verifica per la seconda volta

## Workflow

### Fase 1: Detect — Identificare il fallimento

1. **Tipo:** test-failure | build-break | wrong-output | user-correction
2. **Severity:**
   - **Critical** — perdita di lavoro, dati corrotti, security issue
   - **High** — output completamente errato, richiede riscrittura
   - **Medium** — output parzialmente errato, richiede correzione
3. **Skill coinvolta:** quale skill ha prodotto l'output errato?
4. **Fase workflow:** in quale fase del workflow (0-5) o sessione Playbook (1-12)?

### Fase 2: Analyze — Root Cause Analysis

1. **Cosa e' successo** — descrizione fattuale del problema
2. **Cosa ci si aspettava** — il risultato corretto atteso
3. **Perche' e' successo** — analisi della causa:
   - Regola mancante nella skill?
   - Template outdated?
   - Documentazione errata nel reference?
   - Conflitto tra skill?
   - Input imprevisto non gestito?
4. **Quale step della skill ha fallito** — identificare il punto esatto nel workflow

### Fase 3: Document — Generare LESSONS_LEARNED.md

Creare o aggiornare `LESSONS_LEARNED.md` nella directory della skill fallita:

**Path:** `skills/[nome-skill]/LESSONS_LEARNED.md`

**Formato entry:**

```markdown
## [YYYY-MM-DD] — [Titolo breve del fallimento]

**Tipo:** test-failure | build-break | wrong-output | user-correction
**Severity:** Critical | High | Medium
**Fase workflow:** [Phase 0-5 or current session]

### Cosa e' successo
[Descrizione fattuale: cosa e' accaduto, quale output e' stato prodotto]

### Root Cause
[Analisi della causa principale — essere specifici, non generici]

### Fix applicato
[Come e' stato risolto nell'immediato — il fix di emergenza]

### Patch proposto alla skill
[Diff della modifica alla SKILL.md per prevenire ricorrenza]
**Status:** Proposto | Applicato | Rifiutato

### Lezione
[Regola da seguire in futuro — formulata come "SEMPRE [fare X]" o "MAI [fare Y]"]
```

### Fase 4: Patch — Proporre modifica alla skill

Per severity Critical e High:

1. **Generare diff concreto** per la SKILL.md della skill fallita
2. **Classificare il tipo di fix:**
   - `add_rule` — aggiungere una nuova regola
   - `add_antipattern` — documentare un anti-pattern
   - `modify_rule` — cambiare una regola esistente
   - `add_step` — aggiungere uno step al workflow
   - `update_reference` — aggiornare un file in references/
3. **Presentare all'utente** il patch con:
   - Il diff proposto
   - L'impatto stimato
   - Il rischio della modifica
4. **Applicare solo dopo approvazione** utente

### Fase 5: Link — Aggiornare il sistema

1. **skill-changelog** — registrare l'evento:
   ```
   [data] skill-postmortem: [skill-name] — [tipo fallimento]
   - Root cause: [causa]
   - Patch: [applicato/proposto/rifiutato]
   ```
2. **skill-retrospective** — il postmortem viene usato come input alla prossima retrospective
3. **MEMORY.md** — se il fallimento rivela una convenzione di progetto, aggiornare

## Regole

- **Mai generare LESSONS_LEARNED.md senza root cause** — no "probabilmente era...", no speculazioni
- **Un fallimento per entry** — non accumulare piu' eventi nella stessa entry
- **Append-only** — LESSONS_LEARNED.md cresce nel tempo, non sovrascrivere entry precedenti
- **Approvazione utente** prima di applicare patch alla SKILL.md
- **Soglia 3+ ripetizioni** — se la stessa lezione compare 3+ volte, la skill ha un problema strutturale. Proporre riscrittura della sezione, non un'altra regola
- **Non documentare fallimenti banali** — typo, errore di copia, dimenticanza una tantum

## Anti-pattern

- **Postmortem senza root cause** — "qualcosa e' andato storto" non e' un postmortem
- **Documentare tutto** — solo fallimenti significativi, non ogni micro-errore
- **Patchare senza approvazione** — mai modificare una skill autonomamente
- **Non linkare a skill-changelog** — il postmortem perde tracciabilita'
- **LESSONS_LEARNED come dump** — deve essere strutturato, non un diario
- **Analisi superficiale** — "la skill non copriva questo caso" senza identificare QUALE step/regola
- **Colpa all'utente** — se l'utente ha dato input ambiguo, la skill doveva chiedere chiarimenti

---

**Versione:** 1.0 (2026-03-01)
**Tipo:** Meta-skill invocabile
**Dipendenze:** skill-retrospective (v1.0+, consumer del postmortem), skill-changelog (logging), systematic-debugging (trigger opzionale), debugging-wizard (trigger opzionale)
