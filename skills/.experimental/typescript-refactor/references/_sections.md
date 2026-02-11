# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Type Architecture (arch)

**Impact:** CRITICAL
**Description:** Structural type design decisions cascade through entire codebases. Wrong type architecture forces workarounds, unsafe casts, and maintenance nightmares everywhere downstream.

## 2. Type Narrowing & Guards (narrow)

**Impact:** CRITICAL
**Description:** Proper narrowing eliminates entire classes of runtime errors and removes the need for unsafe type assertions. Missing narrowing is the #1 cause of `as` cast abuse.

## 3. Modern TypeScript (modern)

**Impact:** HIGH
**Description:** TypeScript 4.x-5.x features replace verbose legacy patterns with concise, type-safe alternatives. Adopting them reduces boilerplate and catches bugs at compile time.

## 4. Generic Patterns (generic)

**Impact:** HIGH
**Description:** Generics are TypeScript's most powerful and most abused feature. Right constraints enable inference; wrong ones force explicit annotation and hurt readability.

## 5. Compiler Performance (compile)

**Impact:** MEDIUM-HIGH
**Description:** Type-level decisions directly affect build times and IDE responsiveness in large codebases. A single recursive type can add seconds to every compilation.

## 6. Error Safety (error)

**Impact:** MEDIUM
**Description:** Type-safe error handling makes impossible states unrepresentable and forces callers to handle every failure mode at compile time.

## 7. Runtime Patterns (perf)

**Impact:** MEDIUM
**Description:** TypeScript idioms that affect emitted JavaScript performance. Choosing the right construct at the type level determines the cost at runtime.

## 8. Quirks & Pitfalls (quirk)

**Impact:** LOW-MEDIUM
**Description:** TypeScript behaviors that violate developer expectations. Understanding these quirks prevents subtle bugs that survive code review and pass type checking.
