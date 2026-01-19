# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Parser Configuration (parser)

**Impact:** CRITICAL
**Description:** Parser misconfiguration cascades to all transformations - wrong parser produces wrong AST which breaks every subsequent operation.

## 2. AST Traversal Patterns (traverse)

**Impact:** CRITICAL
**Description:** Inefficient traversal creates O(n²) complexity on large codebases, turning seconds into minutes. Strategic find() usage is essential.

## 3. Node Filtering (filter)

**Impact:** HIGH
**Description:** Poor filtering causes incorrect transformations or silent failures. Precise filtering catches edge cases and prevents false positives.

## 4. AST Transformation (transform)

**Impact:** HIGH
**Description:** Builder API misuse creates invalid AST nodes that crash toSource() or produce syntactically incorrect code.

## 5. Code Generation (codegen)

**Impact:** MEDIUM
**Description:** toSource() misconfiguration loses original formatting, causing unnecessary diffs and failed code reviews.

## 6. Testing Strategies (test)

**Impact:** MEDIUM
**Description:** Inadequate testing allows regressions and misses edge cases, causing production incidents when codemods run at scale.

## 7. Runner Optimization (runner)

**Impact:** LOW-MEDIUM
**Description:** Runner configuration affects parallelization and ignore patterns, impacting performance on large codebases.

## 8. Advanced Patterns (advanced)

**Impact:** LOW
**Description:** Composition, scoping, and complex multi-transform patterns for sophisticated codemod architectures.
