---
title: Use Playwright Inspector for Interactive Debugging
impact: LOW-MEDIUM
impactDescription: 5× faster test development and debugging
tags: debug, inspector, breakpoints, interactive, development
---

## Use Playwright Inspector for Interactive Debugging

Playwright Inspector lets you step through tests interactively, inspect selectors, and generate code. Use it for developing new tests and debugging failures.

**Incorrect (blind debugging):**

```typescript
// tests/checkout.spec.ts
test('complete checkout', async ({ page }) => {
  await page.goto('/checkout');

  // Something fails here but you don't know why
  await page.getByRole('button', { name: 'Pay' }).click();
  // Error: locator.click: Target closed

  // Without inspector, you're guessing:
  // - Is the button there?
  // - Is it visible?
  // - Is there an overlay blocking it?
});

// Run: npx playwright test
// Output: Error with no visual context
```

**Correct (interactive debugging):**

```typescript
// tests/checkout.spec.ts
test('complete checkout', async ({ page }) => {
  await page.goto('/checkout');

  // Add breakpoint to pause and inspect
  await page.pause();

  // Now you can:
  // - See the actual page state
  // - Test different selectors
  // - Step through one action at a time
  await page.getByRole('button', { name: 'Pay' }).click();
});

// Run: npx playwright test --debug
// Inspector opens with full visibility
```

**Launch inspector methods:**

```bash
# Run all tests with inspector
npx playwright test --debug

# Run specific test with inspector
npx playwright test tests/login.spec.ts --debug

# Debug specific test by name
npx playwright test -g "login flow" --debug
```

**VS Code integration:**

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Playwright Tests",
      "runtimeExecutable": "npx",
      "runtimeArgs": ["playwright", "test", "--debug"],
      "console": "integratedTerminal"
    }
  ]
}
```

Reference: [Playwright Inspector](https://playwright.dev/docs/debug#playwright-inspector)
