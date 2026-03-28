# Bug Categories

These categories define the types of bugs the review passes look for. Each finding must reference one of these category IDs. Severity defaults can be overridden per-finding based on context, or by repo rules in `.bug-review.md`.

---

## 1. Null/Undefined Access (`null-access`)

**Default Severity**: CRITICAL
**Description**: Code accesses properties or methods on a value that can be null or undefined without checking first. Causes TypeError crashes at runtime.
**Examples**: `user.name` when `user` can be null, optional chaining missing, database query returning null.

## 2. Off-by-One / Boundary Error (`boundary`)

**Default Severity**: CRITICAL
**Description**: Loop bounds, array indexing, string slicing, or range calculations that are off by one. Causes silent data corruption or out-of-bounds access.
**Examples**: `for (i = 0; i <= arr.length)`, `str.substring(0, len - 1)` missing last char, pagination skipping first item.

## 3. Race Condition (`race`)

**Default Severity**: CRITICAL
**Description**: Two or more operations access shared state concurrently without proper synchronization. Results depend on execution order.
**Examples**: TOCTOU (check-then-act), concurrent map modification, parallel async updates without locks, unprotected shared counters.

## 4. Resource Leak (`resource-leak`)

**Default Severity**: HIGH
**Description**: Resources acquired but never released. Over time, this exhausts system resources (memory, file descriptors, connections).
**Examples**: Unclosed database connections, file handles not closed in error paths, event listeners never removed, timers not cleared.

## 5. Injection / XSS (`injection`)

**Default Severity**: HIGH
**Description**: User-controlled input reaches a sensitive sink (SQL query, HTML output, shell command, file path) without sanitization.
**Examples**: SQL injection via string concatenation, XSS via innerHTML, command injection via child_process, path traversal via user-supplied filename.

## 6. Auth/Authz Bypass (`auth-bypass`)

**Default Severity**: HIGH
**Description**: Missing or incorrect authentication/authorization checks allowing unauthorized access to data or operations.
**Examples**: API endpoint missing auth middleware, role check using wrong field, token validation skipped in error path, IDOR (accessing other users' resources).

## 7. Data Loss / Corruption (`data-loss`)

**Default Severity**: HIGH
**Description**: Operations that silently lose or corrupt data. Often subtle and discovered late.
**Examples**: Overwriting without backup, missing database transactions, truncating data on type conversion, ignoring write errors.

## 8. Error Swallowing (`error-swallow`)

**Default Severity**: MEDIUM
**Description**: Errors caught but not handled, logged, or propagated. Silently hides failures, making debugging impossible.
**Examples**: Empty catch blocks, `.catch(() => {})`, ignoring callback errors, logging error but continuing as if success.

## 9. Type Coercion (`type-coercion`)

**Default Severity**: MEDIUM
**Description**: Implicit type conversions causing unexpected behavior. Particularly common in JavaScript/TypeScript.
**Examples**: `==` instead of `===`, string + number concatenation, truthy/falsy checks on 0 or empty string, JSON.parse without validation.

## 10. Stale Closure / Reference (`stale-ref`)

**Default Severity**: MEDIUM
**Description**: Closures or references capturing a mutable value that changes after capture, leading to stale data.
**Examples**: React useEffect with missing dependencies, setTimeout capturing loop variable, event handler referencing outdated state.

## 11. API Contract Violation (`api-contract`)

**Default Severity**: MEDIUM
**Description**: Code violates the expected interface of a function, API, or library. May work by accident but breaks on updates.
**Examples**: Wrong argument order, missing required fields, assuming return type without checking, deprecated API usage.

## 12. Dead Code / Unreachable Path (`dead-code`)

**Default Severity**: LOW
**Description**: Logic branches that can never execute due to earlier conditions. Indicates a logic error elsewhere.
**Examples**: `if (x && !x)`, return before code, impossible enum case, overridden method never called.

## 13. Performance Regression (`perf`)

**Default Severity**: LOW
**Description**: Code patterns that significantly degrade performance in hot paths. Only flagged when the regression is substantial.
**Examples**: O(n^2) loop where O(n) is possible, unnecessary re-renders, repeated database queries in a loop, missing index hints.

## 14. Configuration Error (`config`)

**Default Severity**: LOW
**Description**: Incorrect or mismatched configuration values that cause runtime failures or unexpected behavior.
**Examples**: Wrong environment variable name, mismatched API version, incorrect timeout value, hardcoded dev URL in production code.

---

## Severity Weights (for ranking)

| Severity | Weight | Meaning |
|----------|--------|---------|
| CRITICAL | 4 | Causes crashes, data loss, or security breaches in production |
| HIGH | 3 | Significant bugs that affect correctness or security |
| MEDIUM | 2 | Real bugs with limited blast radius or workarounds available |
| LOW | 1 | Minor issues, potential future problems |

## Learned Category Weights

Each category has a **weight** (0.0 to 1.0) that adjusts its impact on finding ranking. Weights are initialized to 1.0 and **learned from resolution rate data** — categories where developers consistently fix the flagged issues get higher weight, categories where findings are ignored get suppressed.

The ranking formula is: `final_score = votes × severity_weight × category_weight`

Weights are stored in `config.json → category_weights` and updated by `scripts/update-weights.sh` after resolution data is collected. Categories with weight below 0.1 are suppressed entirely (findings in those categories are discarded before presentation).

To reset weights: set all values in `config.json → category_weights` back to 1.0.

The weight learning requires minimum data: 10+ findings across 3+ resolved PRs. Below that threshold, all categories keep their default weight of 1.0.
