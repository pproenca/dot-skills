---
title: Capture Screenshots and Videos on Failure
impact: LOW-MEDIUM
impactDescription: 50% faster failure investigation
tags: debug, screenshots, video, failure, artifacts
---

## Capture Screenshots and Videos on Failure

Visual artifacts provide immediate insight into what the page looked like when a test failed. Configure automatic capture for efficient debugging.

**Incorrect (no artifact capture):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // No screenshot or video configuration
    // When tests fail, you only get error messages
  },
});

// Test failure output:
// Error: expect(locator).toBeVisible()
// Locator: getByText('Welcome')
// - No visual of actual page state
// - No recording of what led to failure
```

**Correct (capture on failure):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Screenshots on failure
    screenshot: 'only-on-failure',

    // Video on failure
    video: 'retain-on-failure',
  },
});

// Test failure now includes:
// - Screenshot of final page state
// - Video of entire test execution
```

**Video configuration options:**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    video: {
      mode: 'retain-on-failure',
      size: { width: 1280, height: 720 }, // Video resolution
    },
  },
});
```

**CI artifact upload:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Upload screenshots and videos
  uses: actions/upload-artifact@v4
  if: failure()
  with:
    name: test-artifacts
    path: |
      test-results/**/*.png
      test-results/**/*.webm
    retention-days: 7
```

**Storage considerations:**

| Artifact | Typical Size | Recommendation |
|----------|--------------|----------------|
| Screenshot | 100-500KB | Always capture on failure |
| Video (30s) | 2-5MB | Retain on failure only |
| Trace | 5-20MB | On first retry |

Reference: [Playwright Screenshots](https://playwright.dev/docs/screenshots)
