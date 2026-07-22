---
title: Decision-oriented title, sentence case, no trailing period
tags: prefix, concept, concept
---

## Decision-oriented title, sentence case, no trailing period

Name the wrong default this rule corrects — what a capable model writes here by
default — then its concrete consequence, in 2-5 sentences. Explain the *why*:
the model generalizes from the reason, not the instruction. If you cannot name
what a reader does wrong without this rule, the rule does not belong here.

```ts
// The canonical way. Production-realistic names — posts, invoiceId,
// organizationId — never foo/bar or MyComponent.
const invoice = await ctx.db.invoice.findFirst({ where: { id: invoiceId } });
```

Optional: one or two sentences of follow-through, or a
**When NOT to use this pattern:** paragraph naming a real exception.

Reference: [Source title](https://trpc.io/docs/...)

<!-- Add an **Incorrect:** / **Correct:** pair ONLY when the wrong way is a
     genuine, common trap. Keep the diff minimal — same names, only the key
     line changes. A strawman foil is worse than a single good example.

     Omit impact/impactDescription: this is a correctness skill, not a
     performance one. Never invent a "2-10x" number for an API-correctness rule.

     Cite trpc.io docs, the trpc/trpc source, or a named GitHub issue. Not
     tutorials, listicles, or Stack Overflow. -->
