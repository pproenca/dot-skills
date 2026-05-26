# Sections

This file defines the four orthogonal categories of moves an agent makes when
distilling a code pattern on demand from a specific GitHub codebase, given a
focused query. The prefix in parentheses is the filename prefix that groups
rules. Categories are ordered by the sequence they fire in a real session:
find the right code → trace it outward and inward → filter noise from
load-bearing → capture findings for reuse.

The four categories are **orthogonal** — getting one right does not help with
the others. Match the symptom in front of you:

- "About to grep blindly or open whole files" → `find`
- "Found the implementation, need to map its public surface or variants" → `trace`
- "Surrounded by boilerplate / legacy / tests; pattern is buried" → `filter`
- "Found the answer; about to close the session" → `capture`

This skill is the **methodology layer** for ad-hoc code-pattern extraction.
Per-library code topography (where shadcn keeps its tokens, where opencode
puts its Effect services, where base-ui defines its slot composition) is
**not** rules — it is reference data living in `registry/<library>.md`,
intentionally empty at v0.1.0 and growing only when real lookups demand new
entries.

A library that gets queried more than ~3 times is **graduating** to a full
static code-atlas distillation skill (the heavy sibling, see
`opencode-ts`, `openai-codex-rust-patterns`, `nextjs-ppr-patterns`). When that
happens, retire the registry entry — the full skill subsumes the topography.

---

## 1. Find (find)

**Description:** Locating the right code given the query. The default failure
mode is grepping blindly for query keywords and opening whole files to read
linearly — both burn tokens and miss the canonical demonstration of intent.
Covers classifying the query into a recognizable kind (component vs
composition vs state vs effect vs error vs build vs routing) which picks
folder hints and grep targets, gripping narrowly before reading, and consulting
tests / `examples/` / `e2e/` as the authors' own canonical usage.

## 2. Trace (trace)

**Description:** Mapping the pattern's surface once you have located it. The
default failure mode is forming a hypothesis from a single file without
checking imports (missing the public boundary) or usages (missing variants
and evolution). Covers following imports outward from the implementation file
to discover the public surface, and following usages inward from the public
surface to see how the pattern is actually consumed in the same repo.

## 3. Filter (filter)

**Description:** Cutting noise from the answer. The default failure mode is
surfacing everything that grepped — boilerplate re-exports, legacy
deprecated paths, test scaffolding, helper utilities — as if all of it were
the pattern. Covers identifying load-bearing code (the implementation that
makes the pattern work) and rejecting noise (re-exports, builders, helpers,
`_old/`/`legacy/` dirs, test scaffolding) before producing the answer.

## 4. Capture (capture)

**Description:** Recording topography findings so the next lookup is cheaper.
The default failure mode is treating each session as one-shot, then
re-discovering the same repo URL, branch, SHA, folder map, and naming
conventions next time. Covers writing a thin code-topography record to
`registry/<library>.md` at the end of a successful session — and graduating
a library to a full static code-atlas skill when it has been queried more
than ~3 times.
