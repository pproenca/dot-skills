---
title: Write the code section of knowledge/libraries/<library>.md after a successful session
tags: capture, knowledge, reuse, merge-discipline, graduation
---

## Write the code section of knowledge/libraries/<library>.md after a successful session

By default each code-distill session is one-shot — the agent discovers the repo URL, branch, SHA, folder map, and naming conventions, then loses all of that when the session ends. The next agent re-discovers the same facts. The move is to **capture topography findings to the shared knowledge graph at `knowledge/libraries/<library>.md` (code: section only)** after each successful session, and to **graduate libraries with ≥ 3 lookups to a full static code-atlas distillation skill**. The file is shared with `docs-search`, which writes the `docs:` section — this skill owns the `code:` section, neither overwrites the other.

**Write when** you have just distilled a pattern from a repo, the answer was correct, and the discovery work (folder map, AGENTS.md/CONTRIBUTING.md presence, naming conventions) is fresh from this session. Do **not** write from training-data recall — entries are grounded observations from the session that just completed.

The code section of the knowledge record:

```yaml
---
library: shadcn-ui                       # filename stem, kebab-case
last-verified-date: YYYY-MM-DD

# Shared metadata (any writer may merge into these lists)
uses: ["[[radix-ui]]", "[[cva]]", "[[tailwindcss]]"]
implements: []
notable-landmarks:
  - apps/www = dogfood docs site
  - packages/cli = install-by-copy CLI

# docs-search writes the docs: section; do not touch it from here

# This skill owns the code: section
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
    tests: limited; demo apps act as integration tests
  naming-conventions:
    - PascalCase component files
    - cva() for variant definitions
    - cn() for className composition
  package-manager: pnpm workspaces
  lookup-count: 1
---
```

The merge discipline (CRITICAL):

- If the file does not exist → create with `library:`, shared metadata, and `code:` only
- If the file exists with no `code:` section → add `code:` only; do not modify `docs:` or other sections
- If the file exists with `code:` already → update fields under `code:`, increment `code.lookup-count`, refresh `last-verified-date` and `code.last-verified-sha`
- For shared list fields (`uses`, `implements`, `notable-landmarks`): merge by union; do not replace

When to refresh:

- On every session: increment `code.lookup-count`, refresh `code.last-verified-sha`, refresh `last-verified-date`
- If the folder map changed: update it; note the change in the prose Notes section
- If the SHA is more than ~30 days behind on a fast-moving repo: re-verify before relying on the record
- If the repo was renamed/moved/archived: update or delete the file in the same session

The graduation rule. When `code.lookup-count >= 3` on a single library, the library has earned a full static code-atlas distillation skill (see `opencode-ts`, `openai-codex-rust-patterns`, `nextjs-ppr-patterns` for the heavy form). Once shipped:

1. **Delete** `knowledge/libraries/<library>.md` (the whole file, not just the `code:` section — if `docs-search` also wants to keep its data, that's a separate decision; usually the static skill subsumes both)
2. Add the library to this skill's "When NOT to Apply" with a pointer to the new static skill
3. The library moves out of this light layer into the heavy layer

Do NOT write here:

- Specific code patterns or idioms (those go in the static code-atlas skill if/when authored)
- Opinions about the library
- A stale SHA without a verification date
- The `docs:` section (that is owned by [`docs-search`](../../docs-search/SKILL.md))

The mechanical trigger: at the end of any successful code-distill session for a library whose `code:` section is missing from `knowledge/libraries/`, write it before closing out. If the section exists but is more than ~30 days old, refresh it. Discovery was already done during the session; capturing costs seconds.

Reference: [knowledge/README.md — full schema, wiki-link conventions, and merge discipline](../../../../knowledge/README.md)
