---
title: Make Testable Predictions from Hypotheses
impact: CRITICAL
impactDescription: validates or eliminates hypotheses quickly
tags: hypo, predictions, experiments, scientific-method
---

## Make Testable Predictions from Hypotheses

A hypothesis explains what you've observed; a prediction states what you expect to observe under new conditions. Make predictions before running experiments—if the prediction fails, the hypothesis is wrong.

**Incorrect (no prediction before testing):**

```javascript
// Bug: Shopping cart shows wrong total
// Hypothesis: "Something is wrong with the calculation"
// No prediction—just running code to see what happens

function calculateTotal(items) {
  let total = 0
  for (const item of items) {
    total += item.price * item.quantity
    console.log(total)  // Just watching values with no expectation
  }
  return total
}
```

**Correct (explicit prediction before testing):**

```javascript
// Bug: Shopping cart shows wrong total
// Hypothesis: Discount is applied twice—once in item price, once in total
// Prediction: If discount is double-applied, total will be 20% too low

function calculateTotal(items) {
  let total = 0
  for (const item of items) {
    // Prediction: item.price already has 10% discount applied
    console.log(`Item price: ${item.price}, Expected pre-discount: ${item.originalPrice}`)
    total += item.price * item.quantity
  }
  // Prediction: This line applies discount again
  total = applyDiscount(total, 0.10)  // Bug found: double discount
  return total
}

// Test: Cart with $100 item, 10% discount
// Expected with single discount: $90
// Actual with double discount: $81
// Prediction confirmed: discount applied twice
```

**Good predictions are:**
- Specific and measurable
- Different from what you'd see if the hypothesis were false
- Easy to test with minimal code changes

Reference: [UCSD CSE 15L - The Scientific Debugging Method](https://cseweb.ucsd.edu/classes/wi10/cse15L/c/method.php)
