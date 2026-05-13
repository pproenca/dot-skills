# Conform Algorithm — Bringing Existing Code In Line With These Conventions

Use this when the user asks to **conform, modernize, or align existing components with this skill's conventions** across one or more files (e.g. "make these match our scaffolded shape", "modernize this folder to the React 19 conventions", "audit this PR against our scaffolding rules").

For brand-new code, ignore this doc — go directly to a template. This algorithm exists for the *retrofit* case, where templates can't be used directly.

---

## Principle 1 — Judgment over grep

Every convention in [`conventions.md`](conventions.md) is anchored to a syntactic marker (`forwardRef`, `<Context.Provider>`, `react-helmet`, `e.preventDefault()`, `react-dom/test-utils`). Those markers are **easy to grep for and easy to miss the point of.**

**The decision rule for every convention is: "Does this code break the convention, in spirit?"** — not "Does this string appear?"

| What grep finds | What grep misses (the high-value conforms) |
|----------------|-------------------------------------------|
| `forwardRef(` in an import | A component drilling a `setRef` callback through 3 props because the author was avoiding `forwardRef` awkwardness |
| `<Context.Provider>` JSX | A bespoke `useState` + module-level Set pub/sub re-implementing context |
| `onSubmit=` JSX attribute | A form using `<button onClick>` + manual `useState({ pending, error })` — the exact `useActionState` shape without the name |
| `react-helmet` import | A `useEffect(() => { document.title = ... }, [...])` hand-roll |
| `react-dom/test-utils` import | A test calling `flushSync` + `unstable_*` to coerce render order |
| `useRef<T>()` | `useRef<T>(undefined as any)` casting tricks |

Use grep/AST **only** to:
- Take inventory at the start (count files, list components, list templates that *would* apply)
- As a **post-hoc completeness check** after judgment-based review (e.g. confirm zero remaining `forwardRef` after refactor)

Never use grep as the primary detector for a convention violation. The judgment-based reads catch the disguised cases.

---

## Principle 2 — Convention-major sweep, not file-major

For N files against 12 conventions, the natural reflex is file-major (walk each file, check all 12 conventions). It fails the same way it fails for the `react` skill: late files and low-priority conventions get silently skipped, and cross-file clusters stay invisible.

**Do this instead — convention-major:**

```
1. Load all target files into context up front (read them all before starting).
2. For each convention in conventions.md, in priority order (see below):
     a. State the convention's pattern in one sentence (the intent, not the marker).
     b. Sweep every applicable file simultaneously, looking for breaks of that pattern.
     c. Record findings grouped by convention, with file:line references.
3. After all conventions are swept, present findings ordered by convention × severity.
```

### Convention priority order

`conventions.md` lists conventions topically. For a sweep, walk them in this priority:

1. **Refs as regular prop, not `forwardRef`** — HIGH (deprecated path; codemod available)
2. **Context: `<Context value={...}>`, not `.Provider`** — HIGH (deprecated path)
3. **Forms: server action, not `onSubmit` for mutations** — HIGH (progressive enhancement; pending state correctness)
4. **State derivation: render-time, not effects** — HIGH (correctness — sync holes; covers a large surface)
5. **`useRef<T>(null)` always pass initial value** — MEDIUM (TS breaking change)
6. **External subscriptions: `useSyncExternalStore`, not manual `useEffect` + listeners** — MEDIUM (concurrent-safe)
7. **Test imports: `act` from `react`/`@testing-library/react`, never `react-dom/test-utils`** — MEDIUM (removed in 19)
8. **Server-side validation, always** — MEDIUM (security)
9. **Server Components by default, Client by exception** — MEDIUM (bundle size)
10. **Exhaustive switches in reducers** — LOW (catches a class of bugs at compile time)
11. **Custom hook naming: `use{Verb}{Noun}` / `use{Noun}`** — LOW (clarity)
12. **File naming + import grouping** — LOW (cosmetic, formatter-equivalent)

---

## Procedure

### Step 0 — Confirm the file set

Get the explicit list of files from the user. Don't sweep an unbounded directory.

### Step 1 — Inventory pass

Read every file once. Tag each as:

- Component (Server or Client — note which)
- Custom hook module
- Reducer module
- Context provider
- Form / action module
- Test file
- Other

Use the tag set to filter applicable conventions per file (e.g. "Server-side validation" applies only to action modules; "Exhaustive switches in reducers" applies only to reducer modules).

### Step 2 — Convention-major sweep

For each convention in the priority order above, do one pass over all applicable files. For each file, ask: "Does this code achieve the convention's intent, in spirit?"

When you find a break, record:
- **File:line** — exact location
- **Pattern break** — one sentence in the spirit of the convention ("this form uses `e.preventDefault()` + manual `useState({ pending, error })` — the exact `useActionState` shape, without the name")
- **Conform action** — the concrete shape change needed (point to a template if one applies: e.g. "shape matches `form-action.tsx.template` — replace with that shape")

### Step 3 — Report findings

Group by convention. Within a convention, group by file. Add a **Cross-file observations** subsection per convention when 2+ files share the same break.

### Step 4 — Apply (optional)

When the user approves:
- Apply by convention, not by file — finish all of convention 1 across all files before starting convention 2.
- For mechanically-replaceable cases (`<Context.Provider>` → `<Context>`, `forwardRef` removal), prefer the official codemods and note them. Don't reinvent.
- After applying a convention, take an inventory pass to confirm no regressions.

---

## What this algorithm refuses to do

- **Sweep an unbounded directory** — demand a scope.
- **File-major reports** — never emit findings as "## src/Foo.tsx — issues: …" headings. Always group by convention.
- **Grep-only findings** — read the surrounding 30 lines before declaring a break. Grep is the trigger, never the verdict.
- **Cosmetic-only sweeps that look like refactors** — `<Context.Provider>` → `<Context>` is a codemod. The skill-worthy conforms are the shape changes (form refactors to `useActionState`, derived state moved to render, external subscriptions to `useSyncExternalStore`).

---

## Quick sanity check before reporting

- Did I sweep every applicable convention against every applicable file?
- For each finding, is the evidence holistic (I read the surrounding code) or just a keyword match?
- Did I surface cross-file clusters where they exist?
- Did I propose a template (or codemod) where one fits, instead of hand-writing the shape?
- If a convention had zero findings, did I say so explicitly?
