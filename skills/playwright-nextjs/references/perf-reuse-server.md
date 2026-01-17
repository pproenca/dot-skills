---
title: Reuse Development Server When Possible
impact: MEDIUM
impactDescription: eliminates 30-60s server startup per test run
tags: perf, webserver, configuration, development, startup
---

## Reuse Development Server When Possible

Starting a new server for each test run wastes time during local development. Reuse an existing server when available.

**Incorrect (always starts new server):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    // Always starts new server, even if one is running
    reuseExistingServer: false,
  },
});
```

**Correct (reuse locally, fresh in CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    // Reuse existing server locally, start fresh in CI
    reuseExistingServer: !process.env.CI,
    timeout: 120000, // Build can take time
  },
});
```

**Local development workflow:**

```bash
# Terminal 1: Start dev server once
npm run dev

# Terminal 2: Run tests repeatedly (reuses server)
npx playwright test
npx playwright test --watch
```

**Multiple servers for different apps:**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: [
    {
      command: 'npm run start:frontend',
      url: 'http://localhost:3000',
      reuseExistingServer: !process.env.CI,
    },
    {
      command: 'npm run start:api',
      url: 'http://localhost:4000',
      reuseExistingServer: !process.env.CI,
    },
  ],
});
```

**Environment-specific server commands:**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: process.env.CI
      ? 'npm run build && npm run start' // Production build in CI
      : 'npm run dev', // Dev server locally
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Benefits of reuse:**

| Scenario | New Server | Reuse Server |
|----------|------------|--------------|
| Local test run | 30-60s startup | Instant |
| Watch mode | New server per run | Same server |
| CI | Fresh server (correct) | N/A |

Reference: [Playwright Web Server](https://playwright.dev/docs/test-webserver)
