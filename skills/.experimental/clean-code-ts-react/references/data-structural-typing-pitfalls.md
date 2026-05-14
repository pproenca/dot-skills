---
title: Beware Structural Typing Aliasing
impact: MEDIUM-HIGH
impactDescription: prevents semantically distinct types from being silently interchangeable
tags: data, structural-typing, nominal, types
---

## Beware Structural Typing Aliasing

TypeScript uses structural (duck) typing — two types with the same shape are interchangeable even when they mean different things. Most of the time this is great ergonomics; occasionally it causes silent bugs. A function that accepts `Point2D` will happily take `Vector2D` because the shape matches, even though adding a position to a velocity is nonsense. When the distinction is load-bearing, brand or tag the types.

**Incorrect (semantically distinct types are interchangeable):**

```ts
// Caller can pass a Vector2D where a Point2D is expected — compiles, makes no sense.
type Point2D  = { x: number; y: number };
type Vector2D = { x: number; y: number };

function distance(a: Point2D, b: Point2D): number {
  return Math.hypot(b.x - a.x, b.y - a.y);
}

const velocity: Vector2D = { x: 3, y: 4 };
const origin:   Point2D  = { x: 0, y: 0 };
distance(origin, velocity); // compiles; semantically wrong
```

**Correct (tag the types so the compiler refuses the mix-up):**

```ts
// Same shape, but the brand makes the kinds incompatible.
type Point2D  = { readonly __kind: 'Point';  x: number; y: number };
type Vector2D = { readonly __kind: 'Vector'; x: number; y: number };

const point  = (x: number, y: number): Point2D  => ({ __kind: 'Point',  x, y });
const vector = (x: number, y: number): Vector2D => ({ __kind: 'Vector', x, y });

function distance(a: Point2D, b: Point2D): number {
  return Math.hypot(b.x - a.x, b.y - a.y);
}

distance(point(0, 0), vector(3, 4)); // Error: Vector2D not assignable to Point2D
```

**When NOT to apply this pattern:**
- Most app code — structural typing is a feature, not a bug; ducktyping JSON shapes from APIs is exactly what you want.
- Distinctions that are purely documentary and never matter at runtime — a `Celsius` vs `Fahrenheit` number in a UI that always shows the unit label is fine as plain `number`.
- Public library APIs where consumers pass their own shaped types — rejecting them on nominal grounds is unfriendly without strong invariant to defend.

**Why this matters:** Structural typing is great default, but when types mean different things — currencies, units, IDs, coordinates — nominal distinction prevents a category of "looks fine, compiles, wrong" bugs.

Reference: [Clean Code, Chapter 6: Objects and Data Structures](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Effective TypeScript: Item 4 — Get Comfortable with Structural Typing](https://effectivetypescript.com/)
