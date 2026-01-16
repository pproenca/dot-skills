---
title: Make Intermittent Bugs Deterministic
impact: CRITICAL
impactDescription: 100% reproducibility from random failures
tags: repro, intermittent, flaky, race-conditions
---

## Make Intermittent Bugs Deterministic

Intermittent bugs that "sometimes happen" are often timing-dependent. Introduce artificial delays, increase load, or control random seeds to transform unpredictable failures into reproducible issues.

**Incorrect (hoping to catch the intermittent bug):**

```python
# Bug: "Order total sometimes wrong"
# Approach: Run the test many times and hope it fails

def test_order_total():
    order = create_order()
    add_item(order, price=100)
    add_item(order, price=50)
    assert order.total == 150  # Passes 95% of the time

# Run 100 times, fails randomly, can't debug
```

**Correct (forcing the race condition):**

```python
# Bug: "Order total sometimes wrong"
# Approach: Force the timing issue to occur consistently

def test_order_total_race_condition():
    order = create_order()

    # Simulate concurrent modifications that cause the bug
    with ThreadPoolExecutor() as executor:
        futures = [
            executor.submit(add_item, order, price=100),
            executor.submit(add_item, order, price=50),
        ]
        wait(futures)

    # Now fails consistently: total is 100 or 50, not 150
    # Root cause: Non-atomic total calculation
    assert order.total == 150
```

**Techniques for intermittent bugs:**
- Add `sleep()` calls to widen race windows
- Use thread sanitizers (TSan) to detect races
- Control random seeds for reproducible "random" behavior
- Increase system load to amplify timing issues

Reference: [Cornell CS312 - Debugging Techniques](https://www.cs.cornell.edu/courses/cs312/2006fa/lectures/lec26.html)
