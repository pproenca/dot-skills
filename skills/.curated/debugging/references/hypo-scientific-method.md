---
title: Apply the Scientific Method
impact: CRITICAL
impactDescription: Eliminates 80%+ of random debugging; provides systematic path to root cause
tags: hypo, scientific-method, hypothesis, experiment, systematic
---

## Apply the Scientific Method

Debug like a scientist: observe, hypothesize, predict, test, conclude. This systematic approach eliminates guesswork and ensures you converge on the root cause rather than wandering aimlessly through code.

**Incorrect (random exploration):**

```python
# Bug: Users sometimes get wrong totals in shopping cart

def calculate_total(cart):
    total = 0
    for item in cart.items:
        total += item.price * item.quantity  # Check this
    return total + cart.shipping  # Or check this

# Developer starts adding random print statements
print(f"total: {total}")  # Looks right...
print(f"shipping: {cart.shipping}")  # Looks right...
# Adds more prints, removes some, changes code, reverts...
# 2 hours later: still confused, code is a mess
```

**Correct (scientific method):**

```python
# Bug: Users sometimes get wrong totals in shopping cart

# STEP 1: OBSERVE
# - Total is sometimes higher than expected
# - Happens with certain items, not all orders
# - Difference is always exactly one item's price

# STEP 2: HYPOTHESIZE
# Hypothesis 1: Item counted twice somewhere
# Hypothesis 2: Old cart data mixing with new
# Hypothesis 3: Currency conversion error

# STEP 3: PREDICT (for Hypothesis 1)
# If item is counted twice, the excess should equal
# exactly one item's price in the cart

# STEP 4: TEST
def calculate_total_debug(cart):
    seen_items = []
    total = 0
    for item in cart.items:
        if item.id in seen_items:
            print(f"DUPLICATE FOUND: {item.id}")  # Test prediction
        seen_items.append(item.id)
        total += item.price * item.quantity
    return total + cart.shipping

# STEP 5: CONCLUDE
# Test revealed: item.id appears twice when user clicks
# "Add to Cart" rapidly. Root cause: no debounce on button.
```

**Scientific debugging template:**
1. **Observe:** What exactly do you see? (symptoms, data, errors)
2. **Hypothesize:** What could cause this? (at least 2-3 options)
3. **Predict:** If hypothesis X is true, what else should be true?
4. **Test:** Design experiment to verify/falsify prediction
5. **Conclude:** Was hypothesis correct? Update understanding

**When NOT to use this pattern:**
- Trivial bugs where cause is immediately obvious
- Build/syntax errors with clear error messages

Reference: [MIT 6.031 - Scientific Debugging](https://web.mit.edu/6.031/www/sp17/classes/11-debugging/)
