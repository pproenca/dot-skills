---
title: Use Array Literals Instead of Array Constructor
impact: MEDIUM
impactDescription: avoids single-argument ambiguity
tags: data, arrays, literals, constructor
---

## Use Array Literals Instead of Array Constructor

Use array literal syntax `[]` instead of `new Array()`. The constructor behaves unexpectedly with a single numeric argument, creating sparse arrays.

**Incorrect (Array constructor ambiguity):**

```javascript
// Creates array with 3 empty slots, not [3]!
const items = new Array(3);
console.log(items.length);  // 3
console.log(items[0]);       // undefined (sparse)

// This works but is inconsistent
const values = new Array(1, 2, 3);  // [1, 2, 3]

// Mixing styles
const orders = new Array();
orders.push({ id: 1 });
```

**Correct (array literals):**

```javascript
const items = [3];  // Array containing number 3
console.log(items.length);  // 1
console.log(items[0]);       // 3

const values = [1, 2, 3];

const orders = [];
orders.push({ id: 1 });
```

**Exception (pre-allocating fixed size):**

```javascript
// Explicitly creating fixed-size array is OK
const buffer = new Array(1024);
for (let i = 0; i < buffer.length; i++) {
  buffer[i] = 0;
}

// Or use Array.from for initialization
const zeros = Array.from({ length: 1024 }, () => 0);
```

**With spread and methods:**

```javascript
// Concatenating arrays
const allItems = [...itemsA, ...itemsB];

// Creating from iterable
const chars = [...'hello'];

// Array.of for single numeric value
const singleNumber = Array.of(3);  // [3]
```

Reference: [Google JavaScript Style Guide - Array literals](https://google.github.io/styleguide/jsguide.html#features-arrays-ctor)
