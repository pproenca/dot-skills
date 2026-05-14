---
title: Use Intention-Revealing Names
impact: CRITICAL
impactDescription: eliminates the mental mapping a reader must do on every read
tags: name, intention, clarity, naming
---

## Use Intention-Revealing Names

A name should answer why a value exists, what it represents, and how it is used — without forcing the reader to scan the surrounding code or a comment. If you must explain a variable in a comment, the variable itself is under-named. The cost of choosing a good name is paid once; the cost of decoding a bad one is paid on every read.

**Incorrect (cryptic name forces the reader to reverse-engineer intent):**

```tsx
// Reader must guess: what is d? what unit? what is `getThem`? Why `x[0] === 4`?
const d = 86400000;

function getThem(theList: number[][]): number[][] {
  const list1: number[][] = [];
  for (const x of theList) {
    if (x[0] === 4) list1.push(x);
  }
  return list1;
}
```

**Correct (name carries the intent so no comment is needed):**

```tsx
// Reader knows immediately: it's milliseconds in a day, and we're filtering flagged cells.
const MILLIS_PER_DAY = 86400000;

type Cell = { status: number; value: number };
const FLAGGED = 4;

function getFlaggedCells(board: Cell[]): Cell[] {
  return board.filter((cell) => cell.status === FLAGGED);
}
```

**When NOT to apply this pattern:**
- Loop counters in tight scopes (`for (let i = 0; i < items.length; i++)`) — `i` is universally understood and renaming to `index` adds noise without clarity.
- Math operations where conventional single letters are the domain vocabulary: `x`, `y`, `dx`, `dy` in geometry; `m`, `b` in `y = mx + b`. The convention itself is the intent.
- Trivial lambda parameters where the surrounding call already names the intent: `orders.filter((o) => o.total > 0)` is fine; renaming `o` to `order` is a style choice, not a clarity gain.

**Why this matters:** Names are the cheapest form of documentation, and unlike comments they cannot drift out of sync with the code they describe.

Reference: [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock on naming for type narrowing](https://www.totaltypescript.com/)
