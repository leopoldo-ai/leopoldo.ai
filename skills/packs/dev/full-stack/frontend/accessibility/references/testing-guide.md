# Screen Reader Testing Guide

Step-by-step procedures for testing web applications with screen readers. Covers VoiceOver (macOS) and NVDA (Windows), the two most commonly available screen readers for development testing.

---

## Table of Contents

1. [Why Manual Screen Reader Testing](#why-manual-screen-reader-testing)
2. [General Principles](#general-principles)
3. [VoiceOver (macOS) — Complete Guide](#voiceover-macos--complete-guide)
4. [NVDA (Windows) — Complete Guide](#nvda-windows--complete-guide)
5. [Testing Flows](#testing-flows)
6. [Common Issues and How to Identify Them](#common-issues-and-how-to-identify-them)
7. [Reporting Findings](#reporting-findings)
8. [Keyboard-Only Testing Guide](#keyboard-only-testing-guide)
9. [Automated Testing Setup](#automated-testing-setup)

---

## Why Manual Screen Reader Testing

Automated tools (axe-core, Lighthouse) detect approximately 30-40% of accessibility issues. They can catch:
- Missing alt text
- Missing form labels
- Insufficient color contrast
- Missing landmarks
- Duplicate IDs

They cannot catch:
- Whether alt text is meaningful (not just "image")
- Whether focus order is logical
- Whether dynamic content updates are announced appropriately
- Whether custom widgets are operable with a screen reader
- Whether ARIA attributes produce a coherent reading experience
- Whether error messages are communicated effectively
- Whether the page makes sense when read linearly

Manual screen reader testing fills these gaps and is required for WCAG 2.2 AA compliance verification.

---

## General Principles

1. **Test with the browser the screen reader is designed for:**
   - VoiceOver: Safari (macOS)
   - NVDA: Firefox or Chrome (Windows)
   - JAWS: Chrome or Edge (Windows)

2. **Use both browse mode and focus mode:**
   - Browse mode (virtual cursor): read through content sequentially
   - Focus mode (forms mode): interact with form controls and widgets

3. **Test critical user flows, not just individual pages.** Navigate the complete path a user would take.

4. **Listen, do not just watch.** Turn off your monitor or close your eyes for portions of the test to experience the audio-only flow.

5. **Document everything.** Record the screen reader output for each step so you can pinpoint exactly where issues occur.

---

## VoiceOver (macOS) — Complete Guide

### Setup

1. **Enable VoiceOver:** Press `Cmd + F5` (or touch the Touch ID button three times if configured).
2. **Open VoiceOver Utility:** Press `VO + F8` (where VO = Control + Option) to configure settings.
3. **Recommended settings:**
   - Verbosity > Default: Set to "High" for detailed testing
   - Web > Web navigation: "DOM order"
   - Web > Automatically speak web page: Enable for full-page testing
4. **Use Safari** for the most accurate testing (VoiceOver is optimized for Safari).

### Essential Commands

The VoiceOver modifier key (VO) is **Control + Option** by default.

#### Navigation

| Command | Action |
|---------|--------|
| `VO + Right Arrow` | Move to next element |
| `VO + Left Arrow` | Move to previous element |
| `VO + Space` | Activate/click the current element |
| `VO + Shift + Down Arrow` | Enter a group (interact with a complex element) |
| `VO + Shift + Up Arrow` | Exit a group |
| `Tab` | Move to next focusable element |
| `Shift + Tab` | Move to previous focusable element |
| `VO + A` | Read from current position |
| `Control` | Stop speaking |

#### Quick Navigation (Single Key)

Enable Quick Nav with `Left Arrow + Right Arrow` simultaneously. Then use single keys:

| Key | Jump to |
|-----|---------|
| `H` | Next heading |
| `Shift + H` | Previous heading |
| `1-6` | Next heading of level 1-6 |
| `L` | Next link |
| `F` | Next form control |
| `T` | Next table |
| `W` | Next ARIA landmark |
| `X` | Next list |
| `B` | Next button |

#### Rotor

The Rotor (`VO + U`) provides structured navigation:

| Rotor Category | Purpose |
|----------------|---------|
| Headings | View heading hierarchy and navigate |
| Links | List all links on page |
| Form Controls | List all form elements |
| Landmarks | List all ARIA landmarks |
| Tables | List and navigate tables |
| Web Spots | Automatically detected regions |

Use Left/Right Arrows to switch categories, Up/Down to navigate within a category, Enter to go to the selected item.

### Testing Procedure

#### Step 1: Page Load

1. Navigate to the page in Safari.
2. Enable VoiceOver (`Cmd + F5`).
3. Listen to what VoiceOver announces on page load:
   - Does it announce the page title?
   - Does it announce the number of landmarks, headings, links?
4. **Expected:** Page title is announced, landmarks are present.

#### Step 2: Heading Structure

1. Open the Rotor (`VO + U`), select "Headings".
2. Review the heading list:
   - Is there exactly one `<h1>`?
   - Are headings in logical order (no skipped levels)?
   - Do heading texts describe their sections?
3. Navigate through headings with `H` key (Quick Nav enabled).
4. **Expected:** Clean hierarchy, descriptive heading text.

#### Step 3: Landmarks

1. Open the Rotor, select "Landmarks".
2. Verify the following landmarks exist:
   - banner (header)
   - navigation (nav)
   - main (main content)
   - contentinfo (footer)
3. Navigate between landmarks with `W` key.
4. **Expected:** All major page regions are landmarked and labeled.

#### Step 4: Skip Link

1. Press `Tab` immediately after page load.
2. First focused element should be "Skip to main content" (or similar).
3. Press `Enter` on the skip link.
4. **Expected:** Focus moves to main content area. VoiceOver announces the main content region.

#### Step 5: Navigation Menu

1. Tab to the navigation.
2. Navigate through all menu items.
3. If there are dropdowns, verify:
   - `aria-expanded` state is announced
   - Submenu items are reachable with Arrow keys
   - Escape closes the dropdown
4. **Expected:** All nav items announced with role and state.

#### Step 6: Forms

1. Tab to the first form field.
2. For each field, verify VoiceOver announces:
   - The label text
   - The input type (text field, dropdown, checkbox, etc.)
   - Required status (if applicable)
   - Associated help text (if any)
3. Submit the form with errors intentionally.
4. Verify error messages:
   - Are they announced?
   - Can you navigate to the error summary?
   - Is each error linked to its field?
5. **Expected:** Full label, type, and state announced for every field. Errors clearly communicated.

#### Step 7: Images

1. Navigate through images with Quick Nav or Rotor.
2. For each image:
   - Meaningful images: alt text describes the purpose
   - Decorative images: should not be announced (empty alt)
   - Complex images: description is available
3. **Expected:** Meaningful alt text, decorative images silent.

#### Step 8: Dynamic Content

1. Trigger dynamic updates (add to cart, form validation, notifications).
2. Listen for live region announcements.
3. Verify:
   - Success messages announced politely
   - Error messages announced assertively
   - Content updates do not steal focus unexpectedly
4. **Expected:** Dynamic updates announced without disrupting workflow.

#### Step 9: Custom Widgets

1. Navigate to tabs, accordions, modals, carousels, menus.
2. For each widget, verify:
   - Role is announced (e.g., "tab", "dialog", "menu")
   - State is announced (e.g., "expanded", "selected", "1 of 5")
   - Keyboard interaction matches expected pattern (see ARIA Patterns reference)
3. **Expected:** Full role, state, and keyboard support per ARIA Authoring Practices.

#### Step 10: Tables

1. Navigate to data tables.
2. Enter the table (`VO + Shift + Down Arrow`).
3. Navigate with `VO + Arrow keys` through cells.
4. Verify:
   - Table has a caption or label
   - Column/row headers are announced when navigating data cells
5. **Expected:** Headers associated with data cells, table purpose clear.

### Disabling VoiceOver

Press `Cmd + F5` to toggle VoiceOver off.

---

## NVDA (Windows) — Complete Guide

### Setup

1. **Download NVDA** from [nvaccess.org](https://www.nvaccess.org/download/) (free, open source).
2. **Install or run portable version.**
3. **Recommended settings** (NVDA Menu > Preferences > Settings):
   - Browse Mode > Automatic focus mode for focus changes: Enable
   - Browse Mode > Automatic focus mode for caret movement: Enable
   - Document Formatting: Enable all relevant options
4. **Use Firefox** for the most comprehensive NVDA support.

### Essential Commands

The NVDA modifier key is **Insert** (or **Caps Lock** if configured).

#### Navigation (Browse Mode)

| Command | Action |
|---------|--------|
| `Down Arrow` | Next line |
| `Up Arrow` | Previous line |
| `Enter` | Activate link/button |
| `Space` | Activate button / toggle checkbox |
| `Tab` | Next focusable element |
| `Shift + Tab` | Previous focusable element |
| `NVDA + Down Arrow` | Read from current position |
| `Control` | Stop speaking |
| `NVDA + Space` | Toggle between browse and focus mode |

#### Quick Navigation (Single Key — Browse Mode)

| Key | Jump to |
|-----|---------|
| `H` | Next heading |
| `Shift + H` | Previous heading |
| `1-6` | Next heading of level 1-6 |
| `K` | Next link |
| `F` | Next form field |
| `T` | Next table |
| `D` | Next landmark |
| `L` | Next list |
| `B` | Next button |
| `G` | Next graphic (image) |
| `I` | Next list item |
| `E` | Next edit field |

#### Elements List

Press `NVDA + F7` to open the Elements List — equivalent to VoiceOver's Rotor:

| Category | Shows |
|----------|-------|
| Links | All links on the page |
| Headings | Heading hierarchy |
| Form Fields | All form controls |
| Buttons | All buttons |
| Landmarks | ARIA landmarks |

Use Tab to switch between types, arrow keys to navigate, Enter to go to element.

### Testing Procedure

#### Step 1: Page Load

1. Open the page in Firefox.
2. Start NVDA (if not already running).
3. NVDA will begin reading the page. Press `Control` to stop.
4. Listen for:
   - Page title announcement
   - Number of landmarks, headings, form fields
5. **Expected:** Meaningful page title, landmarks detected.

#### Step 2: Heading Structure

1. Press `NVDA + F7`, select "Headings" tab.
2. Review the heading tree:
   - Single `<h1>`?
   - No skipped levels?
   - Descriptive text?
3. Press `H` repeatedly to step through headings.
4. At each heading, press `Down Arrow` to read the content below it.
5. **Expected:** Clean heading structure, descriptive labels.

#### Step 3: Landmarks

1. Press `D` to navigate between landmarks.
2. NVDA announces the landmark type and label (e.g., "banner landmark", "navigation, Main menu").
3. Verify all expected landmarks are present.
4. **Expected:** banner, navigation, main, contentinfo at minimum.

#### Step 4: Skip Link

1. Press `Tab` from the top of the page.
2. First focus: "Skip to main content" or similar.
3. Press `Enter`.
4. **Expected:** Focus moves to main content. NVDA begins reading main content.

#### Step 5: Forms

1. Press `F` to jump to the first form field.
2. NVDA enters focus mode automatically.
3. For each field, verify announcement includes:
   - Label text
   - Field type (edit, dropdown, checkbox, radio button)
   - Required state
   - Current value (if pre-filled)
   - Description/help text
4. Deliberately trigger validation errors.
5. Verify:
   - Error messages are read (via `aria-describedby` or `role="alert"`)
   - `aria-invalid="true"` causes "invalid entry" announcement
   - Error summary at top of form is navigable
6. **Expected:** Complete form context for every field, errors clearly announced.

#### Step 6: Browse Mode vs. Focus Mode

1. While on a form field, press `NVDA + Space` to toggle between modes.
2. In browse mode: arrow keys read through content linearly.
3. In focus mode: arrow keys interact with the control (e.g., select dropdown options).
4. Verify that custom widgets work correctly in both modes:
   - Tabs: browse mode should read tab names; focus mode should allow arrow key switching.
   - Combobox: focus mode should allow typing and arrow key navigation of suggestions.
5. **Expected:** Correct mode switching, all widgets operable.

#### Step 7: Live Regions

1. Trigger dynamic content updates (notifications, loading states, cart updates).
2. Listen for NVDA announcements.
3. Verify:
   - `role="alert"` content interrupts and is read immediately.
   - `role="status"` / `aria-live="polite"` content is read at the next pause.
   - Content is not announced multiple times.
4. **Expected:** Appropriate live region behavior for each notification type.

#### Step 8: Images

1. Press `G` to navigate through images.
2. Verify:
   - Meaningful images: descriptive alt text read.
   - Decorative images: skipped (or "graphic" with no additional info).
   - Linked images: link destination + alt text both communicated.
3. **Expected:** All images appropriately described or hidden.

#### Step 9: Tables

1. Press `T` to jump to a table.
2. NVDA announces rows/columns count.
3. Navigate with `Control + Alt + Arrow keys`:
   - `Ctrl + Alt + Right Arrow`: Next column
   - `Ctrl + Alt + Left Arrow`: Previous column
   - `Ctrl + Alt + Down Arrow`: Next row
   - `Ctrl + Alt + Up Arrow`: Previous row
4. Verify:
   - Column headers are announced when moving between cells in a row.
   - Row headers are announced when moving between rows.
   - Caption or table label is announced when entering the table.
5. **Expected:** Full header-cell association, table has accessible name.

#### Step 10: Custom Widgets

1. Navigate to each custom widget (tabs, accordion, modal, tree, combobox).
2. For each, verify:
   - Role announcement (e.g., "tab control", "dialog", "tree view").
   - State announcement (e.g., "expanded", "collapsed", "selected", "1 of 4").
   - Keyboard behavior matches expectations (arrow keys, Enter, Escape, Space).
   - After state changes, new state is announced.
3. **Expected:** Full ARIA pattern compliance.

---

## Testing Flows

For each project, test these critical flows end-to-end with a screen reader:

### Flow 1: First-Time Visit

1. Land on homepage.
2. Understand what the site does (from headings, main content).
3. Navigate to a key section.
4. Return to homepage.

**Verify:** Site purpose is clear, navigation is intuitive, no dead ends.

### Flow 2: Registration / Sign-Up

1. Find the registration link.
2. Navigate to the registration form.
3. Fill in all fields (verify labels, required indicators).
4. Submit with intentional errors (verify error handling).
5. Complete registration successfully.

**Verify:** Every field labeled, errors communicated, success confirmed.

### Flow 3: Core Feature Usage

1. Navigate to the primary feature (e.g., search, create, browse catalog).
2. Complete the core task (e.g., search for an item, create a document).
3. Interact with results (e.g., filter, sort, paginate).
4. Perform an action on a result (e.g., add to cart, open details).

**Verify:** Core feature fully operable, results navigable, actions confirmed.

### Flow 4: Settings / Profile

1. Navigate to account settings.
2. Update a setting (e.g., notification preferences, profile info).
3. Save changes.
4. Verify confirmation.

**Verify:** All settings controls operable, changes confirmed.

### Flow 5: Error States

1. Trigger a 404 page.
2. Trigger a server error (500).
3. Trigger form validation errors.
4. Trigger network timeout (offline state).

**Verify:** Error messages communicated, recovery path available.

---

## Common Issues and How to Identify Them

### Issue: Unlabeled form fields

**How it manifests:** Screen reader says "edit" or "text field" without any label.

**How to find it:** Tab through all form fields. If you hear only the field type with no descriptive label, the field is unlabeled.

**Root causes:**
- Missing `<label>` element
- `<label>` without `for` attribute matching `input` `id`
- Placeholder used as only label (disappears and not reliably announced)
- `aria-label` or `aria-labelledby` missing or pointing to nonexistent element

### Issue: Missing or meaningless alt text

**How it manifests:** Screen reader says "graphic" (no alt), or "image.png" (filename as alt), or "image" (generic alt).

**How to find it:** Navigate to images with `G` (NVDA) or Rotor > Images (VoiceOver). Listen to what is announced.

**Root causes:**
- `alt` attribute missing entirely
- `alt` is the filename
- `alt` is generic ("image", "photo", "icon")
- `alt` describes appearance instead of purpose

### Issue: Keyboard trap

**How it manifests:** User tabs into a widget and cannot tab out of it.

**How to find it:** Tab through the entire page. If focus gets stuck in a component and neither Tab nor Escape allows you to leave, it is a keyboard trap.

**Root causes:**
- Custom widget captures all keyboard events
- Modal does not have Escape handler
- Focus management code does not account for Tab beyond the last element
- Embedded content (iframe, video player) traps focus

### Issue: Missing focus indicator

**How it manifests:** You tab to an element but cannot visually see where focus is.

**How to find it:** Tab through the page while watching the screen. If focus is not visible on an element, the indicator is missing or invisible.

**Root causes:**
- `outline: none` without alternative styling
- Focus style has insufficient contrast
- Focus style only changes color (not visible to color-blind users)
- Custom component does not forward focus styles

### Issue: Dynamic content not announced

**How it manifests:** A notification appears visually but the screen reader says nothing.

**How to find it:** Trigger actions that produce notifications, status messages, or content updates. If the screen reader remains silent, the live region is missing or misconfigured.

**Root causes:**
- No `aria-live` attribute on the container
- Container not in the DOM before content is injected
- `aria-live` on the dynamic content itself instead of a persistent container
- `aria-live="off"` set permanently

### Issue: Incorrect heading hierarchy

**How it manifests:** The heading list in the elements list / rotor shows gaps or illogical ordering.

**How to find it:** Open the heading list (NVDA: `NVDA + F7` > Headings; VoiceOver: `VO + U` > Headings). Check the levels.

**Root causes:**
- Using heading tags for visual styling rather than document structure
- Skipping heading levels (e.g., h2 to h4)
- Multiple `<h1>` elements on one page
- No `<h1>` at all

### Issue: Custom widget missing ARIA

**How it manifests:** Screen reader announces a widget as "group" or "clickable" instead of its intended role (tab, dialog, tree, etc.).

**How to find it:** Navigate to the widget. Listen to the role announcement. If it does not match the expected ARIA role, attributes are missing.

**Root causes:**
- Missing `role` attribute
- Missing state attributes (`aria-expanded`, `aria-selected`, `aria-checked`)
- ARIA attributes not updated when state changes
- Using div/span without any ARIA for interactive components

---

## Reporting Findings

When documenting screen reader testing results, use this template for each issue:

```markdown
### [Issue ID] — [Brief Description]

**Severity:** Critical | Major | Minor
**WCAG Criterion:** [Number] [Name] (Level)
**Screen Reader:** VoiceOver / NVDA / Both
**Browser:** Safari / Firefox / Chrome
**Page/Flow:** [Where the issue occurs]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What the screen reader should announce or how the user should be able to interact]

**Actual Behavior:**
[What actually happens — include exact screen reader output if possible]

**Recommended Fix:**
[Specific code change or ARIA attribute to add/modify]

**Code Reference:**
[File path and line number, or component name]
```

### Severity Definitions

| Severity | Definition | Example |
|----------|-----------|---------|
| **Critical** | Content or functionality completely inaccessible | Form cannot be submitted, modal cannot be closed, entire section unreadable |
| **Major** | Significant barrier, workaround may exist | Form field unlabeled but next field gives context, tab order confusing but all elements reachable |
| **Minor** | Inconvenience or suboptimal experience | Heading hierarchy has a gap, live region announcement is slightly late, decorative image announced |

---

## Keyboard-Only Testing Guide

Keyboard testing is a separate but complementary activity to screen reader testing. Many sighted keyboard-only users (motor disabilities, power users) rely on keyboard navigation without a screen reader.

### Setup

1. **Disconnect or ignore your mouse/trackpad.**
2. **Open the page in your browser.**
3. **Begin testing from the browser address bar** — press Tab to enter the page.

### Checklist

| # | Check | How to Verify | Pass Criteria |
|---|-------|---------------|---------------|
| 1 | Skip link | First Tab stop from top | Skip link appears, activates correctly |
| 2 | Tab order | Tab through entire page | Logical order matching visual layout |
| 3 | Focus visibility | Tab through entire page | Every element shows visible focus indicator |
| 4 | Interactive elements | Tab to buttons, links, inputs | All are focusable and activatable |
| 5 | Custom controls | Tab to dropdowns, sliders, tabs | Operable with keyboard alone |
| 6 | Modals | Open a modal | Focus moves into modal, trapped inside, Escape closes |
| 7 | Dropdown menus | Open a dropdown | Arrow keys navigate, Escape closes, focus returns |
| 8 | No traps | Tab through entire page | Can always exit any component |
| 9 | Reverse order | Shift+Tab through page | Reverse order is logical |
| 10 | Enter/Space | Activate buttons and links | All activate correctly |
| 11 | Arrow keys | Navigate within widgets | Tabs, menus, trees respond to arrows |
| 12 | Escape | Close overlays | All modals, dropdowns, tooltips close |

### Common Keyboard Issues

1. **Custom buttons not focusable:** `<div>` or `<span>` used as button without `tabindex="0"`.
2. **Links without href:** `<a>` without `href` is not focusable by default.
3. **Click-only handlers:** `onClick` without `onKeyDown` for Enter/Space.
4. **Scroll containers not focusable:** Content inside scrollable div unreachable by keyboard.
5. **Tooltips on hover only:** No keyboard equivalent for hover-triggered content.

---

## Automated Testing Setup

Automated tests catch regressions and ensure a baseline of accessibility. They complement but do not replace manual testing.

### axe-core with Playwright

```typescript
// tests/accessibility.spec.ts
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

const routes = [
  { name: 'Homepage', path: '/' },
  { name: 'Login', path: '/login' },
  { name: 'Dashboard', path: '/dashboard' },
  { name: 'Settings', path: '/settings' },
  { name: 'Profile', path: '/profile' },
];

for (const route of routes) {
  test(`${route.name} (${route.path}) has no accessibility violations`, async ({ page }) => {
    await page.goto(route.path);

    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
      .exclude('.third-party-widget') // Exclude elements you cannot control
      .analyze();

    // Log violations for debugging
    if (results.violations.length > 0) {
      console.log(`Accessibility violations on ${route.path}:`);
      results.violations.forEach((v) => {
        console.log(`  [${v.impact}] ${v.id}: ${v.description}`);
        v.nodes.forEach((n) => {
          console.log(`    Element: ${n.target}`);
          console.log(`    Fix: ${n.failureSummary}`);
        });
      });
    }

    expect(results.violations).toEqual([]);
  });
}

// Test specific interactions
test('Modal dialog is accessible', async ({ page }) => {
  await page.goto('/');

  // Open modal
  await page.click('[data-testid="open-modal"]');
  await page.waitForSelector('[role="dialog"]');

  // Verify modal accessibility
  const results = await new AxeBuilder({ page })
    .include('[role="dialog"]')
    .analyze();

  expect(results.violations).toEqual([]);

  // Verify focus is inside modal
  const focusedElement = await page.evaluate(() => {
    const active = document.activeElement;
    const dialog = document.querySelector('[role="dialog"]');
    return dialog?.contains(active);
  });
  expect(focusedElement).toBe(true);

  // Verify Escape closes modal
  await page.keyboard.press('Escape');
  await expect(page.locator('[role="dialog"]')).not.toBeVisible();
});
```

### ESLint Plugin (React/Next.js)

```bash
npm install --save-dev eslint-plugin-jsx-a11y
```

```json
// .eslintrc.json
{
  "extends": ["plugin:jsx-a11y/strict"],
  "plugins": ["jsx-a11y"],
  "rules": {
    "jsx-a11y/alt-text": "error",
    "jsx-a11y/anchor-has-content": "error",
    "jsx-a11y/anchor-is-valid": "error",
    "jsx-a11y/aria-props": "error",
    "jsx-a11y/aria-proptypes": "error",
    "jsx-a11y/aria-role": "error",
    "jsx-a11y/aria-unsupported-elements": "error",
    "jsx-a11y/click-events-have-key-events": "error",
    "jsx-a11y/heading-has-content": "error",
    "jsx-a11y/html-has-lang": "error",
    "jsx-a11y/img-redundant-alt": "error",
    "jsx-a11y/interactive-supports-focus": "error",
    "jsx-a11y/label-has-associated-control": "error",
    "jsx-a11y/media-has-caption": "error",
    "jsx-a11y/mouse-events-have-key-events": "error",
    "jsx-a11y/no-access-key": "error",
    "jsx-a11y/no-autofocus": "warn",
    "jsx-a11y/no-distracting-elements": "error",
    "jsx-a11y/no-interactive-element-to-noninteractive-role": "error",
    "jsx-a11y/no-noninteractive-element-interactions": "warn",
    "jsx-a11y/no-noninteractive-element-to-interactive-role": "error",
    "jsx-a11y/no-noninteractive-tabindex": "error",
    "jsx-a11y/no-redundant-roles": "error",
    "jsx-a11y/no-static-element-interactions": "warn",
    "jsx-a11y/role-has-required-aria-props": "error",
    "jsx-a11y/role-supports-aria-props": "error",
    "jsx-a11y/scope": "error",
    "jsx-a11y/tabindex-no-positive": "error"
  }
}
```

### Lighthouse CI

```bash
npm install --save-dev @lhci/cli
```

```javascript
// lighthouserc.js
module.exports = {
  ci: {
    collect: {
      url: [
        'http://localhost:3000/',
        'http://localhost:3000/login',
        'http://localhost:3000/dashboard',
      ],
      startServerCommand: 'npm run start',
      numberOfRuns: 1,
    },
    assert: {
      assertions: {
        'categories:accessibility': ['error', { minScore: 0.95 }],
        // Individual audit assertions
        'color-contrast': 'error',
        'document-title': 'error',
        'html-has-lang': 'error',
        'image-alt': 'error',
        'label': 'error',
        'link-name': 'error',
        'list': 'error',
        'meta-viewport': 'error',
        'tabindex': 'error',
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
```

### CI Pipeline Integration

```yaml
# .github/workflows/accessibility.yml
name: Accessibility CI

on:
  pull_request:
    branches: [main]

jobs:
  a11y-automated:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - run: npm ci

      - run: npx playwright install --with-deps chromium

      - name: Build application
        run: npm run build

      - name: Start application
        run: npm run start &
        env:
          PORT: 3000

      - name: Wait for application
        run: npx wait-on http://localhost:3000

      - name: Run axe-core tests
        run: npx playwright test tests/accessibility.spec.ts

      - name: Run Lighthouse CI
        run: npx lhci autorun

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: accessibility-reports
          path: |
            playwright-report/
            .lighthouseci/
```

### Storybook Integration

For component-level testing during development:

```bash
npm install --save-dev @storybook/addon-a11y
```

```typescript
// .storybook/main.ts
const config = {
  addons: [
    '@storybook/addon-a11y',
  ],
};
export default config;
```

This runs axe-core checks on every story, showing violations directly in the Storybook UI during development. Developers see accessibility issues before code is even committed.
