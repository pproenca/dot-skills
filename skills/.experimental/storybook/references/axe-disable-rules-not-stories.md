---
title: Disable specific axe rules per-story, not the whole a11y check
impact: HIGH
impactDescription: preserves coverage of every other axe rule on the same story
tags: axe, a11y, rules, suppression
---

## Disable specific axe rules per-story, not the whole a11y check

When axe flags a known false positive — a third-party widget with a non-conformant `role`, an intentional decorative image — the temptation is `parameters.a11y.test: 'off'` for that story. That nukes the entire audit, including the rules that *would* catch a real violation in the same story (missing labels on the form below, contrast issue in the heading). Disable the *specific rule* with `parameters.a11y.config.rules` instead. Every other rule keeps running.

**Incorrect (whole a11y check off — masks unrelated violations):**

```tsx
// FacebookEmbed.stories.tsx — third-party iframe trips the `frame-title` rule
export const Default: Story = {
  parameters: {
    a11y: { test: 'off' }, // also disables every other rule on this story
  },
};
```

**Correct (disable only the offending rule, keep the rest of the audit):**

```tsx
export const Default: Story = {
  parameters: {
    a11y: {
      config: {
        rules: [
          // Third-party iframe; we can't add a title without forking the embed.
          { id: 'frame-title', enabled: false },
        ],
      },
    },
  },
};
```

**Selector-scoped disable (rule applies, but skips elements matching the selector):**

```tsx
export const FormWithLegacyAutofill: Story = {
  parameters: {
    a11y: {
      config: {
        rules: [
          // Legacy `autocomplete="nope"` is a deliberate anti-autofill hack;
          // skip the rule for that one input only.
          { id: 'autocomplete-valid', selector: '*:not([autocomplete="nope"])' },
        ],
      },
    },
  },
};
```

**Document why every disable exists:**

```tsx
parameters: {
  a11y: {
    config: {
      rules: [
        // Vendor: chat-widget@2.x renders a button with role="presentation".
        // Tracked: ENG-4421 (waiting on vendor fix). Re-enable when bumped to 3.x.
        { id: 'button-name', enabled: false },
      ],
    },
  },
},
```

**Why this matters:** "Off" hides bugs. Per-rule disables are surgical — the rest of the audit still catches the next bug to land in this story.

Reference: [Storybook a11y configuration](https://storybook.js.org/docs/writing-tests/accessibility-testing#configure), [axe-core rules](https://dequeuniversity.com/rules/axe/)
