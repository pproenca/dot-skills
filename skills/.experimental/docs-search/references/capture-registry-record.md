---
title: Write the docs section of knowledge/libraries/<library>.md after a successful lookup
tags: capture, knowledge, reuse, merge-discipline
---

## Write the docs section of knowledge/libraries/<library>.md after a successful lookup

By default each doc lookup is one-shot — the agent discovers the docs root, the changelog URL, the samples repo, and whether `llms.txt` exists, then loses all of that when the session ends. The next agent re-discovers the same facts. The move is to **capture topography findings in the shared knowledge graph at `knowledge/libraries/<library>.md` (docs: section only)** immediately after a successful lookup. The same file is shared with `code-distill` — it owns the `code:` section, this skill owns the `docs:` section, neither overwrites the other.

```text
When to write (apply at end of a real successful lookup):

  - You searched a library's docs and got the right answer → write
  - You probed for llms.txt (found or not) → record the result
  - You found the canonical changelog / samples / upgrades URLs → record

DO NOT write from training-data knowledge alone. Entries are grounded
observations from real WebFetches, not recall.

The docs section of the knowledge record:
```

```yaml
---
library: stripe                       # filename stem, kebab-case
last-verified-date: YYYY-MM-DD        # update on every write

# Shared metadata (any writer may merge into these lists)
uses: []                              # libraries this library depends on
implements: []                        # patterns it implements ([[wiki-links]])
notable-landmarks:
  - /docs/error-codes (canonical error reference)
  - stripe-mock (local test server)

# This skill owns the docs: section
docs:
  root: https://stripe.com/docs
  llms-txt: null                      # probed YYYY-MM-DD, none yet
  api-reference: /docs/api
  changelog: https://stripe.com/changelog
  version-model: dated                # semver | dated | unversioned
  version-selector: api-version URL param
  upgrades: https://stripe.com/docs/upgrades
  samples-repo: https://github.com/stripe-samples
  status-page: https://status.stripe.com
  discord-or-forum: null

# code-distill writes the code: section; do not touch it from here
---
```

The merge discipline (CRITICAL):

- If the file does not exist → create it with `library:`, shared metadata, and `docs:` only
- If the file exists with no `docs:` section → add `docs:` only; do not modify `code:` or other sections
- If the file exists with `docs:` already → update fields under `docs:` and refresh `last-verified-date`; never overwrite the whole file blindly
- For shared list fields (`uses`, `implements`, `notable-landmarks`): merge by union; do not replace

When to refresh:

- On every lookup for this library: re-check changelog URL still resolves; re-probe `llms.txt` if previously null and ≥ 90 days have passed; bump `last-verified-date`
- On major library version bump: full re-verification of all URLs (docs sites get reorganized)
- When a lookup fails because a recorded URL 404s: update in the same session that hit the failure

What NOT to write here:

- Idiomatic rules (those go in a full library-reference distillation skill — see [`library-reference-distillation`](../../library-reference-distillation/SKILL.md))
- API method documentation (the library's docs are the source)
- Opinions or recommendations about the library
- The `code:` section — that is owned by [`code-distill`](../../code-distill/SKILL.md)

The mechanical trigger: at the end of any successful doc-search session for a library whose `docs:` section is missing from `knowledge/libraries/`, write it before closing out. Discovery was already done during the lookup; capturing costs seconds.

Reference: [knowledge/README.md — full schema and merge discipline](../../../../knowledge/README.md)
