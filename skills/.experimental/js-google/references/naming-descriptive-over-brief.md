---
title: Prefer Descriptive Names Over Brevity
impact: HIGH
impactDescription: significantly improves code comprehension
tags: naming, readability, descriptive, clarity
---

## Prefer Descriptive Names Over Brevity

Use descriptive names that clearly convey purpose. Avoid ambiguous abbreviations and single letters except in very small scopes (under 10 lines).

**Incorrect (cryptic abbreviations):**

```javascript
function procUsrOrds(u, cb) {
  const ords = u.ords;
  for (let i = 0; i < ords.length; i++) {
    const o = ords[i];
    const r = calcTot(o);
    cb(r);
  }
}

function hndlBtnClk(e) {
  const t = e.target;
  const v = t.value;
  updSt(v);
}
```

**Correct (descriptive names):**

```javascript
function processUserOrders(user, callback) {
  const orders = user.orders;
  for (let index = 0; index < orders.length; index++) {
    const order = orders[index];
    const result = calculateTotal(order);
    callback(result);
  }
}

function handleButtonClick(event) {
  const targetElement = event.target;
  const inputValue = targetElement.value;
  updateState(inputValue);
}
```

**Acceptable short names (small scope):**

```javascript
// OK in arrow function with small scope
const totalPrice = items.reduce((sum, item) => sum + item.price, 0);

// OK for standard loop counters in simple loops
for (let i = 0; i < 5; i++) {
  console.log(i);
}
```

**Forbidden abbreviations:**
- Deleting internal letters: `msg` for `message`, `btn` for `button`
- Ambiguous: `tmp`, `data`, `info`, `str`, `num`

Reference: [Google JavaScript Style Guide - Naming rules](https://google.github.io/styleguide/jsguide.html#naming-rules-common-to-all-identifiers)
