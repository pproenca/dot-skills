---
title: Rule Title Here
tags: prefix, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. Explain the *why* — the model generalizes from the reason, not the
instruction. Don't restate something the model already does correctly.

For this skill, a rule only earns its place if the answer differs because the
dialect is PostgreSQL or because the code runs inside the Next.js App Router.
Dialect-agnostic Drizzle advice belongs in a different skill.

```typescript
// The canonical way. Real, domain-realistic names — not foo/bar.
const [invoice] = await db.select().from(invoices).where(eq(invoices.id, invoiceId))
```

Reference: [Source title](https://example.com)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap. Keep the diff minimal. A strawman foil is worse than
     a single good example.

     Verify API claims against the installed package, not from memory:
       npm pack drizzle-orm@<version> && tar xzf drizzle-orm-*.tgz
     Type definitions under package/pg-core/ are the authority. -->
