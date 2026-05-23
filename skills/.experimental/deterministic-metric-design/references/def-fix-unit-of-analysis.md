---
title: Fix the Unit of Analysis and the Measurement Boundary
impact: HIGH
impactDescription: prevents incomparable values from silently mixed scopes
tags: def, unit-of-analysis, boundary, comparability
---

## Fix the Unit of Analysis and the Measurement Boundary

The same construct measured at different units (statement, function, file, module, service) yields different and non-comparable numbers, and an unstated boundary — does it include tests? generated code? vendored dependencies? — means two runs measure different populations. Pin the unit and the boundary once: comparisons and aggregates are only valid within the same unit and the same boundary. Boundary drift is a silent corruptor because the formula looks unchanged while the population underneath it shifts.

**Incorrect (unit and boundary drift):**

```python
# duplication ratio — computed per-file here, per-repo elsewhere, and the corpus
# silently includes generated protobuf stubs that are ~90% identical to each other
def duplication(path):
    files = glob(f"{path}/**/*.py")          # includes *_pb2.py, migrations, vendor/
    return cloned_tokens(files) / total_tokens(files)
# "12% duplication" cannot be compared to last week's "5%" — different scope each run.
```

**Correct (unit + boundary declared and enforced):**

```python
# Unit of analysis: a first-party module.  Boundary: authored source only.
EXCLUDE = ("*_pb2.py", "migrations/*", "vendor/*", "*/tests/*")
def duplication(module_dir):
    files = [f for f in glob(f"{module_dir}/**/*.py") if not matches_any(f, EXCLUDE)]
    return cloned_tokens(files) / total_tokens(files)   # per-module, authored code
# Cross-module and week-over-week comparisons now measure the same population.
```

Reference: [Fenton & Bieman, *Software Metrics*, Ch. 2 — entities and attributes](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
