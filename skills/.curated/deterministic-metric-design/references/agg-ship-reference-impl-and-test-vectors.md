---
title: Ship a Reference Implementation and Published Test Vectors
impact: LOW-MEDIUM
impactDescription: prevents independent implementations from disagreeing
tags: agg, test-vectors, reference-implementation, adoption
---

## Ship a Reference Implementation and Published Test Vectors

A metric becomes infrastructure only when independent implementations compute the same value — the step that turned cryptographic hashes, RSA, and NDCG from papers into standards was publishing canonical inputs paired with expected outputs. Prose alone yields three tools and three numbers. Ship a reference implementation and a set of test vectors (input, expected value, tolerance) that any conforming implementation must reproduce, so adopters can prove they match before they trust it.

**Incorrect (prose-only definition):**

```text
"Complexity is the number of independent paths through the function."
# Three teams implement three subtly different counts; their numbers never reconcile.
```

**Correct (reference implementation + canonical test vectors):**

```jsonc
// test-vectors.json — any conforming implementation MUST reproduce these exactly
[
  {"input": "fixtures/guard_clauses.py", "metric": "cyclomatic", "expected": 4, "tol": 0},
  {"input": "fixtures/nested_loops.py",  "metric": "cyclomatic", "expected": 7, "tol": 0},
  {"input": "fixtures/empty_module.py",  "metric": "cyclomatic", "expected": 1, "tol": 0}
]
```

Reference: [NIST Cryptographic Algorithm Validation Program — test vectors enabling conformance](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program)
