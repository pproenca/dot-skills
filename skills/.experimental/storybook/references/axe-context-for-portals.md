---
title: Set `parameters.a11y.context` for components that render into portals
impact: HIGH
impactDescription: prevents axe missing toasts, dialogs, popovers entirely
tags: axe, a11y, context, portal
---

## Set `parameters.a11y.context` for components that render into portals

By default, axe scopes its scan to the story root (`#storybook-root` or equivalent). Components that render into a portal — toasts attached to `document.body`, dialogs in a `<Dialog>` element at the body root, popovers via `ReactDOM.createPortal` — render *outside* the story root, so axe never sees them. The story shows a perfectly accessible button that opens a modal with no accessible name, and a11y reports zero violations. Set `context` to a selector that includes both the story root and the portal mount.

**Incorrect (default `context` — axe scans story root only, misses the portal):**

```tsx
// Dialog.stories.tsx — Dialog renders via createPortal into document.body
export const Open: Story = {
  args: { open: true },
  // a11y addon scans only the trigger button; the dialog itself is invisible to axe
};
```

**Correct (`context` includes the portal mount):**

```tsx
export const Open: Story = {
  args: { open: true },
  parameters: {
    a11y: {
      context: 'body', // scan the entire body — includes the portal
    },
  },
};
```

**More precise: scope to story root + a known portal selector:**

```tsx
// preview.ts — applies to all stories
const preview: Preview = {
  parameters: {
    a11y: {
      context: '#storybook-root, [data-portal-root]', // story root + the design system's portal root
    },
  },
};
```

**Common portal patterns and their `context`:**

| Pattern | Recommended `context` |
|---------|-----------------------|
| Toast/notification (top-of-body) | `'body'` |
| Headless UI Dialog (renders in body) | `'body'` |
| Radix UI portal (`[data-radix-portal]`) | `'#storybook-root, [data-radix-portal]'` |
| Custom design-system portal root | `'#storybook-root, #app-portals'` |
| Tooltip/popover only | Usually fine with default — they render inline if `inert` |

**Verify the scope is right:** Open the a11y panel, click "Highlights," and confirm the highlighted region includes the portal contents. If it doesn't, the `context` selector is wrong.

**Why this matters:** Dialogs and toasts are exactly where a11y bugs hide — keyboard traps, missing focus management, missing labels. A story that scans only the trigger gives false confidence.

Reference: [Storybook a11y context](https://storybook.js.org/docs/writing-tests/accessibility-testing#context), [axe-core context API](https://www.deque.com/axe/core-documentation/api-documentation/#context-parameter)
