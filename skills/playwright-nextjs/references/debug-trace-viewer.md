---
title: Use Trace Viewer for Failed Tests
impact: LOW-MEDIUM
impactDescription: 10× faster debugging with step-by-step replay
tags: debug, trace, viewer, debugging, failure-analysis
---

## Use Trace Viewer for Failed Tests

Playwright's Trace Viewer shows a step-by-step replay of test execution including screenshots, DOM snapshots, network requests, and console logs. Essential for debugging CI failures.

**Incorrect (no trace capture configured):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // No trace configuration
    // When tests fail in CI, you have no visibility into what happened
  },
});

// Test fails in CI - you only see error message
// No way to see page state, network requests, or console logs
```

**Correct (trace on failure):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Capture trace only when test fails or retries
    trace: 'on-first-retry',

    // Alternative options:
    // trace: 'on' - Always capture (large files)
    // trace: 'retain-on-failure' - Keep only for failures
    // trace: 'off' - Never capture
  },
});
```

**View traces locally:**

```bash
# After test failure, open trace
npx playwright show-trace test-results/test-name/trace.zip

# Or view in browser
npx playwright show-trace --browser

# Opens interactive viewer with:
# - Timeline of actions
# - Screenshots at each step
# - Network requests
# - Console logs
# - DOM snapshots
```

**Download traces from CI:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Upload trace artifacts
  uses: actions/upload-artifact@v4
  if: failure() # Only upload on failure
  with:
    name: playwright-traces
    path: test-results/
    retention-days: 7
```

Reference: [Playwright Trace Viewer](https://playwright.dev/docs/trace-viewer)
