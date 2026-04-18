---
name: skill-retrospective
description: Use at end of session, after complex multi-step tasks, or when the user says "retrospective", "session review", "migliorare skill", "improve skills", "cosa possiamo migliorare", "friction analysis". Identifies friction points, maps them to responsible skills, proposes patches for user approval.
type: technique
---

# Skill Retrospective — Autonomous Skill Improvement Loop

Meta-skill che analizza il lavoro svolto in sessione, identifica friction points, propone miglioramenti concreti alle skill coinvolte, e li applica dopo approvazione utente.

## Concetto

```
Sessione completata → Session Scan → Friction Detection → Skill Mapping → Patch Generation → User Review → Apply & Log
```

## Quando invocarla

- **Fine sessione** dopo lavoro complesso (closure loop, build loop, board meeting)
- **Dopo un problema** quando la causa e' una lacuna nella skill
- **Periodicamente** ogni 3-5 sessioni come review generale
- **Su richiesta utente** "cosa possiamo migliorare?", "retrospective"

## Workflow

### 1. Session Scan

Raccogliere: skill usate, task completati, durata/complessita', contesto compattato?, output prodotti.

### 2. Friction Detection

Per ogni skill usata, valutare 6 categorie:

| Categoria | Domanda chiave |
|-----------|---------------|
| **Data Loss** | Output persi per context compaction? |
| **Manual Steps** | Step ripetitivi automatizzabili? |
| **Missing Rules** | Situazioni non coperte? |
| **Inadequate Rules** | Regole che non funzionano in pratica? |
| **Missing Anti-patterns** | Errori non documentati? |
| **Scope Gaps** | La skill copre tutto il suo dominio? |

**Input da skill-postmortem:** se invocato durante la sessione, leggere `LESSONS_LEARNED.md` come friction pre-analizzate. Non duplicare il lavoro.

**Severity:** Critical (perdita lavoro) | High (riduce efficienza) | Medium (rallenta) | Low (marginale)

### 3. Skill Mapping

Per ogni friction: skill responsabile → sezione da modificare → tipo fix (`add_rule`, `add_antipattern`, `modify_rule`, `add_step`, `new_skill`, `link_postmortem`).

### 4. Patch Generation

Solo per friction Critical/High. Per ogni patch: friction, severity, fix type, file, sezione, diff concreto, impatto, rischio.

### 5. User Review

Tabella riepilogativa di tutti i patch. Utente sceglie: approva tutti / selettivi / modifica / rifiuta (con motivo).

### 6. Apply & Log

Per ogni patch approvato:
1. Applicare diff alla skill (Edit tool)
2. Bump minor version
3. Aggiornare skill-changelog: data, skill, versione, friction, fix, source
4. Aggiornare MEMORY.md se impatta convenzioni
5. Verificare coerenza interna della skill modificata

## Categorizzazione automatica

| Tema | Pattern | Fix tipico |
|------|---------|-----------|
| **Context loss** | Output non salvati | add_rule: salvare intermedi |
| **Missing automation** | Step manuali ripetuti | add_step: automatizzare |
| **Rule gap** | Situazione non prevista | add_rule: coprire il caso |
| **Antipattern** | Errore non documentato | add_antipattern |
| **Scope creep** | Variazioni di scope non gestite | modify_rule |
| **Integration gap** | Due skill non comunicano | modify_rule: handoff |

## Integrazione con skill-postmortem

- **postmortem** = singolo fallimento, root cause, LESSONS_LEARNED.md
- **retrospective** = sessione intera, pattern di friction, patch a multiple skill

Se postmortem eseguito: leggere LESSONS_LEARNED → includere come friction pre-analizzata → verificare se patch applicato → se no, includere nei patch retrospective.

## Regole

- **Mai modificare una skill senza approvazione utente**
- **Solo friction Critical/High** generano patch — Medium/Low loggati
- **Una modifica per volta** — non accumulare 10 patch alla stessa skill
- **Verificare dopo ogni patch** — coerenza interna
- **Non aggiungere complessita' gratuita** — fix > 10 righe → valutare skill nuova
- **Friction ricorrente (3+ sessioni)** = skill strutturalmente inadeguata → proporre riscrittura

## Anti-pattern

- Retrospective senza dati concreti (solo "sensazioni")
- Patchare per caso singolo non ripetibile
- Ignorare Medium ricorrenti (diventano High)
- Modificare skill durante il lavoro (solo a fine sessione)
- Non aggiornare skill-changelog
- Aggiungere regole contraddittorie
