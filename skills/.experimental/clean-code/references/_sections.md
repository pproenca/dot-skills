# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Meaningful Names (name)

**Impact:** CRITICAL
**Description:** Names are the primary documentation. Bad names cascade confusion throughout the codebase, forcing every reader to decipher intent.

## 2. Functions (func)

**Impact:** CRITICAL
**Description:** Functions are the verbs of code. Small, focused functions enable understanding, testing, and reuse while reducing complexity.

## 3. Comments (cmt)

**Impact:** HIGH
**Description:** Comments should explain intent, not obvious mechanics. Wrong or stale comments actively mislead readers and cost more than no comments.

## 4. Formatting (fmt)

**Impact:** HIGH
**Description:** Consistent formatting reduces cognitive load. Code should read top-to-bottom like a newspaper article.

## 5. Error Handling (err)

**Impact:** HIGH
**Description:** Clean error handling separates happy path from exceptional cases. Use the error mechanism idiomatic to your language (exceptions, Result types, or explicit error returns).

## 6. Objects and Data Structures (obj)

**Impact:** MEDIUM-HIGH
**Description:** Objects hide data and expose behavior; data structures expose data and have no behavior. Mixing these creates hybrid messes.

## 7. Boundaries (bound)

**Impact:** MEDIUM-HIGH
**Description:** Third-party code and external APIs are boundaries. Wrap them to isolate change, ease testing, and maintain control over your codebase's interfaces.

## 8. Classes and Systems (class)

**Impact:** MEDIUM-HIGH
**Description:** Classes should be small and have a single responsibility. Systems should separate construction from use. SRP and DIP are among the highest-leverage design principles.

## 9. Unit Tests (test)

**Impact:** MEDIUM
**Description:** Tests are first-class citizens that enable safe refactoring. Test code deserves the same care as production code.

## 10. Emergence and Simple Design (emerge)

**Impact:** MEDIUM
**Description:** Good design emerges from following four rules in order: pass tests, reveal intent, eliminate duplication, minimize elements. Resist the urge to over-engineer.
