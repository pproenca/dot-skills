---
title: Make domain objects valid at construction, not validated at call sites
tags: model, invariants, construction, parse-dont-validate
---

## Make domain objects valid at construction, not validated at call sites

The wrong default is separating construction from validation: a constructor that accepts anything, plus a `validate()` the caller is trusted to invoke. Every path that constructs without validating is a live route for an invariant-violating object to enter the system, and the compiler cannot see the difference. When an object cannot exist in an invalid state, every downstream function is freed from re-checking — that is the payoff the split throws away.

**Evidence of violation:** (a) a validation function separate from construction such that constructing without calling it succeeds — cite the constructor and at least one call path that constructs unvalidated, or the absence of anything preventing it; (b) the same invariant guard duplicated at two or more construction or mutation call sites instead of living inside the constructor/factory; or (c) a constructor that accepts and stores values the type's own docs or tests declare invalid (a negative quantity, an end date before a start date).

**Carve-outs (must be cited to claim):** framework-required bare constructors (an ORM's no-argument constructor) when marked private/internal so no application code path uses them; a single parse-style factory (`OrderLine.parse(raw)`) as the type's only public entry is the fix, not a violation — cite that construction is otherwise inaccessible.

**Incorrect (validity is the caller's homework):**

```ts
export class DateRange {
  constructor(public start: Date, public end: Date) {}
}

export function validateDateRange(range: DateRange): void {
  if (range.end < range.start) throw new InvalidRangeError()
}
// half the call sites remember validateDateRange; the other half ship the bug
```

**Correct (an invalid range cannot exist):**

```ts
export class DateRange {
  private constructor(readonly start: Date, readonly end: Date) {}

  static of(start: Date, end: Date): DateRange {
    if (end < start) throw new InvalidRangeError()
    return new DateRange(start, end)
  }
}
```

Reference: [Eric Evans — Domain-Driven Design Reference: Value Objects, Factories](https://www.domainlanguage.com/ddd/reference/), [Martin Fowler — ValueObject](https://martinfowler.com/bliki/ValueObject.html)
