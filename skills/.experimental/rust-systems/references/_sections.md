# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Project Organization (org)

**Impact:** HIGH
**Description:** Proper workspace structure, crate separation, and directory organization enable maintainability at scale. Feature-based crate grouping and clear binary/library separation reduce coupling and improve build times.

## 2. Module Structure (mod)

**Impact:** HIGH
**Description:** Consistent module organization with explicit declarations, proper re-exports, and co-located tests creates predictable codebases. Flat structures with strategic subdirectories balance simplicity and organization.

## 3. Naming Conventions (name)

**Impact:** HIGH
**Description:** Consistent naming following Rust conventions (RFC 430) makes code self-documenting. Verb prefixes, semantic suffixes, and unit indicators communicate intent without requiring comments.

## 4. Type & Trait Patterns (type)

**Impact:** HIGH
**Description:** Idiomatic struct design with Option<T> for nullable fields, associated types in traits, builder patterns, and proper derive usage create type-safe, ergonomic APIs that leverage Rust's type system.

## 5. Error Handling (err)

**Impact:** HIGH
**Description:** Two-tier error strategy (thiserror for libraries, anyhow for applications), rich error context, graceful degradation for non-critical operations, and proper error propagation create robust systems that fail gracefully.
