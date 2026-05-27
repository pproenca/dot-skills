---
title: Avoid Defining a Metric as an Uncomputable Ideal
impact: CRITICAL
impactDescription: prevents defining a metric no Turing machine can compute
tags: comp, kolmogorov-complexity, uncomputability, proxy
---

## Avoid Defining a Metric as an Uncomputable Ideal

The most elegant definition of "smallest equivalent program" is its Kolmogorov complexity — the length of the shortest program that reproduces the behavior. K is uncomputable: no total algorithm outputs K(x) for all inputs x. A metric defined as K, or as any quantity from which K could be recovered, can never be computed — it is a definition that *forbids* measurement. Recognize the uncomputable ideal, then deliberately step down to a computable proxy and state, in the spec, that you have done so and in which direction the proxy errs.

**Incorrect (metric defined in terms of K):**

```python
# reducibility = nodes used beyond the theoretical minimum for this behavior
def reducibility(program):
    return size(program) - kolmogorov_complexity(program)   # K is UNCOMPUTABLE
# kolmogorov_complexity() cannot exist as a total function — this never runs correctly.
```

**Correct (computable proxy, ideal acknowledged):**

```python
# Ideal (uncomputable): size(P) - K(P).
# Proxy: size removed by a fixed, computable, behavior-preserving rewrite set T.
# The proxy is a sound LOWER BOUND on the ideal (see comp-design-a-proxy-with-a-proven-error-direction).
def reducibility_proxy(program, T):
    canonical = normalize(program, T)         # apply T to a unique fixed point (confluence rule)
    return size(program) - size(canonical)    # always computable, always <= ideal
```

**A principled computable stand-in:** Minimum Description Length approximates the *spirit* of K with a real codelength when you need whole-corpus compressibility rather than per-program reduction.

Reference: [Li & Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 4th ed.](https://link.springer.com/book/10.1007/978-3-030-11298-1)
