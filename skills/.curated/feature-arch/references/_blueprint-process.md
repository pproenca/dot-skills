# Blueprint Process: Deriving a Project-Specific Target Architecture

This file is the agent's playbook when this skill is invoked on a real project.
The output is a concrete, persisted blueprint at `docs/architecture/FEATURE-ARCH-TARGET.md`
that future agent sessions can read and align changes against.

The rules elsewhere in this skill (`struct-*`, `import-*`, `bound-*`, …) are the
*principles*. This document is the *process* that turns those principles into a
project-shaped end-state. Every decision in the blueprint must cite one or more
rules so reviewers can trace the *why*.

The blueprint is not aspirational fiction. Every feature, path, and public-API
entry in it must be either (a) already present in the repo, or (b) listed in the
migration plan with a concrete file move / file create step.

---

## Step 1: Gather project context (no decisions yet)

The agent reads, never writes, in this step. Collect signals from these sources
and keep raw findings — they will be cited in the blueprint's Context section.

### 1a. Framework and stack

Read `package.json` (or equivalent). Capture:

- **Framework**: Next.js (app router vs pages), Vite + React Router, Remix, CRA, Expo, etc.
- **Server state**: TanStack Query, SWR, RSC + `cache()`, Apollo, none.
- **Client state**: Redux Toolkit, Zustand, Jotai, Context-only, Valtio, none.
- **Routing model**: file-based (Next app dir, Remix, TanStack Router), config-based (React Router declarative), or mixed.
- **Styling**: Tailwind, CSS Modules, vanilla-extract, styled-components, etc.
- **Test runner**: Vitest, Jest, Playwright, Cypress.

Framework dictates several blueprint defaults — e.g., Next.js app router moves
the "app layer" into `app/` routes, and server components shift data-fetching
ownership. Record framework explicitly; do not assume.

### 1b. Current directory shape

Run a depth-3 listing of `src/` (or the project root if there is no `src/`).
Classify the current shape as one of:

| Shape | Signals | Implication |
|-------|---------|-------------|
| **Already feature-based** | `src/features/*/` or `src/modules/*/` or `src/domains/*/` exists with >1 child | Blueprint should *codify and tighten* existing structure, not rewrite it |
| **Technical grouping** | `src/components/`, `src/hooks/`, `src/api/`, `src/utils/` at top level | Blueprint is a migration target; expect a substantial migration plan |
| **Page/route grouping** | `src/pages/*/components|hooks` or `app/*/components|hooks` | Mixed — features may be implicit in route segments |
| **Greenfield** | Few files, mostly scaffolding | Blueprint is the seed structure for new work |

The shape determines the *size* of the migration plan section, not the *shape*
of the target. The target is always feature-based per the rules in this skill.

### 1c. Domain language from docs

Read in order, take the first 2–3 that exist:

1. `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/`, or equivalent agent-instruction files
2. `README.md` (look for product description, "what is X" sections)
3. `openspec/` directory — every `openspec/specs/*` directory name is a candidate capability
4. `docs/` — top-level docs imply top-level domains

Extract proper-noun domain terms ("Checkout", "Inventory", "Onboarding",
"Workspaces"). These become the feature shortlist seed.

### 1d. Routes and entry points

If the framework is route-driven, list the route segments. Each top-level
route segment is a feature candidate. Examples:

- Next.js app router: each first-level directory under `app/` that isn't a
  route group `(…)` or special file.
- React Router: each top-level `<Route>` path's first segment.
- Remix: each first-level directory under `app/routes/`.

### 1e. Implicit features in existing code

Even with technical grouping, features exist implicitly. Look for:

- **Filename clusters**: `PostCard.tsx`, `PostList.tsx`, `usePost.ts`, `postApi.ts` → feature `post`
- **Model files**: types/models with names that recur across `components/`, `hooks/`, `api/`
- **Route handlers**: API routes grouped by resource (`/api/posts`, `/api/comments`)

---

## Step 2: Propose a feature list, then confirm with the user

Combine 1c, 1d, and 1e into a **candidate feature list**. For each candidate,
record:

- **Name** (singular, domain noun, kebab-case folder)
- **Source signal** (where you saw it: route, docs, filename cluster)
- **Confidence** (high / medium / low)

Present the list via `AskUserQuestion` (multi-select) so the user can keep,
drop, rename, or split features. Sample question:

> "I see these candidate features: `post`, `comment`, `user`, `checkout`, `cart`,
> `notifications`. Confirm which belong in your target architecture, or note
> any to rename/split."

If the project already has `src/features/` (case 1b "Already feature-based"),
treat existing folder names as ground truth and only ask about renames,
merges, or new features.

After confirmation, fix the feature list. No further additions go in this
session's blueprint — additional features get added later via spec.

---

## Step 3: Record architectural decisions explicitly

These are the project-specific decisions that the rules in this skill don't
make for you. Record each decision *and the alternative considered* in the
blueprint's "Decisions" section.

| Decision | Options | How to choose |
|----------|---------|--------------|
| Layer model | `features/ + shared/ + app/` (default) <br/> `features/ + shared/ + entities/ + app/` (FSD) <br/> route-as-app (Next app router) | Default unless the team uses FSD explicitly or the framework is Next app router |
| Cross-feature communication | Composition at app layer only (default) <br/> Event bus (`bound-event-based-communication`) <br/> Shared store slice | Composition unless features need to react to each other without app-layer involvement |
| Server state owner | Server components (RSC) <br/> TanStack Query <br/> SWR <br/> Apollo | Match the stack from 1a; do not introduce a new lib |
| Client state owner | Context-only <br/> Zustand <br/> Redux Toolkit | Match the stack from 1a |
| Routing ownership | Feature-scoped (`bound-feature-scoped-routing`) <br/> App-layer router config | Feature-scoped unless framework imposes app-layer config |
| Public API style | `index.ts` barrel per feature (`import-public-api`) <br/> Named-export entrypoint file <br/> Subpath exports (`features/x/public`) | `index.ts` per feature unless tree-shaking benchmarks force otherwise |
| Shared layer scope | UI primitives + truly generic utils only (`struct-shared-layer`) <br/> Includes domain-agnostic hooks <br/> Includes design system | UI primitives + utils unless a design system package already exists |

For each decision, the blueprint records: *choice*, *rationale*, *rule(s) cited*.

---

## Step 4: Generate the blueprint

Fill in `assets/templates/feature-arch-target.md.template` with everything
collected so far. The template has placeholder sections — every placeholder
must be replaced with concrete project values. Do not ship a blueprint with
literal `{feature-name}` placeholders.

The blueprint goes to `docs/architecture/FEATURE-ARCH-TARGET.md` unless the
project already uses a different docs path; if so, mirror the existing
convention (e.g., `docs/adr/`, `documentation/architecture/`).

Required content discipline:

- **Tree section**: literal path strings (`src/features/checkout/api/submit-payment.ts`),
  not pseudo-trees. Show every directory the agent intends to create or keep.
- **Public API section**: per feature, list named exports of `index.ts` —
  `export { ComponentName }`, `export type { TypeName }`, `export { useHookName }`.
- **Import boundary matrix**: an N×N table where N is the feature count.
  Each cell is one of: `allowed`, `forbidden`, `via app`, `via events`.
- **State ownership**: per feature, list what server state and what client
  state it owns. Cross-cutting state lives in `shared/` and is listed once.
- **Migration plan**: numbered steps. Each step is a single concrete action:
  *move*, *create*, *split*, *rename*, *delete*, *add public export*. Each
  step lists the files involved. Estimate effort (S/M/L) per step.
- **Conformance checklist**: human-checkable items, no tooling commands —
  e.g., `[ ] No file under src/features/* imports from another features/* subtree`.

---

## Step 5: Anchor every claim in a rule

Every section of the blueprint must end with a `**Rules applied:**` line that
links to the rule files in this skill that govern that section. This makes
the blueprint a *projection* of the rules onto the project, not a parallel
authority. Example:

```
**Rules applied:** [struct-feature-folders](../../skills/.curated/feature-arch/references/struct-feature-folders.md),
[struct-feature-self-contained](../../skills/.curated/feature-arch/references/struct-feature-self-contained.md)
```

If a section cannot cite a rule, either (a) it shouldn't be in the blueprint,
or (b) a new rule is missing from the skill and should be raised as a follow-up.

---

## Step 6: Hand off

The final agent message after generating the blueprint should:

1. Print the blueprint path.
2. Summarise: feature count, migration step count, estimated total effort.
3. List the top 3 *highest-risk* decisions for the user to review.
4. Suggest the immediate next action — usually "review the blueprint and run
   `/openspec:proposal` for the first migration step" or equivalent.

Do not start applying migration steps in the same turn. The blueprint is the
deliverable; execution is a separate, user-approved follow-up.

---

## When the project is too small for a blueprint

If the project has fewer than ~10 source files, or no clear domain language
yet, skip the blueprint and instead output a one-page "seed structure" — a
literal target tree for the first feature plus the `app/` and `shared/`
skeletons. Note in the output that this is a seed and a full blueprint should
be generated after the second or third feature exists.
