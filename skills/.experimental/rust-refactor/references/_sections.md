# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Type Safety & Newtype Patterns (type)

**Impact:** CRITICAL
**Description:** Leveraging Rust's type system prevents entire classes of bugs at compile time. Newtype patterns prevent unit confusion and encode invariants.

## 2. Ownership & Borrowing (own)

**Impact:** CRITICAL
**Description:** Correct ownership patterns eliminate borrow checker fights and enable clean refactors. Wrong ownership decisions cascade through entire codebases.

## 3. Error Handling Patterns (err)

**Impact:** HIGH
**Description:** Proper Result/Option usage and error propagation creates maintainable, composable error handling across module boundaries.

## 4. API Design & Traits (api)

**Impact:** HIGH
**Description:** Well-designed public APIs enable future evolution without breaking changes. Trait bounds and generics create flexible, reusable abstractions.

## 5. Module & Visibility (mod)

**Impact:** MEDIUM-HIGH
**Description:** Proper module organization and visibility controls hide implementation details, enabling safe internal refactoring without breaking consumers.

## 6. Conversion Traits (conv)

**Impact:** MEDIUM
**Description:** From/Into/AsRef patterns create flexible, ergonomic APIs that accept multiple input types without code duplication.

## 7. Idiomatic Patterns (idiom)

**Impact:** MEDIUM
**Description:** Standard Rust idioms improve readability, enable tooling support, and make code easier to maintain by following community conventions.

## 8. Iterator & Collections (iter)

**Impact:** LOW-MEDIUM
**Description:** Proper iterator usage reduces boilerplate, improves clarity, and often enables compiler optimizations through lazy evaluation.
