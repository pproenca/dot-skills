# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Type Safety & Patterns (type)

**Impact:** CRITICAL
**Description:** Leveraging Rust's type system prevents entire classes of bugs at compile time. Newtype patterns prevent unit confusion, encode invariants, and replace stringly-typed APIs. Builder patterns, associated types, and trait objects create type-safe, ergonomic APIs.

## 2. Ownership & Borrowing (own)

**Impact:** CRITICAL
**Description:** Correct ownership patterns eliminate borrow checker fights and enable clean refactors. Wrong ownership decisions cascade through entire codebases, forcing defensive cloning and limiting API flexibility.

## 3. Error Handling (err)

**Impact:** HIGH
**Description:** Two-tier error strategy (thiserror for libraries, anyhow for applications), rich error context, graceful degradation, and proper error propagation create robust systems that fail gracefully with actionable diagnostics.

## 4. API Design & Traits (api)

**Impact:** HIGH
**Description:** Well-designed public APIs enable future evolution without breaking changes. Trait bounds, generics, sealed traits, and extension traits create flexible, reusable abstractions.

## 5. Project Organization (org)

**Impact:** HIGH
**Description:** Proper workspace structure, crate separation, and directory organization enable maintainability at scale. Feature-based crate grouping and clear binary/library separation reduce coupling and improve build times.

## 6. Module & Visibility (mod)

**Impact:** MEDIUM-HIGH
**Description:** Consistent module organization with explicit declarations, proper re-exports, and co-located tests creates predictable codebases. Flat structures with strategic subdirectories balance simplicity and organization.

## 7. Naming Conventions (name)

**Impact:** MEDIUM-HIGH
**Description:** Consistent naming following Rust conventions (RFC 430) makes code self-documenting. Verb prefixes, semantic suffixes, and unit indicators communicate intent without requiring comments.

## 8. Conversion Traits (conv)

**Impact:** MEDIUM
**Description:** From/Into/AsRef patterns create flexible, ergonomic APIs that accept multiple input types without code duplication. Proper conversion trait implementation reduces boilerplate and follows Rust idioms.

## 9. Idiomatic Patterns (idiom)

**Impact:** MEDIUM
**Description:** Standard Rust idioms improve readability, enable tooling support, and make code easier to maintain by following community conventions like Default, let-else, and destructuring.

## 10. Iterator & Collections (iter)

**Impact:** LOW-MEDIUM
**Description:** Proper iterator usage reduces boilerplate, improves clarity, and often enables compiler optimizations through lazy evaluation.
