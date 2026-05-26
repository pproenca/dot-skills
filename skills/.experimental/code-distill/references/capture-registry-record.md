---
title: After a successful session, write a thin code-topography record to registry
tags: capture, registry, reuse, graduation
---

## After a successful session, write a thin code-topography record to registry

By default each code-distill session is one-shot — the agent discovers the repo URL, branch, SHA, folder map, and naming conventions, then loses all of that when the session ends. The next agent re-discovers the same facts. The move is to **capture topography findings to `registry/<library>.md` after each successful session**, and to **graduate libraries with > 3 lookups to a full static code-atlas distillation skill**. The registry is the cumulative memory of every distillation that has run.

**Write a record when** you have just distilled a pattern from a repo, the answer was correct, and the discovery work (folder map, AGENTS.md/CONTRIBUTING.md presence, naming conventions) is fresh from this session. Do **not** write a record from training-data recall — entries are grounded observations from the session that just completed.

The minimum-viable code-topography record (~30 lines):

```yaml
---
library: shadcn-ui
repo: https://github.com/shadcn-ui/ui
default-branch: main
last-verified-sha: <SHA>
last-verified-date: YYYY-MM-DD
agents-md: false                 # no AGENTS.md at root
contributing-md: true            # at /CONTRIBUTING.md
folder-map:
  components: apps/www/registry/<style>/ui/
  tokens: apps/www/registry/<style>/lib/utils.ts (cn function)
  examples: apps/www/registry/<style>/example/
  docs: apps/www/content/docs/
  tests: (limited; demo apps act as integration tests)
naming-conventions:
  - PascalCase component files (Button.tsx)
  - cva() for variant definitions
  - cn() for className composition
  - Radix slot composition via @radix-ui/react-slot
package-manager: pnpm workspaces
notable-landmarks:
  - apps/www is the dogfood docs site
  - packages/cli is the install-by-copy CLI
lookup-count: 1
---
```

**Updating an existing record**, on each successful session: increment `lookup-count`, refresh `last-verified-sha` and `last-verified-date`. Update the folder map if it changed. If the SHA is more than ~30 days behind on a fast-moving repo, re-verify before relying on the record.

**The graduation rule.** When `lookup-count >= 3` on a single library, the library has earned a full static code-atlas distillation skill (see `opencode-ts`, `openai-codex-rust-patterns`, `nextjs-ppr-patterns` for the heavy form). Once shipped: retire (delete) `registry/<library>.md`, add the library to this skill's "When NOT to Apply" with a pointer to the new static skill, and the library moves out of this light layer into the heavy layer.

**Do NOT put in a record**: specific code patterns or idioms (those go in the static skill if/when authored), opinions about the library, or a stale SHA without a verification date.

The mechanical trigger: at the end of any successful code-distill session for a library that does not yet have a registry record (or that has one with > 30 days since last verification), write or update the record before closing out. The discovery work was already done during the session; capturing it is free.

Reference: [The docs-search skill's `capture-registry-record` rule — same discipline applied to doc topography instead of code](../../docs-search/references/capture-registry-record.md)
