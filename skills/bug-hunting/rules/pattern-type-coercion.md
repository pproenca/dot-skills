---
title: Watch for Type Coercion Bugs
impact: MEDIUM
impactDescription: prevents silent data corruption bugs
tags: pattern, type-coercion, javascript, implicit-conversion
---

## Watch for Type Coercion Bugs

Type coercion bugs occur when languages implicitly convert between types. JavaScript is notorious for this: string concatenation instead of addition, truthy/falsy surprises, and loose equality comparisons.

**Incorrect (implicit type coercion):**

```javascript
// Bug 1: String concatenation instead of addition
function calculateTotal(price, tax) {
  return price + tax  // If tax is "10" (string): "100" + "10" = "10010"
}
calculateTotal(100, document.getElementById('tax').value)  // Input values are strings!

// Bug 2: Falsy zero treated as missing
function getDiscount(discount) {
  return discount || 10  // Returns 10 when discount is 0!
}
getDiscount(0)  // Expected: 0, Actual: 10

// Bug 3: Loose equality surprises
if (userId == null) {  // True for both null AND undefined
  // ...
}
'0' == false  // true (wat)
[] == false   // true (double wat)
```

**Correct (explicit type handling):**

```javascript
// Fixed 1: Parse input explicitly
function calculateTotal(price, tax) {
  const numericTax = parseFloat(tax)
  if (isNaN(numericTax)) {
    throw new Error('Invalid tax value')
  }
  return price + numericTax
}

// Fixed 2: Explicit undefined check
function getDiscount(discount) {
  return discount !== undefined ? discount : 10
  // Or with nullish coalescing: discount ?? 10
}
getDiscount(0)  // Correctly returns 0

// Fixed 3: Strict equality
if (userId === null) {  // Only true for null, not undefined
  // ...
}
'0' === false  // false (correct)
[] === false   // false (correct)
```

**Type coercion danger zones:**
- Form input values (always strings)
- JSON parsed numbers (may be strings)
- Query parameters (always strings)
- Arithmetic with mixed types
- Boolean coercion of 0, "", null, undefined

Reference: [TMS Outsource - What is Debugging](https://tms-outsource.com/blog/posts/what-is-debugging/)
