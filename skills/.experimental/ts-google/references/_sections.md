# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Module Organization (module)

**Impact:** CRITICAL
**Description:** Import/export patterns affect build times, tree-shaking, and error detection at scale. Named exports catch typos at import time.

## 2. Type Safety (types)

**Impact:** CRITICAL
**Description:** Proper typing prevents runtime errors and enables compiler optimizations. Avoiding `any` is the foundation of type safety.

## 3. Class Design (class)

**Impact:** HIGH
**Description:** Class structure affects memory layout, VM optimization, and API surface. Parameter properties reduce boilerplate while maintaining safety.

## 4. Function Patterns (func)

**Impact:** HIGH
**Description:** Function design affects call overhead, `this` binding, and readability. Prefer declarations over expressions for named functions.

## 5. Control Flow (control)

**Impact:** MEDIUM-HIGH
**Description:** Proper control flow prevents bugs and improves code predictability. Always use braces and triple equals.

## 6. Error Handling (error)

**Impact:** MEDIUM
**Description:** Consistent error handling enables debugging and prevents silent failures. Always throw Error instances with stack traces.

## 7. Naming & Style (naming)

**Impact:** MEDIUM
**Description:** Consistent naming improves readability and tooling support. Use descriptive names and follow case conventions.

## 8. Literals & Coercion (literal)

**Impact:** LOW-MEDIUM
**Description:** Proper literal usage prevents type coercion bugs. Use explicit coercion functions instead of implicit coercion.
