# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **the lifecycle of a component in your design system** (configure → author → wire → decorate → test → audit → document → ship). Earlier stages cascade — a wrong `main.ts` breaks every story; a malformed CSF Meta blocks autodocs, controls, tests, and the a11y panel; a missing decorator silently breaks interaction tests for an entire team.

---

## 1. Setup & Configuration (config)

**Impact:** CRITICAL  
**Description:** `.storybook/main.ts`, `preview.ts`, framework selection, and addon registration are loaded once and underpin every story, every test, and every doc page. A wrong framework package or a missing addon entry silently disables features across the whole Storybook instance.

## 2. Story Authoring (CSF3) (csf)

**Impact:** CRITICAL  
**Description:** Component Story Format 3 with `satisfies Meta<typeof Component>` is the contract every Storybook tool reads from — autodocs, controls, the test addon, the a11y panel, and Chromatic. Bad CSF shape (default-export `Meta` without `satisfies`, mistyped `StoryObj`, unnecessary `render` overrides, story names that collide) blocks tooling for that file and confuses the model when generating siblings.

## 3. Args, ArgTypes & Controls (args)

**Impact:** HIGH  
**Description:** `args` and `argTypes` drive the controls panel, the autodocs prop table, and what `play` functions receive. Without explicit `args`, Storybook can't render controls; without `argTypes` for opaque types (unions, callbacks, complex objects), the controls panel falls back to no-input or text and the design system loses its interactive surface.

## 4. Decorators & Composition (deco)

**Impact:** HIGH  
**Description:** Decorators wrap stories with the same providers production uses — theme, router, query client, i18n, MSW. A story that "works in isolation" but has no Theme decorator silently renders in default theme, breaks visual regression in dark mode, and produces interaction tests that pass in dev but fail in CI. Decorators are how stories stay realistic without each one re-importing setup.

## 5. Interaction Testing (test)

**Impact:** HIGH  
**Description:** `play` functions, the `@storybook/addon-vitest` runner, and `storybook/test` (`expect`, `userEvent`, `fn`) turn each story into an executable test. The cascade: a story without a `play` is documented but not verified; a `play` without `await` produces flaky CI; using `@storybook/test` (Storybook 8 path) instead of `storybook/test` (Storybook 9+) silently breaks on upgrade.

## 6. Accessibility (axe)

**Impact:** HIGH  
**Description:** `@storybook/addon-a11y` runs axe-core against every story and can fail the test run when `parameters.a11y.test = 'error'`. Without it, accessibility is an afterthought caught only in audits; with it, every PR that adds a story is also a WCAG check. Per-story rule overrides exist precisely so the audit stays green without weakening the global config.

## 7. Documentation & Design System (docs)

**Impact:** MEDIUM-HIGH  
**Description:** Autodocs (`tags: ['autodocs']`) generates a docs page from the Meta and stories; MDX adds prose, tokens, and design rationale that autodocs can't express. The design system's value is realized at this layer — without it, Storybook is a developer tool, not a shared design surface.

## 8. Build, Performance & Deployment (build)

**Impact:** MEDIUM  
**Description:** Static builds (`storybook build`), on-demand bundling, Vite over Webpack 5, and Chromatic or static-host deployment determine whether the design system is consumable by designers and PMs. A 5-minute cold start or a Storybook that only runs locally is a Storybook nobody outside engineering visits.
