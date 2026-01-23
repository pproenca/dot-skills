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

## 5. Objects and Data Structures (obj)

**Impact:** MEDIUM-HIGH
**Description:** Objects hide data and expose behavior; data structures expose data and have no behavior. Mixing these creates hybrid messes.

## 6. Error Handling (err)

**Impact:** MEDIUM-HIGH
**Description:** Clean error handling separates happy path from exceptional cases. Use exceptions rather than return codes.

## 7. Unit Tests (test)

**Impact:** MEDIUM
**Description:** Tests are first-class citizens that enable safe refactoring. Test code deserves the same care as production code.

## 8. Classes and Systems (class)

**Impact:** MEDIUM
**Description:** Classes should be small and have a single responsibility. Systems should separate construction from use.
