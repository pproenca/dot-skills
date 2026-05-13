# Review & Refactor Algorithm

Use this when the user asks to **review, refactor, modernize, or audit Next.js 16 App Router code** — whether one file, a directory, or a whole repository.

**Do not skim this.** The default review reflex — file-by-file, grep-first — produces shallow, inconsistent results on this rule set. The procedure below is engineered to surface the refactors that grep cannot, and to make category skipping observable.

---

## Principle 1 — Judgment over grep

Every single-file rule in this skill names a *pattern shape*, not a syntactic marker. The rule file titles describe the shape; the rule bodies open with **Shapes to recognize** — a list of 2–4 syntactic disguises the same break can wear.

**The decision rule for every rule is: "Does this code break the pattern, in spirit?"** — not "Does this string appear?"

| What grep finds | What grep misses (the high-value refactors) |
|----------------|---------------------------------------------|
| `'use client'` directive | A `layout.tsx` that's marked `'use client'` for one button — the whole layout subtree is now client-rendered |
| `import { Icon } from 'lucide-react'` | A barrel re-export through `components/ui/index.ts` doing the same expensive resolution |
| `cache: 'no-store'` | Manual `Date.now()` in a query string to bust cache implicitly, doing what `revalidateTag` should do declaratively |
| `useEffect(() => fetch(...))` in a Client Component | Initial data fetched on the client via TanStack Query / SWR when the page is server-renderable |
| Missing `<Suspense>` | A single page-level `loading.tsx` that gates an entire dashboard while one slow tile resolves |

Use grep/AST **only** to:
- Take inventory at the start (count routes, list Server Components, list Client Components, list Server Actions)
- As a **post-hoc completeness check** after judgment-based review (e.g. confirm zero remaining barrel-file imports *after* you finished refactoring)

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
- The reviewer never sees the *cross-file patterns* in a category (e.g. "3 of these 5 pages have the same client-side data-fetching bug").
- Cross-cutting findings (dead routes, duplicated server actions, near-duplicate layouts) cannot surface from a file-local lens.
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
| **Scope** | Explicit file set, ≤ ~20 files (a feature directory, a PR, a hand-picked set) | A whole tree (`app/`, the repo, a subsystem) — no pre-curated file list |
| **Inventory** | Read every file fully | Glob + classify *without reading bodies*; then read targeted files |
| **Sweep** | Full category-major sweep across every file for every category | Targeted sweeps: top-N files per category by heuristic (see below) + full Category 9 over the inventory |
| **Output** | Findings per category × file | Inventory table + targeted findings + Category 9 findings + explicit gaps |

Both modes emit the same coverage table (Step 4 below).

**Heuristics for Mode B targeted sweeps:**
- Build & Bundle → all `next.config.{js,ts,mjs}`, all `package.json`, all files matching `import * as` (barrel candidates), top 10 components by line count.
- Caching Strategy → all `app/**/page.tsx`, `app/**/layout.tsx`, `app/**/route.ts`; all files containing `fetch(`, `cache(`, or `'use cache'`.
- Server Components & Data Fetching → all `app/**/page.tsx`, `app/**/layout.tsx`; all files containing `await fetch` or `await db.`.
- Routing & Navigation → all `app/**/page.tsx`, all parallel/intercepting route folders (`@*/`, `(.)*/`), all `proxy.ts`.
- Server Actions & Mutations → all files containing `'use server'` or `<form action={`; all route handlers (`route.ts`).
- Streaming & Loading States → all `loading.tsx`, all `error.tsx`, all files containing `<Suspense>`.
- Metadata & SEO → all `app/**/page.tsx`, `app/**/layout.tsx`, all `sitemap.{ts,xml}`, all `robots.{ts,txt}`, all `opengraph-image.{ts,tsx,png}`.
- Client Components → all files with `'use client'`.
- Category 9 → full inventory.

If a heuristic returns < 3 files, sweep all of them. If it returns > 15, sweep the first 15 ranked and note the truncation in the coverage table.

---

## Procedure

### Step 0 — Pick the mode

| User said | Mode |
|---|---|
| "audit these N files", "review this PR", explicit list | **Mode A** |
| "audit my Next.js codebase", "review app/", "modernize this repo", or any whole-tree language | **Mode B** |
| Ambiguous | Ask. Show the file count both modes would produce. |

Never refuse a whole-repo audit — pick Mode B.

### Step 1 — Scope declaration (REQUIRED OUTPUT)

Before any reading, emit this preamble verbatim with the placeholders filled. The user must be able to see what you're about to do.

```
## Audit scope

- **Mode:** A (scoped) | B (repo)
- **Files in scope:** <N total> — <brief breakdown e.g. "12 pages, 4 layouts, 6 route handlers, 8 Server Actions, 14 Client Components, 2 next.config files">
- **Categories to sweep, in order:**
  1/9 Build & Bundle Optimization (CRITICAL) — <files to sweep>
  2/9 Caching Strategy (CRITICAL) — <files to sweep>
  3/9 Server Components & Data Fetching (HIGH) — <files to sweep>
  4/9 Routing & Navigation (HIGH) — <files to sweep>
  5/9 Server Actions & Mutations (MEDIUM-HIGH) — <files to sweep>
  6/9 Streaming & Loading States (MEDIUM) — <files to sweep>
  7/9 Metadata & SEO (MEDIUM) — <files to sweep>
  8/9 Client Components (LOW-MEDIUM) — <files to sweep>
  9/9 Codebase Hygiene (CROSS-CUTTING) — full inventory
```

A scope declaration that omits any category number is a malformed audit — you cannot proceed.

### Step 2 — Inventory pass

Read every file once (Mode A) or glob + classify by filename and top-level imports without reading bodies (Mode B). For each, tag:

- Server Component (no `'use client'`, no client hooks, typically in `app/` outside `'use client'` files)
- Client Component (`'use client'` directive)
- Server Action file (`'use server'` at top, or contains `'use server'` inside functions)
- Route handler (`route.ts`, exports `GET`/`POST`/etc.)
- Route entry (`page.tsx`, `layout.tsx`, `template.tsx`)
- Special route file (`loading.tsx`, `error.tsx`, `not-found.tsx`, `default.tsx`)
- Metadata file (`sitemap.ts`, `robots.ts`, `opengraph-image.tsx`, `icon.tsx`)
- Config (`next.config.*`, `proxy.ts`)
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

| Category | `app/page.tsx` | `app/dashboard/page.tsx` | `app/api/users/route.ts` | … |
|---|---|---|---|---|
| 1 Build & Bundle | n/a | n/a | n/a | |
| 2 Caching | clean | 2 findings | 1 finding | |
| 3 Server Components | clean | 1 finding | n/a | |
| … | | | | |
| 9 Codebase Hygiene | applied across all files: 3 findings | | | |

**Mode B example:**

| Category | Pages (12) | Layouts (4) | Route handlers (6) | Server Actions (8) | Client Comps (14) | Config (3) |
|---|---|---|---|---|---|---|
| 1 Build & Bundle | 10 swept, 0 findings | n/a | n/a | n/a | 10 swept, 4 findings | 3 swept, 2 findings |
| 2 Caching | 12 swept, 6 findings | 4 swept, 1 finding | 6 swept, 3 findings | 8 swept, 2 findings | n/a | n/a |
| 3 Server Components | 12 swept, 5 findings | 4 swept, 0 findings | n/a | n/a | n/a | n/a |
| … | | | | | | |
| 9 Codebase Hygiene | full inventory: 11 findings (4 dedup, 3 dead routes, 2 boundary, 2 prop drift) | | | | | |

The coverage table is non-negotiable. It is the artifact that makes silent skipping impossible — a missing row or a missing column is immediately visible.

### Step 5 — Report findings

Group output **by category**, then by file. For each finding:

- **File:line** — exact location
- **Pattern break** — one sentence, in the spirit of the rule (not "missing `'use cache'`" but "this server-side fetcher is invoked from three routes and re-runs on every request — should be cached")
- **Suggested refactor** — concrete shape, not just a rule name
- **Rule reference** — link to the rule file

Add a **Cross-file observations** subsection per category when 2+ files share the same break — surface the cluster, don't repeat the explanation.

Category 9 findings have a different shape because they are inherently cross-file:
- **Affected files** — full list, with the canonical version named first if applicable
- **Proposed action** — extract / consolidate / delete / rename / move to server
- **Estimated impact** — bundle bytes saved, files deleted, routes consolidated, props normalized
- **Risk** — anything blocking (e.g. dynamic import, external consumer, public API surface, parallel route)

### Step 6 — Apply (optional)

When the user approves refactors:
- Apply by category, not by file — finish all of category 1 across all files before starting category 2. This makes the diff coherent per concern and easier to review.
- Apply Category 9 refactors **last** — they often touch files modified in earlier categories, and doing them last lets you fold the previous fixes into the consolidated shared module / route.
- After applying each category, take an inventory pass: re-read the touched files to confirm no regressions introduced (especially: did a fix to one rule break a parallel-route or intercepting-route convention?).

---

## What this algorithm refuses to do

- **File-major reports** — never emit findings as "## app/page.tsx — issues: …" headings. Always group by category.
- **Grep-only findings** — if the only evidence is a string match, re-check by reading the surrounding 30 lines and judging the pattern. Grep is the *trigger*, never the *verdict*.
- **Skipping the scope declaration or coverage table** — these are required artifacts. An audit without them is not an audit.
- **Trivial syntactic rewrites masquerading as refactors** — replacing `cache: 'force-cache'` with `'use cache'` is a codemod, not a refactor. The skill-worthy refactors are the ones that change the *shape* of data flow, caching boundaries, and server/client split.
- **Mass cache-tag additions without a revalidation story** — adding `cacheLife` profiles without thinking about what invalidates them is worse than no cache.

What this algorithm **does not** refuse:
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
