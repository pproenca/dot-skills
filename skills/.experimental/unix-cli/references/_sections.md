# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Argument & Flag Design (args)

**Impact:** CRITICAL
**Description:** Proper argument parsing is the entry point to every CLI invocation; violations break composition, confuse users, and prevent script automation.

## 2. Exit Codes (exit)

**Impact:** CRITICAL
**Description:** Exit codes are the primary interface for scripts and CI/CD pipelines; incorrect codes cause cascading automation failures and silent data corruption.

## 3. Output Streams (output)

**Impact:** CRITICAL
**Description:** Correctly separating stdout and stderr enables UNIX pipes and redirection; mixing them breaks the fundamental composability of the UNIX tool chain.

## 4. Error Handling (error)

**Impact:** HIGH
**Description:** Clear, actionable error messages reduce user frustration and support burden; poor errors multiply debugging time across every failure.

## 5. I/O & Composition (io)

**Impact:** HIGH
**Description:** Proper stdin/stdout handling and stateless design enable tools to work together; poor I/O patterns break the UNIX philosophy of small, composable programs.

## 6. Help & Documentation (help)

**Impact:** MEDIUM-HIGH
**Description:** Discoverable, well-structured help reduces learning curve and support requests; poor help forces users to external documentation or trial-and-error.

## 7. Signals & Robustness (signal)

**Impact:** MEDIUM
**Description:** Proper signal handling prevents orphaned processes, enables graceful shutdown, and respects user intent when interrupting operations.

## 8. Configuration & Environment (config)

**Impact:** MEDIUM
**Description:** Following XDG and environment variable conventions prevents config file sprawl and ensures consistent behavior across environments.
