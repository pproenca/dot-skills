---
title: Demote 'use client' files whose hook usage doesn't require the client
impact: HIGH
impactDescription: shrinks client bundle, allows server rendering, removes hydration cost for static subtrees
tags: cross, use-client, server-components, boundary, bundle-size
---

## Demote 'use client' files whose hook usage doesn't require the client

**This is a cross-cutting rule.** It surfaces when you scan all `'use client'` files together and notice that some don't actually need to be on the client.

### Shapes to recognize

- A file with `'use client'` whose only "hook" is `useId` for an ARIA attribute on otherwise-static markup (`useId` itself is SSR-safe, but the directive turned the whole subtree client).
- A file with `'use client'` that uses `useState` to hold a value initialized once and never updated by an event (you wanted a constant — `useState` is just doing the job of `const`).
- A file with `'use client'` that only renders `children` plus a static wrapper — the directive likely propagated up because of an ancestor and is no longer needed at this level.
- A file with `'use client'` whose interactivity is a single onClick that could be lifted into a small Client island wrapped around the surrounding static content (see [`rsc-composition-pattern.md`](rsc-composition-pattern.md)).
- A file with `'use client'` that imports a heavy library used only for a server-computable transformation (date formatting, markdown rendering against a constant string).

### Detection procedure

1. List every file with `'use client'` in the inventory.
2. For each, classify by why it's a client component:
   - **Real interactivity:** event handlers tied to state changes, refs to DOM measurement, browser-only APIs.
   - **Hooks that require client:** `useEffect`, `useLayoutEffect`, `useReducer` with side-effects, `useSyncExternalStore`, anything from `react-dom`.
   - **Nothing requires client** — directive is vestigial or the file should be split.
3. For category 3 files, propose: drop the directive (if nothing requires client) or split into a static parent + a small client island (if a leaf needs interactivity but most of the file doesn't).

### Multi-file example

**Incorrect (three files, all `'use client'`, none requiring it):**

```typescript
// src/marketing/Hero.tsx
'use client'
import { useId } from 'react'
export function Hero({ heading }: { heading: string }) {
  const id = useId()
  return (
    <section aria-labelledby={id}>
      <h1 id={id}>{heading}</h1>
      <p>Static marketing copy</p>
    </section>
  )
}
// → useId is SSR-safe. No interactivity. Directive shouldn't be here.

// src/layout/Page.tsx
'use client'
import { ReactNode } from 'react'
export function Page({ children }: { children: ReactNode }) {
  return <main className="page">{children}</main>
}
// → Only renders children + wrapper. The directive likely propagated up
//   from an old child component that's since been moved.

// src/blog/PostBody.tsx
'use client'
import { marked } from 'marked'  // 35 KB
export function PostBody({ markdown }: { markdown: string }) {
  const html = marked.parse(markdown)
  return <div className="prose" dangerouslySetInnerHTML={{ __html: html }} />
}
// → marked.parse is pure; markdown is a prop. Should render on the server,
//   the 35 KB library doesn't need to ship to the client.
```

**Correct (all three become Server Components):**

```typescript
// src/marketing/Hero.tsx — directive removed
import { useId } from 'react'
export function Hero({ heading }: { heading: string }) { /* ... */ }

// src/layout/Page.tsx — directive removed
export function Page({ children }: { children: ReactNode }) { /* ... */ }

// src/blog/PostBody.tsx — directive removed, marked runs on the server
import { marked } from 'marked'
export function PostBody({ markdown }: { markdown: string }) {
  const html = marked.parse(markdown)
  return <div className="prose" dangerouslySetInnerHTML={{ __html: html }} />
}
```

**Cross-file observation:**

> 3 of the 14 `'use client'` files have no client-only requirement. Demoting drops ~38 KB from the client bundle and removes hydration cost for ~12% of the route tree.

**Split case** (mixed) — when a file has *one* interactive leaf but most of the tree is static:

```typescript
// Before — entire ProductPage is client because of one button.
'use client'
export function ProductPage({ product }: { product: Product }) {
  const [qty, setQty] = useState(1)
  return (
    <article>
      <ProductHero product={product} />     // static
      <ProductDescription html={product.description} />  // static, heavy
      <ProductReviews reviews={product.reviews} />       // static
      <button onClick={() => addToCart(product.id, qty)}>Add to cart</button>
    </article>
  )
}

// After — server parent, client island only around the interactive leaf.
// ProductPage.tsx (server)
export function ProductPage({ product }: { product: Product }) {
  return (
    <article>
      <ProductHero product={product} />
      <ProductDescription html={product.description} />
      <ProductReviews reviews={product.reviews} />
      <AddToCartButton productId={product.id} />  // ↓ client island
    </article>
  )
}

// AddToCartButton.tsx (client)
'use client'
export function AddToCartButton({ productId }: { productId: string }) {
  const [qty, setQty] = useState(1)
  return <button onClick={() => addToCart(productId, qty)}>Add to cart</button>
}
```

### When NOT to demote

- The file uses `useEffect`, `useLayoutEffect`, `useSyncExternalStore`, or a DOM ref — those are real client requirements.
- The file uses `useState` and *does* update it from an event handler or callback — even if the JSX looks static at a glance.
- The file is imported by a Client Component context provider — the directive may be load-bearing for the tree.

### Risk before demoting

- Demotion changes import semantics: a Server Component cannot import a Client Component freely (and vice-versa).
- After demoting, run the route — Next.js / similar frameworks will throw `You're importing a component that needs ...` if you got it wrong.
- The split case (Server parent + Client island) is the safer refactor when in doubt — it preserves interactivity exactly while moving the static mass off the client.

Reference: [Server and Client Components](https://react.dev/reference/rsc/server-components), [Use Client](https://react.dev/reference/rsc/use-client)
