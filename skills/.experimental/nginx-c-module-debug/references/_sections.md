# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Crash Diagnosis & Signals (crash)

**Impact:** CRITICAL
**Description:** Segfaults and worker crashes are the most urgent debugging scenario — identifying the crash signature and signal type determines the entire debugging strategy.

## 2. Memory Bug Detection (memdbg)

**Impact:** CRITICAL
**Description:** Use-after-free, pool corruption, and leaks are the #1 root cause of nginx module bugs — pool-allocated memory disappears silently when the wrong pool is destroyed.

## 3. GDB & Core Dump Analysis (gdb)

**Impact:** HIGH
**Description:** GDB with coredumps is the primary post-mortem tool — correct setup and nginx-specific inspection commands cut diagnosis time from hours to minutes.

## 4. Request Flow Tracing (trace)

**Impact:** HIGH
**Description:** Wrong-behavior bugs require tracing a request through phases, subrequests, and filter chains — missing a callback or phase transition hides the root cause.

## 5. Debug Logging Patterns (dbglog)

**Impact:** MEDIUM-HIGH
**Description:** Structured debug logging with ngx_log_debug macros and debug_connection filtering produces targeted diagnostics without drowning in noise.

## 6. State & Lifecycle Debugging (state)

**Impact:** MEDIUM
**Description:** Connection state machines, upstream callback sequences, and event handler transitions have strict ordering — state mismatches cause intermittent failures that resist reproduction.

## 7. Dynamic Tracing Tools (probe)

**Impact:** MEDIUM
**Description:** DTrace, SystemTap, and strace enable production debugging without recompilation — tracing live worker processes reveals timing-dependent bugs invisible in test environments.

## 8. Build & Sanitizer Configuration (build)

**Impact:** LOW-MEDIUM
**Description:** Correct --with-debug flags, AddressSanitizer, and Valgrind configuration catches memory errors at development time before they become production crashes.
