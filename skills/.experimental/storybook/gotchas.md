# Gotchas

Failure points discovered while using this skill in practice. Append-only — add new entries with a date and concrete reproduction. Empty `gotchas.md` is a smell: every skill collects them over time.

---

## (Seed entries to verify as the skill is used)

### `@storybook/test` import path silently coexists with `storybook/test`
Both packages resolve in a Storybook 9+/10 project (the legacy `@storybook/test` is left as a transitive dep). Imports from the legacy path "work" but produce a *separate* `expect` instance, so spy assertions made there can be invisible to the Vitest runner. **Fix:** Run `npx storybook upgrade` (the codemod rewrites imports) and remove `@storybook/test` from `package.json`. Lint with `eslint-plugin-storybook` to prevent regressions.
Added: 2026-05 (skill seed)

### a11y addon doesn't see anything inside React portals
Default `parameters.a11y.context` is `#storybook-root`. Components rendering into `document.body` (Headless UI Dialog, Radix portals, toast libraries) are invisible to axe — the panel shows zero violations even when the portal content is broken. **Fix:** [`axe-context-for-portals`](references/axe-context-for-portals.md).
Added: 2026-05 (skill seed)

### Annotated `Meta<typeof Component>` widens args silently
`const meta: Meta<typeof Button> = { ... }` widens `args` so per-story `StoryObj<typeof meta>` accepts any prop shape. The story file compiles and renders, but the type-check that catches stories drifting from the component's props is gone. **Fix:** [`csf-satisfies-meta-not-typed`](references/csf-satisfies-meta-not-typed.md).
Added: 2026-05 (skill seed)

### `play: async ({ canvas, userEvent }) => ...` only works on Storybook 9+
Storybook 8 plays receive `{ canvasElement }` and require `within(canvasElement)` and a top-level `userEvent` import. Mixing patterns within one project (some files migrated, some not) produces stories that pass in dev but fail in CI. **Fix:** Standardize on the v9+ destructured form and run the upgrade codemod.
Added: 2026-05 (skill seed)
