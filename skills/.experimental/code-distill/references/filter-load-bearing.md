---
title: Cut boilerplate, legacy paths, and test scaffolding to surface the load-bearing pattern
tags: filter, load-bearing, noise
---

## Cut boilerplate, legacy paths, and test scaffolding to surface the load-bearing pattern

By default once the agent has gathered candidate code (via find + trace), it reports everything that the greps surfaced as if it were all part of the pattern. The result is a noisy answer full of re-exports, helper utilities, deprecated paths, and test scaffolding — which obscures the load-bearing code that actually makes the pattern work. The move is to **explicitly cut noise** before producing the answer, and to name the cut categories so the user can re-include anything that was wrongly filtered.

```text
The noise categories (cut these from the answer, by default):

  1. Re-exports / barrels
       export { Slot } from "./slot"
       export * from "./internal"
     These are zero-content; they reveal the package shape but
     not the pattern. Mention them in passing ("re-exported from
     X") and do not show the re-export file itself.

  2. Builder / helper utilities
       function createSlotPropsResolver(...) { ... }
     Helpers that exist because the pattern needs them but that
     are not themselves the pattern. Acknowledge their existence;
     do not detail them unless the user asked about a helper.

  3. Legacy / deprecated paths
       packages/<lib>/legacy/, _old/, deprecated/, vN-compat/
       Files marked @deprecated in JSDoc
     Often present in mature libraries during migration. If the
     query is about CURRENT usage, cut these. If the query is
     about migration or version history, surface them as legacy.

  4. Test scaffolding
       describe/it blocks, test fixtures, mock implementations
       conftest.py, setup.ts, __mocks__/
     Tests demonstrate the pattern (find-tests-show-intent) but
     test scaffolding (describe shells, mock builders) is not
     the pattern. Use tests for intent, then cut the wrapping.

  5. Code-style boilerplate
       JSDoc blocks, license headers, type-only re-imports,
       `import type` lines, prettier-formatted whitespace runs
     Always cut unless the user asked about types or licensing.

What COUNTS as load-bearing (keep these):

  - The function/class/component that contains the pattern's
    distinctive verbs (the `cloneElement` for Slot; the
    `Effect.gen` for effect-ts services; the `cva()` call for
    shadcn variants)
  - The hooks/contexts that wire the pattern across the tree
  - The TypeScript generics or constraint that encode the
    pattern's contract
  - Real call sites that demonstrate at least 2 distinct
    variants (per trace-usages-inward)

The audit:
  After drafting the answer, name each piece you included and
  justify its presence with "this is load-bearing because ___."
  If the justification is "it appeared in the grep results," cut
  it. If the justification is "without this, the pattern doesn't
  work," keep it.

Anti-pattern:
  Producing a 12-file dump labeled "here is how X is implemented"
  where 3 files are re-exports, 4 are tests, 2 are deprecated,
  and 3 are helpers. The user wanted the pattern, not a tour of
  the directory.
```

The mechanical trigger: before producing the final answer, list each file/function you are about to include and pass it through the noise categories above. Anything in a noise category is cut unless explicitly justified. The answer becomes 3 load-bearing pieces instead of 12 mixed ones.

Reference: [The library-reference-distillation skill's `source-failure-gap` rule — the same "what would I cut?" discipline applied to rule selection](../../library-reference-distillation/references/source-failure-gap.md)
