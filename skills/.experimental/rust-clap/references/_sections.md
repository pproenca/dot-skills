# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Type-Driven Design (type)

**Impact:** CRITICAL
**Description:** Use Rust's type system to eliminate runtime parsing errors and invalid states. Wrong type choices cause cascading bugs and poor user experience.

## 2. Derive API Patterns (derive)

**Impact:** CRITICAL
**Description:** The derive API is the recommended approach for most CLIs. Incorrect patterns cause verbose code, maintenance burden, and inconsistent behavior.

## 3. Argument Configuration (arg)

**Impact:** HIGH
**Description:** Correct argument setup with defaults, environment variables, and requirements prevents user confusion and runtime errors.

## 4. Validation & Parsing (valid)

**Impact:** HIGH
**Description:** Custom validators and parsers ensure data integrity before business logic runs, providing clear error messages to users.

## 5. Subcommand Architecture (subcmd)

**Impact:** MEDIUM-HIGH
**Description:** Well-structured subcommands enable scalable CLI design, code organization, and intuitive user navigation.

## 6. Help & Documentation (help)

**Impact:** MEDIUM
**Description:** Good help text, shell completions, and man pages improve CLI usability and discoverability significantly.

## 7. Error Handling (error)

**Impact:** MEDIUM
**Description:** User-friendly errors with actionable suggestions improve CLI experience and reduce support burden.

## 8. Testing Patterns (test)

**Impact:** LOW-MEDIUM
**Description:** Proper CLI testing with assert_cmd and predicates catches regressions and validates user workflows.
