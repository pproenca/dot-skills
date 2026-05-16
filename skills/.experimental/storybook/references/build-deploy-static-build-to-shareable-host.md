---
title: Deploy `storybook build` output to a shareable host on every PR
impact: MEDIUM
impactDescription: enables designer and PM review without local dev setup
tags: build, deploy, chromatic, ci
---

## Deploy `storybook build` output to a shareable host on every PR

A Storybook that only runs on a developer's laptop is a dev tool, not a design system. Designers can't approve a component change, PMs can't review a new state, and external stakeholders (regulators, accessibility auditors) can't audit. `storybook build` produces a static directory deployable to any host (Chromatic, Vercel, Netlify, GitHub Pages, S3+CloudFront). Wire it into CI so every PR gets a unique preview URL and `main` always has a fresh public build.

**Incorrect (no published build — Storybook is dev-only):**

```yml
# .github/workflows/ci.yml — only runs tests, never publishes
- run: npm test
```

**Correct (PR previews via Chromatic — also handles visual regression):**

```yml
# .github/workflows/chromatic.yml
name: 'Storybook + visual regression'

on: [push, pull_request]

jobs:
  chromatic:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0       # Chromatic needs full history for baselines
      - uses: actions/setup-node@v5
        with: { node-version: '22', cache: 'npm' }
      - run: npm ci
      - uses: chromaui/action@latest
        with:
          projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
          # Chromatic builds Storybook, snapshots every story, and posts a PR comment
          # with the preview URL + visual diff results
```

**Alternative (Vercel preview without visual regression):**

```yml
- run: npm run build-storybook  # outputs storybook-static/
- uses: amondnet/vercel-action@v25
  with:
    vercel-token: ${{ secrets.VERCEL_TOKEN }}
    working-directory: storybook-static
    vercel-args: '--prod=${{ github.ref == 'refs/heads/main' }}'
```

**`package.json` scripts:**

```json
{
  "scripts": {
    "storybook": "storybook dev -p 6006",
    "build-storybook": "storybook build",
    "preview-storybook": "npx http-server storybook-static -p 6006 --silent"
  }
}
```

**Why this matters:** Cross-functional review is what turns Storybook into a design system. A PR-preview URL in the description means designers click it; without one, design review collapses back into screenshots in Slack.

Reference: [Storybook deploy](https://storybook.js.org/docs/sharing/publish-storybook), [Chromatic CI integration](https://www.chromatic.com/docs/ci/)
