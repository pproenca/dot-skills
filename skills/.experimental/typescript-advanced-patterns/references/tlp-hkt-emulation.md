---
title: Emulate Higher-Kinded Types with Interface Dictionaries
impact: HIGH
impactDescription: enables generic-over-container abstractions (Functor, Monad, Traversable) without needing native HKTs
tags: tlp, hkt, type-level, abstraction, library-design
---

## Emulate Higher-Kinded Types with Interface Dictionaries

TypeScript lacks native higher-kinded types — you cannot abstract over a type constructor (`F<_>`) the way you abstract over a type (`T`). For most application code this is a non-issue. For library authors building Functor/Monad/Traversable abstractions or polymorphic container utilities, it's a hard wall. The canonical workaround is the *interface-dictionary trick* (fp-ts and Effect both use variants of it): declare a global interface keyed by a string brand, where each container library registers its type constructor, then dispatch through that interface. The result behaves like an HKT for the purpose of authoring generic combinators.

**Incorrect (separate implementations per container — combinatorial explosion):**

```typescript
function mapArray<A, B>(fa: A[], f: (a: A) => B): B[] { return fa.map(f) }
function mapOptional<A, B>(fa: A | null, f: (a: A) => B): B | null { return fa === null ? null : f(fa) }
function mapPromise<A, B>(fa: Promise<A>, f: (a: A) => B): Promise<B> { return fa.then(f) }

// To share a single combinator like `sequence` across all of these, you write
// `sequenceArray`, `sequenceOptional`, `sequencePromise` — three separate functions
// with parallel logic. Adding a new container is 10+ new exports.
```

**Correct (URI dictionary + dispatch):**

```typescript
// 1. The dictionary — open for extension.
interface URItoKind<A> {}
type URIS = keyof URItoKind<unknown>
type Kind<URI extends URIS, A> = URItoKind<A>[URI]

// 2. Each container registers its type constructor.
declare module './hkt' {  // file-relative augmentation
  interface URItoKind<A> {
    Array: A[]
    Optional: A | null
    Promise: Promise<A>
  }
}

// 3. A typeclass over `URI` rather than over a concrete container.
interface Functor<URI extends URIS> {
  map: <A, B>(fa: Kind<URI, A>, f: (a: A) => B) => Kind<URI, B>
}

// 4. Instances.
const ArrayFunctor: Functor<'Array'> = { map: (fa, f) => fa.map(f) }
const OptionalFunctor: Functor<'Optional'> = { map: (fa, f) => fa === null ? null : f(fa) }
const PromiseFunctor: Functor<'Promise'> = { map: (fa, f) => fa.then(f) }

// 5. A combinator that's generic over any Functor.
function double<URI extends URIS>(F: Functor<URI>, fa: Kind<URI, number>): Kind<URI, number> {
  return F.map(fa, n => n * 2)
}

double(ArrayFunctor, [1, 2, 3])             // [2, 4, 6]
double(OptionalFunctor, 5 as number | null)    // 10 | null
double(PromiseFunctor, Promise.resolve(7))  // Promise<number>
```

The dictionary is an interface, which means consumers can declaration-merge new entries (see `[[decl-declaration-merging]]`). That open-extension property is what makes this pattern survive in real ecosystems: fp-ts has dozens of registered URIs added by separate packages.

**When NOT to apply:**
- Application code. The cost (boilerplate, slower hovers, opaque error messages) almost always exceeds the benefit when you don't ship typeclass-style combinators.
- When a single overloaded function would do — overloads are cheaper to read and write than a Functor instance.
- When using libraries (Effect, fp-ts) that already do this for you — extend their existing dictionary rather than starting your own.
- When you only need to abstract over one or two concrete containers — write the two implementations directly; the dictionary's payoff comes from being open-extensible.

**Scope delta:**
- Genuinely new ground — no existing TypeScript skill in this repo covers HKT emulation. This is the single most-requested "advanced" pattern from library authors and the one with the steepest learning curve.

Reference: [fp-ts — Higher Kinded Types](https://gcanti.github.io/fp-ts/recipes/HKT.html)
