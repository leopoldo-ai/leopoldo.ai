# Mappa Domini Skill

Keyword per scoprire skill su GitHub quando manca un'expertise nel board.

## Come usare

Quando il board orchestrator identifica un dominio mancante:

1. Mappare il dominio alle keyword di ricerca (vedi sotto)
2. Cercare su GitHub: `gh search repos "<keyword> claude skill" --sort stars`
3. Presentare top 3-5 risultati all'utente
4. **Obbligatorio:** Eseguire `/review-skill-safety` prima dell'installazione
5. Installare in `skills/[nome-skill]/`

---

## Dominio → Keyword di ricerca

### Sicurezza & AppSec
**Expertise mancante:** "security expert", "penetration testing", "vulnerability assessment"
**Skill gia' installata:** `secure-code-guardian`

**Keyword GitHub:**
- `claude skill security`
- `claude skill owasp`
- `claude skill appsec`

### DevOps & Infrastructure
**Expertise mancante:** "devops", "CI/CD", "deployment", "docker", "kubernetes"

**Keyword GitHub:**
- `claude skill devops`
- `claude skill ci-cd`
- `claude skill vercel deployment`
- `claude skill docker`

### Legal & Compliance
**Expertise mancante:** "legal review", "GDPR", "privacy", "contratti", "compliance"

**Keyword GitHub:**
- `claude skill legal`
- `claude skill gdpr`
- `claude skill compliance`
- `claude skill privacy`


### Data Science & Analytics
**Expertise mancante:** "data analysis", "machine learning", "analytics", "statistics"

**Keyword GitHub:**
- `claude skill data-science`
- `claude skill analytics`
- `claude skill machine-learning`


### HR & Talent Management
**Expertise mancante:** "HR analytics", "talent management", "recruitment process", "assessment"

**Keyword GitHub:**
- `claude skill hr`
- `claude skill recruitment`
- `claude skill talent`
- `claude skill assessment`


### CRM & Sales
**Expertise mancante:** "CRM", "sales automation", "pipeline management", "outreach"

**Keyword GitHub:**
- `claude skill crm`
- `claude skill sales`
- `claude skill outreach`


### Copywriting & Content
**Expertise mancante:** "copywriting", "content strategy", "brand voice", "tone of voice"
**Skill gia' installate:** `email-copywriting`, `marketing-campaigns`

**Keyword GitHub:**
- `claude skill copywriting`
- `claude skill content-strategy`
- `claude skill brand-voice`

### Accessibility
**Expertise mancante:** "accessibility", "a11y", "WCAG", "inclusive design"

**Keyword GitHub:**
- `claude skill accessibility`
- `claude skill a11y`
- `claude skill wcag`

### Performance & Monitoring
**Expertise mancante:** "web performance", "monitoring", "observability", "logging"

**Keyword GitHub:**
- `claude skill performance`
- `claude skill monitoring`
- `claude skill observability`
- `claude skill web-vitals`


### Project Management
**Expertise mancante:** "project management", "agile", "sprint planning", "OKR"

**Keyword GitHub:**
- `claude skill project-management`
- `claude skill agile`
- `claude skill okr`

---

## Skill gia' installate per dominio

### Dominio coperto: Strategia & Business
`strategy-advisor`, `ceo-advisor`, `product-manager-toolkit`

### Dominio coperto: Development
`nextjs-developer`, `typescript-pro`, `postgres-pro`, `api-designer`, `test-master`, `secure-code-guardian`, `nextjs-app-router-fundamentals`, `nextjs-server-client-components`, `neon-postgres-setup`, `drizzle-orm-patterns`

### Dominio coperto: Frontend & Design
`shadcnblocks-components`, `frontend-design`, `frontend-ui-ux`, `tremor-design-system`, `dashboard-builder`

### Dominio coperto: Email & Marketing
`email-marketing-bible`, `email-copywriting`, `marketing-campaigns`

### Dominio coperto: Change Mgmt & Comunicazione
`document-skills:internal-comms`, `document-skills:pptx`

### Dominio coperto: Reporting
`data-visualization`, `xlsx-reports`, `docx-reports`

### Dominio coperto: Security (skill review)
`review-skill-safety`

---

## Strategia di ricerca

### Ricerca base
```bash
gh search repos "claude skill security" --sort stars --limit 10
```

### Ricerca su repo noti con molte skill
```bash
# Jeffallan/claude-skills — 66 skill
gh api repos/Jeffallan/claude-skills/contents/skills --jq '.[].name'

# wsimmonds/claude-nextjs-skills — 10 skill Next.js
gh api repos/wsimmonds/claude-nextjs-skills/contents/skills --jq '.[].name'
```

### Fallback
Se nessun risultato:
1. **Allargare la ricerca** — Provare categoria padre
2. **Provare sinonimi** — Usare le keyword alternative dalla mappa sopra
3. **Chiedere all'utente** — "Nessuna skill trovata per [dominio]. Hai un repo specifico o un nome skill?"

---

**Nota:** Questa mappa evolve man mano che nuove skill vengono scoperte e installate. Aggiornare dopo ogni nuova installazione.
