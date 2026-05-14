# Orchestrator — Lessons Learned

## 2026-03-28 | Railway env var escaping + postmortem gate skip

**Severity:** High
**Type:** user-correction
**Context:** Setting bcrypt hash as Railway env var for admin login

### Root Cause
1. Bcrypt hashes contain `$` characters. Railway CLI interprets `$` as shell variable expansion, truncating the value. Took 6+ attempts instead of pivoting after 2.
2. On user correction signal ("stai sclerando"), orchestrator acknowledged but did NOT trigger the mandatory postmortem gate (Step 0 violation).

### Lessons
- **ALWAYS** test env var values with special characters (`$`, `!`, `#`) by reading back immediately after setting. If truncated, pivot to dashboard or API.
- **NEVER** retry the same failing approach more than twice. After 2 failures, stop and change strategy (different tool, different encoding, different channel).
- **ALWAYS** trigger postmortem on correction signals before ANY other response. The gate is non-negotiable. "Acknowledging the feedback" is not the same as running the postmortem.
- **ALWAYS** for bcrypt hashes on Railway, use the web dashboard or wrap in single quotes with explicit verification.

### Prevention
- Add a mental checklist for env var operations: set → verify → test endpoint
- Correction detection must be reflexive, not reasoned about

---

## 2026-04-23 | Document generation skill bypass (Graziano DD PDF)

**Severity:** High
**Type:** user-correction
**Context:** Utente richiede "fammi un PDF" per deliverable DD finanziaria. Orchestrator procede con pandoc + Chrome headless + CSS scritto a mano, bypassando 4+ skill Leopoldo disegnate per document generation.

### Cosa è successo (fattuale)

1. Richiesta: "fammi un PDF" (deliverable DD finanziaria ~25KB markdown)
2. Orchestrator ha bypassato `Skill` tool e avviato direttamente pandoc + Chrome headless
3. CSS scritto da zero in 3 iterazioni (prima base, poi redesign con palette navy, poi fix tabelle)
4. Utente ha fornito correction signal "impresentabile"
5. Orchestrator ha iterato sul CSS invece di invocare postmortem (Step 0 violation, identico a 2026-03-28)
6. Solo dopo richiesta esplicita utente "hai usato leo?" l'orchestrator ha riconosciuto il bypass

### Cosa ci si aspettava

All'arrivo del trigger "PDF", scan obbligatorio della skill registry per match su document-generation skills disponibili:

- `document-skills:pdf` (toolkit PDF)
- `business-report` (multi-section .docx con TOC, headers, styling brand-kit)
- `theme-factory` (10 preset tematici per artifact)
- `canvas-design` (design visivo PNG/PDF)
- `brand-kit` (single source of truth: colori, tipografia, spacing)
- `one-pager` (single-page documenti brandizzati)

Invocazione via `Skill` tool della migliore match PRIMA di scrivere codice di rendering.

### Root cause

**Multi-factor failure chain:**

1. **Skill discovery omessa**: all'arrivo del task l'orchestrator non ha scansionato la skill list per pattern "document generation". Task → tool selection è avvenuto by-pass dello skill registry.
2. **Dev bias**: preferenza per tool controllabile (pandoc, CSS scritto a mano) vs skill con output "opaco". Razionalizzazione: "so farlo più in fretta".
3. **Missing gate**: nessun hook/check nell'orchestrator previene l'esecuzione diretta di rendering CLI (pandoc, Chrome headless, reportlab, wkhtmltopdf) senza passaggio attraverso una skill. Il `PreToolUse` hook non ha un matcher per document-generation intent.
4. **Correction signal ignorato (recidiva 2026-03-28)**: "impresentabile" → correction signal → Step 0 richiede postmortem → orchestrator ha iterato CSS. Stesso pattern di 2026-03-28 dove "stai sclerando" è stato riconosciuto ma non ha triggerato il gate.
5. **Self-applicability failure**: l'orchestrator gira NEL repo Leopoldo, davanti all'architetto del sistema. Bypassare le skill qui significa dimostrare che il sistema non si auto-applica. Segnale grave.

**Step che ha fallito:** orchestrator Step 1 (Routing). Routing ha considerato solo "quale agent chiamare" (advisory-desk per la valuation, già fatto) e NON ha considerato "quale skill per il rendering finale".

### Lezioni

- **ALWAYS** alla prima menzione di PDF/DOCX/PPTX/XLSX/deck/report/memo/presentation/spreadsheet/pitch/one-pager: invocare `Skill` tool con match su `document-skills:*`, `business-report`, `investor-deck`, `pitch-deck`, `canvas-design`, `theme-factory`, `brand-kit`, `one-pager`, `quote-template`, `invoice-template` PRIMA di ogni altra azione.
- **NEVER** scrivere CSS/HTML/LaTeX da zero per rendering documenti se esiste una skill Leopoldo che copre il caso d'uso. È anti-pattern definitorio del sistema.
- **NEVER** iterare un fix dopo un correction signal utente. Postmortem first, fix after. (Recidiva: vedi entry 2026-03-28.)
- **ALWAYS** quando operi nel repo Leopoldo stesso, il self-apply test è implicito: "userei io stesso questa skill se fossi un cliente?". Se la risposta è no, non bypassarla.

### Patch proposto

**Target:** orchestrator `SKILL.md` e/o nuovo hook `.leopoldo/hooks/document-gen-gate.sh`

#### Opzione A — Regola nell'orchestrator (soft gate)

Aggiungere sezione in `skills/engine/orchestrator/SKILL.md`:

```markdown
## Document Generation Gate (hard check)

Trigger lessicali: "pdf", "docx", "pptx", "xlsx", "excel", "word",
"powerpoint", "deck", "report", "memo", "presentazione", "foglio",
"one-pager", "pitch", "quote", "invoice", "fattura", "preventivo".

Sequenza OBBLIGATORIA:

1. STOP. Non scrivere CSS, non chiamare pandoc/reportlab/wkhtmltopdf/chrome headless.
2. Invocare `Skill` tool con match migliore:
   - PDF/stampa generica → document-skills:pdf
   - Report strutturato docx → business-report
   - Presentazione pptx → pitch-deck | investor-deck | document-skills:pptx
   - Excel/modello → advanced-excel-analyst | document-skills:xlsx
   - One-pager marketing → one-pager
   - Design visivo artistico → canvas-design | document-skills:canvas-design
   - Brand coherence → brand-kit (sempre come prerequisito)
3. Se nessuna skill copre il caso: state esplicitamente "nessuna skill Leopoldo
   copre questo caso d'uso per [ragione X]. Procedo con tooling diretto?"
   → wait for user confirmation.
4. Rendering CLI diretto (pandoc, chrome headless, reportlab) senza
   passaggio skill è ANTI-PATTERN. Loggare in skill-changelog come bypass.
```

#### Opzione B — Hook PreToolUse (hard gate)

`.leopoldo/hooks/document-gen-gate.sh`:

```bash
#!/bin/bash
# Blocca pandoc/chrome-headless/reportlab senza skill invocation recente

TOOL=$(jq -r '.tool // empty' <<<"$1")
CMD=$(jq -r '.command // empty' <<<"$1")

if [[ "$TOOL" == "Bash" ]] && [[ "$CMD" =~ (pandoc|reportlab|Chrome.*--print-to-pdf|wkhtmltopdf|weasyprint) ]]; then
  # Check se nell'ultima finestra conversazionale c'è skill.invoked event
  # per document-skills:* / business-report / theme-factory / brand-kit
  RECENT_SKILL=$(grep -l "skill.invoked.*\(document-skills\|business-report\|theme-factory\|brand-kit\|one-pager\|canvas-design\|pitch-deck\|investor-deck\)" .state/journal/*.jsonl 2>/dev/null | tail -1)
  if [[ -z "$RECENT_SKILL" ]]; then
    echo "BLOCKED: document generation CLI tool invoked without Leopoldo skill invocation." >&2
    echo "Expected skill: document-skills:pdf, business-report, theme-factory, brand-kit, ..." >&2
    echo "Say 'skip gate' to override." >&2
    exit 2
  fi
fi
exit 0
```

Registrare in `settings.json` con matcher `Bash` su PreToolUse.

**Impatto:** blocca DIY document generation. Costringe invocazione skill.
**Rischio:** false positive su use-case legittimi non coperti da skill. Override via "skip gate" come da convenzione.

**Classificazione patch:** `add_rule` + `add_step` (orchestrator) + nuovo hook (settings.json).

**Status:** Proposto. Wait for user approval.

### Link

- skill-changelog: evento postmortem 2026-04-23 orchestrator
- evolution-agent: flag per retrospettiva settimanale — recidiva correction signal Step 0 (2ª occorrenza, threshold 3 = skill ha problema strutturale)
- Issue: il gate di Step 0 (correction detection) NON è automatizzato. È un'istruzione nel system prompt. Proposta: hook UserPromptSubmit che fa matching lessicale su correction signals e inietta `CORRECTION_DETECTED: trigger postmortem` nel context.
