---
name: storybook
description: Use whenever creating, configuring, or extending Storybook for a TS/React (or any framework) component library — covers main.ts/preview.ts setup, CSF3 story authoring, args/argTypes/controls, decorators and providers, MSW and module mocking, play-function interaction tests via the Vitest addon, the @storybook/addon-a11y workflow (axe-core), autodocs vs MDX docs, design tokens, Figma linking, Chromatic deployment, and on-demand build performance. Triggers on tasks like "write a story", "set up Storybook", "configure addon-a11y", "fix this play function", "deploy Storybook", "add a Figma link", "test Storybook in CI" — even when the user doesn't say "storybook" but is editing a `*.stories.tsx`, `.storybook/main.ts`, or `.storybook/preview.ts`. Targets Storybook 9+/10 (modern `storybook/test` import path, Vitest addon, CSF3 + `satisfies Meta`). Does NOT cover generic React patterns (use the `react` skill), generic Testing Library queries (use `react-testing-library`), or WCAG primer (this skill points at addon-a11y + axe rule config, not the spec).
---

# dot-skills Storybook Best Practices

Comprehensive guide for using Storybook 9+ as the workshop *and* test bench for a TypeScript/React component library. **44 rules across 8 categories**, ordered by the lifecycle of a component in your design system: a wrong `.storybook/main.ts` cascades into every story; a malformed CSF Meta blocks autodocs, controls, tests, and the a11y panel for that file.

## What this skill covers

1. **Setup** — `main.ts`, `preview.ts`, framework selection (Vite vs Webpack, Next.js vs React-only), addon installation via the CLI, `staticDirs`.
2. **Story authoring (CSF3)** — `satisfies Meta<typeof Component>`, named exports = stories, `tags: ['autodocs']` placement, when `render` is appropriate, story naming conventions.
3. **Args, argTypes, controls** — when to rely on inference, when to declare `control: 'select'`, `fn()` from `storybook/test` for callbacks, args vs parameters vs globals.
4. **Decorators & composition** — global providers in `preview.ts`, MSW for network mocks, subpath-import module mocking (Storybook 9+), decorator signature pitfalls.
5. **Interaction testing** — `play` functions, the `storybook/test` import path (NOT `@storybook/test`), destructured `canvas`/`userEvent`, `findBy*` over `waitFor`, `addon-vitest` for CI, portable stories.
6. **Accessibility (`axe-core` via `@storybook/addon-a11y`)** — `parameters.a11y.test = 'error'` as a real gate, per-rule disables, `runOnly` scoped to your WCAG target, portal `context`, `globals.a11y.manual` for intentional-violation fixtures.
7. **Documentation & design system** — autodocs vs MDX, MDX referencing stories with `<Canvas of={...} />`, status tags, design tokens as stories, Figma links via `parameters.design`.
8. **Build & deployment** — Vite over Webpack, on-demand bundling for large libraries, deploy to Chromatic/Vercel for designer review, CI cache configuration.

## When to Apply

Reach for this skill when:

- Editing or creating a `*.stories.tsx`, `*.mdx`, `.storybook/main.ts`, `.storybook/preview.ts`, or `vitest.config.ts` that loads `storybookTest`.
- Setting up Storybook on a new project (framework choice, `npx storybook init` follow-up).
- Adding or upgrading an addon (a11y, vitest, designs, msw).
- Wiring component tests through `play` functions and the Vitest addon.
- Investigating "Storybook is slow", "controls show text instead of select", "a11y panel shows nothing for my dialog", "play function is flaky in CI".

**Skip this skill and use:**
- `react-optimise` / `clean-code-ts-react` for the underlying component design.
- `react-testing-library` for `render`/`screen`/`userEvent` semantics outside Storybook.
- WCAG/ARIA reference docs for the spec itself; this skill assumes you know what `aria-labelledby` does and tells you how `addon-a11y` checks it.

## Rule Categories by Priority

Order reflects the **component lifecycle** (configure → author → wire → decorate → test → audit → document → ship). Earlier stages cascade.

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Setup & Configuration | CRITICAL | `config-` | 6 |
| 2 | Story Authoring (CSF3) | CRITICAL | `csf-` | 7 |
| 3 | Args, ArgTypes & Controls | HIGH | `args-` | 5 |
| 4 | Decorators & Composition | HIGH | `deco-` | 5 |
| 5 | Interaction Testing | HIGH | `test-` | 7 |
| 6 | Accessibility (axe) | HIGH | `axe-` | 5 |
| 7 | Documentation & Design System | MEDIUM-HIGH | `docs-` | 5 |
| 8 | Build, Performance & Deployment | MEDIUM | `build-` | 4 |

## Quick Reference

### 1. Setup & Configuration (CRITICAL)

- [`config-typed-main-config`](references/config-typed-main-config.md) — Type `main.ts` with `satisfies StorybookConfig`
- [`config-pick-the-right-framework-package`](references/config-pick-the-right-framework-package.md) — Use the framework package that matches your build (`@storybook/nextjs-vite` for Next.js, etc.)
- [`config-narrow-stories-glob`](references/config-narrow-stories-glob.md) — Narrow the `stories` glob to story files only
- [`config-typed-preview`](references/config-typed-preview.md) — Type `preview.ts` with the framework's `Preview` type
- [`config-add-addons-via-cli`](references/config-add-addons-via-cli.md) — Install addons with `npx storybook add`, never by hand
- [`config-static-dirs-not-bundler-imports`](references/config-static-dirs-not-bundler-imports.md) — Serve assets via `staticDirs`, not bundler imports

### 2. Story Authoring — CSF3 (CRITICAL)

- [`csf-satisfies-meta-not-typed`](references/csf-satisfies-meta-not-typed.md) — `satisfies Meta<typeof Component>`, never `: Meta<typeof Component>`
- [`csf-prefer-args-over-render`](references/csf-prefer-args-over-render.md) — Default to `args`; reserve `render` for compound stories
- [`csf-set-meta-component-explicitly`](references/csf-set-meta-component-explicitly.md) — Always set `meta.component` (autodocs/controls/types depend on it)
- [`csf-name-stories-by-state`](references/csf-name-stories-by-state.md) — Name stories by user-visible state, not by prop value
- [`csf-tags-autodocs-on-meta`](references/csf-tags-autodocs-on-meta.md) — `tags: ['autodocs']` belongs on the meta, not per-story
- [`csf-co-locate-stories-with-component`](references/csf-co-locate-stories-with-component.md) — Co-locate `Component.stories.tsx` next to `Component.tsx`
- [`csf-default-export-is-the-meta`](references/csf-default-export-is-the-meta.md) — Default export = meta; named exports = stories

### 3. Args, ArgTypes & Controls (HIGH)

- [`args-derive-from-component-props`](references/args-derive-from-component-props.md) — Let `argTypes` be inferred; declare only what inference can't see
- [`args-use-fn-for-callbacks`](references/args-use-fn-for-callbacks.md) — Use `fn()` from `storybook/test` for callback args
- [`args-explicit-control-for-unions`](references/args-explicit-control-for-unions.md) — Declare `control` + `options` for unions inference can't reach
- [`args-no-jsx-in-args`](references/args-no-jsx-in-args.md) — No JSX in `args`; compose JSX in `render`
- [`args-pick-args-vs-parameters-vs-globals`](references/args-pick-args-vs-parameters-vs-globals.md) — `args` = component inputs, `parameters` = addon config, `globals` = toolbar state

### 4. Decorators & Composition (HIGH)

- [`deco-global-providers-in-preview`](references/deco-global-providers-in-preview.md) — Theme/QueryClient/Intl providers go in `preview.ts`
- [`deco-msw-for-network-mocks`](references/deco-msw-for-network-mocks.md) — Mock the network layer with MSW; don't stub the SDK
- [`deco-mock-modules-with-subpath-imports`](references/deco-mock-modules-with-subpath-imports.md) — Mock non-network modules via `package.json#imports`
- [`deco-decorator-component-not-call`](references/deco-decorator-component-not-call.md) — Render decorators as `<Story />`, not `{story()}`
- [`deco-context-aware-decorators`](references/deco-context-aware-decorators.md) — Read `globals` and `parameters` from `context` for reactive wrappers

### 5. Interaction Testing (HIGH)

- [`test-import-from-storybook-test`](references/test-import-from-storybook-test.md) — Import from `storybook/test` (Storybook 9+), not `@storybook/test`
- [`test-await-every-userevent-call`](references/test-await-every-userevent-call.md) — `await` every `userEvent` call
- [`test-use-canvas-from-play-arg`](references/test-use-canvas-from-play-arg.md) — Destructure `canvas`/`userEvent` from the play arg
- [`test-fn-for-spied-callbacks`](references/test-fn-for-spied-callbacks.md) — `args: { onSubmit: fn() }`, then assert with `expect(args.onSubmit).toHaveBeenCalledWith(...)`
- [`test-findby-over-waitfor`](references/test-findby-over-waitfor.md) — Prefer `findByRole` over `waitFor` + `getByRole`
- [`test-vitest-addon-for-ci`](references/test-vitest-addon-for-ci.md) — Run plays in CI via `@storybook/addon-vitest`, not the legacy test-runner
- [`test-portable-stories-for-rtl`](references/test-portable-stories-for-rtl.md) — Reuse stories in RTL/Vitest tests via `composeStories`

### 6. Accessibility — axe (HIGH)

- [`axe-set-test-error-globally`](references/axe-set-test-error-globally.md) — `parameters.a11y.test = 'error'` as a real gate, in `preview.ts`
- [`axe-disable-rules-not-stories`](references/axe-disable-rules-not-stories.md) — Disable specific rules; never `test: 'off'` on a whole story
- [`axe-restrict-runonly-to-wcag-aa`](references/axe-restrict-runonly-to-wcag-aa.md) — Scope `runOnly` to your WCAG target (typically AA)
- [`axe-context-for-portals`](references/axe-context-for-portals.md) — Set `parameters.a11y.context` for components that render into portals
- [`axe-globals-manual-for-intentional-violations`](references/axe-globals-manual-for-intentional-violations.md) — `globals.a11y.manual: true` for fixtures that intentionally violate

### 7. Documentation & Design System (MEDIUM-HIGH)

- [`docs-autodocs-vs-mdx`](references/docs-autodocs-vs-mdx.md) — Autodocs for component pages, MDX for cross-cutting docs
- [`docs-mdx-references-stories`](references/docs-mdx-references-stories.md) — `<Canvas of={Story} />` instead of inline renders
- [`docs-component-status-tags`](references/docs-component-status-tags.md) — Surface lifecycle with status tags + sidebar badges
- [`docs-design-tokens-as-stories`](references/docs-design-tokens-as-stories.md) — Document tokens as stories for visual regression
- [`docs-figma-link-via-design-addon`](references/docs-figma-link-via-design-addon.md) — Link each story to its Figma frame via `parameters.design`

### 8. Build, Performance & Deployment (MEDIUM)

- [`build-prefer-vite-over-webpack`](references/build-prefer-vite-over-webpack.md) — Vite-based framework packages over legacy Webpack
- [`build-trim-test-bundle`](references/build-trim-test-bundle.md) — Trim the Vitest-addon test build via `main.ts` `build.test` config
- [`build-deploy-static-build-to-shareable-host`](references/build-deploy-static-build-to-shareable-host.md) — Deploy `storybook build` to Chromatic/Vercel for every PR
- [`build-cache-storybook-in-ci`](references/build-cache-storybook-in-ci.md) — Cache the Vite/Webpack and Playwright layers in CI

## How to use

- Start with [references/_sections.md](references/_sections.md) for the category structure and impact rationale.
- For "I'm setting up Storybook," read all `config-` rules then `csf-`.
- For "I'm writing a new story," read `csf-` and `args-`.
- For "I want tests on my stories," read `test-` and `deco-msw-for-network-mocks`.
- For "I want a11y to fail CI on violations," read all `axe-` rules.
- For [`gotchas.md`](gotchas.md): failure modes discovered over time; always check before debugging an obscure issue.
- Add new rules using [`assets/templates/_template.md`](assets/templates/_template.md).

## Reference files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [gotchas.md](gotchas.md) | Failure modes accumulated over time |
| [metadata.json](metadata.json) | Version, references, abstract |

## Related skills

- `clean-code-ts-react` — Underlying component design quality (naming, function shape, abstraction).
- `react-testing-library` — RTL queries and patterns when used outside Storybook.
- `web-interface-guidelines` — Vercel Web Interface Guidelines for the components you're documenting.
