---
title: Use Valgrind Pool-Level Tracing to Find Leaked Allocations
impact: CRITICAL
impactDescription: turns 1 opaque pool block into 100s of individually tracked allocations for Valgrind
tags: memdbg, valgrind, pool, allocation-tracing
---

## Use Valgrind Pool-Level Tracing to Find Leaked Allocations

Standard Valgrind cannot track nginx pool allocations because `ngx_palloc` internally manages a large `mmap`'d block. All pool allocations appear as a single large block, making it impossible to identify which `ngx_palloc` call leaks. Recompile nginx with `NGX_DEBUG_PALLOC` defined to force each `ngx_palloc` call to use `malloc` directly, making every allocation visible to Valgrind with a full backtrace to the exact source line.

**Incorrect (runs Valgrind on standard nginx build, showing one opaque allocation):**

```c
/*
 * Standard build — configure and run under Valgrind:
 *
 *   ./configure --with-debug
 *   make
 *   valgrind --leak-check=full ./objs/nginx -g 'daemon off; master_process off;'
 *
 * Valgrind output shows:
 *
 *   ==12345== 262,144 bytes in 1 blocks are possibly lost
 *      at 0x4C2FB0F: malloc (in /usr/lib/valgrind/...)
 *      by 0x44A3E2: ngx_alloc (ngx_alloc.c:22)
 *      by 0x44B1C7: ngx_palloc_block (ngx_palloc.c:132)
 *      by 0x44B0D3: ngx_palloc (ngx_palloc.c:98)
 *
 * BUG: no visibility into WHICH ngx_palloc call leaked —
 * all allocations collapse into the pool's internal block.
 * Cannot distinguish the leaking module allocation from
 * hundreds of legitimate pool allocations.
 */
```

**Correct (compiles with NGX_DEBUG_PALLOC to make each allocation a separate malloc):**

```c
/*
 * Debug build — define NGX_DEBUG_PALLOC so each ngx_palloc calls malloc:
 *
 *   ./configure --with-debug --with-cc-opt='-DNGX_DEBUG_PALLOC=1'
 *   make
 *   valgrind --leak-check=full --show-leak-kinds=all \
 *     ./objs/nginx -g 'daemon off; master_process off;'
 *
 * Valgrind output now shows EACH allocation separately:
 *
 *   ==12345== 4,096 bytes in 1 blocks are definitely lost
 *      at 0x4C2FB0F: malloc (in /usr/lib/valgrind/...)
 *      by 0x44A3E2: ngx_alloc (ngx_alloc.c:22)
 *      by 0x44B0D3: ngx_palloc (ngx_palloc.c:68)
 *      by 0x4823AF: ngx_http_mymodule_handler (ngx_http_mymodule.c:147)
 *      by 0x457C21: ngx_http_core_content_phase (ngx_http_core_module.c:1261)
 *
 * SAFE: exact source file and line number of the leaking allocation.
 * Combine with --track-origins=yes to trace uninitialized value origins.
 *
 * IMPORTANT: NGX_DEBUG_PALLOC disables pool block reuse, so memory usage
 * is higher and performance is lower — use only for debugging, never
 * in production.
 */
```

**See also:** [`build-debug-palloc`](build-debug-palloc.md) for the canonical NGX_DEBUG_PALLOC build configuration and ASan integration.

Reference: [nginx Development Guide — Memory Pools](https://nginx.org/en/docs/dev/development_guide.html#pool)
