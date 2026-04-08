# Phase Requirements Reference

Detailed per-phase checklists extracted from DEVELOPMENT_PLAN.md with verification criteria.

## Table of Contents

1. [Phase Overview](#phase-overview)
2. [Phase 1-11 Checklists](#phase-checklists)
3. [Gate Decision Criteria](#gate-decision-criteria)
4. [Board Review Triggers](#board-review-triggers)
5. [Testing Thresholds](#testing-thresholds)

---

## Phase Overview

| Phase | Name | Critical? | Board Review? | Estimated Checks |
|-------|------|-----------|---------------|-----------------|
| 1 | Project Scaffold | No | No | 10 |
| 2 | Auth System | Yes | No | 12 |
| 3 | Core CRUD + Layout | No | No | 15 |
| 4 | Revenue Module | Yes | No | 14 |
| 5 | Cost Modules | No | No | 14 |
| 6 | Financing Module | No | No | 7 |
| 7 | Financial Engine | **Yes** | **Yes** | 18 |
| 8 | Output Pages + Viz | No | No | 13 |
| 9 | Sensitivity Analysis | No | No | 7 |
| 10 | Export | **Yes** | **Yes** | 10 |
| 11 | Polish & Testing | **Yes** | **Yes** | 14 |

---

## Phase Checklists

### Phase 1: Project Scaffold

#### Implementation
- [ ] Next.js app created with TypeScript strict, Tailwind, ESLint, App Router, src-dir
- [ ] `tsconfig.json` with `strict: true` and `@/` path aliases
- [ ] All core dependencies installed (prisma, next-auth, react-hook-form, zod, etc.)
- [ ] shadcn/ui initialized with base components (button, input, card, dialog, table, etc.)
- [ ] Folder structure matches `src/` convention from CLAUDE.md
- [ ] `src/lib/prisma.ts` singleton with soft delete middleware
- [ ] `src/lib/utils.ts` with `cn()` helper
- [ ] `npx prisma generate` runs without errors

#### Architecture
- [ ] Path aliases working (`@/components/...`, `@/lib/...`)
- [ ] No `any` types, no `@ts-ignore`

#### Testing
- [ ] `npm run build` passes with zero errors
- [ ] `npm run lint` passes

#### Documentation
- [ ] CLAUDE.md reflects actual project structure

**Gate:** `npm run build` must pass.

---

### Phase 2: Auth System

#### Implementation
- [ ] Auth.js v5 configured in `src/lib/auth.ts`
- [ ] Credentials provider (email + bcrypt password)
- [ ] Google OAuth provider
- [ ] GitHub OAuth provider
- [ ] JWT callback includes userId and role
- [ ] Session callback exposes userId and role
- [ ] Route handler at `src/app/api/auth/[...nextauth]/route.ts`
- [ ] Middleware protects `/projects/*` and `/admin/*`
- [ ] RBAC hook `src/hooks/use-permissions.ts`
- [ ] RBAC utility `src/lib/rbac.ts`
- [ ] Login page at `src/app/(auth)/login/page.tsx`
- [ ] Register page at `src/app/(auth)/register/page.tsx`

#### Architecture
- [ ] JWT strategy (no database sessions)
- [ ] RBAC checks: 5 roles × 17 permissions
- [ ] Middleware correctly redirects unauthenticated users
- [ ] Password hashing with bcrypt (min 10 rounds)

#### Testing
- [ ] Login with credentials works
- [ ] Login with OAuth works (if configured)
- [ ] Registration creates user with hashed password
- [ ] Protected routes redirect to login
- [ ] RBAC blocks unauthorized actions
- [ ] `npm run build` passes

#### Documentation
- [ ] Auth flow documented
- [ ] RBAC matrix documented

**Gate:** Login/register functional, protected routes working.

---

### Phase 3: Core CRUD + Layout

#### Implementation
- [ ] Dashboard layout with sidebar + header
- [ ] Sidebar navigation (project/scenario)
- [ ] Header with user menu and logout
- [ ] Breadcrumbs component
- [ ] Projects list page
- [ ] Create project dialog
- [ ] Project settings page
- [ ] Server actions: createProject, updateProject, deleteProject, listProjects
- [ ] Scenario list within project
- [ ] Create scenario (blank + deep copy)
- [ ] Server actions: createScenario, duplicateScenario, deleteScenario, setActiveScenario
- [ ] Deep copy transaction (all 10+ child tables)
- [ ] Auto-save hook `use-auto-save.ts`
- [ ] Optimistic locking utility
- [ ] Project members management (invite, role change)

#### Architecture
- [ ] Soft delete on all business entities
- [ ] Optimistic locking with `updated_at` check → 409
- [ ] Deep copy uses `$transaction` and remaps all FKs
- [ ] Auto-save debounce (1s)
- [ ] Sonner toast for save feedback

#### Testing
- [ ] Create/read/update/delete project works
- [ ] Create/duplicate/delete scenario works
- [ ] Deep copy preserves all child data
- [ ] Auto-save triggers correctly
- [ ] Optimistic locking returns 409 on conflict
- [ ] `npm run build` passes

#### Documentation
- [ ] API routes documented
- [ ] Deep copy logic documented

**Gate:** Full CRUD cycle working for projects and scenarios.

---

### Phase 4: Revenue Module

#### Implementation
- [ ] Revenue streams list page
- [ ] Add revenue stream dialog with type selector (4 types)
- [ ] Dynamic form: Subscription (MRR, churn, expansion, freemium)
- [ ] Dynamic form: One-Off (volume × price, milestone variant)
- [ ] Dynamic form: Consumable (active users × usage × price)
- [ ] Dynamic form: Marketplace (GMV × take rate)
- [ ] Zod validators per type
- [ ] Server actions: CRUD revenue streams
- [ ] Products sub-table per stream
- [ ] Client Groups sub-table
- [ ] Client-Product relations editable matrix
- [ ] Sort order (drag & drop)
- [ ] Revenue preview (inline calculation)
- [ ] Auto-save on every field

#### Architecture
- [ ] Forms use react-hook-form + zod
- [ ] Type-specific validation schemas
- [ ] Hierarchy: Scenario → RevenueStream → Product/ClientGroup → Relation
- [ ] All CRUD uses soft delete
- [ ] Auto-save with debounce

#### Testing
- [ ] All 4 revenue types create/save correctly
- [ ] Products and client groups CRUD works
- [ ] Client-product matrix editable
- [ ] Revenue preview shows correct values
- [ ] Auto-save persists data
- [ ] `npm run build` passes

#### Documentation
- [ ] Revenue stream types documented
- [ ] Form validation rules documented

**Gate:** All 4 revenue types functional with auto-save.

---

### Phase 5: Cost Modules

#### Implementation
- [ ] Personnel costs page with editable TanStack Table
- [ ] Department grouping
- [ ] Social charges auto-calculation
- [ ] Server actions: CRUD personnel costs
- [ ] OpEx page (recurring + one-time)
- [ ] OpEx category grouping
- [ ] Server actions: CRUD opex items
- [ ] CapEx page with depreciation
- [ ] Useful life + depreciation preview
- [ ] Server actions: CRUD capex items
- [ ] Working Capital config page
- [ ] DSO, DPO, inventory days inputs
- [ ] VAT configuration

#### Architecture
- [ ] TanStack Table with inline editing
- [ ] Depreciation calculation: straight-line by default
- [ ] Working capital tied to revenue/cost periods
- [ ] All modules auto-save

#### Testing
- [ ] Personnel CRUD with department totals
- [ ] OpEx CRUD with category totals
- [ ] CapEx with depreciation schedule
- [ ] Working capital config saves
- [ ] `npm run build` passes

#### Documentation
- [ ] Cost calculation methods documented
- [ ] Depreciation methods documented

**Gate:** All cost modules functional with auto-save.

---

### Phase 6: Financing Module

#### Implementation
- [ ] Financing events page
- [ ] Event type selector (Equity, Debt, Grant, Convertible)
- [ ] Per-type forms
- [ ] Timeline visualization
- [ ] Debt: interest rate + repayment schedule
- [ ] Server actions: CRUD financing events

#### Architecture
- [ ] Financing events affect CF and BS correctly
- [ ] Interest calculations over time
- [ ] Repayment schedule generation

#### Testing
- [ ] All 4 event types create/save
- [ ] Timeline displays correctly
- [ ] `npm run build` passes

#### Documentation
- [ ] Financing event types documented

**Gate:** Financing events saved and displayed correctly.

---

### Phase 7: Financial Engine (**CRITICAL**)

#### Implementation
- [ ] `src/engine/types.ts` — all TypeScript types
- [ ] `src/engine/periods.ts` — 22-period grid with helpers
- [ ] Revenue calculators: subscription, one-off, consumable, marketplace (each + tests)
- [ ] Cost calculators: personnel, opex, capex with depreciation (each + tests)
- [ ] `src/engine/financing.ts` + tests
- [ ] `src/engine/working-capital.ts` + tests
- [ ] `src/engine/statements/pnl.ts` + tests
- [ ] `src/engine/statements/cashflow.ts` + tests
- [ ] `src/engine/statements/balance-sheet.ts` + tests
- [ ] `src/engine/kpi.ts` + tests
- [ ] `src/engine/sensitivity.ts` + tests
- [ ] `src/engine/index.ts` — full orchestrator
- [ ] Server action: `recalculateScenario(scenarioId)`
- [ ] Cache invalidation: `is_stale = true` on input change

#### Architecture
- [ ] Pure functions (no side effects in calculators)
- [ ] Period helpers reused across all calculators
- [ ] BS balance equation holds: Assets = Liabilities + Equity
- [ ] CF ties out to BS cash
- [ ] P&L net income ties to BS retained earnings
- [ ] Cross-statement consistency verified

#### Testing
- [ ] Unit tests for every calculator (Vitest)
- [ ] Edge cases: zero values, negative values, single period
- [ ] Cross-statement tie-out tests
- [ ] `npm run test` — all pass
- [ ] `npm run build` passes

#### Documentation
- [ ] Formula documentation per calculator
- [ ] Period structure documented
- [ ] KPI definitions and formulas

**Gate:** All tests pass. BS balances. CF ties out. Cross-statement consistency.

**Board review recommended:** This is the core engine. Get `cfo` + `senior-architect` + `financial-analyst` review.

---

### Phase 8: Output Pages + Visualizations

#### Implementation
- [ ] P&L page with 22-column table
- [ ] P&L chart (area/bar stacked) with Recharts
- [ ] Cash Flow page with waterfall chart
- [ ] Balance Sheet page and table
- [ ] KPI Dashboard (burn rate, runway, ARR, LTV/CAC, margins)
- [ ] KPI sparkline mini-charts
- [ ] Scenario comparison mode (side-by-side)
- [ ] Auto-recalculate when `is_stale = true`

#### Architecture
- [ ] Charts use consistent color palette
- [ ] Tables use TanStack Table with frozen headers
- [ ] Lazy-loaded chart components
- [ ] Responsive layout

#### Testing
- [ ] Output pages render correct data
- [ ] Charts display correctly
- [ ] Scenario comparison works
- [ ] Auto-recalculate triggers on stale data
- [ ] `npm run build` passes

#### Documentation
- [ ] Chart types documented
- [ ] KPI definitions visible to user

**Gate:** All output pages render correctly with real data.

---

### Phase 9: Sensitivity Analysis

#### Implementation
- [ ] Sensitivity page
- [ ] Parameter selector
- [ ] Variation range config (±10/20/30%)
- [ ] Sensitivity matrix calculation
- [ ] Heatmap with @nivo/heatmap
- [ ] Tornado chart with Recharts
- [ ] Impact table

#### Architecture
- [ ] Sensitivity engine reuses financial engine
- [ ] Results cached per parameter combination

#### Testing
- [ ] Heatmap renders correct values
- [ ] Tornado chart displays correctly
- [ ] `npm run build` passes

**Gate:** Sensitivity analysis functional with real data.

---

### Phase 10: Export (**CRITICAL**)

#### Implementation
- [ ] Excel export: 9-tab workbook (Summary, Revenue, Personnel, OPEX, CAPEX, P&L, CF, BS, Charts)
- [ ] PDF export: Executive summary (5-7 pages)
- [ ] JSON export: API-friendly format
- [ ] Export page with format options
- [ ] Server actions for file generation
- [ ] Download endpoint

#### Architecture
- [ ] Excel uses `export-specifications.md` structure
- [ ] PDF uses proper formatting (see spec)
- [ ] Files generated server-side
- [ ] Temp files cleaned up after download

#### Testing
- [ ] Excel opens correctly in Excel/Google Sheets
- [ ] PDF renders correctly
- [ ] JSON is valid and complete
- [ ] All 22 periods present in exports
- [ ] `npm run build` passes

#### Documentation
- [ ] Export formats documented for user

**Gate:** All export formats generate correct files.

**Board review recommended:** Financial accuracy of exports is critical.

---

### Phase 11: Polish & Testing (**CRITICAL**)

#### Implementation
- [ ] Error boundaries on all pages
- [ ] Loading states with Skeleton
- [ ] Empty states
- [ ] Toast notifications consistent (sonner)
- [ ] Responsive: sidebar collapsible, tables scrollable
- [ ] Playwright setup
- [ ] E2E: login → create project → create scenario → add revenue → view output
- [ ] E2E: export Excel
- [ ] Performance: lazy load charts, virtualize large tables
- [ ] Prisma query optimization (select specific fields)

#### Architecture
- [ ] No unhandled errors in production
- [ ] Consistent error handling pattern
- [ ] Performance budget: < 3s page load

#### Testing
- [ ] E2E tests pass in CI
- [ ] No console errors in production build
- [ ] `npm run build` — zero errors
- [ ] `npm run lint` — zero warnings
- [ ] All unit tests pass

#### Documentation
- [ ] README.md updated with status
- [ ] All phases marked ✅

**Gate:** Zero build errors, zero lint warnings, E2E tests pass.

**Board review recommended:** Final quality gate before launch.

---

## Gate Decision Criteria

### READY (✅)

ALL of the following must be true:
- `npm run build` passes with zero errors
- All implementation checklist items checked
- All architecture checks pass
- All test assertions pass
- No critical blockers

### BLOCKED (⚠️)

ANY of the following:
- 1-3 non-critical items unchecked but workaround exists
- Tests passing but with known warnings
- Minor architecture deviations documented and justified
- Build passes but with non-blocking warnings

**Required action:** Document blockers, create action items, fix within 1-2 days.

### NOT READY (❌)

ANY of the following:
- `npm run build` fails
- Core functionality not working
- > 3 implementation items unchecked
- Critical architecture violation
- Test failures on core paths

**Required action:** Continue phase, do not proceed.

---

## Board Review Triggers

Board review is **recommended** for these phases:

| Phase | Why | Board Composition |
|-------|-----|------------------|
| 7 (Financial Engine) | Core calculations must be accurate | CFO + Senior Architect + Financial Analyst |
| 10 (Export) | Output accuracy is business-critical | CFO + Financial Analyst + Fullstack Dev |
| 11 (Polish & Testing) | Final quality gate | CTO + Product Manager + QA Lead |

### Board Review Process

1. Run `/complete-phase N --with-board-review`
2. Checklist generated first
3. If checklist shows READY or BLOCKED (minor):
   - Board orchestrator invoked automatically
   - Board reviews checklist + code
   - Board provides verdict
4. If checklist shows NOT READY:
   - Board not invoked (fix issues first)
   - Re-run after fixes

---

## Testing Thresholds

### Unit Tests (Vitest)

| Phase | Minimum Coverage | Focus Areas |
|-------|-----------------|-------------|
| 7 | 90% on engine/ | All calculators, all period types |
| 8 | 70% on components | Chart rendering, data transformation |
| 10 | 80% on export | File generation, data completeness |

### E2E Tests (Playwright)

| Phase | Minimum Scenarios | Focus |
|-------|------------------|-------|
| 11 | 5 happy paths | Full user journey |
| 11 | 3 edge cases | Empty data, large datasets, errors |

### Performance

| Metric | Threshold | Tool |
|--------|----------|------|
| Build time | < 60s | `npm run build` |
| Page load (LCP) | < 3s | Lighthouse |
| Table render (1000 rows) | < 500ms | React Profiler |
| Chart render | < 200ms | React Profiler |

---

**Note:** This reference is loaded into context by the phase-completion-checklist skill. Keep SKILL.md lean by referencing this file for detailed per-phase requirements.
