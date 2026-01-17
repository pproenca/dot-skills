---
title: Explain the Problem Aloud (Rubber Duck)
impact: CRITICAL
impactDescription: Reveals gaps in understanding; 50%+ of bugs found during explanation
tags: hypo, rubber-duck, verbalization, metacognition, explanation
---

## Explain the Problem Aloud (Rubber Duck)

Explain your code and the bug to someone (or something) else, line by line. The act of verbalizing forces you to examine assumptions and often reveals the bug before you finish explaining.

**Incorrect (debugging silently in your head):**

```javascript
// Bug: Function returns wrong result
function calculateDiscount(price, quantity, memberLevel) {
  let discount = 0;
  if (quantity > 10) discount = 0.1;
  if (quantity > 50) discount = 0.2;
  if (memberLevel === 'gold') discount += 0.05;
  if (memberLevel === 'platinum') discount += 0.1;
  return price * quantity * discount;  // Stare at code...
}                                        // Looks right...

// Developer stares at code for 30 minutes
// "I don't see the bug..."
// Keeps re-reading the same lines
```

**Correct (explain to a rubber duck):**

```javascript
// Bug: Function returns wrong result
function calculateDiscount(price, quantity, memberLevel) {
  let discount = 0;

  // "OK duck, this function calculates the discounted price."
  // "First, discount starts at 0..."
  if (quantity > 10) discount = 0.1;
  // "If quantity is over 10, discount is 10%..."
  if (quantity > 50) discount = 0.2;
  // "If over 50, discount is 20%..."
  if (memberLevel === 'gold') discount += 0.05;
  // "Gold members get 5% extra..."
  if (memberLevel === 'platinum') discount += 0.1;
  // "Platinum gets 10% extra..."

  return price * quantity * discount;
  // "Then return price times quantity times discount..."
  // "Wait. That gives the DISCOUNT AMOUNT, not the final price!"
  // "It should be: price * quantity * (1 - discount)"
  // BUG FOUND IN 2 MINUTES
}
```

**Rubber duck debugging process:**
1. Get a rubber duck (or any object, or a colleague)
2. Explain what the code is SUPPOSED to do
3. Explain what it ACTUALLY does, line by line
4. Explain your data at each step
5. The bug usually reveals itself during explanation

**Why this works:**
- Forces you to slow down and be precise
- Exposes assumptions you didn't realize you were making
- Shifts perspective from "writer" to "explainer"
- Engages verbal reasoning alongside visual code reading

**When NOT to use this pattern:**
- Race conditions and timing bugs (hard to verbalize)
- Bugs in code you don't understand at all yet

Reference: [Rubber Duck Debugging](https://rubberduckdebugging.com/)
