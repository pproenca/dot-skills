# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Pattern Correctness (pattern)

**Impact:** CRITICAL
**Description:** Invalid patterns cause parse failures or silent mismatches. Patterns must be valid, parseable code that tree-sitter can process.

## 2. Meta Variable Usage (meta)

**Impact:** CRITICAL
**Description:** Incorrect meta variable syntax causes capture failures and unexpected matches. Meta variables are the foundation of pattern flexibility.

## 3. Rule Composition (compose)

**Impact:** HIGH
**Description:** Poor rule composition leads to missed matches or over-matching. Combining atomic, relational, and composite rules requires understanding execution semantics.

## 4. Constraint Design (const)

**Impact:** HIGH
**Description:** Missing or incorrect constraints cause false positives or negatives. Constraints filter matches after pattern matching.

## 5. Rewrite Correctness (rewrite)

**Impact:** MEDIUM-HIGH
**Description:** Incorrect rewrite patterns can introduce bugs into codebases. Rewrites must preserve program semantics while making intended changes.

## 6. Project Organization (org)

**Impact:** MEDIUM
**Description:** Poor organization leads to maintenance burden and rule conflicts. Well-structured projects enable team collaboration and rule reuse.

## 7. Performance Optimization (perf)

**Impact:** MEDIUM
**Description:** Inefficient rules slow down scans on large codebases. Pattern specificity and rule structure affect matching performance.

## 8. Testing & Debugging (test)

**Impact:** LOW-MEDIUM
**Description:** Lack of testing leads to regressions and hard-to-diagnose issues. Testing rules before deployment prevents production surprises.
