# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Structure & Decomposition (struct)

**Impact:** CRITICAL
**Description:** Long methods and classes are the root cause of maintenance issues. Breaking them down cascades into all other improvements and is the foundation of effective refactoring.

## 2. Coupling & Dependencies (couple)

**Impact:** CRITICAL
**Description:** Tight coupling makes all subsequent changes expensive. Reducing coupling through dependency injection and proper interfaces is foundational to maintainability.

## 3. Naming & Clarity (name)

**Impact:** HIGH
**Description:** Poor naming cascades into misunderstanding, bugs, and increased cognitive load. Clear, intention-revealing names make code self-documenting.

## 4. Conditional Logic (cond)

**Impact:** HIGH
**Description:** Complex conditionals are major contributors to cyclomatic and cognitive complexity. Simplifying them dramatically improves readability and testability.

## 5. Abstraction & Patterns (pattern)

**Impact:** MEDIUM-HIGH
**Description:** Proper abstractions and design patterns enable extensibility without modification (Open-Closed Principle), reducing future refactoring needs.

## 6. Data Organization (data)

**Impact:** MEDIUM
**Description:** How data is structured affects all operations on it. Proper encapsulation and organization reduce coupling and improve code clarity.

## 7. Error Handling (error)

**Impact:** MEDIUM
**Description:** Proper error handling prevents cascade failures and improves debuggability. Consistent error patterns make code more predictable and maintainable.

## 8. Micro-Refactoring (micro)

**Impact:** LOW
**Description:** Small improvements like removing dead code and simplifying expressions accumulate into significant maintainability gains over time.
