---
title: Read only the named knowledge entry; never scan knowledge/libraries/
tags: find, bounded-access, lazy-load, token-cost
---

## Read only the named knowledge entry; never scan knowledge/libraries/

By default once the agent learns there is a knowledge graph under `/knowledge/libraries/`, it does `ls knowledge/libraries/` to "see what's available" before reading the named entry — or reads several entries to "compare." Both burn tokens linearly in the size of the knowledge store. The move is to **treat the filename as the index**: when the user names library X, read exactly `knowledge/libraries/<x-slug>.md` and proceed. The filesystem is the hash table; lazy access is what keeps per-invocation token cost bounded regardless of how many entries accumulate over time.

```text
The bounded-access discipline:

  When the user names library X (or a repo to distill against):
    1. Compute the slug (kebab-case, matching the library's own name):
         "shadcn/ui"      → shadcn-ui
         "base-ui"         → base-ui
         "Effect-ts"       → effect-ts
    2. Try exactly: read knowledge/libraries/<slug>.md
    3a. File exists with a code: section → proceed with that entry
    3b. File exists with no code: section → still read it (for shared
        metadata and the docs: section's hints), then do code discovery
        and capture the code: section at session end
    3c. File does not exist → full discovery (find-classify-query
        through trace-usages-inward); capture findings at session end

  Never:
    - ls knowledge/libraries/ to "see what's available" before
      reading the named entry
    - read multiple library entries to compare unless the user's
      question explicitly requires cross-library comparison
    - read knowledge/README.md on every invocation (only when
      WRITING a new entry)
    - grep across knowledge/libraries/ for keywords (the filename
      is the canonical key)

  The only legitimate multi-entry access:
    - Following a wiki-link: if libraries/shadcn-ui.md has
      uses: [[radix-ui]] AND the query specifically asks about
      what shadcn inherits from Radix, you MAY follow to
      libraries/radix-ui.md
    - Cross-library pattern lookup: if knowledge/patterns/ exists
      (it doesn't yet) and the user asks "what else implements
      composition like X?" — the pattern node lists instances,
      then read only the named instances

Token-cost guardrail:
  Per-invocation knowledge read cost = O(1) when disciplined.
  Per-invocation knowledge read cost = O(N) when undisciplined.
  With N → 100+ entries, the difference is measured in seconds
  and thousands of tokens per query.
```

The mechanical check: before any operation that touches more than ONE file under `knowledge/`, ask "is this strictly required for the named query?" If the answer is "I want to see what's there" or "it might be useful," the answer is no — bound the access to the named entry. If a needed entry doesn't exist, do discovery and capture; do not browse the registry first.

Reference: [knowledge/README.md — Reading from knowledge section codifies the same discipline](../../../../knowledge/README.md)
