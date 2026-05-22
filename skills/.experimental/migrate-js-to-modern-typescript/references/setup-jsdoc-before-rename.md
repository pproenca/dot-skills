---
title: Type JS with JSDoc and ts-check Before Renaming
impact: HIGH
impactDescription: prevents type errors at rename time
tags: setup, jsdoc, ts-check, bridge
---

## Type JS with JSDoc and ts-check Before Renaming

You can add types and fix type errors inside a `.js` file using a `// @ts-check` comment and JSDoc annotations, with no change to the build. When you later flip the extension to `.ts`, the file already type-checks — separating the risky semantic work from the mechanical rename so a rename never lands a wall of new errors.

**Incorrect (rename first — every type error surfaces at once):**

```javascript
// payments.js renamed straight to payments.ts with no prior typing.
function chargeCard(amount, currency) {
  return gateway.charge({ amount, currency })
}
// On rename: amount and currency are implicit any, gateway is untyped,
// and the return type is unknown — all surfacing in one overwhelming pass.
```

**Correct (annotate in place with JSDoc, then rename when green):**

```javascript
// @ts-check
/**
 * @param {number} amount
 * @param {"usd" | "eur"} currency
 * @returns {Promise<ChargeResult>}
 */
function chargeCard(amount, currency) {
  return gateway.charge({ amount, currency })
}
// Errors are found and fixed here, in JavaScript. The later rename to
// payments.ts is then a no-op for the type checker.
```

Reference: [Type Checking JavaScript Files](https://www.typescriptlang.org/docs/handbook/intro-to-js-ts.html)
