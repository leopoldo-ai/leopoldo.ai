---
name: accessibility
description: "Use when working on WCAG 2.2 compliance, ARIA patterns, keyboard navigation, screen reader testing, color contrast, or inclusive design."
type: technique
---

# Accessibility — WCAG 2.2 AA Compliance

## Role

Accessibility expert ensuring WCAG 2.2 AA compliance. Audits interfaces, remediates violations, implements inclusive design patterns, validates with automated tools and assistive technologies. **Accessible-by-default** is always preferable to retrofitted accessibility.

## Workflow

| Phase | Actions |
|-------|---------|
| 1. Audit | Automated: axe-core (all pages), Lighthouse (target 95+), eslint-plugin-jsx-a11y. Manual: keyboard tab-through, screen reader (VoiceOver/NVDA), zoom 200%, 320px viewport, prefers-reduced-motion, high-contrast mode. |
| 2. Semantic HTML | One `<h1>` per page, no skipped levels. Landmarks: `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>`. Every input has `<label>`. Images: descriptive `alt` or `alt=""` for decorative. Links describe destination. Tables: `<caption>`, `<th scope>`. |
| 3. Interactive Patterns | All interactive elements keyboard-operable. Logical tab order (no tabindex > 0). Visible focus indicators (2px min, 3:1 contrast). Focus management: move focus on route change/modal open, return on close. Focus trapping in modals. Skip-to-content link. Touch targets 44x44px min. |
| 4. Visual | Meet contrast ratios (see table below). Use rem/em for fonts. Line-height 1.5+ for body. Content readable at 200% zoom and 320px width. Respect prefers-reduced-motion. Never disable zoom. |
| 5. Testing | CI: axe-core + Playwright, Lighthouse threshold. Manual: screen reader, keyboard-only, zoom, viewport, motion. Quarterly: user testing with AT users. |

## Color Contrast Requirements

| Text Type | Min Ratio | WCAG |
|-----------|:---------:|------|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | 1.4.3 AA |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 1.4.3 AA |
| UI components & graphical objects | 3:1 | 1.4.11 AA |
| Focus indicators | 3:1 | 2.4.13 AA |

## Rules (Non-Negotiable)

1. **Semantic HTML before ARIA.** A `<button>` is always preferable to `<div role="button" tabindex="0">`.
2. **Visible focus indicators** on every interactive element. Minimum 2px outline, 3:1 contrast. Never `outline: none` without alternative.
3. **Keyboard navigation** for all interactive elements. If clickable, must be focusable and keyboard-activatable.
4. **Alt text** for all meaningful images. `alt=""` for decorative. Never omit `alt` attribute.
5. **4.5:1 contrast** for normal text, 3:1 for large text. Verify both light and dark modes.
6. **Never color alone** to convey information. Supplement with icons, text, or patterns.
7. **Never disable zoom** (`user-scalable=no` or `maximum-scale < 5`).
8. **Screen reader testing** required for every major feature. Automated catches only 30-40%.
9. **Skip-to-content link** as first focusable element on every page.
10. **Focus trapping in modals.** Tab cycles within, Escape closes, focus returns to trigger.

## Common ARIA Patterns

| Pattern | Key ARIA | Keyboard |
|---------|----------|----------|
| Dialog/Modal | `role="dialog"`, `aria-modal="true"`, `aria-labelledby` | Escape closes, Tab trapped |
| Tabs | `role="tablist/tab/tabpanel"`, `aria-selected` | Arrow keys switch, Tab to panel |
| Accordion | `<button>`, `aria-expanded`, `aria-controls` | Enter/Space toggle |
| Combobox | `role="combobox"`, `aria-expanded`, `aria-activedescendant` | Arrows navigate, Escape closes |
| Menu | `role="menu/menuitem"`, `aria-haspopup` | Arrows navigate, Enter activates |
| Toast/Alert | `role="alert"` or `role="status"` | `aria-live="assertive"` for errors, `"polite"` for info |
| Toggle/Switch | `role="switch"`, `aria-checked` | Space toggles |

## Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| `<div>` as button with onclick | Use native `<button>` |
| `aria-label` duplicating visible text | Remove redundant aria-label |
| `tabindex` values > 0 | Use DOM order for tab sequence |
| `display: none` for SR-only content | Use `.sr-only` class (position: absolute, clip, 1px) |
| Auto-playing media without controls | Add `controls`, `<track>` for captions |
| Placeholder as only label | Use `<label>` + optional placeholder |
| Infinite scroll without keyboard alternative | Add "Load more" button + pagination |

## Testing Checklist

**Keyboard:** Tab order logical, Shift+Tab backward, Enter/Space activates, Escape closes popups, no traps (except modals), skip link works, focus visible.

**Screen Reader:** Content announced correctly, images have alt, inputs labeled, errors announced, dynamic updates via live regions, headings navigable, landmarks present.

**Visual:** Normal text 4.5:1, large text 3:1, UI components 3:1, readable at 200% zoom, no horizontal scroll at 320px, focus indicators 3:1, no color-only information.

**Motion:** prefers-reduced-motion respected, no flashing > 3/sec, auto-play has pause controls.

**Touch:** Targets 44x44px min, 8px+ spacing, gestures have single-pointer alternatives.
