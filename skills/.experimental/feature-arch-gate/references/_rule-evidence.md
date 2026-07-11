# Rule Evidence & Vendoring Provenance

The 33 rule files this gate enforces live in this skill's own `references/` directory — the gate is fully self-sufficient at review time and needs nothing outside its own folder. They are a **vendored snapshot** of the feature-arch distillation skill, recorded here for provenance and re-syncing:

- **Source skill:** feature-arch (the same repo's distillation skill; also published from this collection)
- **Vendored from version:** 1.1.0 (its metadata.json at snapshot time)
- **Snapshot date:** 2026-07-11

When the source skill releases a new version, re-run the decidability filter over its rules, re-copy the qualifying files, and update both tables below plus the version above. Divergence between a vendored file and its source original is a sync bug, not a fork.

If any rule file listed below is missing or unreadable at review time, **stop and report the error**. Never review with partial rules and never let a missing rule count as a PASS.

## Vendored Rules

Only rules that pass the decidability test are enforced — a reviewer must be able to decide PASS/FAIL from evidence in the artifact alone. 33 of the source's 43 rules qualify; each is a file in this skill's `references/` directory.

| Rule file | What evidence decides it |
|-----------|--------------------------|
| `struct-feature-folders.md` | Feature-specific code under top-level `components/`, `hooks/`, or `api/` folders instead of `features/<name>/` |
| `struct-feature-self-contained.md` | A feature's files importing its own building blocks from scattered non-feature locations (`src/hooks/`, `src/utils/`) instead of within the feature folder |
| `struct-shared-layer.md` | Domain-named code (`ProductCard`, `calculate-tax`, `use-checkout`) inside `shared/`, or `shared/` code consumed by fewer than 2 features today (speculative placement — apply the rule's litmus test even to generic-looking primitives; "it's a generic Button" does not exempt dead code) |
| `struct-flat-hierarchy.md` | Directory nesting deeper than 3 levels inside a feature folder |
| `struct-optional-segments.md` | Empty segment folders, or a segment folder holding a single file where a flat file would do (e.g. `types/index.ts` only) |
| `struct-app-layer.md` | Route-tree definitions (`Routes`, `createBrowserRouter`) or provider composition inside a feature folder |
| `import-unidirectional-flow.md` | An import in `shared/` from `features/` or `app/`, or an import in `features/` from `app/` |
| `import-no-cross-feature.md` | An import path from one feature into another (exception: code in `relations/<other>/` importing that feature's public API) |
| `import-public-api.md` | An import from outside a feature reaching past its `index.ts` into `components/`, `hooks/`, `utils/`, etc. |
| `import-avoid-barrel-files.md` | Chained `export *` barrels — a feature `index.ts` re-exporting entire subfolders that are themselves `export *` barrels |
| `import-path-aliases.md` | `../../../` relative chains escaping the feature folder where a configured `@/` alias exists |
| `import-type-only.md` | An imported binding used only in type positions without `import type` syntax |
| `bound-interface-contracts.md` | An exported feature component whose props are untyped or implicitly `any` (no interface/type on the signature) |
| `bound-feature-scoped-routing.md` | Hardcoded multi-segment route string literals (`` `/users/${id}/settings` ``) inside feature components instead of a feature route builder |
| `bound-minimize-shared-state.md` | State outside the rule's whitelist (auth, theme/locale, feature flags) living in a global store consumed by feature code |
| `fquery-single-responsibility.md` | Permutation query variants coexisting (`getPost`, `getPostWithComments`, `getPostWithCommentsAndAuthor`) |
| `fquery-colocate-with-feature.md` | A central `src/api/` layer with per-entity files while a `features/` layer exists for those entities |
| `fquery-parallel-fetching.md` | Sequential `await`s where a later request does not use an earlier request's result |
| `fquery-avoid-n-plus-one.md` | A per-item fetch inside a loop/`map` over a fetched list (rule's own exceptions apply: N always < 5, near-100% cache hits, deliberate lazy-load) |
| `fquery-feature-scoped-keys.md` | The same query-key root used by two features, or ad-hoc inline keys instead of keys rooted in the owning feature |
| `fquery-server-component-fetching.md` | `'use client'` + `useEffect` fetching initial render data in a codebase with React Server Components (N/A for client-only codebases) |
| `fcomp-composition-over-props.md` | A prop threaded through 2+ intermediate components that never use it themselves |
| `fcomp-colocate-styles.md` | Per-component style files in a central `styles/` directory instead of next to their components |
| `fcomp-error-boundaries.md` | 2+ sibling feature roots rendered with no error boundary between them and the app root (a single top-level boundary for all features also fails) |
| `fstate-feature-scoped-stores.md` | One store file holding state slices for 2+ business domains (a mixed global store read by features can also trip `bound-minimize-shared-state` — the evidence shapes differ, so both may legitimately fire on one store) |
| `fstate-server-state-separation.md` | Manual fetch calls plus loading/cache flags inside a client store when a query library is present in the project (N/A when no query library exists) |
| `test-colocate-with-feature.md` | A central `tests/` tree mirroring feature structure instead of tests colocated in feature folders |
| `test-feature-isolation.md` | A feature's unit test importing other features' real providers/hooks without mocking them |
| `test-shared-utilities.md` | A global test render wrapper composing feature providers, or feature-specific factories living outside their feature |
| `test-integration-at-app-layer.md` | A test that composes 2+ features located inside a feature folder rather than at the app layer |
| `name-feature-naming.md` | Plural domain folder names (`features/customers/`), or feature folders named after UI/technical patterns (`modal-manager/`, `form-handler/`) |
| `name-file-conventions.md` | Filenames not following a single consistent kebab-case (default) or PascalCase (accepted house) convention — camelCase filenames or mixed casing is the violation |
| `name-descriptive-exports.md` | Generic export names (`Card`, `List`, `Button`) exported from feature folders (`shared/` components are exempt) |

## Excluded Rules

Rules from the source skill that are teaching material, not decidable checks. They are deliberately **not vendored**: they remain valuable in the source skill, they are just not enforceable as a gate.

| Rule file | Why excluded |
|-----------|--------------|
| `struct-domain-folders.md` | The trigger is advisory ("stops scaling somewhere around 15–20 features"); when to introduce a `domains/` layer is a human scaling decision, not artifact evidence. (If a target already has a `domains/` layer, its two decidable sub-checks — no single-domain `domains/`, no sibling-domain imports except `core/` — can be spot-checked out of band) |
| `bound-feature-isolation.md` | Its violation evidence (direct cross-feature imports) is identical to `import-no-cross-feature` — importing both double-counts one finding |
| `bound-event-based-communication.md` | Choosing events over app-layer composition is a design judgment; the decidable core (no direct cross-feature calls) duplicates `import-no-cross-feature` |
| `bound-feature-size.md` | Thresholds are explicitly "consider"-level (5–15 typical, 20+ consider splitting); cohesion boundaries split reviewers |
| `fcomp-single-responsibility.md` | "One thing well" has no measurable boundary; two competent reviewers reach different verdicts on the same component |
| `fcomp-container-presentational.md` | An architectural preference, not a violation with nameable evidence; hooks-era components legitimately blend the two |
| `fcomp-props-as-data-boundary.md` | Every violation shape is already caught by `import-no-cross-feature`, `import-public-api`, or `bound-minimize-shared-state` |
| `fstate-lift-minimally.md` | "As high as necessary" depends on intent (future consumers, reset semantics) not visible in the artifact |
| `fstate-context-sparingly.md` | "Frequently-changing state" is not statically decidable; the appropriateness whitelist requires judgment |
| `fstate-reset-on-unmount.md` | The rule's own exceptions (cart, drafts, preferences) make persist-vs-reset a product decision, not artifact evidence |

<!-- If the source skill gains or changes rules, re-run the decidability filter, re-vendor the
     qualifying files, and update both tables. A source rule that is neither vendored nor
     excluded is a sync bug. -->
