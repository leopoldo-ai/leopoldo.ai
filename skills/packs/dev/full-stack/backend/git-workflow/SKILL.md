---
name: git-workflow
version: 0.2.0
description: Manages git workflow for autonomous development loops. Handles conventional commits, feature branching, atomic commits after each completed task, and PR creation. Use when committing code, creating branches, managing PRs, or running autonomous build loops that need version control. Triggers on commit, branch, PR, git workflow, version control.
---

# Git Workflow — Autonomous Build Loop

Gestisce il workflow git per loop di sviluppo autonomi. Commit atomici, branch per feature, conventional commits, PR automatiche.

**Progetto:** Qualsiasi progetto con loop di sviluppo autonomo

## Quando usare

- Dopo ogni task completato in un loop autonomo → commit atomico
- Inizio feature → creare branch
- Feature completata → creare PR
- Qualsiasi operazione git strutturata

## Convenzioni

### Branch naming
```
feature/[scope]-[description]
fix/[scope]-[description]
chore/[scope]-[description]

# Esempi
feature/sync-api-chunked
feature/dashboard-contacts-table
fix/webhook-validation
chore/drizzle-migration-cleanup
```

### Conventional commits
```
<type>(<scope>): <description>

# Types
feat:     Nuova funzionalita'
fix:      Bug fix
refactor: Refactoring senza cambio comportamento
test:     Aggiunta/modifica test
chore:    Manutenzione, config, dipendenze
docs:     Documentazione
style:    Formattazione, nessun cambio logica
perf:     Miglioramento performance
ci:       CI/CD config

# Scope (definire per progetto)
sync, dashboard, contacts, campaigns, organizations, api, db, auth, ui

# Esempi
feat(sync): add chunked API sync with cursor pagination
fix(api): validate webhook signature before processing
test(contacts): add integration tests for contact upsert
refactor(db): extract Drizzle client to shared module
chore(deps): update drizzle-orm to 0.35.x
```

## Workflow per loop autonomo

### Inizio sessione
```
1. git checkout main && git pull
2. git checkout -b feature/[scope]-[description]
3. Iniziare il loop di task
```

### Dopo ogni task completato
```
1. Verificare che il task sia effettivamente completato (test passa, build OK)
2. git add [file specifici] — MAI git add . o git add -A
3. git commit con conventional commit message
4. project-memory → scan incrementale, aggiorna PROJECT_STATE.md
5. Continuare al task successivo
```

### Fine feature
```
1. Verificare build completo: npm run build
2. Verificare lint: npm run lint
3. Verificare test: npm run test
4. git push -u origin feature/[scope]-[description]
5. Creare PR con gh pr create
```

## Regole commit atomici

Ogni commit deve:
- **Rappresentare un singolo task completato** dal task-decomposer
- **Lasciare il progetto in stato funzionante** (build + lint passano)
- **Includere solo i file modificati dal task** (no file estranei)
- **Avere un messaggio che spiega il "perche'"** non il "cosa"

```
# BUONO: spiega il perche'
feat(sync): add cursor-based pagination to handle 200K contacts within Vercel timeout

# CATTIVO: dice solo il cosa
feat(sync): add pagination
```

## Template PR

```markdown
## Summary
- [1-3 bullet points che descrivono la feature]

## Tasks completati
- [x] Task 1.1: [descrizione]
- [x] Task 1.2: [descrizione]
- [x] Task 2.1: [descrizione]

## Test plan
- [ ] Unit test passano
- [ ] Integration test passano
- [ ] Build completo senza errori
- [ ] Lint senza warning
- [ ] [Test specifici della feature]

## Note per il reviewer
[Eventuali decisioni architetturali, trade-off, o punti di attenzione]
```

## Gestione conflitti

1. **Mai force push** su branch condivisi
2. **Rebase preferito** su merge per feature branch personali
3. Se conflitto durante loop autonomo:
   a. Stoppare il loop
   b. Segnalare all'utente con dettagli del conflitto
   c. Attendere risoluzione umana
   d. Riprendere il loop

## Protezioni

- **Mai commit su main** direttamente
- **Mai commit di file .env** o secrets
- **Mai --no-verify** per saltare hooks
- **Mai --force** push senza conferma utente
- **Mai amend** di commit gia' pushati
- **Sempre specificare file** nel git add (no `-A`, no `.`)

## Integrazione con task-decomposer

Quando il task-decomposer produce un build plan, il git-workflow:

1. Crea il branch dalla prima fase del piano
2. Dopo ogni task completato, commit atomico
3. Se il piano ha fasi parallele, commit separati per ogni task
4. A fine piano, push + PR

---

**Versione:** 1.1 (aggiornato 2026-02-28: integrazione project-memory dopo ogni commit)
**Dipendenze:** Bash tool (git, gh CLI), project-memory (scan incrementale post-commit)
