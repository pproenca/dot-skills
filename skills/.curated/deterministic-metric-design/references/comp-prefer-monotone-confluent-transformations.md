---
title: Build "Size After Rewriting" From Confluent, Terminating Transforms
impact: HIGH
impactDescription: prevents an order-dependent, non-deterministic fixed point
tags: comp, confluence, term-rewriting, well-defined
---

## Build "Size After Rewriting" From Confluent, Terminating Transforms

When a metric is "size after applying transformation set T to a fixed point," the result must not depend on the order transforms were applied, or the metric is not even a function — the same input yields different numbers on different runs. A rewrite system that is *confluent* (Church–Rosser: any application order reaches the same normal form) and *terminating* guarantees a unique fixed point, making the metric well-defined and deterministic. Without confluence, "the reduced size" is ambiguous and the proxy silently becomes non-deterministic.

**Incorrect (order-dependent rewriting → ambiguous result):**

```python
# inline-then-extract and extract-then-inline reach different fixed points, so
# size_after_T is not a function of the input — its value varies with application order.
def size_after_T(program):
    while changed:
        program = apply_in_arbitrary_order([inline, extract, fold], program)
    return size(program)
```

**Correct (normalize to a canonical form — confluent and terminating):**

```python
# Restrict T to a confluent, terminating rewrite set (each rule strictly decreases a
# well-founded measure). The normal form is unique regardless of application order.
def size_after_T(program):
    canonical = normalize_to_canonical_form(program)   # confluent + terminating ⇒ unique
    return size(canonical)
```

Prove termination with a well-founded measure that every rule decreases; prove local confluence and apply Newman's lemma to get global confluence. This is the computability-side guarantee behind the determinism rules in `det-`.

Reference: [Baader & Nipkow, *Term Rewriting and All That*, Cambridge University Press](https://www.cambridge.org/core/books/term-rewriting-and-all-that/71768055278D0DC3DC8B093F9DC8E5C5)
