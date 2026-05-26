---
title: From the public surface, follow usages inward to see variants and evolution
tags: trace, usages, variants
---

## From the public surface, follow usages inward to see variants and evolution

By default once the agent has identified the public symbol of a pattern (e.g. `Slot` from base-ui), it reports the symbol's signature and stops. This misses the **variants** — the different shapes consumers actually use the pattern in, the edge cases, and how the pattern evolved. The move is to **follow usages inward** by grepping for call sites of the public symbol across the same repo and reporting the variation, not just the abstract definition.

```text
The inward-trace sequence:

  1. From the public symbol P (e.g. `Slot`, `useQueryState`,
     `Effect.gen`), grep across the SAME repo for call sites:

       grep -rn "<P>" --type=ts \
            --glob='!**/dist/**' \
            --glob='!**/node_modules/**'

  2. Categorize the hits:
       - Library-internal usage (the library uses its own symbol
         inside other implementations) → shows the canonical
         compositional pattern
       - Test usage → shows edge cases and contract
       - Example usage → shows the recommended consumer shape
       - Demo / docs usage → shows the marketed usage shape

  3. For each category, sample 2-3 call sites and note the
     PARAMETER PATTERNS:

       Slot variant A:  <Slot>{children}</Slot>     (passthrough)
       Slot variant B:  <Slot asChild>{children}</Slot>
                                                    (delegate)
       Slot variant C:  <Slot ref={ref} {...props}>{children}</Slot>
                                                    (forwarded ref)

  4. Report the SHAPE of variation to the user, with at least one
     concrete example per variant. Variants reveal the pattern's
     real flexibility — and the gaps a static API doc doesn't show.

  5. If a recent commit changed how the pattern is used (renamed
     prop, added a required arg), the inward grep will surface
     BOTH the old and new shapes. That's a drift signal worth
     flagging — describe the current shape, but note when the
     repo is mid-migration.

Why this matters:
  - The abstract type signature `Slot<T>(props: SlotProps<T>): ReactNode`
    is uninformative. The four real call patterns in
    `apps/www/src/registry/` are what teach the pattern.

  - Inward usage also reveals the COMBINATORS — patterns that show
    up when the public symbol is composed with another (e.g. Slot
    + asChild + cloneElement; useQueryState + parseAsInteger +
    .withDefault(0)).

Anti-pattern:
  Reporting "the pattern is `Slot(props)`" with no concrete call
  example. The user asked HOW it's implemented; that means showing
  at least one variant from the real repo, not the type signature.
```

The mechanical trigger: before reporting "the pattern is X" to the user, surface 2-3 concrete call sites from the same repo. If you cannot find 2 distinct variants in the inward grep, treat the pattern as narrower than you thought — or recognize you are looking at an internal helper, not a public surface, and re-run the outward trace.

Reference: [The library-reference-distillation skill's `source-failure-gap` rule — also extracted by tracing rule sources to real call sites in the repo](../../library-reference-distillation/references/source-failure-gap.md)
