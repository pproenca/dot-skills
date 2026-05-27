# Knowledge — Shared Graph of Library and Pattern Facts

A wiki-linked markdown graph of factual knowledge, shared across all skills in this repo. Each file is a node; `[[wiki-links]]` in frontmatter are edges.

This dir is **not a skill** — it has no `SKILL.md`. It is the data layer that skills (like [`docs-search`](../skills/.experimental/docs-search/SKILL.md) and [`code-distill`](../skills/.experimental/code-distill/SKILL.md)) **read from** and **append to**, and that the agent can query directly when it just needs facts.

## Why this exists

Earlier iterations of `docs-search` and `code-distill` each had their own `registry/` subdir, which would have caused:

- **Duplication** — each library queried for both docs and code would have two records that drifted apart.
- **No cross-cutting view** — no way to ask "what else implements composition like shadcn?" without scanning every skill's registry separately.

Moving knowledge outside the skills (into a shared graph) gives **one source of truth per library** and lets the agent traverse relations between libraries when useful.

## Layout

```
knowledge/
  README.md                        ← this file (schema + conventions)
  libraries/                       ← one file per library
    <kebab-slug>.md
    (empty initially; grows from real lookups)
  patterns/                        ← reserved for cross-library patterns
    (not created yet; add when a pattern recurs across ≥ 2 libraries)
```

## Library record schema

Each file at `libraries/<slug>.md` has structured YAML frontmatter with up to three top-level sections plus shared metadata. Either or both of `docs:` and `code:` may be present — they're written by different skills (`docs-search` and `code-distill`) and must not overwrite each other.

```yaml
---
library: shadcn-ui                       # canonical kebab-slug = filename stem

# Cross-cutting relations (wiki-links)
uses: ["[[radix-ui]]", "[[cva]]", "[[tailwindcss]]"]
implements: ["[[composition-via-slot]]"]  # links to patterns/ if/when they exist
similar-to: ["[[base-ui]]"]

# Shared metadata
last-verified-date: YYYY-MM-DD
notable-landmarks:
  - apps/www = dogfood docs site
  - packages/cli = install-by-copy CLI

# Doc topography — written by docs-search
docs:
  root: https://ui.shadcn.com
  llms-txt: null                         # probed YYYY-MM-DD
  api-reference: /docs/components
  changelog: https://github.com/shadcn-ui/ui/releases
  version-model: semver
  upgrades: null
  status-page: null

# Code topography — written by code-distill
code:
  repo: https://github.com/shadcn-ui/ui
  default-branch: main
  last-verified-sha: <SHA>
  agents-md: false
  contributing-md: true
  folder-map:
    components: apps/www/registry/<style>/ui/
    tokens: apps/www/registry/<style>/lib/utils.ts
    examples: apps/www/registry/<style>/example/
  naming-conventions:
    - PascalCase component files
    - cva() for variants
    - cn() for className composition
  package-manager: pnpm workspaces
  lookup-count: 1
---

## Notes

(Optional prose for anything that doesn't fit structured fields.)
```

## Conventions

### Slugs

The filename stem **is** the canonical library key. Use kebab-case lowercase, matching the project's own name (`shadcn-ui` not `shadcn_ui` or `ShadcnUI`). Stable slugs make wiki-links durable.

### Wiki-links

Use Obsidian-style `[[slug]]` syntax for relations. The link target must be a file under `knowledge/` (e.g. `[[radix-ui]]` → `knowledge/libraries/radix-ui.md`). Dangling links are fine — they're a backlog of nodes to write.

### Merge discipline (CRITICAL)

When writing a record, **never overwrite a section you don't own**:

| Section | Owner |
|---------|-------|
| `library:` | first writer (must not change after creation) |
| `docs:` | `docs-search` only |
| `code:` | `code-distill` only |
| `uses:`, `implements:`, `similar-to:` | any writer; merge by union |
| `last-verified-date:` | the writer; reflects the most recent verification |
| `notable-landmarks:` | any writer; merge by union |
| Notes (prose) | any writer; append, don't replace |

If a skill needs to update a section it doesn't own (rare; cross-skill correction), it must read the full file first, modify only its own section, and write back the whole file.

### What does NOT belong here

- **Idiomatic rules** ("always use X over Y") — those go in a full static skill (see `library-reference-distillation` for doc-source skills, or a code-atlas skill like `opencode-ts` for code-source ones).
- **API method documentation** — the library's own docs are the source.
- **Opinions or recommendations**.
- **Personal observations** — those belong in `~/.claude/.../memory/` (the auto-memory system), not here. Knowledge is reusable and shareable; memory is personal.

## Lifecycle

- **Creation** — a library file is created when a skill (`docs-search` or `code-distill`) does a real successful lookup against that library. Never pre-empt.
- **Growth** — incremental. Each successful lookup may refresh `last-verified-date` and (for code) increment `code.lookup-count`.
- **Graduation** — when `code.lookup-count >= 3`, the library has earned a full static code-atlas skill (sibling of `opencode-ts`). Once that skill ships, **delete** this library file and add the library to `code-distill`'s "When NOT to Apply" pointing at the new static skill. The light-layer entry is retired.
- **Eviction** — a library file with `last-verified-date` > 90 days old AND no relations (no `uses`, `implements`, `similar-to`, no inbound wiki-links) is a candidate for deletion. Stale + unconnected = no signal. Delete rather than maintain.

## Reading from knowledge

Skills MUST follow lazy access:

1. The user names a library (e.g. "shadcn-ui").
2. Skill does **exactly** `read knowledge/libraries/shadcn-ui.md`.
3. If file exists → proceed with that single entry.
4. If file does not exist → fall back to live discovery (per the skill's methodology), then capture the result at end of session.

Never scan `knowledge/libraries/` to "see what's available" before reading the named entry. The filename **is** the index.

## Graph queries

When useful (not pre-empted), the agent can traverse the graph:

- **Forward links**: `read knowledge/libraries/shadcn-ui.md` → see `uses: [[radix-ui]]` → `read knowledge/libraries/radix-ui.md`.
- **Backward links** (less common): `grep -l "\[\[shadcn-ui\]\]" knowledge/libraries/` returns every node that links back.
- **Pattern instances**: when `knowledge/patterns/` exists, a pattern node lists its `instances:` array — directly answers "which libraries implement composition?"

The graph is **opt-in**; basic library lookups don't need it.
