# Review & Refactor Algorithm

Use this when the user asks to **review, refactor, modernize, or audit React code across one or more files** (e.g. "audit these 12 files for React 19", "find issues in this PR", "modernize this directory").

**Do not skim this.** The default review reflex — file-by-file, grep-first — produces shallow, inconsistent results on this rule set. The procedure below is designed to surface the refactors that grep cannot.

---

## Principle 1 — Judgment over grep

Every rule in this skill is keyed off a syntactic marker (`forwardRef`, `useFormState`, `<Context.Provider>`, an effect with a state setter inside, etc.). Those markers are **easy to grep for and easy to miss the point of.**

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

Never use grep as the primary detector for a rule. If a violation is visible only via grep, it's the easy case — and you'll miss the harder ones.

---

## Principle 2 — Category-major sweep, not file-major

When reviewing N files against the 44 rules, the natural reflex is file-major:

```
for each file:
  for each of 8 categories:
    for each rule in category:
      check file
```

This fails in practice because:
- Late files and low-priority categories silently get skipped due to context fatigue.
- The reviewer never sees the *cross-file patterns* in a category (e.g. "3 of these 5 components have the same derived-state-via-effect bug").
- Reports come out file-by-file, which the user has to mentally re-group by theme.

**Do this instead — category-major:**

```
1. Load all target files into context up front (read them all before starting the analysis).
2. For each category, in priority order (CRITICAL → HIGH → MEDIUM-HIGH → MEDIUM → LOW-MEDIUM):
     a. State the category's pattern in one sentence (the underlying intent, not the syntactic marker).
     b. Sweep every file simultaneously, looking for breaks of that pattern.
     c. Record findings grouped by category, with file:line references.
3. After all 8 categories are swept, present findings ordered by category × severity.
```

The category-major order means every file gets the same scrutiny per category. It also means cross-file patterns surface naturally ("the Form / Profile / Settings components all do derived state via effect").

---

## Procedure

### Step 0 — Confirm the file set

Ask the user (or take from their request) the **explicit set of files**. Do not start with a directory glob without confirmation — sweeping a whole repo wastes context. If the user said "this PR", get the diff file list.

### Step 1 — Inventory pass

Read every file once. For each, jot a 1-line tag:

- Server Component (no `'use client'`, no hooks that require client)
- Client Component (`'use client'` directive)
- Server Action file
- Custom hook module
- Route entry (`page.tsx`, `layout.tsx`)
- Reducer / context provider
- Other (utility, types)

This tag set drives which categories apply to which files (e.g. "Server Components" category doesn't apply to a custom hook file).

### Step 2 — Category-major sweep

Walk categories in priority order. For each category, do **one pass over all files**, with the pattern statement loaded as the lens.

The category sections in `_sections.md` give you the impact; the rule files give you incorrect/correct examples. Read the rule examples as **shape exemplars**, not as regex patterns. The example shows the canonical break; your job is to recognize the same break in different clothing.

**Category 1 — Concurrent Rendering (CRITICAL)**
Pattern: heavy work and navigation should not block input. Look for: missing `useTransition` around obviously-expensive setState calls; unguarded list re-renders; `<Suspense>` fallbacks that swap in for fast components and cause flicker; missing `<Activity>` for tabs/modals that need state preservation.

**Category 2 — Server Components (CRITICAL)**
Pattern: data should be fetched on the server; the client/server boundary should be as deep in the tree as possible. Look for: `'use client'` at the root of a component tree that doesn't need it; client components doing `fetch()` in `useEffect`; non-serializable values (functions, class instances) passed across the boundary; static content rendered inside a client island.

**Category 3 — Actions & Forms (HIGH)**
Pattern: mutations are form actions, not `onSubmit`. Pending state comes from `useFormStatus` / `useActionState`. Look for: `e.preventDefault()` + `useState` for `pending`/`error` (a `useActionState` shape in disguise); client-only validation with no server check; optimistic updates done manually with `useState` instead of `useOptimistic`.

**Category 4 — Data Fetching (HIGH)**
Pattern: parallel where possible, cached at the request scope, declarative loading via Suspense, metadata inline. Look for: sequential `await` calls where `Promise.all` would parallelize; duplicate fetches in the same request (each component fetching the same user); `react-helmet` / manual `<head>` writes; manual `<link rel="preload">` tags; `useEffect` + `useState` fetch dance instead of `use()` or a Server Component.

**Category 5 — State Management (MEDIUM-HIGH)**
Pattern: derived values are computed in render. Context is split so unrelated consumers don't re-render. Complex state lives in a reducer. Look for: `useState` + `useEffect` that exists only to mirror a computed value; one giant context with state + dispatch causing unrelated re-renders; nested `useState` calls that should be a reducer; expensive initial state computed on every render instead of via the lazy initializer.

**Category 6 — Memoization & Performance (MEDIUM)**
Pattern: don't memo by default — let React Compiler handle it — but DO memo when a measurable cost is present. Look for: `useMemo` wrapping trivial work (string concat, simple math); `useCallback` on every handler without justification; missing memo where an expensive prop is recomputed inline (inline object/array passed to a memoed child negates the memo).

**Category 7 — Effects & Events (MEDIUM)**
Pattern: effects synchronize with external systems. They are NOT for derived state, mutations, parent notification, app init, or external subscriptions (use `useSyncExternalStore`). Look for: effects whose body is `setOther(...)` — that's derived state; effects whose body is a side-effect after a state change — that's the event handler's job; effects with `[obj]` or `[arr]` dependencies — those compare by reference and re-run unexpectedly.

**Category 8 — Component Patterns (LOW-MEDIUM)**
Pattern: `ref` is a regular prop; controlled vs uncontrolled is a deliberate choice; composition over prop explosion; `key` resets identity intentionally. Look for: `forwardRef` wrappers; ref drilled through props because the author dodged `forwardRef`; components with 12+ props that should accept `children`; uncontrolled→controlled flips mid-lifecycle.

### Step 3 — Report findings

Group output **by category**, then by file. For each finding:

- **File:line** — exact location
- **Pattern break** — one sentence, in the spirit of the rule (not "uses `forwardRef`" but "this component wraps `forwardRef` even though no consumer needs the React-18 shape")
- **Suggested refactor** — concrete shape, not just a rule name
- **Rule reference** — link to the rule file for the user to read deeper

Add a **Cross-file observations** subsection per category when 2+ files share the same break — surface the cluster, don't repeat the explanation.

### Step 4 — Apply (optional)

When the user approves refactors:
- Apply by category, not by file — finish all of category 1 across all files before starting category 2. This makes the diff coherent per concern and easier to review.
- After applying a category, take an inventory pass: re-read the touched files to confirm no regressions introduced.

---

## What this algorithm refuses to do

- **Greenfield codebase scans without a file set** — don't `find . -name '*.tsx' | xargs` 800 files into context. Demand a scope.
- **File-major reports** — never emit findings as "## src/Foo.tsx — issues: …" headings. Always group by category.
- **Grep-only findings** — if the only evidence is a string match, re-check by reading the surrounding 30 lines and judging the pattern. Grep is the *trigger*, never the *verdict*.
- **Trivial syntactic rewrites masquerading as refactors** — replacing `<Context.Provider>` with `<Context>` is a codemod, not a refactor. The skill-worthy refactors are the ones that change the *shape* of state and effects.

---

## Quick sanity check before reporting

Before delivering findings, ask yourself:
- Did I sweep every category against every applicable file, or did I bail early?
- For each finding, is the evidence holistic (I read the surrounding code) or just a keyword match?
- Did I surface cross-file clusters where they exist?
- If a category had zero findings, did I say so explicitly (negative result is information)?
