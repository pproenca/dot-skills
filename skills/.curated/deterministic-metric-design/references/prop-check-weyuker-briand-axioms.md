---
title: Check Your Measure Against the Weyuker / Briand Axioms
impact: HIGH
impactDescription: prevents structural defects like a non-additive size measure
tags: prop, weyuker, briand-morasca-basili, axioms
---

## Check Your Measure Against the Weyuker / Briand Axioms

Published property sets exist for software measures — Weyuker's nine properties for complexity measures, and the Briand–Morasca–Basili axiomatic definitions for size, length, complexity, cohesion, and coupling. Checking your measure against the *right* set catches structural defects early. A measure labeled "size," for instance, should be non-negative, zero only for the empty artifact, and additive when you concatenate two disjoint modules. A measure that violates the axioms its construct demands is mislabeled — it is measuring something other than what its name claims.

**Incorrect (a "size" measure that isn't additive):**

```python
def size(module):
    return len(set(all_tokens(module)))   # counts DISTINCT tokens (a vocabulary measure)
# size(A ++ B) < size(A) + size(B) whenever A and B share tokens — violates size additivity.
```

**Correct (axiom-respecting size; deviations named):**

```python
# Size axioms (Briand et al.): non-negative; zero iff empty; additive over disjoint modules.
def size(module):
    return count_nodes(parse_to_ast(module))   # additive: size(A ++ B) == size(A) + size(B)
# A non-additive distinct-token count is a legitimate measure — but call it "vocabulary", not "size".
```

Reference: [Briand, Morasca & Basili, "Property-Based Software Engineering Measurement," *IEEE TSE* 22(1) (1996)](https://doi.org/10.1109/32.481535)
