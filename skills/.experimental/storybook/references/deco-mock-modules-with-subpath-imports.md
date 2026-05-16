---
title: Mock non-network modules with subpath imports, not runtime patching
impact: HIGH
impactDescription: enables typed, shared mocks instead of brittle per-decorator vi.spyOn calls
tags: deco, mocking, modules, subpath-imports
---

## Mock non-network modules with subpath imports, not runtime patching

For non-network dependencies — `Date.now`, `crypto.randomUUID`, a clock, an analytics SDK, a feature-flag client — runtime patching with `vi.spyOn` inside a decorator is brittle: the spy leaks between stories, type-checking is lost, and the mocked module disappears from autodocs source. Storybook 9+ supports module mocking via Node subpath imports (`#package` style) — declare the mock in `package.json#imports`, write a `*.mock.ts` shim, and Storybook substitutes it everywhere stories are rendered while leaving production untouched.

**Incorrect (runtime spy in a decorator — leaks, untyped, disappears in static build):**

```tsx
const meta = {
  component: SessionTimer,
  decorators: [
    (Story) => {
      vi.spyOn(Date, 'now').mockReturnValue(new Date('2025-12-01').getTime());
      return <Story />;
    },
  ],
} satisfies Meta<typeof SessionTimer>;
```

**Correct (subpath import mocked via `package.json` + `clock.mock.ts`):**

```json
// package.json
{
  "imports": {
    "#clock": {
      "storybook": "./src/lib/clock.mock.ts",
      "default": "./src/lib/clock.ts"
    }
  }
}
```

```ts
// src/lib/clock.ts (production)
export const now = () => Date.now();
```

```ts
// src/lib/clock.mock.ts (used in stories)
import { fn } from 'storybook/test';
export const now = fn(() => new Date('2025-12-01T12:00:00Z').getTime()).mockName('now');
```

```tsx
// SessionTimer.tsx — imports from #clock; same in prod and Storybook, different impl
import { now } from '#clock';

export function SessionTimer({ startedAt }: { startedAt: number }) {
  const elapsed = Math.floor((now() - startedAt) / 1000);
  return <span>{elapsed}s</span>;
}
```

```tsx
// SessionTimer.stories.tsx — override per story by importing the mocked module
import { now } from '#clock';

export const NewSession: Story = {
  args: { startedAt: new Date('2025-12-01T12:00:00Z').getTime() },
};

export const TenMinuteSession: Story = {
  args: { startedAt: new Date('2025-12-01T11:50:00Z').getTime() },
  loaders: [() => now.mockReturnValue(new Date('2025-12-01T12:00:00Z').getTime())],
};
```

**When NOT to use this pattern:**
- Network calls — use [MSW](deco-msw-for-network-mocks.md) instead; HTTP has its own well-supported mocking layer.
- One-off mocks specific to a single story — `loaders` with inline `vi.spyOn` is acceptable; don't add a subpath for a single use.

**Why this matters:** Subpath mocks are shared, typed, and follow the import graph. Runtime patches are private to a decorator and break every time someone refactors the call site.

Reference: [Storybook module mocking](https://storybook.js.org/docs/writing-stories/mocking-data-and-modules/mocking-modules), [Node subpath imports](https://nodejs.org/api/packages.html#subpath-imports)
