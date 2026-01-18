# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Module System & Imports (module)

**Impact:** CRITICAL
**Description:** Module structure, import ordering, and dependency management prevent loading failures and circular dependencies that break applications.

## 2. Language Features (lang)

**Impact:** CRITICAL
**Description:** Proper use of modern JS features (const/let, classes, arrow functions) prevents subtle bugs, improves reliability, and enables tooling optimization.

## 3. Type Safety & JSDoc (type)

**Impact:** HIGH
**Description:** Type annotations and documentation enable IDE support, compiler checks, and prevent type-related runtime errors in large codebases.

## 4. Naming Conventions (naming)

**Impact:** HIGH
**Description:** Consistent naming improves code comprehension, prevents ambiguity, and enables effective code search across large codebases.

## 5. Control Flow & Error Handling (control)

**Impact:** MEDIUM-HIGH
**Description:** Proper exception handling, equality checks, and control structures prevent silent failures and hard-to-debug runtime errors.

## 6. Functions & Parameters (func)

**Impact:** MEDIUM
**Description:** Function design patterns (arrow functions, rest params, defaults) affect code clarity, this-binding behavior, and API ergonomics.

## 7. Objects & Arrays (data)

**Impact:** MEDIUM
**Description:** Data structure patterns (literals, destructuring, spread) impact code consistency, prevent mutation bugs, and enable VM optimizations.

## 8. Formatting & Style (format)

**Impact:** LOW
**Description:** Whitespace, braces, and line limits maintain visual consistency for team collaboration but have minimal runtime impact.
