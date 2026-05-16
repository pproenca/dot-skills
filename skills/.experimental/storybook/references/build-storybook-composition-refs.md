---
title: Use Storybook Composition (`refs`) to unify multi-package design systems
impact: MEDIUM-HIGH
impactDescription: prevents N-URL bookmarks across N packages; one host Storybook consumes them all
tags: build, composition, refs, monorepo, multi-package
---

## Use Storybook Composition (`refs`) to unify multi-package design systems

Real design systems rarely live in one package. There's `@org/tokens`, `@org/primitives`, `@org/components`, plus the consuming app's local Storybook. Asking designers to bookmark four URLs guarantees nobody visits three of them. Storybook Composition's `refs` field in `main.ts` embeds remote (or sibling-monorepo) Storybooks into one host Storybook, with a unified sidebar — designers navigate "Foundations → Primitives → Components → App" in one URL. Each ref is just a deployed `storybook-static` build (or a local port in dev); the host doesn't need to import code from the refs, it just needs the URL.

**Incorrect (each package builds its own Storybook, designers bookmark four URLs):**

```ts
// packages/tokens/.storybook/main.ts
const config = { stories: ['../src/**/*.stories.tsx'] } satisfies StorybookConfig;
// packages/components/.storybook/main.ts — same, but no link to tokens Storybook
// packages/app/.storybook/main.ts — same, isolated from both
```

**Correct (`refs` in the host Storybook composes everything):**

```ts
// apps/storybook-host/.storybook/main.ts — the canonical URL designers visit
import type { StorybookConfig } from '@storybook/react-vite';

const config = {
  framework: '@storybook/react-vite',
  stories: ['../src/**/*.stories.tsx'], // host's own pages (Welcome, Getting Started, Patterns)
  refs: {
    'tokens': {
      title:     'Foundations & Tokens',
      url:       process.env.STORYBOOK_REFS_LOCAL
        ? 'http://localhost:6007'
        : 'https://tokens.design.example.com',
      expanded:  true,
    },
    'primitives': {
      title:     'Primitives',
      url:       process.env.STORYBOOK_REFS_LOCAL
        ? 'http://localhost:6008'
        : 'https://primitives.design.example.com',
      sourceUrl: 'https://github.com/example/design-system/tree/main/packages/primitives',
    },
    'components': {
      title:     'Components',
      url:       process.env.STORYBOOK_REFS_LOCAL
        ? 'http://localhost:6009'
        : 'https://components.design.example.com',
      sourceUrl: 'https://github.com/example/design-system/tree/main/packages/components',
    },
  },
} satisfies StorybookConfig;

export default config;
```

**Local dev: run all refs in parallel with `concurrently`:**

```json
{
  "scripts": {
    "storybook:tokens":     "storybook dev -p 6007 -c packages/tokens/.storybook --no-open",
    "storybook:primitives": "storybook dev -p 6008 -c packages/primitives/.storybook --no-open",
    "storybook:components": "storybook dev -p 6009 -c packages/components/.storybook --no-open",
    "storybook:host":       "STORYBOOK_REFS_LOCAL=1 storybook dev -p 6006 -c apps/storybook-host/.storybook",
    "storybook":            "concurrently \"npm:storybook:tokens\" \"npm:storybook:primitives\" \"npm:storybook:components\" \"npm:storybook:host\""
  }
}
```

**Production: deploy each ref independently, point `url` at the deployed host:**

```yml
# .github/workflows/storybook-deploy.yml — matrix-deploy each package
strategy:
  matrix:
    pkg: [tokens, primitives, components, host]
steps:
  - run: cd packages/${{ matrix.pkg }} && npm run build-storybook
  - uses: chromaui/action@latest
    with:
      projectToken: ${{ secrets[format('CHROMATIC_TOKEN_{0}', matrix.pkg)] }}
      storybookBuildDir: packages/${{ matrix.pkg }}/storybook-static
```

**Package Composition** (design system publishes its Storybook URL in `package.json` so consumers compose automatically):

```json
// @org/design-system/package.json — published to npm
{
  "storybook": {
    "url": "https://design.example.com"
  }
}
```

```ts
// Consumer app — no manual `refs` entry needed; Storybook finds it
// .storybook/main.ts
const config = {
  refs: (config, { configType }) => ({
    ...config, // any explicit refs above
    // `@org/design-system` from package.json contributes its URL automatically
  }),
} satisfies StorybookConfig;
```

**Behavior notes:**
- The host doesn't import refs' code; the sidebar lazy-loads each ref's iframe on demand. Cold start of the host is unaffected by ref size.
- `sourceUrl` adds a "View source" link on each ref's stories.
- Chromatic snapshots each ref independently — the host doesn't snapshot ref stories.
- Search across all refs works automatically.

**When NOT to use this pattern:**
- Single-package design system (one Storybook covers everything). Composition is overhead.
- Refs that aren't independently deployable (e.g., the only way to build them is `npm i` in the host repo). Use the [package composition](https://storybook.js.org/docs/sharing/package-composition) variant or just merge the Storybooks.
- Sensitive internal Storybooks behind auth — Composition needs the iframe URL to be loadable from the host's origin.

**Why this matters:** A design system gets used when it's *easy to browse*. Four separate Storybooks across four URLs is friction every designer feels every day. One composed sidebar collapses that friction to zero without merging four monorepo packages into one giant Storybook config.

Reference: [Storybook Composition docs](https://storybook.js.org/docs/sharing/storybook-composition/), [Package Composition](https://storybook.js.org/docs/sharing/package-composition), [Chromatic Composition guide](https://www.chromatic.com/docs/composition/), [Nx + Storybook composition](https://nx.dev/docs/technologies/test-tools/storybook/guides/one-storybook-with-composition)
