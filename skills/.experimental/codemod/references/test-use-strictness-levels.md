---
title: Choose Appropriate Test Strictness Level
impact: MEDIUM
impactDescription: reduces false test failures by 50-90%
tags: test, strictness, comparison, formatting
---

## Choose Appropriate Test Strictness Level

Use the `--strictness` flag to control how output is compared to expected. Stricter levels catch more issues but may fail on formatting differences.

**Incorrect (wrong strictness for transform type):**

```bash
# Using strict mode for a transform that reorders imports
npx codemod jssg test ./import-sorter.ts --strictness strict

# Test fails even though output is semantically correct:
# Expected: import { a, b } from 'x';
# Actual:   import { b, a } from 'x';
# These are functionally identical but strict mode fails
```

**Correct (appropriate strictness for transform type):**

```bash
# Use loose mode for transforms that may reorder elements
npx codemod jssg test ./import-sorter.ts --strictness loose
# Passes: ignores import ordering differences

# Use strict mode for formatting-sensitive transforms
npx codemod jssg test ./preserve-whitespace.ts --strictness strict
# Catches: any whitespace changes that shouldn't happen

# Use ast mode for semantic transforms
npx codemod jssg test ./api-migration.ts --strictness ast
# Passes: as long as AST is equivalent
```

**Strictness level guide:**

| Level | Compares | Use When |
|-------|----------|----------|
| `strict` | Exact string | Formatting must be preserved |
| `cst` | Syntax tree | Whitespace changes acceptable |
| `ast` | Abstract tree | Only semantics matter |
| `loose` | Semantic | Reordering is acceptable |

**Recommendation:** Start with `strict`, relax only when the transform naturally produces equivalent but differently-formatted output.

Reference: [JSSG Testing](https://docs.codemod.com/jssg/testing)
