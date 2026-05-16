---
title: Cache the Vite/Webpack and node_modules layers in CI
impact: MEDIUM
impactDescription: reduces CI Storybook build from 4 minutes to 20 seconds typical
tags: build, ci, cache, performance
---

## Cache the Vite/Webpack and node_modules layers in CI

Every Storybook CI run does the same expensive work — install dependencies, parse stories, transform TS, run PostCSS, output HTML. None of it changes between runs unless `package-lock.json` or the source changes. Caching `node_modules` and the bundler's per-project cache (`node_modules/.vite/storybook` for Vite, `.cache` for Webpack) turns a 4-minute Storybook build into a 20-second incremental rebuild. Same for the Vitest addon test runs.

**Incorrect (no cache — every CI run pays full cost):**

```yml
# .github/workflows/ci.yml
jobs:
  storybook:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - uses: actions/setup-node@v5
        with: { node-version: '22' }
      - run: npm ci
      - run: npm run build-storybook   # full cold build, every time
```

**Correct (cache npm + Vite + Playwright — incremental on subsequent runs):**

```yml
jobs:
  storybook:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v5
        with:
          node-version: '22'
          cache: 'npm'           # caches ~/.npm based on package-lock.json

      - name: Cache Vite + Storybook build cache
        uses: actions/cache@v4
        with:
          path: |
            node_modules/.vite
            node_modules/.cache
            storybook-static
          key: storybook-${{ runner.os }}-${{ hashFiles('package-lock.json', '.storybook/**', 'src/**/*.stories.*') }}
          restore-keys: |
            storybook-${{ runner.os }}-

      - name: Cache Playwright browsers (for addon-vitest)
        uses: actions/cache@v4
        with:
          path: ~/.cache/ms-playwright
          key: playwright-${{ runner.os }}-${{ hashFiles('package-lock.json') }}

      - run: npm ci
      - run: npx playwright install chromium --with-deps
      - run: npm run build-storybook
      - run: npx vitest run --project=storybook
```

**Cache key strategy:**
- **`package-lock.json` hash** — invalidates when dependencies change.
- **`.storybook/**` hash** — invalidates when Storybook config changes.
- **`*.stories.*` hash** — invalidates when stories themselves change. Tune this; if it churns too often, drop it.
- **`restore-keys`** — falls back to the previous-best cache when the key misses, so even a busted cache gives you partial speedup.

**Why this matters:** Slow CI for design-system reviews kills the feedback loop with designers and PMs. A 30-second turnaround means the PR can be reviewed in real time on Slack; a 5-minute turnaround means the conversation moves on.

Reference: [GitHub Actions cache](https://github.com/actions/cache), [Vite cache directory](https://vitejs.dev/config/shared-options.html#cachedir)
