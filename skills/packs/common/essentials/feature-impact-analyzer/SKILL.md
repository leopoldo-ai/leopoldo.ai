---
name: feature-impact-analyzer
description: Use when the user requests "/feature-impact", "analizza impatto feature", "vale la pena implementare X?", or needs structured multi-perspective analysis (technical, product, financial, strategic, UX) with RICE scoring and decision matrix before committing to a feature.
type: technique
---

# Feature Impact Analyzer

Coordinates specialized skills to produce a comprehensive impact analysis of proposed features, combining RICE prioritization, technical feasibility, financial impact, and strategic alignment into a single decision matrix.

## Core Workflow

### Phase 1: Feature Definition

1. **Extract feature description** from user request
2. **Gather context**:
   - PRD corrente (cercare in `docs/` il PRD piu' recente)
   - Roadmap e milestone (da CLAUDE.md sezione workflow)
   - Architettura esistente (scan codebase + `CLAUDE.md` sezione stack)
3. **Confirm scope** with user via `AskUserQuestion`

### Phase 2: Multi-Perspective Analysis

Invoke skills in parallel using Task tool:

#### Product Analysis (`product-manager-toolkit`)
- **RICE Score**: Reach, Impact, Confidence, Effort
- Customer segment affected
- Alignment with product vision
- Competitive advantage

#### Technical Analysis (`senior-architect` + `nextjs-developer`)
- Implementation complexity (T-shirt sizing: S/M/L/XL)
- Architecture impact (new/modified components, new dependencies)
- Technical debt introduced or resolved
- Estimated effort (story points or dev-days)

#### Financial Analysis (`strategy-advisor`)
- Development cost (effort × daily rate)
- Infrastructure cost delta (Vercel Pro, Neon)
- Revenue impact projection (direct/indirect)
- ROI estimate (3-month, 6-month, 12-month)

#### Strategic Analysis (`strategy-advisor` + `ceo-advisor`)
- Market positioning impact
- Competitive differentiation
- Alignment with business goals
- Risk assessment

#### UX Analysis (`ux-researcher-designer`) — optional
- User journey impact
- Usability considerations
- Design effort

### Phase 3: Decision Matrix

Combine all analyses into weighted decision matrix:

```markdown
# Feature Impact Analysis: [Feature Name]

## Decision Matrix

| Dimension | Score (1-5) | Weight | Weighted |
|-----------|-------------|--------|----------|
| Product (RICE) | [X] | 25% | [X.XX] |
| Technical Feasibility | [X] | 20% | [X.XX] |
| Financial ROI | [X] | 25% | [X.XX] |
| Strategic Alignment | [X] | 20% | [X.XX] |
| UX Impact | [X] | 10% | [X.XX] |
| **Total** | | | **[X.XX]/5** |

## Verdict
- ⭐ 4.0-5.0: **Strong Go** — Prioritize immediately
- ✅ 3.0-3.9: **Go** — Schedule for next sprint/phase
- ⚠️ 2.0-2.9: **Conditional** — Needs refinement
- ❌ 1.0-1.9: **No Go** — Defer or discard

## RICE Breakdown
| Factor | Value | Rationale |
|--------|-------|-----------|
| Reach | [X]/5 | [explanation] |
| Impact | [X]/5 | [explanation] |
| Confidence | [X]% | [explanation] |
| Effort | [X] days | [explanation] |

## Technical Assessment
- **Complexity:** [S/M/L/XL]
- **Files affected:** [N] files across [N] modules
- **New dependencies:** [list or "none"]
- **Breaking changes:** [yes/no + details]

## Financial Projection
| Metric | 3 months | 6 months | 12 months |
|--------|----------|----------|-----------|
| Dev cost | €[X] | — | — |
| Infra cost | €[X]/mo | €[X]/mo | €[X]/mo |
| Revenue impact | €[X] | €[X] | €[X] |
| **Net ROI** | **[X]%** | **[X]%** | **[X]%** |

## Risks & Mitigations
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|

## Action Items
1. [ ] ...
```

## Comparison Mode

For evaluating multiple features against each other:

```
/feature-impact --compare "Feature A" vs "Feature B" vs "Feature C"
```

Generates side-by-side comparison matrix with all dimensions.

## Quick Analysis Mode

For faster, lighter analysis (2-3 skills only):

```
/feature-impact --quick "Feature name"
```

Skips UX and Strategic analysis, focuses on Product + Technical + Financial.
