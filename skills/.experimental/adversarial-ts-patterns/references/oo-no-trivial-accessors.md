---
title: No trivial get/set pairs mirroring a private field
tags: oo, accessors, encapsulation, readonly
---

## No trivial get/set pairs mirroring a private field

The wrong default is the JavaBean reflex — a `private _name` with a `get name()` and `set name(v)` that forward it unchanged. In Java the accessor pair future-proofs a binary API; TypeScript properties are already interception points (a field can become an accessor later without changing call sites), so the pair buys nothing today and nothing later. The Google TypeScript style guide makes it a hard rule — at least one accessor of a pair must be non-trivial; do not define pass-through accessors only to hide a property; make it public, or `readonly` if only reads are wanted.

**Evidence of violation:** a getter/setter pair on a class where both bodies only return or assign the backing field, with no validation, transformation, or side effect in either. A lone non-trivial accessor (a getter that computes, a setter that validates) is compliant. There is no other carve-out — read-only exposure is `public readonly`, not a getter over a private field.

**Incorrect (pass-through pair hides a plain property):**

```ts
class Invoice {
  private _dueDate: Date
  get dueDate(): Date { return this._dueDate }
  set dueDate(value: Date) { this._dueDate = value }
}
```

**Correct (public field; readonly when writes are not wanted):**

```ts
class Invoice {
  constructor(public dueDate: Date, public readonly number: string) {}
}
```

Reference: [Google TypeScript Style Guide — Getters and setters](https://google.github.io/styleguide/tsguide.html#features-classes-getters-and-setters)
