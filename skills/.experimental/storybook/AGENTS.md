# Storybook

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive Storybook 9+/10 reference for AI agents and LLMs working with TypeScript/React component libraries. Contains 44 rules across 8 categories — setup & configuration, CSF3 story authoring, args/argTypes/controls, decorators & composition, interaction testing (play functions + Vitest addon), accessibility (axe-core via @storybook/addon-a11y), documentation & design system (autodocs/MDX/tokens/Figma), and build/deployment (Vite, on-demand bundling, Chromatic, CI caching). Each rule includes incorrect/correct examples in modern CSF3 + `satisfies Meta` form, plus When-NOT-to-use guidance for principle conflicts. Targets Storybook 9+ APIs (`storybook/test` import path, `parameters.a11y.test = 'error'`, destructured `canvas`/`userEvent` in play, `@storybook/addon-vitest` for CI).

---

## Table of Contents

1. [Setup & Configuration](references/_sections.md#1-setup-&-configuration) — **CRITICAL**
   - 1.1 [Install addons with `npx storybook add` instead of hand-editing](references/config-add-addons-via-cli.md) — CRITICAL (prevents missing peer-dependency installs and broken registration)
   - 1.2 [Narrow the `stories` glob to story files only](references/config-narrow-stories-glob.md) — CRITICAL (2-10x faster cold start, prevents accidental story matching)
   - 1.3 [Pick the framework package that matches your build](references/config-pick-the-right-framework-package.md) — CRITICAL (prevents broken RSC, image optimization, and routing in stories)
   - 1.4 [Serve assets via `staticDirs`, not bundler imports](references/config-static-dirs-not-bundler-imports.md) — CRITICAL (prevents broken asset paths in static builds)
   - 1.5 [Type main.ts with `satisfies StorybookConfig`](references/config-typed-main-config.md) — CRITICAL (prevents addon-name and framework-options typos from passing silently)
   - 1.6 [Type preview.ts with the framework's `Preview` type](references/config-typed-preview.md) — CRITICAL (prevents silently-ignored typos in global decorators, parameters, and globalTypes)
2. [Story Authoring (CSF3)](references/_sections.md#2-story-authoring-(csf3)) — **CRITICAL**
   - 2.1 [Always set `component` on the meta](references/csf-set-meta-component-explicitly.md) — CRITICAL (enables autodocs, controls, prop-type inference, and arg autocompletion)
   - 2.2 [Name stories by the state they capture, not the prop they set](references/csf-name-stories-by-state.md) — CRITICAL (enables designers and PMs to scan the sidebar without reading args)
   - 2.3 [Place `Component.stories.tsx` next to `Component.tsx`](references/csf-co-locate-stories-with-component.md) — CRITICAL (prevents story rot by surfacing stories in every component file tree and diff)
   - 2.4 [Prefer `args` over `render` for single-component stories](references/csf-prefer-args-over-render.md) — CRITICAL (enables controls, autodocs, and play-function arg injection)
   - 2.5 [Put `tags: ['autodocs']` on the meta, not on individual stories](references/csf-tags-autodocs-on-meta.md) — CRITICAL (prevents missing or duplicated docs pages)
   - 2.6 [The default export is the `meta`, never a story](references/csf-default-export-is-the-meta.md) — CRITICAL (prevents silent story-discovery breakage)
   - 2.7 [Use `satisfies Meta<typeof Component>`, not a type annotation](references/csf-satisfies-meta-not-typed.md) — CRITICAL (preserves narrow arg types so `StoryObj<typeof meta>` autocompletes)
3. [Args, ArgTypes & Controls](references/_sections.md#3-args,-argtypes-&-controls) — **HIGH**
   - 3.1 [Avoid JSX in `args` defaults — compose JSX in `render` instead](references/args-no-jsx-in-args.md) — HIGH (prevents broken docs source code and Chromatic snapshot diffs)
   - 3.2 [Declare `control` and `options` for prop types Storybook can't infer](references/args-explicit-control-for-unions.md) — HIGH (prevents invalid string inputs and enables proper select/radio controls)
   - 3.3 [Let `args` be inferred from props; only declare `argTypes` for opaque types](references/args-derive-from-component-props.md) — HIGH (removes ~70% of argTypes boilerplate while keeping controls accurate)
   - 3.4 [Pick the right knob — `args` vs `parameters` vs `globals`](references/args-pick-args-vs-parameters-vs-globals.md) — HIGH (prevents misuse that breaks controls, addons, or toolbar state)
   - 3.5 [Use `fn()` from `storybook/test` for callback args](references/args-use-fn-for-callbacks.md) — HIGH (enables Actions tab logging and spy-based assertions in one line)
4. [Decorators & Composition](references/_sections.md#4-decorators-&-composition) — **HIGH**
   - 4.1 [Decorators receive a `Story` component — render it as `<Story />`, not `{story()}`](references/deco-decorator-component-not-call.md) — HIGH (prevents lost story context (args, parameters, decorator chain))
   - 4.2 [Mock network with MSW handlers, not by stubbing the SDK](references/deco-msw-for-network-mocks.md) — HIGH (prevents stories from breaking when the data-fetching layer is refactored)
   - 4.3 [Mock non-network modules with subpath imports, not runtime patching](references/deco-mock-modules-with-subpath-imports.md) — HIGH (enables typed, shared mocks instead of brittle per-decorator vi.spyOn calls)
   - 4.4 [Put global providers in `preview.ts` decorators, not in every story](references/deco-global-providers-in-preview.md) — HIGH (prevents per-story drift and silent provider gaps)
   - 4.5 [Read `context` in decorators to make them story-reactive](references/deco-context-aware-decorators.md) — HIGH (enables one decorator to handle theme, locale, and viewport changes)
5. [Interaction Testing](references/_sections.md#5-interaction-testing) — **HIGH**
   - 5.1 [Always `await` every `userEvent` call in `play` functions](references/test-await-every-userevent-call.md) — HIGH (eliminates flaky CI runs from race conditions)
   - 5.2 [Destructure `canvas` and `userEvent` from the `play` argument](references/test-use-canvas-from-play-arg.md) — HIGH (eliminates 2 lines of boilerplate per play function and aligns with v9+ test API)
   - 5.3 [Import test utilities from `storybook/test`, not `@storybook/test`](references/test-import-from-storybook-test.md) — HIGH (prevents silent breakage on Storybook 9+ upgrade)
   - 5.4 [Prefer `findBy*` over `waitFor` + `getBy*` for async appearance](references/test-findby-over-waitfor.md) — HIGH (reduces flakiness and improves failure messages by 2-3x)
   - 5.5 [Reuse stories in RTL/Vitest tests via `composeStories`](references/test-portable-stories-for-rtl.md) — HIGH (eliminates duplicate fixture setup between stories and unit tests)
   - 5.6 [Run play functions in CI via the Vitest addon, not the legacy test-runner](references/test-vitest-addon-for-ci.md) — HIGH (3-5x faster CI runs and shared coverage with unit tests)
   - 5.7 [Use `fn()` spies on callback args, then assert in `play`](references/test-fn-for-spied-callbacks.md) — HIGH (enables behavior assertions on every story without duplicate fixtures)
6. [Accessibility](references/_sections.md#6-accessibility) — **HIGH**
   - 6.1 [Disable specific axe rules per-story, not the whole a11y check](references/axe-disable-rules-not-stories.md) — HIGH (preserves coverage of every other axe rule on the same story)
   - 6.2 [Restrict `runOnly` to the WCAG levels you commit to](references/axe-restrict-runonly-to-wcag-aa.md) — HIGH (reduces noise from AAA and experimental rules nobody plans to meet)
   - 6.3 [Set `parameters.a11y.context` for components that render into portals](references/axe-context-for-portals.md) — HIGH (prevents axe missing toasts, dialogs, popovers entirely)
   - 6.4 [Set `parameters.a11y.test = 'error'` in `preview.ts`](references/axe-set-test-error-globally.md) — HIGH (enables a11y as a real CI gate instead of advisory warnings)
   - 6.5 [Use `globals.a11y.manual` for stories that intentionally show a violation state](references/axe-globals-manual-for-intentional-violations.md) — HIGH (prevents global rule disables that mask unrelated violations)
7. [Documentation & Design System](references/_sections.md#7-documentation-&-design-system) — **MEDIUM-HIGH**
   - 7.1 [Document design tokens as stories, not just MDX](references/docs-design-tokens-as-stories.md) — MEDIUM-HIGH (enables visual regression on token changes and prevents MDX hex-value drift)
   - 7.2 [In MDX, reference stories with `<Canvas of={Story} />` instead of duplicating renders](references/docs-mdx-references-stories.md) — MEDIUM-HIGH (prevents MDX inline renders from drifting from the stories file)
   - 7.3 [Link each story to its Figma frame via `parameters.design`](references/docs-figma-link-via-design-addon.md) — MEDIUM-HIGH (enables side-by-side Figma vs implementation review without context switching)
   - 7.4 [Surface component lifecycle with status tags and sidebar badges](references/docs-component-status-tags.md) — MEDIUM-HIGH (prevents consumers from adopting experimental APIs or depending on deprecated ones)
   - 7.5 [Use `autodocs` for component pages, MDX for cross-cutting docs](references/docs-autodocs-vs-mdx.md) — MEDIUM-HIGH (prevents handwritten prop-table drift while preserving MDX for cross-cutting docs)
8. [Build, Performance & Deployment](references/_sections.md#8-build,-performance-&-deployment) — **MEDIUM**
   - 8.1 [Cache the Vite/Webpack and node_modules layers in CI](references/build-cache-storybook-in-ci.md) — MEDIUM (reduces CI Storybook build from 4 minutes to 20 seconds typical)
   - 8.2 [Deploy `storybook build` output to a shareable host on every PR](references/build-deploy-static-build-to-shareable-host.md) — MEDIUM (enables designer and PM review without local dev setup)
   - 8.3 [Prefer Vite-based framework packages over Webpack](references/build-prefer-vite-over-webpack.md) — MEDIUM (5-10x faster cold start and HMR vs Webpack-based frameworks)
   - 8.4 [Trim the test-build bundle for the Vitest addon](references/build-trim-test-bundle.md) — MEDIUM (reduces Vitest addon bundle by skipping docs/a11y/MDX during play runs)

---

## References

1. [https://storybook.js.org/docs](https://storybook.js.org/docs)
2. [https://storybook.js.org/blog](https://storybook.js.org/blog)
3. [https://storybook.js.org/docs/api/csf](https://storybook.js.org/docs/api/csf)
4. [https://storybook.js.org/docs/writing-tests/interaction-testing](https://storybook.js.org/docs/writing-tests/interaction-testing)
5. [https://storybook.js.org/docs/writing-tests/accessibility-testing](https://storybook.js.org/docs/writing-tests/accessibility-testing)
6. [https://storybook.js.org/docs/writing-tests/integrations/vitest-addon](https://storybook.js.org/docs/writing-tests/integrations/vitest-addon)
7. [https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest](https://storybook.js.org/docs/api/portable-stories/portable-stories-vitest)
8. [https://storybook.js.org/docs/configure](https://storybook.js.org/docs/configure)
9. [https://storybook.js.org/docs/writing-stories/decorators](https://storybook.js.org/docs/writing-stories/decorators)
10. [https://storybook.js.org/docs/essentials/toolbars-and-globals](https://storybook.js.org/docs/essentials/toolbars-and-globals)
11. [https://github.com/storybookjs/storybook](https://github.com/storybookjs/storybook)
12. [https://www.chromatic.com/docs/](https://www.chromatic.com/docs/)
13. [https://mswjs.io/docs/](https://mswjs.io/docs/)
14. [https://www.deque.com/axe/core-documentation/api-documentation/](https://www.deque.com/axe/core-documentation/api-documentation/)
15. [https://testing-library.com/docs/](https://testing-library.com/docs/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |