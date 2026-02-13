---
title: Enable NGX_DEBUG_PALLOC for Fine-Grained Pool Allocation Tracking
impact: LOW-MEDIUM
impactDescription: makes each pool allocation individually trackable by memory tools
tags: build, debug-palloc, pool, allocation, tracking
---

## Enable NGX_DEBUG_PALLOC for Fine-Grained Pool Allocation Tracking

nginx pools allocate large blocks and sub-allocate from them, making individual allocations invisible to Valgrind and ASan. Defining `NGX_DEBUG_PALLOC=1` forces `ngx_palloc` to use `malloc` for every allocation instead of sub-allocating from pool blocks. This makes every allocation visible to memory debugging tools with full call stacks, at the cost of changed allocation patterns and higher overhead.

**Incorrect (running ASan on standard nginx build, per-allocation bugs invisible):**

```c
/*
 * Standard build — pools sub-allocate from 4096-byte blocks:
 *
 * ./configure --with-debug --with-cc-opt='-fsanitize=address -O1 -g \
 *     -fno-omit-frame-pointer' --with-ld-opt='-fsanitize=address'
 * make -j$(nproc)
 *
 * Pool allocation pattern (standard):
 *
 *   ngx_create_pool(4096)
 *     → malloc(4096)              ← ASan sees this one block
 *       ngx_palloc(pool, 64)     ← sub-allocated, invisible to ASan
 *       ngx_palloc(pool, 128)    ← sub-allocated, invisible to ASan
 *       ngx_palloc(pool, 32)     ← sub-allocated, invisible to ASan
 *
 * When the pool is destroyed, ASan reports one free for the entire
 * block. If the module reads from the second allocation after pool
 * destruction, ASan may not detect it — the whole block was freed
 * at once, and ASan cannot distinguish sub-allocations within it.
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t   *ctx;
    ngx_str_t  *cached;

    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* allocate a string buffer from the request pool */
    cached = ngx_palloc(r->pool, sizeof(ngx_str_t));
    cached->data = ngx_pnalloc(r->pool, r->uri.len);
    cached->len = r->uri.len;
    ngx_memcpy(cached->data, r->uri.data, r->uri.len);

    /* save pointer to connection-scoped storage */
    ctx->saved_ref = cached;
    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /*
     * BUG: after request pool is destroyed, ctx->saved_ref->data
     * is invalid. But ASan only sees one large block free — it
     * cannot pinpoint which ngx_palloc call created the dangling
     * pointer. ASan report shows:
     *
     *   freed by: ngx_destroy_pool (ngx_palloc.c:74)
     *   (no info about which specific allocation within the pool)
     */

    return NGX_OK;
}
```

**Correct (building with NGX_DEBUG_PALLOC=1 for per-allocation tracking):**

```c
/*
 * Debug build — every ngx_palloc becomes a separate malloc:
 *
 * ./configure --with-debug \
 *     --with-cc-opt='-fsanitize=address -O1 -g \
 *         -fno-omit-frame-pointer -DNGX_DEBUG_PALLOC=1' \
 *     --with-ld-opt='-fsanitize=address'
 * make -j$(nproc)
 *
 * Pool allocation pattern (with NGX_DEBUG_PALLOC):
 *
 *   ngx_create_pool(4096)
 *     → malloc(sizeof(ngx_pool_t))     ← ASan tracks this
 *       ngx_palloc(pool, 64)
 *         → malloc(64)                 ← ASan tracks this separately
 *       ngx_palloc(pool, 128)
 *         → malloc(128)                ← ASan tracks this separately
 *       ngx_palloc(pool, 32)
 *         → malloc(32)                 ← ASan tracks this separately
 *
 * When the pool is destroyed, each sub-allocation is freed
 * individually. ASan can now detect use-after-free for any
 * specific allocation with its exact allocation call stack.
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t   *ctx;
    ngx_str_t  *cached;

    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* each ngx_palloc is now a separate malloc — ASan tracks it */
    cached = ngx_palloc(r->pool, sizeof(ngx_str_t));
    cached->data = ngx_pnalloc(r->pool, r->uri.len);
    cached->len = r->uri.len;
    ngx_memcpy(cached->data, r->uri.data, r->uri.len);

    ctx->saved_ref = cached;
    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);

    /*
     * With NGX_DEBUG_PALLOC, ASan now reports the exact allocation:
     *
     * ==4827==ERROR: AddressSanitizer: heap-use-after-free
     *   READ of size 8 at 0x60200000efa0 thread T0
     *     #0 ngx_http_mymodule_log ngx_http_mymodule.c:112
     *
     * freed by thread T0 here:
     *     #0 free (libasan.so)
     *     #1 ngx_pfree ngx_palloc.c:142
     *     #2 ngx_destroy_pool ngx_palloc.c:88
     *
     * previously allocated by thread T0 here:
     *     #0 malloc (libasan.so)
     *     #1 ngx_palloc ngx_palloc.c:130   ← exact palloc call
     *     #2 ngx_http_mymodule_handler ngx_http_mymodule.c:89
     *
     * (pinpoints the exact ngx_palloc that created the pointer)
     */

    return NGX_OK;
}
```

Reference: [nginx Development Guide — Memory Pools](https://nginx.org/en/docs/dev/development_guide.html#pool)
