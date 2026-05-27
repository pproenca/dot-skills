---
title: Read only the named knowledge entry; never scan knowledge/libraries/
tags: src, bounded-access, lazy-load, token-cost
---

## Read only the named knowledge entry; never scan knowledge/libraries/

By default once the agent learns there is a knowledge graph under `/knowledge/libraries/`, it does `ls knowledge/libraries/` to "see what's available" before reading the named entry — or reads several entries to "compare." Both burn tokens linearly in the size of the knowledge store. The move is to **treat the filename as the index**: when the user names library X, read exactly `knowledge/libraries/<x-slug>.md` and proceed. The filesystem is the hash table; lazy access is what keeps per-invocation token cost bounded regardless of how many entries accumulate over time.

```text
The bounded-access discipline:

  When the user names library X:
    1. Compute the slug (kebab-case, matching the library's own name):
         "shadcn/ui"      → shadcn-ui
         "React Hook Form" → react-hook-form
         "Effect" or "Effect-ts" → effect-ts
    2. Try exactly: read knowledge/libraries/<slug>.md
    3a. File exists → proceed with that single entry
    3b. File does not exist → fall back to discovery (per the
        skill's methodology); capture findings at session end
        per capture-registry-record

  Never:
    - ls knowledge/libraries/ to "see what's available" before
      reading the named entry
    - read multiple entries to compare against each other
    - read knowledge/README.md on every invocation (only read
      it when WRITING a new entry, to confirm schema)
    - grep across knowledge/libraries/ for keywords (the filename
      is already the canonical key)

  The only legitimate multi-entry access:
    - Following a wiki-link from one entry: if libraries/shadcn-ui.md
      has uses: [[radix-ui]], you MAY follow to libraries/radix-ui.md
      — but only if the user's question actually requires the
      upstream dependency. Default: don't traverse, just answer
      from the named entry.

Token-cost guardrail:
  Per-invocation knowledge read cost = O(1) when disciplined.
  Per-invocation knowledge read cost = O(N) when undisciplined.
  With N → 100+ entries, the difference is measured in seconds
  and thousands of tokens per query.
```

The mechanical check: before any operation that touches more than ONE file under `knowledge/`, ask "is this strictly required for the named query?" If the answer is "I want to see what's there" or "it might be useful," the answer is no — bound the access to the named entry and trust the filename-as-index. If a needed entry doesn't exist, do discovery and capture — do not browse the registry first.

Reference: [knowledge/README.md — Reading from knowledge section codifies the same discipline](../../../../knowledge/README.md)
