---
title: Use `globals.a11y.manual` for stories that intentionally show a violation state
impact: HIGH
impactDescription: prevents global rule disables that mask unrelated violations
tags: axe, a11y, manual, fixtures
---

## Use `globals.a11y.manual` for stories that intentionally show a violation state

Some stories *exist* to show a violation: an "error state" that highlights low contrast on disabled inputs, a fixture demonstrating what an inaccessible card looks like before refactoring, a "before / after" pair in design-system docs. These will fail `test: 'error'` for legitimate reasons. The right fix isn't to disable the rule globally — it's `globals: { a11y: { manual: true } }`, which marks the story as "I know, don't run automated checks here; I'll review by hand." It's the explicit, auditable form of "this is an exception."

**Incorrect (disable the rule on a fixture story — the same rule now silently passes elsewhere):**

```tsx
// preview.ts — globally disabling color-contrast to make a fixture story pass
const preview: Preview = {
  parameters: {
    a11y: {
      config: {
        rules: [{ id: 'color-contrast', enabled: false }], // wrong: blanket disable
      },
    },
  },
};
```

**Incorrect (`test: 'off'` on the story — also masks other bugs in the same story):**

```tsx
export const LowContrastDemo: Story = {
  parameters: { a11y: { test: 'off' } }, // disables everything, not just the demo violation
};
```

**Correct (`globals.a11y.manual` — explicitly opt this story out of auto checks):**

```tsx
// LowContrastDemo.stories.tsx — design-system doc story showing what NOT to do
export const LowContrastDemo: Story = {
  args: {
    fg: '#888',
    bg: '#999', // intentional 1.4:1 contrast for the doc
  },
  globals: {
    a11y: { manual: true }, // panel still shows violations; CI doesn't fail
  },
  parameters: {
    docs: {
      description: {
        story:
          'Anti-pattern reference: do not pair grays this close in luminance. ' +
          'Automated a11y checks are disabled for this story; the violation is intentional.',
      },
    },
  },
};
```

**Companion story (the right way) so the doc shows both:**

```tsx
export const SufficientContrast: Story = {
  args: {
    fg: '#1a1a1a',
    bg: '#ffffff', // 18:1 — well above AAA
  },
};
```

**Why this matters:** Globally disabling a rule because of one fixture means every other story silently loses that check. `manual: true` keeps the disable scoped to the one story that needs it, with the panel still showing what's wrong so reviewers can verify it's intentional.

Reference: [Storybook a11y: globals.a11y.manual](https://storybook.js.org/docs/writing-tests/accessibility-testing#globals)
