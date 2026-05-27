---
title: Write a Falsifiable Operational Definition
impact: HIGH
impactDescription: prevents two implementations producing different numbers for one input
tags: def, operationalization, reproducibility, falsifiability
---

## Write a Falsifiable Operational Definition

An operational definition is the exact procedure that turns an artifact into a number. Without one, "complexity = how hard the code is to understand" is unfalsifiable — two people produce two numbers and neither can be shown wrong. A good operational definition names the input representation, the algorithm, and the output unit precisely enough that an independent implementer reproduces your value to the digit. This is the difference between a metric and an opinion.

**Incorrect (conceptual, not operational):**

```text
Cognitive load: how much mental effort a function demands of a reader.
```

Cannot be computed, cannot be falsified, cannot be compared across reviewers.

**Correct (a procedure anyone can run):**

```text
Cognitive-load proxy := SonarSource Cognitive Complexity, computed as:
  input  = the function's desugared control-flow graph
  rule   = +1 per control-flow break (if / for / while / catch / && / || / ?:)
           +current_nesting_depth extra for each nested break
           +1 per non-trivial recursive call
  output = a count (dimensionless, ratio scale, zero = straight-line code)
```

Every clause is a check an independent implementation must reproduce — so a wrong implementation is detectable.

Reference: [SonarSource, "Cognitive Complexity" whitepaper](https://www.sonarsource.com/resources/cognitive-complexity/)
