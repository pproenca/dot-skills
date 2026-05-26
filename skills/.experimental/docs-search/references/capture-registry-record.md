---
title: After a successful lookup, write a thin topography record to registry
tags: capture, registry, reuse
---

## After a successful lookup, write a thin topography record to registry

By default each doc lookup is one-shot — the agent discovers the docs root, the changelog URL, the samples repo, and whether `llms.txt` exists, then loses all of that when the session ends. The next agent re-discovers the same facts. The move is to **capture topography findings in `registry/<library>.md` immediately after a successful lookup**, so subsequent lookups skip the discovery phase. The registry is the cumulative memory of every doc-search that has run.

```text
When to write a registry record (apply at end of a real lookup):

  - You searched a library's docs and succeeded → write the entry
  - You probed for llms.txt (found or not) → record the result
  - You determined the version selector convention → record it
  - You found the canonical changelog/samples URLs → record them

  DO NOT write a record from training-data knowledge alone. Entries
  are grounded observations from real WebFetches, not recall. If
  you didn't actually consult the source during this session, do
  not invent the record.

The minimum-viable record (~30 lines, see registry/README.md):

  ---
  library: stripe
  docs-root: https://stripe.com/docs
  llms-txt: null                    # probed YYYY-MM-DD, none yet
  api-reference: /docs/api
  changelog: https://stripe.com/changelog
  version-model: dated              # e.g. 2023-10-16
  version-selector: api-version URL param
  upgrades: https://stripe.com/docs/upgrades
  samples-repo: https://github.com/stripe-samples
  status-page: https://status.stripe.com
  discord-or-forum: null            # has Slack-style community
  notable-landmarks:
    - /docs/error-codes (canonical error reference)
    - stripe-mock (local test server)
    - Workbench (in-product API explorer)
  last-verified: YYYY-MM-DD
  ---

What to refresh and when:

  - On every lookup for this library: re-check changelog URL
    still resolves; re-probe llms.txt if it was previously null
    and more than 90 days have passed
  - When the library ships a major version: full re-verification
    of all URLs (docs sites are reorganized at major version bumps)
  - When a lookup fails because a recorded URL 404s: update the
    record in the same session that hit the failure

What NOT to put in registry:

  - Idiomatic rules (those belong in a full library-reference
    distillation skill, see [[library-reference-distillation]])
  - API method documentation (the docs themselves are the source)
  - Opinions about the library
```

The mechanical trigger: at the end of any successful doc-search session for a library that does not yet have a registry record, write one before closing out. The work to write the record was already done during the lookup — capturing it costs seconds and saves the next agent minutes.

Reference: [The library-reference-distillation skill's `meta-references-checksum` rule — same discipline applied to a different artifact](../../library-reference-distillation/references/meta-references-checksum.md)
