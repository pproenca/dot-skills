# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Context Discovery (ctx)

**Impact:** CRITICAL
**Description:** Before making any changes, understand project conventions by reading CLAUDE.md, linting configs, and existing patterns. Project standards override generic guidance. Scoping to recently modified code is covered in the Scope Management section.

## 2. Behavior Preservation (behave)

**Impact:** CRITICAL
**Description:** Simplification must never change what code does - only how it is written. Outputs, error handling, side effects, and API surfaces must remain identical.

## 3. Scope Management (scope)

**Impact:** HIGH
**Description:** Focus on recently modified code only. Keep diffs small and reviewable. Avoid unrelated refactors, global rewrites, or architectural changes.

## 4. Control Flow Simplification (flow)

**Impact:** HIGH
**Description:** Reduce nesting through early returns and guard clauses. Avoid nested ternaries. Prefer explicit control flow over dense expressions.

## 5. Naming and Clarity (name)

**Impact:** MEDIUM-HIGH
**Description:** Use precise, intention-revealing names. Nouns for data, verbs for actions. Descriptive names over implicit abbreviations.

## 6. Duplication Reduction (dup)

**Impact:** MEDIUM
**Description:** Extract helpers when code appears 3+ times and extraction improves clarity. Avoid single-use abstractions that obscure intent.

## 7. Dead Code Elimination (dead)

**Impact:** MEDIUM
**Description:** Remove unused code, redundant comments, and obsolete patterns. Delete rather than comment out. Keep comments that explain "why" not "what".

## 8. Language Idioms (idiom)

**Impact:** LOW-MEDIUM
**Description:** Apply language-specific patterns that improve clarity: TypeScript strict types, Rust ownership, Python comprehensions, Go error handling.
