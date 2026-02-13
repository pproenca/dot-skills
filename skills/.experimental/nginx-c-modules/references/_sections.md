# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Memory Management (mem)

**Impact:** CRITICAL
**Description:** Pool misuse causes segfaults and memory leaks; every request allocates from pools. Wrong allocation strategy cascades into worker crashes under load.

## 2. Request Lifecycle (req)

**Impact:** CRITICAL
**Description:** Misunderstanding request lifecycle causes use-after-free, double finalize, and accessing freed data. Subrequests and reference counting add multiplicative complexity.

## 3. Configuration System (conf)

**Impact:** HIGH
**Description:** Wrong UNSET initialization breaks config inheritance across server/location blocks. Bad merge logic causes silent undefined runtime behavior.

## 4. Handler Development (handler)

**Impact:** HIGH
**Description:** Content and phase handlers are the core module work. Wrong response generation corrupts HTTP output or crashes active connections.

## 5. Filter Chain (filter)

**Impact:** MEDIUM-HIGH
**Description:** Filters process every response in the pipeline. Registration order bugs, buffer chain mismanagement, and missing flags corrupt output or cause infinite loops.

## 6. Upstream & Proxy (upstream)

**Impact:** MEDIUM
**Description:** Upstream callback errors cause proxy failures, connection leaks, and retry storms. The complex state machine requires correct callback ordering.

## 7. Event Loop & Concurrency (event)

**Impact:** MEDIUM
**Description:** Blocking calls in handlers freeze entire workers serving thousands of connections. Timer and thread pool misuse introduces resource leaks and race conditions.

## 8. Data Structures & Strings (ds)

**Impact:** LOW-MEDIUM
**Description:** ngx_str_t is NOT null-terminated — the #1 source of bugs for newcomers. Container iteration patterns and hash table immutability differ from standard C idioms.
