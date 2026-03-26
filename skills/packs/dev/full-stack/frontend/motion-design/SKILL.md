---
name: motion-design
description: "Animation and motion design patterns for web interfaces. Use when implementing transitions, micro-interactions, scroll animations, loading states, or any UI motion. 7 codified categories with accessibility (prefers-reduced-motion) and performance guardrails."
version: 0.1.0
layer: userland
category: frontend
triggers:
  - pattern: "animation|motion|transition|micro-interaction|scroll animation|loading animation|framer motion"
dependencies:
  hard: []
  soft:
    - frontend-design
    - brand-kit
    - accessibility
metadata:
  author: lucadealbertis
  source: custom
  domain: frontend
  triggers: animation,motion,transition,micro-interaction,scroll,loading,framer
  role: specialist
  scope: implementation
  output-format: code
  related-skills: frontend-design,brand-kit,accessibility
license: proprietary
---

# Motion Design — Codified Animation Patterns

Provides 7 categories of UI animation patterns with accessibility guardrails, performance budgets, and multi-framework output (CSS, Tailwind, Framer Motion).

## Role Definition

You are a motion design specialist. You see motion as communication — every animation tells the user something about what happened, what's happening, or what will happen. You never add motion for decoration. Every animation has a purpose: guide attention, provide feedback, or establish spatial relationships.

## When to Use

- Adding transitions to page navigations
- Implementing hover/click micro-interactions
- Creating loading states and skeleton screens
- Adding scroll-triggered animations
- Animating data changes (charts, counters, lists)
- Designing modal/accordion/tab transitions

## When NOT to Use

- For brand identity setup (use `brand-kit`)
- For design tokens (use `brand-to-ui`)
- For general UI design without motion focus (use `frontend-design`)

---

## 7 Animation Categories

### 1. Micro-Interactions

Small, immediate feedback for user actions.

| Trigger | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Button hover | Scale 1.02 + shadow elevation | 150ms | ease-out |
| Button press | Scale 0.98 | 100ms | ease-in |
| Toggle switch | Translate knob + color change | 200ms | ease-out |
| Checkbox | Scale 0 → 1 + checkmark draw | 200ms | ease-out |
| Input focus | Border color + subtle glow | 150ms | ease-out |

**CSS:**
```css
.btn { transition: transform 150ms ease-out, box-shadow 150ms ease-out; }
.btn:hover { transform: scale(1.02); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
.btn:active { transform: scale(0.98); }
```

**Tailwind:**
```html
<button class="transition-all duration-150 ease-out hover:scale-[1.02] hover:shadow-lg active:scale-[0.98]">
```

**Framer Motion:**
```tsx
<motion.button whileHover={{ scale: 1.02 }} whileTap={{ scale: 0.98 }} transition={{ duration: 0.15 }}>
```

### 2. Page Transitions

Route changes and view switches.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Fade | Opacity 0 → 1 | 300ms | ease-in-out |
| Slide | translateX(-20px → 0) + fade | 350ms | ease-out |
| Scale | scale(0.95 → 1) + fade | 300ms | ease-out |
| Cross-fade | Old fades out, new fades in | 400ms | ease-in-out |

**Framer Motion (AnimatePresence):**
```tsx
<AnimatePresence mode="wait">
  <motion.div
    key={pathname}
    initial={{ opacity: 0, x: -20 }}
    animate={{ opacity: 1, x: 0 }}
    exit={{ opacity: 0, x: 20 }}
    transition={{ duration: 0.35, ease: "easeOut" }}
  />
</AnimatePresence>
```

### 3. Loading States

Skeleton screens, spinners, progress indicators.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Skeleton pulse | Opacity 0.4 ↔ 1.0 | 1500ms | ease-in-out |
| Skeleton shimmer | Gradient sweep left → right | 2000ms | linear |
| Spinner | Rotate 360deg continuous | 1000ms | linear |
| Progress bar | Width 0% → N% | 500ms | ease-out |

**CSS (Skeleton shimmer):**
```css
.skeleton {
  background: linear-gradient(90deg, #e5e5e5 25%, #f0f0f0 50%, #e5e5e5 75%);
  background-size: 200% 100%;
  animation: shimmer 2s linear infinite;
}
@keyframes shimmer { to { background-position: -200% 0; } }
```

### 4. Scroll Animations

Elements that animate as they enter the viewport.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Fade up | translateY(20px → 0) + fade | 500ms | ease-out |
| Fade in | Opacity 0 → 1 | 400ms | ease-out |
| Stagger | Each child delays +100ms | 400ms each | ease-out |
| Parallax | translateY at 0.5x scroll speed | Continuous | linear |

**Framer Motion (useInView):**
```tsx
const ref = useRef(null)
const isInView = useInView(ref, { once: true, margin: "-100px" })

<motion.div
  ref={ref}
  initial={{ opacity: 0, y: 20 }}
  animate={isInView ? { opacity: 1, y: 0 } : {}}
  transition={{ duration: 0.5, ease: "easeOut" }}
/>
```

### 5. Data Transitions

Charts, counters, and data-driven animations.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Counter | Number 0 → target (counting up) | 800ms | ease-out |
| Chart bars | Height 0 → target | 600ms stagger | ease-in-out |
| Chart lines | Path draw (stroke-dashoffset) | 1000ms | ease-in-out |
| List reorder | LayoutAnimation (Framer) | 300ms | ease-in-out |

**Counter (React hook pattern):**
```tsx
function useCounter(target: number, duration = 800) {
  const [count, setCount] = useState(0)
  useEffect(() => {
    const start = performance.now()
    const step = (now: number) => {
      const progress = Math.min((now - start) / duration, 1)
      setCount(Math.floor(progress * target))
      if (progress < 1) requestAnimationFrame(step)
    }
    requestAnimationFrame(step)
  }, [target, duration])
  return count
}
```

### 6. Feedback Animations

Visual responses to user actions and system events.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Success | Scale 0 → 1 + green flash | 300ms | ease-out |
| Error shake | translateX(-4, 4, -4, 4, 0) | 300ms | ease-out |
| Toast slide | translateY(-100% → 0) + fade | 350ms | ease-out |
| Notification dot | Scale 0 → 1 + pulse | 200ms + 2s pulse | ease-out |

**CSS (Error shake):**
```css
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  20%, 60% { transform: translateX(-4px); }
  40%, 80% { transform: translateX(4px); }
}
.shake { animation: shake 300ms ease-out; }
```

### 7. Layout Shifts

Accordion, tab switch, modal, drawer.

| Pattern | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Accordion | Height 0 → auto + fade | 300ms | ease-in-out |
| Tab content | Opacity swap | 250ms | ease-out |
| Modal enter | Scale 0.95 → 1 + fade + backdrop | 300ms | ease-out |
| Drawer slide | translateX(100% → 0) | 300ms | ease-out |

**Framer Motion (Accordion):**
```tsx
<motion.div
  initial={false}
  animate={{ height: isOpen ? "auto" : 0, opacity: isOpen ? 1 : 0 }}
  transition={{ duration: 0.3, ease: "easeInOut" }}
  style={{ overflow: "hidden" }}
/>
```

---

## Accessibility — Non-Negotiable

**Every animation MUST respect `prefers-reduced-motion`.**

**CSS:**
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
  }
}
```

**Tailwind:**
```html
<div class="motion-safe:animate-fade-in motion-reduce:opacity-100">
```

**Framer Motion:**
```tsx
const prefersReducedMotion = useReducedMotion()
const animation = prefersReducedMotion
  ? { opacity: 1 }
  : { opacity: 1, y: 0 }
```

**Reduced motion does NOT mean no motion.** Use instant opacity transitions (no spatial movement) as fallback.

---

## Performance Rules

1. **Only animate `transform` and `opacity`** — these are GPU-composited, no layout recalculation
2. **Never animate:** `width`, `height`, `top`, `left`, `margin`, `padding` — these trigger layout
3. **Budget:** Max 16ms per frame (60fps). Test with Chrome DevTools Performance tab.
4. **`will-change`:** Apply only during animation, remove after. Never on more than 5 elements simultaneously.
5. **Prefer CSS** over JS when possible — CSS animations run on compositor thread

---

## Brand Alignment

Optional `motion` section in brand-kit.yaml:

```yaml
motion:
  speed: "default"      # slow | default | fast
  easing: "ease-out"    # CSS easing function
  reduced_motion: "opacity"  # opacity | instant | none
```

When not present, use the category defaults from the tables above.

---

**Version:** 0.1.0
**Dipendenze:** frontend-design (soft), brand-kit (soft), accessibility (soft)
**Trigger:** Skill-router quando si menziona animazione, motion, transizione, micro-interaction
