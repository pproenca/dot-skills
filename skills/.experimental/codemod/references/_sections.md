# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. AST Understanding (ast)

**Impact:** CRITICAL
**Description:** Understanding AST structure is foundational for all transformations. Wrong tree interpretation leads to incorrect matches, missed transformations, and broken code.

## 2. Pattern Efficiency (pattern)

**Impact:** CRITICAL
**Description:** Patterns are evaluated millions of times across large codebases. Inefficient or overly generic patterns create multiplicative performance problems.

## 3. Parsing Strategy (parse)

**Impact:** CRITICAL
**Description:** Parser selection determines AST structure. Wrong parser choice cascades through the entire pipeline, producing invalid matches and failed transforms.

## 4. Node Traversal (traverse)

**Impact:** HIGH
**Description:** Efficient navigation reduces O(n^2) to O(n) operations. Proper traversal strategies prevent redundant work across large codebases.

## 5. Semantic Analysis (semantic)

**Impact:** HIGH
**Description:** Cross-file symbol resolution enables safe refactoring. Understanding definitions and references prevents breaking changes during migrations.

## 6. Edit Operations (edit)

**Impact:** MEDIUM-HIGH
**Description:** Proper edit batching prevents conflicts and preserves formatting. Edit ordering affects transform reliability in multi-step operations.

## 7. Workflow Design (workflow)

**Impact:** MEDIUM-HIGH
**Description:** Workflow structure determines parallelization, state management, and resumability. Poor design leads to failed migrations and manual intervention.

## 8. Testing Strategy (test)

**Impact:** MEDIUM
**Description:** Comprehensive testing prevents production incidents. Fixture-based validation catches edge cases before deployment.

## 9. State Management (state)

**Impact:** MEDIUM
**Description:** Proper state handling enables resumable, idempotent migrations. State persistence is critical for large-scale, multi-day transformations.

## 10. Security and Capabilities (security)

**Impact:** LOW-MEDIUM
**Description:** JSSG's deny-by-default security model requires explicit capability grants. Minimal permissions reduce attack surface for untrusted codemods.

## 11. Package Structure (pkg)

**Impact:** LOW
**Description:** Proper packaging enables discoverability, version management, and CI/CD integration. Well-structured packages are reusable and maintainable.
