---
title: Use an object literal with optional fields, or a fluent immutable builder, instead of a mutable Builder class
tags: create, builder, fluent-immutable, partial-type, type-state
---

## Use an object literal with optional fields, or a fluent immutable builder, instead of a mutable Builder class

A model trained on Effective Java's Builder pattern writes `new PizzaBuilder().size(L).addTopping('cheese').setSauce('tomato').build()` — a mutable builder with chained setters returning `this`. In TypeScript, two simpler alternatives almost always apply: (1) an **object literal with optional fields** — `createPizza({ size: 'L', toppings: ['cheese'], sauce: 'tomato' })` — which handles the constructor-with-many-parameters problem in one line; (2) a **fluent immutable builder** — each method returns a *new* builder with the field set — which enables compile-time type-state tracking ("you must call `.size()` before `.build()`"). Reach for the mutable-setters class form only when the builder genuinely needs to be shared between threads / async chains, or when the construction is so step-heavy that the object literal becomes unreadable.

### Shapes to recognize

- A class with a long list of `setX()` methods all returning `this`, ending in `build()`
- A constructor with 5+ parameters and many call sites passing them in different orders (the telescoping-constructor smell that motivates Builder in the first place)
- A `Required<T>` / `Partial<T>` shape where most fields are optional with sensible defaults
- A DSL whose grammar enforces "you must do A before B before C" — type-state territory

**Incorrect (mutable Builder class for an optional-fields case):**

```typescript
class PizzaBuilder {
  private _size: Size = 'M';
  private _toppings: string[] = [];
  private _sauce: Sauce = 'tomato';
  private _crust: Crust = 'regular';

  size(s: Size): this        { this._size = s; return this; }
  addTopping(t: string): this { this._toppings.push(t); return this; }
  sauce(s: Sauce): this      { this._sauce = s; return this; }
  crust(c: Crust): this      { this._crust = c; return this; }

  build(): Pizza {
    return { size: this._size, toppings: this._toppings, sauce: this._sauce, crust: this._crust };
  }
}

const p = new PizzaBuilder()
  .size('L')
  .addTopping('cheese').addTopping('mushroom')
  .sauce('tomato')
  .build();
```

**Correct (object literal with defaults via factory function):**

```typescript
type Pizza = { size: Size; toppings: string[]; sauce: Sauce; crust: Crust };

function createPizza(opts: Partial<Pizza>): Pizza {
  return {
    size: 'M',
    toppings: [],
    sauce: 'tomato',
    crust: 'regular',
    ...opts,
  };
}

const p = createPizza({ size: 'L', toppings: ['cheese', 'mushroom'] });
```

Five lines, no class, no `build()` ceremony. Adding a new field is one `?:` in the type and one default in the factory — the same diff as adding a setter, with less code.

**For the type-state case (must call A before B before C), use a fluent immutable builder:**

```typescript
type QuerySelect<T> = { select: (keyof T)[] };
type QueryFrom<T>   = QuerySelect<T> & { from: string };
type QueryWhere<T>  = QueryFrom<T>   & { where?: Filter<T> };

class Query<S extends Partial<QueryWhere<any>>> {
  constructor(private readonly state: S) {}

  select<T, K extends keyof T>(this: Query<{}>, fields: K[]): Query<QuerySelect<T>> {
    return new Query({ select: fields });
  }
  from<T>(this: Query<QuerySelect<T>>, table: string): Query<QueryFrom<T>> {
    return new Query({ ...this.state, from: table });
  }
  where<T>(this: Query<QueryFrom<T>>, filter: Filter<T>): Query<QueryWhere<T>> {
    return new Query({ ...this.state, where: filter });
  }
  build(this: Query<QueryFrom<any>>): string {
    return `SELECT ${this.state.select.join(', ')} FROM ${this.state.from}`;
  }
}

const sql = new Query({})
  .select<User, 'id' | 'name'>(['id', 'name'])
  .from('users')
  .where({ active: true })
  .build();
// Compile error if you call .where() before .from(), or .build() before .from().
```

Each `this:` constraint enforces that the previous step ran. `new Query(...)` per step gives identity-stable immutable state — safe in shared / async contexts. This pattern appears in Drizzle, Effect's Schema, fp-ts pipes, RxJS observable construction.

### Common pitfalls

- **Forgetting `...opts` LAST.** `{ ...opts, size: 'M' }` always sets `size: 'M'` no matter what the caller passes. The `...opts` must come *after* defaults to allow override. (TypeScript will warn if `opts` is `Required<Pizza>`, but with `Partial<Pizza>` it's silent.)
- **Mutable arrays inside defaults.** `function createPizza(opts: Partial<Pizza>): Pizza { return { toppings: [], ...opts } }` — every default pizza shares the same `[]` reference if you forget to spread `opts.toppings`. Use `toppings: [...(opts.toppings ?? [])]` if subsequent mutation is allowed, or freeze the defaults.
- **Spreading discards undefined-but-present.** `{ ...defaults, size: undefined }` keeps the spread default's `size`. `{ ...defaults, ...opts }` with `opts.size = undefined` ALSO keeps the spread default's `size` only if you use `??` rather than `||`. Subtle but bites.
- **Fluent immutable that mutates `this`.** If a fluent method does `this.state.x = ...; return new Query(this.state)`, you've leaked the mutation back to the previous builder. Always copy the state when constructing the next builder.
- **Builder pattern when nothing demands it.** Adding a builder when a 4-field record with 1 optional field would do is over-engineering. The rule of thumb: if there are <5 fields and order doesn't matter, the object literal wins; if there are >5 fields *and* construction has type-state, the fluent immutable wins.

### Performance trade-offs

- **Object literal + spread:** one allocation per `createPizza` call. Defaults are merged via shallow spread (cheap).
- **Mutable class builder:** one allocation for the builder plus one for the result. Two objects per build. The cheaper-looking method-chained syntax hides this.
- **Fluent immutable builder:** one allocation *per step*. For a 4-step build, four builder instances + the final result. Each is a shallow copy of the previous state. In hot paths (per-render, per-request) this can matter; for app-code one-time-per-something it's negligible.
- **The fluent immutable form is what enables type-state tracking** — every method has a different `this` type because each step returns a different `Query<S>`. That can't be done with a single mutable `this`-returning class. The allocations are paying for the compile-time guarantee.

### When NOT to apply (keep the mutable builder class)

- **Shared state during construction.** Multiple call sites contribute to building one value (the request handler attaches headers, then middleware attaches a body parser, then the route handler attaches a router). Mutating a shared builder is more natural than threading immutable state through each step
- **Genuine DSL with deeply nested grammar.** When you're building a CSS-in-JS engine, an ORM query language, or a UI component tree where the construction grammar is the public API, both the fluent immutable form AND the mutable form are fine — pick whichever the consumers find more readable. Builder classes can win when the grammar has lots of optional repeatable parts (`.addChild()` called N times)
- **Existing convention in the codebase or library.** If every existing builder in the project is `new Foo().setX().setY().build()`, a single fluent-immutable outlier confuses readers. Convention beats marginal improvement

### Related

- GoF class form: [`creational-builder`](../../../.experimental/implementation-design-patterns/references/creational-builder.md)
- Factories that don't need step-by-step construction: [`create-factory-function-over-factory-classes`](create-factory-function-over-factory-classes.md)
- The `Partial<T>` and `Required<T>` utility types: see TS Handbook

Reference: [TS Handbook — Utility Types (`Partial`, `Required`, `Pick`)](https://www.typescriptlang.org/docs/handbook/utility-types.html)
