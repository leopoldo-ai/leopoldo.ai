---
name: storybook-patterns
description: "Use when building component libraries, design systems, or visual testing with Storybook. Covers Storybook 9+, component documentation, visual regression, interaction testing, and Vitest addon. Triggers on: Storybook, stories, component library, design system, visual testing, visual regression, Chromatic, component docs."
type: technique
metadata:
  author: leopoldo
  source: https://github.com/flight505/storybook-assistant
  created: 2026-03-24
  forge_strategy: adapt
  forge_sources:
    - https://github.com/flight505/storybook-assistant
license: MIT
upstream:
  url: https://github.com/flight505/storybook-assistant
  version: main
  last_checked: 2026-03-24
---

# Storybook Patterns -- Component Libraries and Visual Testing

## Why This Exists

| Problem | Solution |
|---------|----------|
| No component documentation workflow in plugin | Storybook for component library and docs |
| Visual regressions caught only in production | Visual testing with Storybook + Vitest |
| Design system components not easily discoverable | Storybook as living documentation |

Adapted from [flight505/storybook-assistant](https://github.com/flight505/storybook-assistant).

## OSS-First Philosophy

| Recommended (OSS) | Aware Of (Premium) |
|-------------------|-------------------|
| Storybook (OSS) | -- |
| Vitest addon (testing) | Chromatic (visual regression SaaS) |
| @storybook/test | Percy (visual testing SaaS) |

## Core Workflow

### 1. Setup

```bash
npx storybook@latest init
# Installs Storybook 9+ with React/Next.js support
```

### 2. Writing Stories

```typescript
// components/Button/Button.stories.tsx
import type { Meta, StoryObj } from "@storybook/react"
import { Button } from "./Button"

const meta: Meta<typeof Button> = {
  component: Button,
  tags: ["autodocs"], // Auto-generate docs
  argTypes: {
    variant: { control: "select", options: ["primary", "secondary", "ghost"] },
    size: { control: "select", options: ["sm", "md", "lg"] },
    disabled: { control: "boolean" }
  }
}

export default meta
type Story = StoryObj<typeof Button>

export const Primary: Story = {
  args: { variant: "primary", children: "Click me" }
}

export const Secondary: Story = {
  args: { variant: "secondary", children: "Click me" }
}

export const AllVariants: Story = {
  render: () => (
    <div className="flex gap-4">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="ghost">Ghost</Button>
    </div>
  )
}
```

### 3. Interaction Testing

```typescript
import { expect, fn, userEvent, within } from "@storybook/test"

export const ClickTest: Story = {
  args: { onClick: fn(), children: "Click me" },
  play: async ({ canvasElement, args }) => {
    const canvas = within(canvasElement)
    await userEvent.click(canvas.getByRole("button"))
    expect(args.onClick).toHaveBeenCalledOnce()
  }
}

export const FormSubmit: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement)
    await userEvent.type(canvas.getByLabelText("Email"), "test@example.com")
    await userEvent.click(canvas.getByRole("button", { name: /submit/i }))
    await expect(canvas.getByText("Success")).toBeInTheDocument()
  }
}
```

### 4. Vitest Integration

```typescript
// vitest.config.ts
import { storybookTest } from "@storybook/experimental-addon-test/vitest-plugin"

export default defineConfig({
  plugins: [storybookTest()],
  test: {
    // Stories become real Vitest tests automatically
    include: ["**/*.stories.tsx"]
  }
})
```

### 5. Documentation

```typescript
// Use MDX for rich docs alongside stories
// components/Button/Button.mdx

import { Meta, Story, Canvas, Controls } from "@storybook/blocks"
import * as ButtonStories from "./Button.stories"

<Meta of={ButtonStories} />

# Button

Buttons trigger actions. Use primary for main CTAs, secondary for alternatives.

<Canvas of={ButtonStories.Primary} />
<Controls />

## Usage guidelines
- One primary button per view
- Use loading state for async actions
- Minimum touch target: 44x44px
```

### 6. Design Tokens in Storybook

```typescript
// .storybook/preview.tsx
import "../app/globals.css" // Import your Tailwind styles

const preview: Preview = {
  parameters: {
    backgrounds: {
      default: "light",
      values: [
        { name: "light", value: "#ffffff" },
        { name: "dark", value: "#0a0a0a" }
      ]
    }
  },
  decorators: [
    (Story) => (
      <div className="font-body p-4">
        <Story />
      </div>
    )
  ]
}
```

## Rules

1. Every reusable component MUST have a story
2. Use `tags: ["autodocs"]` for automatic documentation
3. Interaction tests for components with user interaction
4. Storybook Vitest addon for running stories as real tests
5. Keep stories colocated with components (Button/Button.stories.tsx)
6. Test all variants, states (loading, error, empty, disabled)
7. Use decorators for consistent context (providers, theme, padding)

## Anti-Patterns

| Anti-Pattern | Why Wrong | Do Instead |
|-------------|-----------|------------|
| Stories only for "demo" | Misses testing value | Add interaction tests to stories |
| One mega-story per component | Hard to find specific states | One story per meaningful variant/state |
| Stories in separate directory | Hard to find, gets stale | Colocate with component |
| No autodocs | Components undiscoverable | tags: ["autodocs"] on every meta |
| Manual visual regression | Slow, error-prone | Vitest addon or Chromatic for CI |
