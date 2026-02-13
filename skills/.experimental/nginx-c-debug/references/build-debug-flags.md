---
title: Compile nginx with Full Debug Symbols and No Optimization
impact: LOW-MEDIUM
impactDescription: makes GDB output readable instead of optimized-out
tags: build, debug-symbols, compiler-flags, optimization
---

## Compile nginx with Full Debug Symbols and No Optimization

The default nginx build uses `-O2` optimization which inlines functions, reorders code, and eliminates variables -- making GDB debugging nearly impossible. Build with `--with-debug --with-cc-opt='-O0 -g'` for full debug symbols and no optimization. Variables show their actual values, breakpoints hit on the correct lines, and stepping works as expected.

**Incorrect (building with --with-debug only, still uses -O2 optimization):**

```c
/*
 * Build command that only enables debug logging but
 * leaves compiler optimization at -O2.
 *
 * ./configure --with-debug
 * make -j$(nproc)
 * make install
 *
 * Result: debug log macros are compiled in, but GDB sessions
 * are unusable — variables show "<optimized out>",
 * breakpoints land on wrong lines, stepping skips code.
 */

/* Attempt to inspect a request context in GDB: */
/* (gdb) break ngx_http_mymodule_handler         */
/* (gdb) print *ctx                               */
/* $1 = <optimized out>                           */
/* (gdb) print ctx->state                         */
/* $2 = <optimized out>                           */
/* (gdb) next                                     */
/* (jumps over 3 source lines due to inlining)    */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* GDB cannot inspect these values with -O2 */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: state=%d flags=0x%xd",
                   ctx->state, ctx->flags);

    return NGX_OK;
}
```

**Correct (building with -O0 -g for complete debugging support):**

```c
/*
 * Build command that disables optimization and includes
 * full DWARF debug symbols for GDB.
 *
 * ./configure \
 *     --with-debug \
 *     --with-cc-opt='-O0 -g' \
 *     --prefix=/usr/local/nginx-debug
 * make -j$(nproc)
 * make install
 *
 * --with-debug   → enables ngx_log_debug macros and debug_connection
 * -O0            → no optimization: no inlining, no reordering
 * -g             → full DWARF debug symbols for GDB
 *
 * For even more debug info (macro expansion in GDB):
 *     --with-cc-opt='-O0 -g3 -gdwarf-4'
 */

/* GDB session with -O0 -g build: */
/* (gdb) break ngx_http_mymodule_handler          */
/* Breakpoint 1 at 0x4a3f20: file ngx_http_mymodule.c, line 142. */
/* (gdb) run                                       */
/* (gdb) print *ctx                                */
/* $1 = {state = 2, flags = 0x3, upstream = 0x7f8b2c001a40} */
/* (gdb) print ctx->state                          */
/* $2 = 2                                          */
/* (gdb) next                                      */
/* 143     ngx_log_debug2(...)                      */
/* (single-line stepping works correctly)           */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* GDB shows exact values with -O0 */
    ngx_log_debug2(NGX_LOG_DEBUG_HTTP, r->connection->log, 0,
                   "mymodule: state=%d flags=0x%xd",
                   ctx->state, ctx->flags);

    return NGX_OK;
}
```

Reference: [nginx Debugging Guide](https://docs.nginx.com/nginx/admin-guide/monitoring/debugging/)
