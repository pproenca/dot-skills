---
title: Trace Data Flow Through the System
impact: HIGH
impactDescription: 2-5× faster bug localization; pinpoints exact transformation that corrupts data
tags: obs, data-flow, tracing, transformation, pipeline
---

## Trace Data Flow Through the System

When data is incorrect, trace its journey through the system to find where it becomes corrupted. Add checkpoints at each transformation to see values before and after.

**Incorrect (guessing where corruption happens):**

```python
# Bug: Final price is wrong
# Developer checks random places, can't find issue

def handle_purchase(product_id, quantity, user):
    product = get_product(product_id)  # Check here
    price = calculate_price(product, quantity)  # Or here
    discount = get_discount(user)  # Or here
    final = apply_discount(price, discount)  # Or here
    return charge(user, final)  # Or here

# After 2 hours: still don't know where price goes wrong
```

**Correct (trace data through each stage):**

```python
# Bug: Final price is wrong
# Trace data through every transformation

def handle_purchase(product_id, quantity, user):
    product = get_product(product_id)
    print(f"[1] product.price = {product.price}")  # 29.99 ✓

    price = calculate_price(product, quantity)
    print(f"[2] price (qty={quantity}) = {price}")  # 59.98 ✓ (2 × 29.99)

    discount = get_discount(user)
    print(f"[3] discount = {discount}")  # 0.1 ✓ (10%)

    final = apply_discount(price, discount)
    print(f"[4] final = {final}")  # 5.998 ✗ WRONG!
                                   # Expected ~53.98, got 5.998
                                   # apply_discount is buggy!

    return charge(user, final)

# Found in 5 minutes: apply_discount does price*discount, not price*(1-discount)
```

**Data flow tracing template:**

```python
def trace_data(label, data):
    """Consistent checkpoint format"""
    print(f"[{label}] type={type(data).__name__}, value={data}")
    return data  # Pass through for chaining

# Usage:
result = trace_data("step1", fetch_data())
result = trace_data("step2", transform(result))
result = trace_data("step3", validate(result))
```

**For complex pipelines, create a flow diagram:**

```text
Input (correct)
    ↓
[Transform A] ✓
    ↓
[Transform B] ✓
    ↓
[Transform C] ✗ ← Bug is here
    ↓
Output (wrong)
```

**When NOT to use this pattern:**
- Bug is in control flow, not data
- Asynchronous flows where data trace is hard to follow

Reference: [Why Programs Fail - Tracking Origins](https://www.whyprogramsfail.com/)
