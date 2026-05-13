# Review & Refactor Algorithm

Use this when the user asks to **review, refactor, modernize, or audit React code** — whether one file, a directory, or a whole repository.

**Do not skim this.** The default review reflex — file-by-file, grep-first — produces shallow, inconsistent results on this rule set. The procedure below is engineered to surface the refactors that grep cannot, and to make category skipping observable.

---

## Principle 1 — Judgment over grep

Every single-file rule in this skill names a *pattern shape*, not a syntactic marker. The rule file titles describe the shape; the rule bodies open with **Shapes to recognize** — a list of 2–4 syntactic disguises the same break can wear.

**The decision rule for every rule is: "Does this code break the pattern, in spirit?"** — not "Does this string appear?"

| What grep finds | What grep misses (the high-value refactors) |
|----------------|---------------------------------------------|
| `forwardRef(` in an import | A component that drills a callback ref through 3 props because the author was avoiding `forwardRef` awkwardness |
| `useFormState` symbol | An `onSubmit` handler doing `e.preventDefault()` + manual `useState` for pending/error — a `useActionState` shape in disguise |
| `<Context.Provider>` JSX | A bespoke pub/sub with `useEffect` + module-level Set, replicating what `<Context>` would give for free |
| `useEffect(... [foo])` | A component-level `useState` + effect that exists only to recompute `derived = f(other state)` — i.e. derived state with extra steps |
| `.memo(`, `useMemo(`, `useCallback(` | A child that re-renders on every keystroke because of an inline object passed as a prop, with no memo anywhere — a memoization gap, not a memo overuse |

Use grep/AST **only** to:
- Take inventory at the start (count files, list components, list hooks)
- As a **post-hoc completeness check** after judgment-based review (e.g. confirm zero remaining `forwardRef` calls *after* you finished refactoring)

Never use grep as the primary detector for a rule. If a violation is visible only via grep, it's the easy case — and you'll miss the harder ones. Read each rule's **Shapes to recognize** section *before* sweeping for that rule.

---

## Principle 2 — Category-major sweep, not file-major

When reviewing N files against the 8 single-file categories + Category 9 (cross-cutting), the natural reflex is file-major:

```
for each file:
  for each of 9 categories:
    for each rule in category:
      check file
```

This fails in practice because:
- Late files and low-priority categories silently get skipped due to context fatigue.
- The reviewer never sees the *cross-file patterns* in a category (e.g. "3 of these 5 components have the same derived-state-via-effect bug").
- Cross-cutting findings (dead code, duplicated logic, near-duplicate components) cannot surface from a file-local lens.
- Reports come out file-by-file, which the user has to mentally re-group by theme.

**Do this instead — category-major:**

```
1. Load all target files into context up front.
2. For each of Categories 1-8, in priority order (CRITICAL → HIGH → MEDIUM-HIGH → MEDIUM → LOW-MEDIUM):
     a. State the category's pattern in one sentence (the underlying intent).
     b. Sweep every file simultaneously, looking for breaks of that pattern.
     c. Record findings grouped by category, with file:line references.
3. Run Category 9 (Codebase Hygiene) as a final cross-cutting sweep over the inventory.
4. Emit the required coverage table.
```

---

## Principle 3 — Two modes: scoped vs whole-repo

Whole-repo audits are a real workflow, not a workflow to refuse. The two modes below differ in inventory strategy, not in rule rigor.

| | **Mode A — Scoped audit** | **Mode B — Repository audit** |
|---|---|---|
| **Scope** | Explicit file set, ≤ ~20 files (a feature directory, a PR, a hand-picked set) | A whole tree (`src/`, the repo, a subsystem) — no pre-curated file list |
| **Inventory** | Read every file fully | Glob + classify *without reading bodies*; then read targeted files |
| **Sweep** | Full category-major sweep across every file for every category | Targeted sweeps: top-N files per category by heuristic (see below) + full Category 9 over the inventory |
| **Output** | Findings per category × file | Inventory table + targeted findings + Category 9 findings + explicit gaps |

Both modes emit the same coverage table (Step 4 below).

**Heuristics for Mode B targeted sweeps:**
- Concurrent Rendering → top 10 client components by line count, plus any with `onChange`/`onKeyDown` on long lists.
- Server Components → all files with `'use client'`, all `page.tsx`/`layout.tsx`.
- Actions & Forms → all files matching `<form` JSX.
- Data Fetching → all files containing `await fetch` or `react-helmet`.
- State Management → top 10 components by `useState`/`useReducer` call count.
- Memoization → all files containing `useMemo`/`useCallback`/`React.memo`.
- Effects & Events → top 10 files by `useEffect` call count.
- Component Patterns → all files containing `forwardRef`, all components with > 8 props.
- Category 9 → full inventory.

If a heuristic returns < 3 files, sweep all of them. If it returns > 15, sweep the first 15 ranked and note the truncation in the coverage table.

---

## Procedure

### Step 0 — Pick the mode

| User said | Mode |
|---|---|
| "audit these N files", "review this PR", explicit list | **Mode A** |
| "audit my codebase", "review src/", "modernize this repo", or any whole-tree language | **Mode B** |
| Ambiguous | Ask. Show the file count both modes would produce. |

Never refuse a whole-repo audit — pick Mode B.

### Step 1 — Scope declaration (REQUIRED OUTPUT)

Before any reading, emit this preamble verbatim with the placeholders filled. The user must be able to see what you're about to do.

```
## Audit scope

- **Mode:** A (scoped) | B (repo)
- **Files in scope:** <N total> — <brief breakdown e.g. "37 client components, 8 server components, 4 server actions, 12 hooks">
- **Categories to sweep, in order:**
  1/9 Concurrent Rendering (CRITICAL) — <files to sweep>
  2/9 Server Components (CRITICAL) — <files to sweep>
  3/9 Actions & Forms (HIGH) — <files to sweep>
  4/9 Data Fetching (HIGH) — <files to sweep>
  5/9 State Management (MEDIUM-HIGH) — <files to sweep>
  6/9 Memoization & Performance (MEDIUM) — <files to sweep>
  7/9 Effects & Events (MEDIUM) — <files to sweep>
  8/9 Component Patterns (LOW-MEDIUM) — <files to sweep>
  9/9 Codebase Hygiene (CROSS-CUTTING) — full inventory
```

A scope declaration that omits any category number is a malformed audit — you cannot proceed.

### Step 2 — Inventory pass

Read every file once (Mode A) or glob + classify by filename and top-level imports without reading bodies (Mode B). For each, tag:

- Server Component (no `'use client'`, no hooks that require client)
- Client Component (`'use client'` directive)
- Server Action file (`'use server'`)
- Custom hook module
- Route entry (`page.tsx`, `layout.tsx`)
- Other (utility, types)

In Mode B, this tagging also feeds the Category 9 sweep (e.g. files tagged "Client Component" with hook usage that doesn't need the client become candidates for `cross-boundary-coherence`).

### Step 3 — Category-major sweeps (REQUIRED PROGRESS LINES)

For each of the 9 categories in order, emit a **per-category progress line** *before* sweeping:

```
### Sweeping <N>/9 — <Category Name> (<Impact>) across <M> files
```

Then sweep that category across all in-scope files using its **Shapes to recognize** as the lens (not its API name).

After the sweep, emit one of:
- `**Findings: <K>**` followed by the findings grouped under that heading, OR
- `**Findings: 0** (no breaks of <pattern statement> detected across <M> files)`

A category that gets no progress line is a category that got skipped. **The structure makes skipping observable.**

### Step 4 — Coverage table (REQUIRED OUTPUT)

After all 9 sweeps, emit a coverage table. Rows = categories. Columns = either each file (Mode A) or each tag bucket (Mode B). Cells ∈ `{clean, N findings, n/a}`.

**Mode A example:**

| Category | `Foo.tsx` | `Bar.tsx` | `useUserData.ts` | … |
|---|---|---|---|---|
| 1 Concurrent | clean | 2 findings | n/a | |
| 2 Server Components | n/a | n/a | n/a | |
| … | | | | |
| 9 Codebase Hygiene | applied across all files: 3 findings | | | |

**Mode B example:**

| Category | Client comps (37) | Server comps (8) | Hooks (12) | Routes (6) | Actions (4) |
|---|---|---|---|---|---|
| 1 Concurrent | 10 swept, 4 findings | n/a | n/a | n/a | n/a |
| 2 Server Components | 37 swept (boundary check), 6 findings | 8 swept, 0 findings | n/a | 6 swept, 1 finding | n/a |
| … | | | | | |
| 9 Codebase Hygiene | full inventory: 8 findings (4 dedup, 2 dead code, 2 boundary) | | | | |

The coverage table is non-negotiable. It is the artifact that makes silent skipping impossible — a missing row or a missing column is immediately visible.

### Step 5 — Report findings

Group output **by category**, then by file. For each finding:

- **File:line** — exact location
- **Pattern break** — one sentence, in the spirit of the rule (not "uses `forwardRef`" but "this component wraps `forwardRef` even though no consumer needs the React-18 shape")
- **Suggested refactor** — concrete shape, not just a rule name
- **Rule reference** — link to the rule file

Add a **Cross-file observations** subsection per category when 2+ files share the same break — surface the cluster, don't repeat the explanation.

Category 9 findings have a different shape because they are inherently cross-file:
- **Affected files** — full list, with the canonical version named first if applicable
- **Proposed action** — extract / consolidate / delete / rename / move to server
- **Estimated impact** — bundle bytes saved, files deleted, props normalized
- **Risk** — anything blocking (e.g. dynamic import, external consumer, public API surface)

### Step 6 — Apply (optional)

When the user approves refactors:
- Apply by category, not by file — finish all of category 1 across all files before starting category 2. This makes the diff coherent per concern and easier to review.
- Apply Category 9 refactors **last** — they often touch files modified in earlier categories, and doing them last lets you fold the previous fixes into the consolidated shared hook / component.
- After applying each category, take an inventory pass: re-read the touched files to confirm no regressions introduced.

---

## What this algorithm refuses to do

- **File-major reports** — never emit findings as "## src/Foo.tsx — issues: …" headings. Always group by category.
- **Grep-only findings** — if the only evidence is a string match, re-check by reading the surrounding 30 lines and judging the pattern. Grep is the *trigger*, never the *verdict*.
- **Skipping the scope declaration or coverage table** — these are required artifacts. An audit without them is not an audit.
- **Trivial syntactic rewrites masquerading as refactors** — replacing `<Context.Provider>` with `<Context>` is a codemod, not a refactor. The skill-worthy refactors are the ones that change the *shape* of state and effects, or the *layout* of the codebase.

What this algorithm **does not** refuse, despite an older version of this doc saying so:
- Whole-repo `find` / glob scans — use Mode B with an inventory pass instead.
- Audits without a hand-curated file list — Mode B exists precisely for this.

---

## Quick sanity check before reporting

Before delivering findings, confirm in your head:
- Did I emit the scope declaration with all 9 categories listed?
- Did I emit a progress line for each of the 9 categories?
- For each finding, is the evidence holistic (I read the surrounding code) or just a keyword match?
- Did I surface cross-file clusters where they exist?
- For categories with zero findings, did I emit the explicit "Findings: 0" line?
- Did I run Category 9 as a final cross-cutting sweep, not skip it because it's last?
- Did I emit the coverage table?

If any of these is "no", the audit is incomplete. Go back.
