---
title: Rule Title Here
tags: prefix, concept
---

## Rule Title Here

Name the wrong default this rule corrects and its concrete consequence, in 1-3
sentences. For this skill that usually means: what a model defaulting to Next.js
14/15 does here, and why it breaks (or silently misbehaves) under Next.js 16
Cache Components. Explain the *why* — the model generalizes from the reason, not
the instruction. Don't restate something the model already does correctly.

```tsx
// The canonical Next.js 16 way. Real, domain-realistic names — not foo/bar.
export default async function CheckoutPage() {
  return (
    <Suspense fallback={<CartSkeleton />}>
      <Cart />
    </Suspense>
  )
}
```

Reference: [Source title](https://nextjs.org/docs/...)

<!-- Add an **Incorrect (…):** / **Correct (…):** pair ONLY when the wrong way is
     a genuine, common trap (e.g. the removed experimental.ppr flag, reading
     cookies() inside use cache, single-arg revalidateTag). Keep the diff minimal.
     A strawman foil is worse than a single good example. -->
