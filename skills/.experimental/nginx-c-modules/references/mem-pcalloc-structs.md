---
title: Use ngx_pcalloc for Struct Initialization
impact: HIGH
impactDescription: prevents use of uninitialized fields
tags: mem, pcalloc, initialization, structs
---

## Use ngx_pcalloc for Struct Initialization

`ngx_pcalloc` zeros all memory before returning, ensuring every struct field starts at a known state. Using `ngx_palloc` with manual field assignment risks leaving fields uninitialized, which causes undefined behavior when those fields are later read by nginx internals or other modules.

**Incorrect (ngx_palloc with incomplete field assignment):**

```c
static ngx_int_t
ngx_http_mymodule_create_ctx(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    /* ngx_palloc does NOT zero memory */
    ctx = ngx_palloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    ctx->state = STATE_INIT;
    ctx->count = 0;
    /* BUG: ctx->chain, ctx->upstream, ctx->flags left uninitialized */
    /* reading ctx->chain later produces garbage pointer — crash or corruption */

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    return NGX_OK;
}
```

**Correct (ngx_pcalloc zeros all fields, then set non-zero values):**

```c
static ngx_int_t
ngx_http_mymodule_create_ctx(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    /* ngx_pcalloc zeros all memory — all pointers NULL, all ints 0 */
    ctx = ngx_pcalloc(r->pool, sizeof(my_ctx_t));
    if (ctx == NULL) {
        return NGX_ERROR;
    }

    /* only set fields that need non-zero values */
    ctx->state = STATE_INIT;
    /* ctx->chain == NULL, ctx->upstream == NULL, ctx->flags == 0 */

    ngx_http_set_ctx(r, ctx, ngx_http_mymodule_module);
    return NGX_OK;
}
```

**Note:** This is especially important for structs containing `ngx_chain_t *`, `ngx_buf_t *`, or callback function pointers. Uninitialized pointers are the leading cause of hard-to-reproduce worker crashes.
