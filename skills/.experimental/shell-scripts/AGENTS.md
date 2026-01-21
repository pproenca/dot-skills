# Shell Scripts (Bash/POSIX)

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for shell scripting (bash and POSIX sh), designed for AI agents and LLMs. Contains 48 rules across 9 categories, prioritized by impact from critical (safety & security, portability) to incremental (style & formatting). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Safety & Security](references/_sections.md#1-safety-&-security) — **CRITICAL**
   - 1.1 [Avoid eval for Dynamic Commands](references/safety-eval-avoidance.md) — CRITICAL (eliminates code injection vector)
   - 1.2 [Create Secure Temporary Files](references/safety-temp-files.md) — CRITICAL (prevents symlink attacks and race conditions)
   - 1.3 [Never Use SUID/SGID on Shell Scripts](references/safety-suid-forbidden.md) — CRITICAL (prevents privilege escalation vulnerabilities)
   - 1.4 [Prevent Argument Injection with Double Dash](references/safety-argument-injection.md) — CRITICAL (prevents options interpreted as filenames)
   - 1.5 [Prevent Command Injection from User Input](references/safety-command-injection.md) — CRITICAL (prevents arbitrary code execution)
   - 1.6 [Use Absolute Paths for External Commands](references/safety-absolute-paths.md) — CRITICAL (prevents PATH hijacking attacks)
2. [Portability](references/_sections.md#2-portability) — **CRITICAL**
   - 2.1 [Avoid Bashisms in POSIX Scripts](references/port-avoid-bashisms.md) — CRITICAL (prevents failures on dash/ash/busybox systems)
   - 2.2 [Choose Shebang Based on Portability Needs](references/port-shebang-selection.md) — CRITICAL (determines script compatibility across systems)
   - 2.3 [Use Portable Export Syntax](references/port-export-syntax.md) — CRITICAL (prevents failures on strict POSIX shells)
   - 2.4 [Use Portable Test Constructs](references/port-test-portability.md) — CRITICAL (prevents silent logic failures across shells)
   - 2.5 [Use printf Instead of echo for Portability](references/port-printf-over-echo.md) — CRITICAL (ensures consistent output across all systems)
3. [Error Handling](references/_sections.md#3-error-handling) — **HIGH**
   - 3.1 [Check Command Success Explicitly](references/err-check-commands.md) — HIGH (prevents cascading failures from silent errors)
   - 3.2 [Send Error Messages to stderr](references/err-stderr-messages.md) — HIGH (enables proper output piping and filtering)
   - 3.3 [Use Meaningful Exit Codes](references/err-exit-codes.md) — HIGH (enables proper error handling by callers)
   - 3.4 [Use pipefail to Catch Pipeline Errors](references/err-pipefail.md) — HIGH (detects failures hidden in pipeline stages)
   - 3.5 [Use Strict Mode for Error Detection](references/err-strict-mode.md) — HIGH (catches 90% of common script failures)
   - 3.6 [Use trap for Cleanup on Exit](references/err-trap-cleanup.md) — HIGH (prevents resource leaks and orphaned processes)
4. [Variables & Data](references/_sections.md#4-variables-&-data) — **HIGH**
   - 4.1 [Follow Variable Naming Conventions](references/var-naming-conventions.md) — HIGH (prevents collisions with environment and builtins)
   - 4.2 [Use Arrays for Lists Instead of Strings](references/var-use-arrays.md) — HIGH (prevents word splitting bugs in argument handling)
   - 4.3 [Use local for Function Variables](references/var-local-scope.md) — HIGH (prevents namespace pollution and hidden bugs)
   - 4.4 [Use Parameter Expansion for Defaults](references/var-default-values.md) — HIGH (handles unset variables safely without conditionals)
   - 4.5 [Use readonly for Constants](references/var-readonly-constants.md) — HIGH (prevents accidental modification of configuration values)
5. [Quoting & Expansion](references/_sections.md#5-quoting-&-expansion) — **MEDIUM-HIGH**
   - 5.1 [Always Quote Variable Expansions](references/quote-always-quote-variables.md) — MEDIUM-HIGH (prevents word splitting and glob expansion bugs)
   - 5.2 [Control Glob Expansion Explicitly](references/quote-glob-safety.md) — MEDIUM-HIGH (prevents unintended file matching in commands)
   - 5.3 [Quote Command Substitutions](references/quote-command-substitution.md) — MEDIUM-HIGH (prevents word splitting of command output)
   - 5.4 [Use "$@" for Argument Passing](references/quote-dollar-at.md) — MEDIUM-HIGH (preserves arguments with spaces correctly)
   - 5.5 [Use Braces for Variable Clarity](references/quote-brace-expansion.md) — MEDIUM-HIGH (prevents ambiguous variable boundaries)
   - 5.6 [Use Here Documents for Multi-line Strings](references/quote-here-documents.md) — MEDIUM-HIGH (avoids quoting complexity in long strings)
6. [Functions & Structure](references/_sections.md#6-functions-&-structure) — **MEDIUM**
   - 6.1 [Document Functions with Header Comments](references/func-documentation.md) — MEDIUM (enables maintenance and API understanding)
   - 6.2 [Prefer Functions Over Aliases](references/func-avoid-aliases.md) — MEDIUM (enables arguments and proper scoping)
   - 6.3 [Use main() Function Pattern](references/func-main-pattern.md) — MEDIUM (enables testing and prevents execution on source)
   - 6.4 [Use Return Values Correctly](references/func-return-values.md) — MEDIUM (enables proper error propagation and testing)
   - 6.5 [Write Single-Purpose Functions](references/func-single-purpose.md) — MEDIUM (improves testability and reusability)
7. [Testing & Conditionals](references/_sections.md#7-testing-&-conditionals) — **MEDIUM**
   - 7.1 [Use (( )) for Arithmetic Comparisons](references/test-arithmetic.md) — MEDIUM (provides clearer syntax and prevents string comparison bugs)
   - 7.2 [Use [[ ]] for Tests in Bash](references/test-double-brackets.md) — MEDIUM (prevents word splitting and enables regex)
   - 7.3 [Use case for Pattern Matching](references/test-case-patterns.md) — MEDIUM (cleaner than chained if/elif for multiple patterns)
   - 7.4 [Use Correct File Test Operators](references/test-file-operators.md) — MEDIUM (prevents logic errors with symlinks and special files)
   - 7.5 [Use Explicit Empty/Non-empty String Tests](references/test-explicit-empty.md) — MEDIUM (prevents misreads and silent failures)
8. [Performance](references/_sections.md#8-performance) — **LOW-MEDIUM**
   - 8.1 [Avoid Unnecessary Subshells](references/perf-avoid-subshells.md) — LOW-MEDIUM (reduces fork overhead and variable scope issues)
   - 8.2 [Batch Operations Instead of Loops](references/perf-batch-operations.md) — LOW-MEDIUM (single command vs N process spawns)
   - 8.3 [Read Files Efficiently](references/perf-read-files.md) — LOW-MEDIUM (prevents O(n) line reads and subshell overhead)
   - 8.4 [Use Builtins Over External Commands](references/perf-builtins-over-external.md) — LOW-MEDIUM (10-100× faster by avoiding fork/exec overhead)
   - 8.5 [Use Parameter Expansion for String Operations](references/perf-parameter-expansion.md) — LOW-MEDIUM (avoids external commands for common transformations)
   - 8.6 [Use Process Substitution for Temp Files](references/perf-process-substitution.md) — LOW-MEDIUM (eliminates file I/O and cleanup overhead)
9. [Style & Formatting](references/_sections.md#9-style-&-formatting) — **LOW**
   - 9.1 [Follow Consistent File Structure](references/style-file-structure.md) — LOW (enables quick navigation and maintenance)
   - 9.2 [Use Consistent Indentation](references/style-indentation.md) — LOW (improves readability and maintenance)
   - 9.3 [Use ShellCheck for Static Analysis](references/style-shellcheck.md) — LOW (catches bugs before runtime)
   - 9.4 [Write Useful Comments](references/style-comments.md) — LOW (explains why, not what)

---

## References

1. [https://google.github.io/styleguide/shellguide.html](https://google.github.io/styleguide/shellguide.html)
2. [https://www.shellcheck.net/](https://www.shellcheck.net/)
3. [https://mywiki.wooledge.org/](https://mywiki.wooledge.org/)
4. [https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
5. [http://www.etalabs.net/sh_tricks.html](http://www.etalabs.net/sh_tricks.html)
6. [https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/ShellScriptSecurity/ShellScriptSecurity.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |