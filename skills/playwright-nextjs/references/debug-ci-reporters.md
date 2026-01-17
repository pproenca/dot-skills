---
title: Configure Reporters for CI Integration
impact: LOW-MEDIUM
impactDescription: 2× faster CI failure triage
tags: debug, reporters, ci, github, annotations
---

## Configure Reporters for CI Integration

Choose reporters that integrate with your CI system. GitHub Actions annotations, JUnit XML, and HTML reports each serve different purposes.

**Incorrect (default reporter only):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Default reporter only shows console output
  // No CI integration, no artifacts
});

// CI output:
// FAILED tests/login.spec.ts:15
// Error: expect(locator).toBeVisible()
// - No GitHub annotations
// - No browsable report
// - Hard to find in CI logs
```

**Correct (multi-reporter for CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: process.env.CI
    ? [
        ['github'], // GitHub Actions annotations
        ['junit', { outputFile: 'test-results/junit.xml' }], // CI systems
        ['html', { open: 'never' }], // Detailed HTML report
      ]
    : [
        ['list'], // Console output
        ['html', { open: 'on-failure' }], // Open HTML on failure
      ],
});

// CI output now includes:
// - Inline annotations on PR files
// - JUnit for CI dashboards
// - HTML report artifact
```

**JUnit for CI dashboards:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Publish Test Results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: Playwright Tests
    path: test-results/junit.xml
    reporter: java-junit
```

**HTML report hosting:**

```yaml
# .github/workflows/test.yml
- name: Upload HTML Report
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 14
```

Reference: [Playwright Reporters](https://playwright.dev/docs/test-reporters)
