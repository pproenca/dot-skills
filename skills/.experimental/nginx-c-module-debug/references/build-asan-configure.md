---
title: Build nginx with AddressSanitizer for Memory Error Detection
impact: LOW-MEDIUM
impactDescription: catches use-after-free and buffer overflows at runtime with 2x overhead
tags: build, addresssanitizer, asan, memory-error
---

## Build nginx with AddressSanitizer for Memory Error Detection

AddressSanitizer (ASan) instruments every memory access at compile time, catching use-after-free, buffer overflows, and stack overflows immediately when they occur -- not later when corrupted data is read. Build nginx with `-fsanitize=address` in both CFLAGS and LDFLAGS. ASan prints a detailed report with the exact allocation and free call stacks. Overhead is ~2x which is acceptable for development.

**Incorrect (building with ASan in CFLAGS only, linker fails or runtime missing):**

```c
/*
 * Partial ASan build — only sets CFLAGS, omits LDFLAGS.
 *
 * ./configure \
 *     --with-debug \
 *     --with-cc-opt='-fsanitize=address -g'
 * make -j$(nproc)
 *
 * Possible failures:
 *   1. Linker error: undefined reference to '__asan_report_load8'
 *      (libasan not linked)
 *   2. If it links by accident (distro auto-links), nginx forks
 *      workers that inherit the ASan state incorrectly, causing
 *      false positives on fork.
 *   3. Missing -fno-omit-frame-pointer produces truncated stack
 *      traces in ASan reports — you see the crash but not the
 *      full call chain leading to the allocation.
 */

/*
 * ASan report with missing frame pointers (truncated):
 *
 * ==4827==ERROR: AddressSanitizer: heap-use-after-free
 *   READ of size 8 at 0x60b000001a40 thread T0
 *     #0 0x4a3f20 in ngx_http_mymodule_handler (nginx+0x4a3f20)
 *     #1 0x43210a (<unknown module>)
 *     #2 0x42100b (<unknown module>)
 *
 * freed by thread T0 here:
 *     #0 0x7f8b2c001a40 in free (<unknown module>)
 *     #1 0x410023 (<unknown module>)
 *
 * (no function names, no source lines — useless for diagnosis)
 */
```

**Correct (full ASan build with frame pointers and single-process mode):**

```c
/*
 * Complete ASan build — instruments compiler AND linker, includes
 * frame pointers for full stack traces. -O1 is optional (ASan works
 * with -O0) but produces slightly better stack traces.
 *
 * ./configure \
 *     --with-debug \
 *     --with-cc-opt='-fsanitize=address -O1 -g -fno-omit-frame-pointer' \
 *     --with-ld-opt='-fsanitize=address'
 * make -j$(nproc)
 * make install
 *
 * nginx.conf for ASan debugging:
 *   master_process off;
 *   worker_processes 1;
 *   daemon off;
 *
 * Environment variables for detailed reports:
 *   export ASAN_OPTIONS="detect_leaks=1:log_path=/tmp/asan:abort_on_error=1"
 */

/*
 * ASan report with full frame pointers (actionable):
 *
 * ==4827==ERROR: AddressSanitizer: heap-use-after-free
 *   READ of size 8 at 0x60b000001a40 thread T0
 *     #0 ngx_http_mymodule_log_handler ngx_http_mymodule.c:87
 *     #1 ngx_http_log_request ngx_http_request.c:3612
 *     #2 ngx_http_free_request ngx_http_request.c:3562
 *     #3 ngx_http_close_request ngx_http_request.c:3517
 *
 * freed by thread T0 here:
 *     #0 free (libasan.so)
 *     #1 ngx_destroy_pool ngx_palloc.c:74
 *     #2 ngx_http_free_request ngx_http_request.c:3558
 *
 * previously allocated by thread T0 here:
 *     #0 malloc (libasan.so)
 *     #1 ngx_alloc ngx_alloc.c:22
 *     #2 ngx_palloc_large ngx_palloc.c:186
 *     #3 ngx_http_mymodule_handler ngx_http_mymodule.c:45
 *
 * (exact source lines for allocation, free, and use-after-free)
 */
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
