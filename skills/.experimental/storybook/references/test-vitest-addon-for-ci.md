---
title: Run play functions in CI via the Vitest addon, not the legacy test-runner
impact: HIGH
impactDescription: 3-5x faster CI runs and shared coverage with unit tests
tags: test, ci, vitest, addon-vitest
---

## Run play functions in CI via the Vitest addon, not the legacy test-runner

`@storybook/addon-vitest` runs every story (and its `play` function) as a Vitest test in browser mode. It's faster than the legacy `@storybook/test-runner` because it shares the Vitest worker pool with your unit tests, produces unified coverage reports, and re-uses the same browser instance across stories. The legacy test-runner spins up a Storybook + Playwright browser per shard, which is correct but slow. Greenfield projects should default to the Vitest addon; existing projects can migrate incrementally.

**Incorrect (legacy test-runner — slow, isolated coverage):**

```json
// package.json
{
  "scripts": {
    "test-storybook": "test-storybook --coverage"
  },
  "devDependencies": {
    "@storybook/test-runner": "^0.x"
  }
}
```

```yml
# .github/workflows/ci.yml
- run: npx playwright install --with-deps
- run: npm run build-storybook
- run: npx http-server storybook-static -p 6006 &
- run: npx wait-on http://localhost:6006
- run: npm run test-storybook
```

**Correct (Vitest addon — workspace-integrated, single test command):**

```bash
npx storybook add @storybook/addon-vitest
# Generates vitest.workspace.ts (or merges into vitest.config.ts)
# Adds the storybookTest plugin pointing at Storybook's index
```

```ts
// vitest.config.ts (Vitest 4 — uses `test.projects` inline)
import { defineConfig } from 'vitest/config';
import { storybookTest } from '@storybook/addon-vitest/vitest-plugin';
import { playwright } from '@vitest/browser-playwright';

export default defineConfig({
  test: {
    projects: [
      { extends: true, test: { name: 'unit', include: ['src/**/*.test.ts'] } },
      {
        extends: true,
        plugins: [storybookTest({ configDir: '.storybook' })],
        test: {
          name: 'storybook',
          browser: {
            enabled: true,
            provider: playwright(),
            instances: [{ browser: 'chromium' }],
          },
        },
      },
    ],
  },
});
```

> **Vitest 3 note:** On Vitest 3, multi-project setups live in a separate `vitest.workspace.ts` using `defineWorkspace([...])` — the `storybookTest` plugin is wired into the same project entry, but the file layout differs. `storybook add` writes the right shape for your installed Vitest version.

```yml
# .github/workflows/ci.yml
- run: npx playwright install chromium --with-deps
- run: npx vitest run
# Runs unit tests AND every play function in one command, one process pool
```

**When the legacy test-runner is still appropriate:**
- A non-Vitest project (you use Jest and don't want to add Vitest just for stories).
- You need server-side rendering snapshots or PDF/image output the test-runner has built-in.

**Why this matters:** The Vitest addon collapses two test pipelines (`vitest` for units, `test-storybook` for plays) into one. CI gets faster, coverage merges, and one test config drives both.

Reference: [Storybook Vitest addon](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon), [Storybook 9 release: testing](https://storybook.js.org/blog/storybook-9)
