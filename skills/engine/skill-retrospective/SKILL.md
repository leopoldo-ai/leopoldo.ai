---
name: skill-retrospective
description: Post-session meta-skill that identifies friction points, maps them to responsible skills, generates concrete patches, and applies improvements after user approval. Triggers on retrospective, session review, migliorare skill, improve skills, cosa possiamo migliorare, friction analysis. Use at end of session or after complex multi-step tasks.
---

# Skill Retrospective — Autonomous Skill Improvement Loop

Meta-skill che analizza il lavoro svolto in sessione, identifica friction points, propone miglioramenti concreti alle skill coinvolte, e li applica dopo approvazione utente.

**Progetto:** Skill improvement loop per qualsiasi progetto strutturato

## Concetto

```
Sessione di lavoro completata
         |
         v
  [1. Session Scan]
  Quali skill usate? Quali task?
  Cosa e' andato bene/male?
         |
         v
  [2. Friction Detection]
  Identificare problemi:
  - Output persi (context compaction)
  - Step manuali evitabili
  - Regole mancanti o inadeguate
  - Anti-pattern non documentati
  - Errori ripetuti
         |
         v
  [3. Skill Mapping]
  Friction -> skill responsabile
  (puo' essere: skill mancante)
         |
         v
  [4. Patch Generation]
  Per ogni friction High/Critical:
  Generare diff concreto per la skill
         |
         v
  [5. User Review]
  Mostrare patches all'utente
  Approvare / modificare / rifiutare
         |
         v
  [6. Apply & Log]
  Applicare patches approvati
  Aggiornare skill-changelog
  Aggiornare MEMORY.md se necessario
```

## Quando invocarla

- **Fine sessione:** Dopo lavoro complesso (closure loop, build loop, board meeting)
- **Dopo un problema:** Quando qualcosa va storto e la causa e' una lacuna nella skill
- **Periodicamente:** Ogni 3-5 sessioni come review generale
- **Su richiesta utente:** "cosa possiamo migliorare?", "retrospective", "miglioriamo le skill"

## Workflow dettagliato

### Fase 1: Session Scan

Analizzare la sessione corrente per raccogliere dati:

1. **Skill usate:** Elencare tutte le skill invocate (dal contesto conversazione)
2. **Task completati:** Cosa e' stato prodotto (documenti, codice, analisi)
3. **Durata/complessita':** Quante iterazioni, quanti turni, contesto compattato?
4. **Output prodotti:** File creati/modificati, deliverable generati

```markdown
## Session Scan
- **Skill usate:** product-closure-loop, board-orchestrator, manatal-api, amplemarket-api, granola-mcp
- **Task:** PRD v1.5 closure loop (2 iterazioni, 39 gap, 12 sezioni nuove)
- **Contesto compattato:** Si, dopo iterazione 1
- **Output:** docs/ContactHub_PRD_v1.5.md (2479 righe)
```

### Fase 2: Friction Detection

Per ogni skill usata, valutare 6 categorie di friction:

| Categoria | Domanda chiave | Esempio |
|-----------|---------------|---------|
| **Data Loss** | Output prodotti persi per context compaction? | Sezioni PRD ricostruite da summary lossy |
| **Manual Steps** | Step ripetitivi che la skill poteva automatizzare? | Creare file consolidato a mano invece che incrementale |
| **Missing Rules** | Situazioni non coperte dalle regole della skill? | Nessuna regola su salvare intermedi |
| **Inadequate Rules** | Regole che non funzionano nella pratica? | "Non creare file automaticamente" contraddice la necessita' di persistenza |
| **Missing Anti-patterns** | Errori commessi non documentati come anti-pattern? | Produrre tutto in conversazione senza salvare |
| **Scope Gaps** | La skill copre tutto il suo dominio? | Skill non contemplava l'aggiunta di scope mid-loop |

**Input da skill-postmortem:** Se durante la sessione e' stato invocato `skill-postmortem`, leggere i `LESSONS_LEARNED.md` generati come input per la friction detection. I postmortem forniscono root cause analysis gia' fatta — non duplicare il lavoro, usarli come friction pre-analizzate.

**Severity dei friction:**
- **Critical:** Causa perdita di lavoro o errori gravi
- **High:** Riduce significativamente efficienza o qualita'
- **Medium:** Inconvenienza che rallenta ma non blocca
- **Low:** Miglioramento estetico o marginale

### Fase 3: Skill Mapping

Per ogni friction, identificare:

1. **Skill responsabile:** Quale skill avrebbe dovuto prevenire questo problema?
2. **Sezione da modificare:** Regole? Anti-pattern? Workflow? Configurazione?
3. **Tipo di fix:**
   - `add_rule` — Aggiungere una nuova regola
   - `add_antipattern` — Documentare un anti-pattern
   - `modify_rule` — Cambiare una regola esistente
   - `add_step` — Aggiungere uno step al workflow
   - `new_skill` — Serve una skill nuova (raro)
   - `link_postmortem` — La friction e' gia' stata analizzata da skill-postmortem, linkare il LESSONS_LEARNED.md

```markdown
| Friction | Severity | Skill | Sezione | Fix Type |
|----------|----------|-------|---------|----------|
| Output persi dopo compaction | Critical | product-closure-loop | Regole | add_rule |
| Nessun salvataggio intermedio | Critical | product-closure-loop | Fase 5 | add_step |
| Manual consolidation | High | product-closure-loop | Fase 7 | add_step |
```

### Fase 4: Patch Generation

Per ogni friction Critical/High, generare un **patch concreto** — il diff esatto da applicare alla skill.

Formato patch:

```markdown
### Patch #1: product-closure-loop — SALVA INTERMEDI

**Friction:** Output iterazioni persi dopo context compaction
**Severity:** Critical
**Fix type:** add_rule

**File:** skills/product-closure-loop/skill.md
**Sezione:** ## Regole

**Diff:**
```diff
 ## Regole
+- **SALVA INTERMEDI SEMPRE** — ogni output di iterazione va salvato
+  IMMEDIATAMENTE in `docs/wip/` come markdown. Pattern:
+  `docs/wip/closure_{target}_iter{N}_{tipo}.md`.
+  Previene perdita dati da context compaction.
 - **Mai chiudere con gap Critical aperti**
```

**Impatto:** Previene perdita di ~50% del contenuto dettagliato quando il contesto si compatta
**Rischio:** Nessuno (file temporanei, eliminabili dopo consolidamento)
```

### Fase 5: User Review

Presentare tutti i patch in formato tabella:

```markdown
## Patches proposti

| # | Skill | Friction | Severity | Fix | Approvato? |
|---|-------|----------|----------|-----|-----------|
| 1 | product-closure-loop | Output persi | Critical | add_rule: SALVA INTERMEDI | ? |
| 2 | session-reporter | Non rileva friction | High | add_step: friction section | ? |
| 3 | board-orchestrator | Scope change mid-loop | Medium | add_rule: scope freeze | ? |
```

Chiedere all'utente:
- **Approva tutti** — applico tutto
- **Approva selettivi** — l'utente sceglie quali
- **Modifica** — l'utente cambia un patch prima dell'applicazione
- **Rifiuta** — non applicare (con motivo)

### Fase 6: Apply & Log

Per ogni patch approvato:

1. **Applicare il diff** alla skill (Edit tool)
2. **Aggiornare versione** della skill (bump minor)
3. **Aggiornare `skill-changelog`** con entry:
   ```
   [data] skill-retrospective: [skill-name] v[X.Y] -> v[X.Y+1]
   - Friction: [descrizione]
   - Fix: [tipo] - [descrizione]
   - Source: session retrospective [data]
   ```
4. **Aggiornare `MEMORY.md`** se il fix impatta convenzioni di progetto
5. **Verificare** che la skill modificata sia ancora valida (nessuna contraddizione interna)

## Integrazione con session-reporter

Se `session-reporter` e' invocato nella stessa sessione, la retrospective diventa una sezione del report:

```markdown
## Retrospective — Skill Improvements
| Skill | Fix | Status |
|-------|-----|--------|
| product-closure-loop v1.2→v1.3 | SALVA INTERMEDI rule | Applied |
| session-reporter v1.1→v1.2 | friction section | Applied |

**Friction score sessione:** 2 Critical, 0 High, 1 Medium
**Skills migliorate:** 2
```

## Integrazione con skill-postmortem

`skill-postmortem` e `skill-retrospective` sono complementari:
- **postmortem** = singolo fallimento, root cause analysis, LESSONS_LEARNED.md
- **retrospective** = sessione intera, pattern di friction, patch a multiple skill

Se un postmortem e' stato eseguito durante la sessione:
1. Leggere `LESSONS_LEARNED.md` della skill coinvolta
2. Includere nella friction detection come friction gia' analizzata (tipo `link_postmortem`)
3. Verificare se il patch proposto dal postmortem e' stato applicato
4. Se non applicato, includerlo nei patch della retrospective
5. Non duplicare l'analisi — il postmortem ha gia' fatto la root cause

## Categorizzazione automatica

La retrospective categorizza i friction per tema ricorrente:

| Tema | Pattern | Fix tipico |
|------|---------|-----------|
| **Context loss** | Output in conversazione non salvati | add_rule: salvare file intermedi |
| **Missing automation** | Step manuali ripetuti | add_step: automatizzare nel workflow |
| **Rule gap** | Situazione non prevista dalle regole | add_rule: coprire il caso |
| **Antipattern** | Errore commesso non documentato | add_antipattern: documentare |
| **Scope creep** | Skill non gestisce variazioni di scope | modify_rule: gestire scope change |
| **Integration gap** | Due skill non comunicano bene | modify_rule: aggiungere handoff |
| **Performance** | Skill troppo lenta o verbose | modify_rule: ottimizzare |

## Metriche di salute skill (nel tempo)

Se invocata periodicamente, traccia:

```markdown
## Skill Health Dashboard
| Skill | Friction last 5 sessions | Trend | Last patched |
|-------|-------------------------|-------|-------------|
| product-closure-loop | 2→1→0 | Improving | 2026-02-28 |
| board-orchestrator | 0→0→1 | Stable | 2026-02-15 |
| session-reporter | 1→1→1 | Needs attention | Never |
```

## Regole

- **Mai modificare una skill senza approvazione utente** — mostrare sempre il diff prima
- **Solo friction Critical/High** generano patch — Medium/Low sono loggati ma non patchati automaticamente
- **Una modifica per volta** — non accumulare 10 patch alla stessa skill, applicare incrementalmente
- **Verificare dopo ogni patch** — la skill deve restare coerente internamente
- **Non aggiungere complessita' gratuita** — se il fix richiede piu' di 10 righe, valutare se serve una skill nuova
- **Friction ricorrente (3+ sessioni)** = skill strutturalmente inadeguata, proporre riscrittura
- **Salvare retrospective** in `docs/wip/retrospective_{data}.md` per storico

## Anti-pattern

- Fare retrospective senza dati concreti (solo "sensazioni")
- Patchare skill per un caso singolo che non si ripetera'
- Ignorare friction Medium perche' "non sono Critical" — se ricorrenti, diventano High
- Modificare skill durante il lavoro (solo a fine sessione o dopo task complesso)
- Non aggiornare skill-changelog (perde la tracciabilita')
- Aggiungere regole contraddittorie a quelle esistenti

---

**Versione:** 1.1 (aggiornato 2026-03-01: integrazione con skill-postmortem)
**Dipendenze:** session-reporter (v1.2+), skill-changelog, skill-inventory (opzionale per health dashboard), skill-postmortem (opzionale, input)
