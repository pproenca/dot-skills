---
title: Test Behavior, Not Implementation
impact: MEDIUM
impactDescription: Tests stay green through refactors, red through real regressions
tags: test, react-testing-library, refactor-safety, accessibility
---

## Test Behavior, Not Implementation

Tests that assert on implementation details — state variable values, internal function calls, CSS class names, `data-testid` selectors — break on refactors that don't change behavior. The user doesn't care whether you used `useState` or `useReducer`; they care that clicking the button opens the dialog. Test what the user sees and does.

**Incorrect (asserting on internal state and class names):**

```tsx
import { render } from '@testing-library/react';
import { SettingsPanel } from './SettingsPanel';

test('opens settings dialog', () => {
  const { container } = render(<SettingsPanel />);
  const trigger = container.querySelector('[data-testid="internal-trigger"]')!;
  trigger.dispatchEvent(new MouseEvent('click', { bubbles: true }));

  // Coupled to internals: class names and test ids.
  // Refactor useState -> useReducer, or rename a CSS class, and this breaks
  // even though the user sees identical behavior.
  expect(container.querySelector('.dialog-open')).not.toBeNull();
  expect(container.querySelector('[data-testid="dialog"]')).toHaveClass('open-modal');
});
```

**Correct (asserting on what the user perceives):**

```tsx
import { render, screen } from '@testing-library/react';
import { userEvent } from '@testing-library/user-event';
import { SettingsPanel } from './SettingsPanel';

test('opens settings dialog', async () => {
  const user = userEvent.setup();
  render(<SettingsPanel />);

  await user.click(screen.getByRole('button', { name: /open settings/i }));

  // Asserts on the accessibility tree — what a screen reader (and any user) perceives.
  // Refactors that preserve the UX (useState <-> useReducer, class renames) leave this green.
  expect(screen.getByRole('dialog', { name: /settings/i })).toBeVisible();
});
```

**When NOT to apply this pattern:**
- Unit tests for pure helper functions (e.g., `calculateInvoiceTotal`) — you ARE testing the implementation, and that's the point.
- Performance regression tests that intentionally assert on implementation (e.g., that `useMemo` cache hits keep a render count below a threshold).
- Server components, custom renderers, or animation-heavy code where the accessibility tree is incomplete and a testid is the only stable handle.

**Why this matters:** Tests are a safety net for change. A test coupled to implementation is a tax on every refactor and provides false confidence when behavior actually breaks.

Reference: [Clean Code, Chapter 9: Unit Tests](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Kent C. Dodds — Testing Implementation Details](https://kentcdodds.com/blog/testing-implementation-details)
