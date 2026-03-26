---
name: lazy-context-loader
description: Pattern skill che definisce COME strutturare le skill con file di riferimento per caricamento progressivo. Guida per autori di skill su quando dividere SKILL.md in SKILL.md + references/, naming conventions, soglie di dimensione, e trigger di caricamento. Non un tool runtime, ma un design guide per il sistema di skill.
---

# Lazy Context Loader — Guida al Caricamento Progressivo dei Riferimenti

Guida di design che codifica il pattern `references/` per evitare di saturare la context window con contenuti non necessari.

## Perche' esiste

| Problema | Soluzione |
|----------|-----------|
| SKILL.md da 15KB+ carica tutto in context | Separare core da riferimenti dettagliati |
| Spreco di token per contenuti non usati | Caricare solo quando il workflow li richiede |
| Context window saturo limita la qualita' | SKILL.md snello + references/ on-demand |

## Regole di soglia

| Dimensione SKILL.md | Azione |
|---------------------|--------|
| **> 15 KB** (~400 righe) | **OBBLIGATORIO** splittare in SKILL.md + references/ |
| **8-15 KB** (~200-400 righe) | **CONSIGLIATO** se ci sono sezioni di riferimento distinte |
| **< 8 KB** (~200 righe) | Non necessario, tenere tutto in SKILL.md |

## Struttura consigliata

```
skills/[nome-skill]/
├── SKILL.md              # Core: workflow, regole, anti-pattern (max 8KB)
└── references/
    ├── [topic-1].md      # Riferimento dettagliato, caricato on-demand
    ├── [topic-2].md      # Altro riferimento
    └── ...
```

**SKILL.md contiene:** frontmatter, workflow core, regole, anti-pattern, tabella riferimenti
**references/ contiene:** dettagli tecnici, guide approfondite, template estesi, cataloghi

## Naming conventions per references

- **Kebab-case:** `chunking-strategies.md`, `common-patterns.md`, `board-composition-guide.md`
- **Descrittivi:** il nome deve indicare chiaramente il contenuto
- **No numeri nel nome:** l'ordine non importa, i file sono caricati on-demand
- **No prefissi generici:** non `ref-1.md`, `appendix-a.md`

## Trigger di caricamento

| Trigger | Quando caricare | Esempio |
|---------|----------------|---------|
| **Fase-based** | Il workflow raggiunge una fase specifica | "Fase 3: caricare `references/validation-rules.md`" |
| **Keyword-based** | L'utente menziona un topic specifico | "Se l'utente chiede di STRIDE: caricare `references/stride-framework.md`" |
| **On-demand** | L'utente chiede esplicitamente piu' dettagli | "Per approfondire: vedi `references/advanced-patterns.md`" |

## Template tabella riferimenti nel SKILL.md

Ogni skill con references/ deve includere questa tabella nel body:

```markdown
## Riferimenti dettagliati

| Topic | Reference | Caricare quando |
|-------|-----------|----------------|
| [Topic 1] | `references/[file-1].md` | [Trigger condition] |
| [Topic 2] | `references/[file-2].md` | [Trigger condition] |
```

## Pattern gia' in uso nel progetto

Skill che gia' usano il pattern `references/`:

| Skill | # References | Esempio |
|-------|-------------|---------|
| `board-orchestrator` | 2 | `board-composition-guide.md`, `skill-domains.md` |
| `code-reviewer` | 6 | Checklist per linguaggio/framework |
| `debugging-wizard` | 5 | Metodologie di diagnosi |
| `rag-architect` | 5 | Chunking, embedding, retrieval |
| `prompt-engineer` | 5 | Pattern di prompt design |
| `database-optimizer` | 5 | Query optimization, indexing |
| `dashboard-builder` | 4 | Layout, chart patterns |

## Skill candidate per refactoring

Skill attuali che superano le soglie e beneficerebbero dello split:

| Skill | Dimensione attuale | Azione suggerita |
|-------|-------------------|------------------|
| `email-marketing-bible` | ~17 KB | Splittare: deliverability, segmentazione, automation → references/ |
| `shadcnblocks-components` | ~15 KB | Splittare: catalogo componenti → references/ |
| `product-closure-loop` | ~11 KB | Borderline: valutare se template board → references/ |
| `systematic-debugging` | ~10 KB | Borderline: le 11 reference files sono gia' esterne |

## Cosa va nel SKILL.md core vs references

| Nel SKILL.md (core) | Nei references/ |
|---------------------|-----------------|
| Frontmatter (name, description) | Guide dettagliate per topic |
| Workflow con fasi numerate | Template estesi con esempi |
| Regole (MUST/MUST NOT) | Cataloghi e inventari |
| Anti-pattern | Checklist per dominio specifico |
| Tabella riferimenti | Documentazione tecnica approfondita |
| Versioning footer | Matrici di decisione complesse |

## Anti-pattern

- **Caricare tutti i references upfront** — vanifica lo scopo del lazy loading
- **Duplicare contenuto** tra SKILL.md e references (crea incoerenza quando si aggiorna uno solo)
- **References troppo piccoli** (< 1 KB) — meglio tenere nel SKILL.md
- **References troppo grandi** (> 10 KB) — splittare ulteriormente
- **Non avere tabella di caricamento** — senza trigger, il loader non sa quando caricare
- **Riferimenti circolari** — reference A che rimanda a reference B che rimanda ad A
- **Naming ambiguo** — `utils.md`, `misc.md`, `extra.md` non dicono nulla

---

**Versione:** 1.0 (2026-03-01)
**Tipo:** Design guide / pattern skill (non invocabile runtime)
**Dipendenze:** Nessuna (guida di design)
