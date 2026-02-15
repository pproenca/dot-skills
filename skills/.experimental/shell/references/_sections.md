# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Safety & Security (safety)

**Impact:** CRITICAL
**Description:** Command injection, path security, and privilege issues can compromise entire systems. Security flaws in shell scripts propagate to every process they spawn.

## 2. Portability (port)

**Impact:** CRITICAL
**Description:** Non-portable scripts fail silently across different environments. POSIX compliance ensures scripts work on Linux, macOS, BSD, and minimal containers.

## 3. Error Handling (err)

**Impact:** HIGH
**Description:** Unhandled errors cascade into data corruption and silent failures. Proper exit codes, strict mode, traps, and static analysis prevent downstream damage.

## 4. Variables & Data (var)

**Impact:** HIGH
**Description:** Variable bugs propagate to all downstream commands. Proper arrays, scoping, and naming prevent data corruption and namespace pollution.

## 5. Quoting & Expansion (quote)

**Impact:** MEDIUM-HIGH
**Description:** Unquoted variables cause word splitting and glob expansion in every command using them. Quoting errors are the most common source of shell script bugs.

## 6. Functions & Structure (func)

**Impact:** MEDIUM
**Description:** Poor structure compounds maintenance cost and makes scripts harder to test. Well-designed functions enable reuse and isolation.

## 7. Testing & Conditionals (test)

**Impact:** MEDIUM
**Description:** Wrong test syntax causes subtle logic bugs. Using the correct test constructs prevents unexpected behavior with special characters and edge cases.

## 8. Performance (perf)

**Impact:** LOW-MEDIUM
**Description:** Fork overhead from external commands multiplies in loops. Using builtins and avoiding subshells improves script execution speed significantly.

## 9. Style & Formatting (style)

**Impact:** LOW
**Description:** Consistent style aids readability and maintenance. Following established conventions like Google Shell Style Guide enables team collaboration.
