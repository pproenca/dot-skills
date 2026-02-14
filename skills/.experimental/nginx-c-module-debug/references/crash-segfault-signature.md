---
title: Identify Segfault Crash Signature from Signal and Address
impact: CRITICAL
impactDescription: reduces crash triage from hours to seconds by classifying crash type from signal + address
tags: crash, segfault, signals, sigsegv, coredump
---

## Identify Segfault Crash Signature from Signal and Address

When a worker process crashes, the error log records the signal number and the faulting memory address. This single line of information determines the entire debugging strategy: SIGSEGV at address `0x0` is a NULL pointer dereference, a small hex address like `0x8` or `0x18` indicates struct member access through a NULL pointer (the address is the member offset), and a large invalid address points to use-after-free or heap corruption where the pointer was overwritten with garbage.

**Incorrect (ignoring crash signature and searching code blindly):**

```c
/*
 * Worker crash log shows:
 *   worker process 4827 exited on signal 11
 *   signal 11 (SIGSEGV), code 1, fault address 0x18
 *
 * BAD approach: grep the entire codebase for segfaults, add
 * printf debugging everywhere, rebuild, and hope to reproduce.
 *
 * This wastes hours because the fault address already tells
 * you the crash category.
 */

/* developer adds random NULL checks everywhere */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* scattered printf debugging with no strategy */
    fprintf(stderr, "DEBUG: handler called\n");
    fprintf(stderr, "DEBUG: ctx = %p\n", (void *) ctx);
    fprintf(stderr, "DEBUG: ctx->state = %d\n", ctx->state);

    return NGX_OK;
}
```

**Correct (mapping fault address to crash category for targeted diagnosis):**

```c
/*
 * Worker crash log shows:
 *   worker process 4827 exited on signal 11
 *   signal 11 (SIGSEGV), code 1, fault address 0x18
 *
 * Step 1: Signal 11 = SIGSEGV (invalid memory access)
 *
 * Step 2: Classify by fault address:
 *   0x0         → NULL pointer dereference
 *   0x1 - 0xFFF → struct member access on NULL pointer
 *                  (0x18 = offset of a field in a struct)
 *   large addr  → use-after-free or heap corruption
 *
 * Step 3: fault address 0x18 = small offset → NULL struct access
 *         Find which struct has a member at offset 0x18:
 */

/* Use GDB to identify the struct layout */
/* (gdb) ptype /o my_ctx_t */
/*   offset  |  size  |  type   | field          */
/*     0x00  |     8  |  void*  | data           */
/*     0x08  |     8  |  void*  | handler        */
/*     0x10  |     4  |  int    | state          */
/*     0x14  |     4  |  int    | flags          */
/*     0x18  |     8  |  void*  | upstream  <--- fault offset */

/* Conclusion: ctx->upstream accessed when ctx == NULL */
/* Fix: add NULL check before accessing ctx->upstream */
static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "mymodule: ctx is NULL in handler");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* safe: ctx is validated before member access */
    if (ctx->upstream == NULL) {
        return NGX_HTTP_BAD_GATEWAY;
    }

    return NGX_OK;
}
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
