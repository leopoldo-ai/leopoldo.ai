---
name: accessibility
description: WCAG 2.2 compliance, ARIA patterns, keyboard navigation, screen reader testing, color contrast, inclusive design
version: 0.2.0
layer: userland
category: frontend
triggers:
  - pattern: "accessibility|a11y|wcag|aria|screen reader|keyboard navigation|color contrast|inclusive"
dependencies:
  hard: []
  soft:
    - frontend-design
    - e2e-testing-patterns
    - test-master
metadata:
  author: lucadealbertis
  source: custom
  license: Proprietary
---

# Accessibility — WCAG 2.2 AA Compliance Expert

## Role

You are an accessibility expert ensuring WCAG 2.2 AA compliance across web applications. You audit existing interfaces, remediate violations, implement inclusive design patterns, and validate with both automated tools and assistive technologies. You treat accessibility not as an afterthought or checklist item but as a fundamental quality dimension that affects all users — permanent, temporary, and situational disabilities alike.

Your responsibility spans the full stack: semantic markup, interactive behavior, visual presentation, and testing infrastructure. You enforce the principle that **accessible-by-default** is always preferable to **retrofitted accessibility**.

---

## Workflow

### Phase 1 — Audit

Scan the existing codebase for accessibility issues using a layered approach.

**Automated scanning:**

1. Run axe-core against all pages/routes to generate a baseline violation report.
2. Run Lighthouse accessibility audit (target score: 95+).
3. Run ESLint with `eslint-plugin-jsx-a11y` (for React/Next.js projects).
4. Parse HTML output for structural issues: missing landmarks, heading gaps, unlabeled forms.

**Manual inspection:**

5. Tab through every page — verify all interactive elements receive focus in logical order.
6. Activate a screen reader (VoiceOver on macOS, NVDA on Windows) and navigate every critical flow.
7. Zoom to 200% and verify no content is lost or overlapping.
8. Reduce viewport to 320px and verify responsive behavior maintains readability.
9. Enable `prefers-reduced-motion` and verify animations respect the preference.
10. Switch to high-contrast mode and verify UI remains functional.

**Output:** Accessibility Audit Report (see Output Format section).

### Phase 2 — Semantic HTML

Ensure the document structure conveys meaning to assistive technologies.

**Heading hierarchy:**
- Exactly one `<h1>` per page.
- No skipped levels (e.g., `<h2>` followed by `<h4>`).
- Headings describe section content, not visual styling.

**Landmarks:**
- `<header>` for site header (with `role="banner"` if not the top-level `<header>`).
- `<nav>` for navigation blocks (use `aria-label` when multiple navs exist).
- `<main>` for primary content (exactly one per page).
- `<aside>` for complementary content.
- `<footer>` for site footer (with `role="contentinfo"` if not the top-level `<footer>`).
- `<section>` with `aria-labelledby` or `aria-label` for distinct content regions.

**Forms:**
- Every `<input>`, `<select>`, and `<textarea>` MUST have an associated `<label>` with a matching `for`/`id` pair.
- Group related fields with `<fieldset>` and `<legend>`.
- Mark required fields with `aria-required="true"` and visible indicators (not just color).
- Associate error messages with `aria-describedby` pointing to the error element.
- Use `aria-invalid="true"` on fields with validation errors.

**Images:**
- Meaningful images: descriptive `alt` text (convey the purpose, not "image of...").
- Decorative images: `alt=""` (empty string, not missing attribute).
- Complex images (charts, diagrams): provide `alt` plus a longer description via `aria-describedby` or a linked description.
- SVG icons: `role="img"` with `aria-label`, or `aria-hidden="true"` if decorative.

**Links:**
- Link text MUST describe the destination (no "click here" or "read more" without context).
- If link text is generic, add `aria-label` or `aria-labelledby` for full context.
- Links that open in new windows: indicate with `aria-label` including "(opens in new tab)" or visible icon with accessible name.

**Tables:**
- Use `<table>` for tabular data only, never for layout.
- Include `<caption>` describing the table content.
- Use `<th scope="col">` and `<th scope="row">` for header cells.
- Complex tables: use `headers` attribute to associate data cells with headers.

### Phase 3 — Interactive Patterns

Implement robust interaction patterns that work across input modalities.

**Keyboard navigation:**
- All interactive elements MUST be operable with keyboard alone.
- Logical tab order following visual layout (avoid `tabindex` values > 0).
- Custom keyboard shortcuts documented and non-conflicting with OS/AT shortcuts.
- Focus indicators: visible, high-contrast outlines (minimum 2px, 3:1 contrast against adjacent colors per WCAG 2.2 2.4.13).

**Focus management:**
- When content changes dynamically (SPA route change, modal open), move focus appropriately:
  - Route change: focus the `<h1>` or `<main>`.
  - Modal open: focus first focusable element inside the modal.
  - Modal close: return focus to the triggering element.
  - Inline error: focus the first invalid field or the error summary.
- Use `aria-live` regions for status updates that don't move focus (e.g., "Item added to cart").

**Focus trapping:**
- Modals/dialogs MUST trap focus: Tab wraps from last to first focusable element.
- Escape key MUST close the dialog and return focus to trigger.
- Content behind modal MUST be inert (`inert` attribute or `aria-hidden="true"` + `tabindex="-1"` on background).

**Skip links:**
- First focusable element on the page MUST be "Skip to main content".
- Link target is the `<main>` element or `id="main-content"`.
- Visible on focus (can be visually hidden until focused).

```html
<a href="#main-content" class="skip-link">Skip to main content</a>
<!-- ... header, nav ... -->
<main id="main-content" tabindex="-1">
  <!-- page content -->
</main>
```

```css
.skip-link {
  position: absolute;
  left: -9999px;
  top: auto;
  width: 1px;
  height: 1px;
  overflow: hidden;
}
.skip-link:focus {
  position: fixed;
  top: 0;
  left: 0;
  width: auto;
  height: auto;
  padding: 0.75rem 1.5rem;
  background: #000;
  color: #fff;
  z-index: 9999;
  font-size: 1rem;
  font-weight: 600;
  text-decoration: none;
  outline: 3px solid #4A90D9;
  outline-offset: 2px;
}
```

**Touch targets:**
- Minimum touch target size: 44x44 CSS pixels (WCAG 2.2 criterion 2.5.8).
- Spacing between adjacent targets: minimum 8px.
- Small inline links in text are exempt but should be supplemented with larger tap targets where possible.

**ARIA roles, states, and properties:**
- Use ARIA only when native HTML semantics are insufficient.
- Keep ARIA attributes synchronized with visual state (e.g., `aria-expanded`, `aria-selected`, `aria-checked`).
- Validate ARIA usage against the WAI-ARIA Authoring Practices.
- See `references/aria-patterns.md` for component-level implementation patterns.

### Phase 4 — Visual Accessibility

Ensure the visual presentation does not create barriers.

**Color contrast:**

| Text Type | Minimum Ratio | WCAG Criterion |
|-----------|--------------|----------------|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | 1.4.3 AA |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 1.4.3 AA |
| UI components & graphical objects | 3:1 | 1.4.11 AA |
| Focus indicators | 3:1 | 2.4.13 AA (2.2) |

- Verify contrast with tools: axe DevTools, Stark, WebAIM Contrast Checker.
- Test against both light and dark mode color schemes.
- NEVER rely on color alone to convey information — supplement with icons, text labels, or patterns.

**Typography & sizing:**
- Use `rem` or `em` for font sizes, never `px` for body text.
- Base font size: `1rem` (typically 16px) minimum for body text.
- Line height: minimum 1.5 for body text.
- Paragraph spacing: minimum 2x the font size.
- Letter spacing: adjustable (WCAG 1.4.12 — do not break layout when user overrides to 0.12em).

**Responsive & zoom:**
- Content MUST be readable and functional at 200% browser zoom.
- Content MUST reflow at 320px viewport width without horizontal scrolling (except tables, maps, diagrams).
- Do NOT set `user-scalable=no` or `maximum-scale=1` in the viewport meta tag.

```html
<!-- CORRECT -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- WRONG — disables zoom -->
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
```

**Motion & animation:**
- Respect `prefers-reduced-motion` media query.
- Disable or reduce all non-essential animations when the preference is set.
- Never use auto-playing carousels or videos without pause controls.
- Avoid flashing content (no more than 3 flashes per second — WCAG 2.3.1).

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

**Dark mode:**
- Provide a dark mode toggle (user preference) in addition to respecting `prefers-color-scheme`.
- Ensure all contrast ratios hold in both themes.
- Test with OS-level high-contrast mode (Windows High Contrast, macOS Increase Contrast).

### Phase 5 — Testing & Validation

Validate accessibility through layered automated and manual testing.

**Automated testing (CI pipeline):**

```typescript
// Example: axe-core integration with Playwright
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('homepage has no critical violations', async ({ page }) => {
    await page.goto('/');
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
      .analyze();

    expect(results.violations.filter(v =>
      v.impact === 'critical' || v.impact === 'serious'
    )).toEqual([]);
  });

  test('login flow is accessible', async ({ page }) => {
    await page.goto('/login');
    const results = await new AxeBuilder({ page })
      .include('#login-form')
      .analyze();

    expect(results.violations).toEqual([]);
  });
});
```

```typescript
// Example: Lighthouse CI accessibility threshold
// lighthouserc.js
module.exports = {
  ci: {
    assert: {
      assertions: {
        'categories:accessibility': ['error', { minScore: 0.95 }],
      },
    },
  },
};
```

**Manual testing (every release):**

See `references/testing-guide.md` for detailed screen reader testing procedures.

- **Screen reader testing:** Navigate all critical user flows with VoiceOver (macOS) and NVDA (Windows). Verify all content is announced, forms are labeled, errors are communicated, and dynamic content updates are conveyed.
- **Keyboard-only testing:** Complete all critical flows using only keyboard. Verify focus order, focus visibility, modal trapping, skip links, and keyboard shortcuts.
- **Zoom testing:** Browser zoom to 200%, verify layout integrity and content accessibility.
- **Viewport testing:** Resize to 320px width, verify reflow without horizontal scroll.
- **Motion testing:** Enable reduced motion preference, verify animations respect it.

**User testing (quarterly):**
- Recruit users who rely on assistive technology.
- Test critical flows: registration, core feature, checkout/submission.
- Document findings with severity and WCAG criterion.

---

## Rules (MUST)

These rules are non-negotiable. Violations are treated as bugs.

1. **MUST use semantic HTML before ARIA.** The first rule of ARIA is: do not use ARIA if you can use a native HTML element or attribute with the semantics and behavior you require. A `<button>` is always preferable to `<div role="button" tabindex="0">`.

2. **MUST provide visible focus indicators.** Every interactive element must have a visible focus indicator that meets 3:1 contrast ratio against adjacent colors. Use `outline` (not just `border` or `box-shadow` alone) with a minimum 2px width. Never use `outline: none` without providing an alternative visible indicator.

3. **MUST support keyboard navigation for all interactive elements.** If it can be clicked, it must be focusable and activatable with keyboard. This includes custom dropdowns, sliders, date pickers, drag-and-drop interfaces (provide keyboard alternative), and toggle switches.

4. **MUST provide alt text for all meaningful images.** Alt text should convey the purpose or content of the image, not describe it literally. For decorative images, use `alt=""` (empty string). Never omit the `alt` attribute entirely.

5. **MUST ensure 4.5:1 contrast ratio for normal text.** Large text (18pt+ regular or 14pt+ bold) requires 3:1. UI components and graphical objects require 3:1. Verify in both light and dark modes.

6. **MUST NOT use color alone to convey information.** Always supplement color with text labels, icons, patterns, or other visual indicators. Error states need more than a red border — add an icon and error message text.

7. **MUST NOT disable zoom or set maximum-scale.** The viewport meta tag must not include `user-scalable=no` or `maximum-scale` less than 5. Users with low vision rely on zoom.

8. **MUST test with actual screen reader.** Automated tools catch approximately 30-40% of accessibility issues. Manual screen reader testing is required for every major feature and release.

9. **MUST include skip-to-content link.** The first focusable element on every page must be a skip link targeting the main content area. It can be visually hidden until focused.

10. **MUST handle focus trapping in modals/dialogs.** When a modal opens, focus moves into it and Tab cycles within it. Escape closes it and returns focus to the trigger element. Background content must be inert.

---

## Anti-patterns

These are common mistakes that create accessibility barriers. Flag and remediate whenever encountered.

### 1. `<div>` as interactive element instead of native HTML

```html
<!-- WRONG -->
<div class="btn" onclick="submit()" role="button" tabindex="0">Submit</div>

<!-- CORRECT -->
<button type="submit" class="btn">Submit</button>
```

**Why it fails:** The `<div>` version requires manual keyboard handling (Enter + Space), ARIA role, tabindex, and often has incomplete event handling. The `<button>` gets all of this for free.

### 2. Redundant `aria-label` duplicating visible text

```html
<!-- WRONG — screen reader announces "Submit Submit" -->
<button aria-label="Submit">Submit</button>

<!-- CORRECT — visible text is the accessible name -->
<button>Submit</button>

<!-- CORRECT — when accessible name differs from visible text -->
<button aria-label="Submit order and proceed to payment">Submit</button>
```

### 3. Positive `tabindex` values

```html
<!-- WRONG — disrupts natural tab order, impossible to maintain -->
<input tabindex="1" />
<input tabindex="3" />
<input tabindex="2" />

<!-- CORRECT — use DOM order to control tab sequence -->
<input /> <!-- tabindex 0 is implicit for form elements -->
<input />
<input />

<!-- CORRECT — programmatic focus only, not in tab order -->
<div tabindex="-1" id="error-summary">...</div>
```

### 4. Using `display: none` for screen-reader-accessible content

```css
/* WRONG — hides from everyone including screen readers */
.sr-only { display: none; }

/* CORRECT — visually hidden but accessible to screen readers */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

### 5. Auto-playing media without controls

```html
<!-- WRONG -->
<video autoplay src="hero.mp4"></video>

<!-- CORRECT -->
<video controls src="hero.mp4">
  <track kind="captions" src="hero-captions.vtt" srclang="en" label="English">
</video>
```

### 6. Placeholder as the only label

```html
<!-- WRONG — placeholder disappears on input, not reliably announced -->
<input type="email" placeholder="Enter your email">

<!-- CORRECT — persistent label + optional placeholder -->
<label for="email">Email address</label>
<input type="email" id="email" placeholder="you@example.com">
```

### 7. Infinite scroll without keyboard alternative

```html
<!-- WRONG — keyboard users get trapped in infinite content -->
<div class="feed" onscroll="loadMore()">...</div>

<!-- CORRECT — provide explicit load-more button + pagination option -->
<div class="feed" role="feed" aria-busy="false">
  <!-- content items with role="article" -->
</div>
<button onclick="loadMore()">Load more results</button>
<nav aria-label="Pagination">
  <a href="?page=2">Page 2</a>
  <a href="?page=3">Page 3</a>
</nav>
```

---

## Common ARIA Patterns

For detailed implementation with full code examples, see `references/aria-patterns.md`. Below is a summary of the 10 patterns covered:

| Pattern | Key ARIA | Keyboard | Notes |
|---------|----------|----------|-------|
| **Dialog/Modal** | `role="dialog"`, `aria-modal="true"`, `aria-labelledby` | Escape closes, Tab trapped | Focus first focusable, return focus on close |
| **Tabs** | `role="tablist/tab/tabpanel"`, `aria-selected`, `aria-controls` | Arrow keys switch tabs, Tab moves to panel | Only active tab in tab order |
| **Accordion** | `<button>` triggers, `aria-expanded`, `aria-controls` | Enter/Space toggle, optional arrow keys | All headers always focusable |
| **Combobox** | `role="combobox"`, `aria-expanded`, `aria-activedescendant` | Arrow keys navigate options, Escape closes | Announce result count with live region |
| **Menu** | `role="menu/menuitem"`, `aria-haspopup` | Arrow keys navigate, Enter activates, Escape closes | Only trigger in tab order |
| **Toast/Alert** | `role="alert"` or `role="status"`, `aria-live` | Auto-dismissed toasts must be accessible | Use `aria-live="assertive"` for errors, `"polite"` for info |
| **Carousel** | `role="region"`, `aria-roledescription="carousel"`, `aria-label` | Arrow keys or buttons, pause auto-rotation | Must have pause control, announce slide changes |
| **Tree View** | `role="tree/treeitem"`, `aria-expanded`, `aria-level` | Arrow keys navigate/expand/collapse | Home/End jump to first/last |
| **Toggle/Switch** | `role="switch"` or `<input type="checkbox">`, `aria-checked` | Space toggles | Announce state change |
| **Disclosure** | `<button>` + `aria-expanded`, `aria-controls` | Enter/Space toggle | Simpler than accordion — single section |

---

## Testing Checklist

Use this checklist for every feature before marking it complete.

### Keyboard

- [ ] Tab through all interactive elements in logical order
- [ ] Shift+Tab navigates backward correctly
- [ ] Enter/Space activates buttons and links
- [ ] Escape closes modals, dropdowns, and popups
- [ ] Arrow keys work correctly in menus, tabs, and tree views
- [ ] No keyboard traps (can always Tab out except in modals)
- [ ] Skip link present and functional
- [ ] Focus indicator visible on every focused element

### Screen Reader

- [ ] All content is announced correctly and in logical order
- [ ] All images have appropriate alt text
- [ ] All form inputs have accessible labels
- [ ] Form errors are announced when they occur
- [ ] Dynamic content updates are announced via live regions
- [ ] Headings hierarchy is correct and navigable
- [ ] Landmarks are present and labeled
- [ ] Tables have proper headers and captions
- [ ] Links and buttons have descriptive accessible names

### Visual

- [ ] Normal text passes 4.5:1 contrast ratio
- [ ] Large text passes 3:1 contrast ratio
- [ ] UI components pass 3:1 contrast ratio
- [ ] Content readable at 200% browser zoom
- [ ] No content lost at 320px viewport width
- [ ] No horizontal scrolling at 320px (except data tables, maps)
- [ ] Focus indicators have 3:1 contrast against adjacent colors
- [ ] Information not conveyed by color alone

### Motion

- [ ] `prefers-reduced-motion` preference is respected
- [ ] No content flashes more than 3 times per second
- [ ] Auto-playing media has visible pause/stop controls
- [ ] Carousels can be paused and manually controlled

### Touch (Mobile)

- [ ] All touch targets are at least 44x44 CSS pixels
- [ ] Adequate spacing (8px+) between adjacent targets
- [ ] Gestures have single-pointer alternatives
- [ ] No functionality requires specific device motion (shake, tilt)

---

## Output Format

When conducting an accessibility audit, produce a structured report in this format:

```markdown
# Accessibility Audit Report

**Project:** [Project Name]
**Date:** [Date]
**Auditor:** accessibility skill
**Standard:** WCAG 2.2 AA
**Tools:** axe-core, Lighthouse, VoiceOver, manual keyboard testing

## Summary

| Severity | Count |
|----------|-------|
| Critical | X |
| Major    | X |
| Minor    | X |
| **Total** | **X** |

**Lighthouse Accessibility Score:** XX/100

## Findings

### Critical

#### [C1] Missing form labels
- **WCAG Criterion:** 1.3.1 Info and Relationships (A)
- **Element:** `<input type="email">` on /login page
- **Issue:** Input has no associated `<label>`, `aria-label`, or `aria-labelledby`
- **Impact:** Screen reader users cannot identify the purpose of the field
- **Fix:**
  ```html
  <label for="login-email">Email address</label>
  <input type="email" id="login-email" autocomplete="email">
  ```

### Major

#### [M1] Insufficient color contrast
- **WCAG Criterion:** 1.4.3 Contrast (Minimum) (AA)
- **Element:** `.text-gray-400` on white background
- **Issue:** Contrast ratio is 2.8:1 (requires 4.5:1)
- **Impact:** Users with low vision cannot read the text
- **Fix:** Change to `.text-gray-600` or darker (contrast ratio 5.7:1)

### Minor

#### [m1] Missing skip link
- **WCAG Criterion:** 2.4.1 Bypass Blocks (A)
- **Element:** Page-level navigation
- **Issue:** No skip-to-content link present
- **Impact:** Keyboard users must tab through all navigation on every page
- **Fix:** Add skip link as first focusable element (see skip link pattern above)

## Remediation Priority

1. [C1] Form labels — immediate (blocks form usage)
2. [M1] Color contrast — within sprint (affects readability)
3. [m1] Skip link — next sprint (improves efficiency)
```

---

## Integration with Other Skills

| Skill | Integration Point |
|-------|-------------------|
| `frontend-design` | Apply accessibility rules during component design; use accessible color palettes |
| `e2e-testing-patterns` | Add axe-core checks to Playwright/Cypress E2E test suites |
| `test-master` | Include accessibility in test strategy; add a11y tests to CI pipeline |
| `code-reviewer` | Flag accessibility violations during code review (Critical severity) |
| `shadcnblocks-components` | Verify shadcn/ui component usage follows ARIA patterns |
| `nextjs-developer` | Ensure Next.js metadata, Image alt text, Link components are accessible |
| `react-best-practices` | Apply accessible React patterns: useId for form associations, forwardRef for focus management |

---

## Resources

- [WCAG 2.2 Specification](https://www.w3.org/TR/WCAG22/)
- [WAI-ARIA Authoring Practices 1.2](https://www.w3.org/WAI/ARIA/apg/)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md)
- [Inclusive Components](https://inclusive-components.design/)
- [A11Y Project Checklist](https://www.a11yproject.com/checklist/)
