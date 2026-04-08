# Guida Composizione Board

Guida dettagliata per la selezione dei membri del board in base al tipo di decisione.

## Indice

1. [Classificazione tipo decisione](#classificazione-tipo-decisione)
2. [Regole composizione board](#regole-composizione-board)
3. [Mappatura skill → ruolo board](#mappatura-skill--ruolo-board)
4. [Template matrice decisionale](#template-matrice-decisionale)
5. [Template verbali meeting](#template-verbali-meeting)
6. [Pattern avanzati](#pattern-avanzati)

---

## Classificazione tipo decisione

### Decisioni strategiche (Trasformazione / Roadmap)
**Indicatori:** "strategia", "priorita'", "roadmap", "direzione", "adoption", "organizzazione"

**Board raccomandato:**
- **Strategy Director**: `strategy-advisor` — SWOT, positioning, design organizzativo
- **CEO Advisor**: `ceo-advisor` — Governance, stakeholder management, impatto leadership
- **Product Manager**: `product-manager-toolkit` — RICE scoring, prioritizzazione iniziative
- **Data Lead**: `data-visualization` — Visualizzazione opzioni, matrici confronto

### Decisioni architettura tecnica
**Indicatori:** "architettura", "tech stack", "API", "database", "performance", "sync", "webhook", "migration"

**Board raccomandato:**
- **CTO**: `nextjs-developer` — Next.js patterns, App Router, Vercel deploy
- **DBA**: `postgres-pro` + `neon-postgres-setup` — Schema design, performance, Neon serverless
- **API Architect**: `api-designer` — REST design, error handling, versioning
- **Security Lead**: `secure-code-guardian` — OWASP, GDPR, input validation

### Decisioni frontend / UX (Dashboard)
**Indicatori:** "UI", "UX", "dashboard", "design", "componenti", "layout", "user experience"

**Board raccomandato:**
- **UX Lead**: `frontend-design` — UI/UX production-grade, design system
- **UI Designer**: `frontend-ui-ux` — Craft UI anche senza mockup
- **Frontend Architect**: `shadcnblocks-components` — Componenti shadcn/ui pre-built
- **Dashboard Expert**: `dashboard-builder` + `tremor-design-system` — Grafici KPI, analytics

### Decisioni prodotto / feature
**Indicatori:** "feature", "funzionalita'", "user flow", "backlog", "MVP", "priorita' sviluppo"

**Board raccomandato:**
- **Product Manager**: `product-manager-toolkit` — RICE, backlog prioritization
- **Strategy Director**: `strategy-advisor` — Alignment con obiettivi strategici
- **UX Lead**: `frontend-design` — Impatto sull'esperienza utente
- **CTO**: `nextjs-developer` — Fattibilita' tecnica, effort stimato

### Decisioni email marketing / campagne
**Indicatori:** "email", "campagna", "nurturing", "deliverability", "segmentazione", "IP warm-up"

**Board raccomandato:**
- **Email Strategist**: `email-marketing-bible` — Deliverability, automation, best practice
- **Copywriter**: `email-copywriting` — Strategy, copy, list building
- **Campaign Manager**: `marketing-campaigns` — UTM, analytics, content strategy
- **Strategy Director**: `strategy-advisor` — Alignment con obiettivi business

### Decisioni change management / comunicazione
**Indicatori:** "comunicazione", "adoption", "training", "resistenza", "partner", "onboarding", "cambiamento"

**Board raccomandato:**
- **Strategy Director**: `strategy-advisor` — Stakeholder analysis, positioning
- **CEO Advisor**: `ceo-advisor` — Governance, escalation, leadership alignment
- **Comms Lead**: `document-skills:internal-comms` — Comunicazioni interne, messaging
- **Presentation**: `document-skills:pptx` — Materiali per board/partner meeting

### Decisioni miste / complesse
**Indicatori:** Domini multipli coinvolti, decisioni ad alto impatto, categorizzazione non chiara

**Approccio:**
- Selezionare dinamicamente 5-7 membri dalle aree rilevanti
- Assicurare rappresentanza da: Tecnico, Prodotto, Strategico, Change Management
- Preferire diversita' su profondita' per decisioni complesse

---

## Regole composizione board

### Dimensioni
- **Decisioni semplici**: 3-4 membri (expertise focalizzata)
- **Decisioni complesse**: 5-7 membri (prospettive diverse)
- **Mai superare**: 9 membri (rendimenti decrescenti, troppo lento)

### Principi di bilanciamento
1. **Evitare lo stacking** — Non invitare 5 skill tecniche per una decisione strategica
2. **Includere stakeholder indiretti** — Decisioni tecniche beneficiano della prospettiva product
3. **Rispettare il contesto** — Per decisioni che toccano stakeholder senior, includere sempre `ceo-advisor`
4. **Evitare duplicazioni** — Non invitare la stessa skill due volte o skill troppo simili
5. **Vincolo change management** — Per qualsiasi decisione che impatta il team, includere almeno una skill di comunicazione

---

## Mappatura skill → ruolo board (DINAMICA)

**NOTA:** Questa sezione contiene regole di mapping per categoria, NON una lista statica. Il board-orchestrator scopre le skill disponibili a runtime leggendo CLAUDE.md e scansionando `skills/**/SKILL.md`.

### Regole di assegnazione ruolo automatica

Basandosi sul campo `description` del frontmatter di ogni SKILL.md, assegnare il ruolo con queste regole:

| Se description contiene... | Ruolo assegnato | Categoria |
|---------------------------|-----------------|-----------|
| strategy, SWOT, positioning, competitive | Strategy Director / CSO | Strategico |
| CEO, governance, stakeholder, leadership | CEO Advisor | Strategico |
| product, RICE, backlog, priorit, roadmap | Product Manager / CPO | Strategico |
| next.js, nextjs, vercel, app router, server component | CTO / Tech Lead | Tecnico |
| typescript, type safety, generics | Senior Engineer | Tecnico |
| postgres, SQL, database, query, index | DBA | Tecnico |
| API, REST, endpoint, webhook, OpenAPI | API Architect | Tecnico |
| drizzle, ORM, migration, schema | ORM Specialist | Tecnico |
| neon, serverless postgres | Cloud DB Expert | Tecnico |
| UI, UX, design, component, layout | UX/UI Lead | Frontend |
| dashboard, chart, analytics, KPI, tremor | Dashboard Expert | Frontend |
| shadcn, block, component library | UI Component Lead | Frontend |
| email, deliverability, newsletter, nurturing | Email Strategist | Marketing |
| copywriting, copy, subject line | Email Copywriter | Marketing |
| campaign, UTM, SEO, content strategy | Campaign Manager | Marketing |
| communication, internal, announcement | Comms Lead | Change Mgmt |
| presentation, slide, deck, pptx | Presentation Expert | Change Mgmt |
| security, OWASP, vulnerability, auth | Security Lead | Sicurezza |
| test, TDD, coverage, E2E, unit test | QA Lead | Quality |
| debug, error, troubleshoot, root cause | Debug Expert | Quality |
| code review, quality gate, reviewer | Code Reviewer | Quality |
| RAG, embedding, LLM, AI, prompt | AI/ML Expert | AI |
| performance, optimization, bundle, cache | Performance Lead | Optimization |
| deploy, CI/CD, pipeline, preview | DevOps Lead | Infrastructure |
| scaffold, init, boilerplate, setup | Project Architect | Infrastructure |
| git, commit, branch, PR, workflow | Git/VCS Lead | Infrastructure |
| task, decompos, plan, breakdown | Project Planner | Orchestrazione |
| visualization, table, matrix, chart | Data Visualization Lead | Reporting |
| xlsx, excel, spreadsheet | Excel Specialist | Reporting |
| docx, word, document, report | Document Specialist | Reporting |

### Logica di selezione

1. Leggere tutti i frontmatter disponibili
2. Matchare le keyword della `description` con le regole sopra
3. Selezionare 3-7 skill in base al tipo di decisione
4. Se una skill matcha piu' regole, usare il ruolo piu' specifico
5. Se nessuna skill disponibile copre un dominio necessario, segnalare come "expertise mancante"

### Fallback: skill note (riferimento storico)

Se la discovery dinamica fallisce, queste sono le skill note al momento dell'ultima configurazione. **Usare solo come fallback, preferire sempre la discovery dinamica.**

| Categoria | Skill note |
|-----------|-----------|
| Strategico | strategy-advisor, ceo-advisor, product-manager-toolkit |
| Tecnico | nextjs-developer, typescript-pro, postgres-pro, api-designer, neon-postgres-setup, drizzle-orm-patterns |
| Frontend | shadcnblocks-components, frontend-design, frontend-ui-ux, tremor-design-system, dashboard-builder |
| Marketing | email-marketing-bible, email-copywriting, marketing-campaigns |
| Change Mgmt | document-skills:internal-comms, document-skills:pptx |
| Quality | secure-code-guardian, test-master |
| Reporting | data-visualization, xlsx-reports, docx-reports |

---

## Template matrice decisionale

Per decisioni complesse con opzioni multiple, usare questo approccio a punteggio pesato:

| Criterio | Peso | Opzione A | Opzione B | Opzione C | Note |
|----------|------|-----------|-----------|-----------|------|
| Fattibilita' tecnica | 20% | 8/10 | 6/10 | 9/10 | A: usa stack esistente |
| Impatto utente | 25% | 7/10 | 9/10 | 6/10 | B: UX significativamente migliore |
| Costo | 15% | 9/10 | 5/10 | 8/10 | B: richiede infrastruttura aggiuntiva |
| Time to market | 15% | 6/10 | 8/10 | 5/10 | B: piu' veloce da rilasciare |
| Fit strategico | 15% | 8/10 | 7/10 | 9/10 | C: allineato con visione lungo termine |
| Adoption team | 10% | 7/10 | 5/10 | 8/10 | C: curva apprendimento piu' bassa |
| **Punteggio pesato** | - | **7.45** | **6.85** | **7.30** | A vince marginalmente |

**Come costruire:**
1. Elencare criteri di valutazione (consultare ogni membro del board per il suo dominio)
2. Assegnare pesi (devono sommare a 100%) — includere sempre "Adoption team" per decisioni che impattano il team
3. Ogni membro assegna punteggio (scala 1-10)
4. Calcolare punteggio pesato: `Somma(punteggio_criterio x peso)`
5. Identificare vincitore e margine

---

## Template verbali meeting

Creare file solo se l'utente richiede esplicitamente "salva i verbali" o "documenta il board meeting".

**Percorso file:** `docs/board-meetings/YYYY-MM-DD-tema.md`

```markdown
# Board Meeting: [Tema]

**Data:** [YYYY-MM-DD]
**Tipo:** [Strategica/Tecnica/Prodotto/Change Mgmt/Mista]
**Contesto progetto:** [Sessione X / Fase Y / Altro]

## Partecipanti
- [Ruolo 1] ([Nome skill])
- [Ruolo 2] ([Nome skill])

## Contesto
[1-2 paragrafi sul tema decisionale, riferimenti a sessione/fase/PRD]

## Sintesi discussione

### [Ruolo 1]: [Posizione — Approva/Condizionale/Rigetta]
**Argomenti chiave:**
- [Argomento 1]
- [Argomento 2]
**Preoccupazioni:**
- [Eventuale concern]
**Raccomandazioni:**
- [Raccomandazione specifica]

### [Ruolo 2]: [Posizione]
[Stessa struttura]

## Analisi consenso

**Riepilogo voti:**
- Approva: [X membri]
- Condizionale: [Y membri]
- Rigetta: [Z membri]

**Raccomandazione finale:** [Statement chiaro]
**Livello di confidenza:** [Alto/Medio/Basso]
**Condizioni (se presenti):**
1. [Condizione 1]
2. [Condizione 2]

## Decisione

**Percorso scelto:** [Cosa e' stato deciso]
**Motivazione:** [Perche', considerando tutte le prospettive]

## Action Items
- [ ] [Task 1] (@responsabile, deadline)
- [ ] [Task 2] (@responsabile, deadline)

## Rischi e mitigazioni

1. **[Rischio 1]:**
   - **Impatto:** [Alto/Medio/Basso]
   - **Probabilita':** [Alta/Media/Bassa]
   - **Mitigazione:** [Come affrontarlo]

## Metriche di successo

- **Metrica 1:** [Descrizione] — Target: [Valore] entro [Data]
- **Metrica 2:** [Descrizione] — Target: [Valore] entro [Data]

## Prossimi passi

1. [Azione immediata]
2. [Follow-up]
3. [Checkpoint futuro]

---

_Generato da Board Orchestrator v1.0_
_Partecipanti: [Lista skill names]_
```

---

## Pattern avanzati

### Gestione deadlock

Se il board e' diviso equamente (es. 2-2 o 3-3):

1. **Identificare il punto di disaccordo** — Cos'esattamente causa la divisione?
2. **Richiedere dati aggiuntivi** — Piu' analisi puo' risolvere?
3. **Proporre approccio ibrido** — Combinare elementi da entrambe le parti
4. **Rollout a fasi** — Partire con versione minima, iterare
5. **Escalare all'utente** — Presentare pro/contro chiaramente, far decidere l'utente

### Aggiunta dinamica di membri

Se durante la consultazione un membro suggerisce "dovremmo sentire anche [X dominio]":

1. **Valutare il suggerimento** — Questo dominio e' davvero necessario?
2. **Chiedere permesso utente** — Non espandere il board automaticamente
3. **Aggiungere membro** — Invocare nuova skill con contesto completo
4. **Annotare nell'output** — "Board espanso per includere [X] su suggerimento di [Y]"

### Consultazione parallela vs sequenziale

**Default: Parallela** (piu' veloce, prospettive indipendenti)
- Usare quando i membri non hanno bisogno di vedere l'input degli altri
- Scenario piu' comune

**Sequenziale: Rara** (quando il contesto si costruisce)
- Usare quando i membri successivi devono reagire alle raccomandazioni precedenti
- Es: CEO Advisor aspetta input di Strategy + Product, poi sintetizza
- Piu' lenta ma a volte necessaria per decisioni gerarchiche

### Punteggio di confidenza

Tracciare la confidenza nelle raccomandazioni:

- **Alta confidenza:** Unanime o forte maggioranza (5/5, 6/7), dati chiari
- **Media confidenza:** Maggioranza debole (3/5, 4/7), qualche dissenso, dati incerti
- **Bassa confidenza:** Deadlock (2/2, 3/3), alta incertezza, dati contrastanti

Evidenziare il livello di confidenza nell'output finale.

### Contesto progetto — sempre presente

Ogni consultazione del board deve includere i vincoli di progetto come contesto:

- **Stakeholder chiave:** Identificare i champion/promoter del progetto
- **Approccio adoption:** Definire strategia change management (es. pull > push)
- **Quick wins first:** Risultati visibili prima dei cambiamenti strutturali
- **Vincoli tecnici:** Volume dati, integrazioni, performance target
- **Budget:** Vincoli economici per infrastruttura e servizi
