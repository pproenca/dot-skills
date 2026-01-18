---
title: Never Use eval or Function Constructor
impact: CRITICAL
impactDescription: prevents code injection and CSP violations
tags: lang, security, eval, dynamic-code
---

## Never Use eval or Function Constructor

Dynamic code evaluation with `eval()` or `new Function()` creates security vulnerabilities, breaks static analysis, and violates Content Security Policy. Use safer alternatives.

**Incorrect (eval enables code injection):**

```javascript
function calculateDiscount(formula, price) {
  // User-controlled formula can execute arbitrary code
  return eval(formula.replace('price', price));
}

function createHandler(bodyCode) {
  // Dynamic function creation, same security issues
  return new Function('event', bodyCode);
}

const discount = calculateDiscount('price * 0.1; alert("hacked")', 100);
```

**Correct (safe alternatives):**

```javascript
const DISCOUNT_STRATEGIES = {
  percentage: (price, value) => price * value,
  fixed: (price, value) => Math.max(0, price - value),
  bogo: (price) => price / 2,
};

function calculateDiscount(strategyName, price, value) {
  const strategy = DISCOUNT_STRATEGIES[strategyName];
  if (!strategy) {
    throw new Error(`Unknown discount strategy: ${strategyName}`);
  }
  return strategy(price, value);
}

const discount = calculateDiscount('percentage', 100, 0.1);  // 10
```

**Alternative (JSON for data parsing):**

```javascript
// Instead of eval(jsonString)
const data = JSON.parse(jsonString);
```

Reference: [Google JavaScript Style Guide - Disallowed features](https://google.github.io/styleguide/jsguide.html#disallowed-features-code-not-in-strict-mode)
