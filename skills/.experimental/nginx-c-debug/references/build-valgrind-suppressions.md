---
title: Use nginx Valgrind Suppressions to Reduce False Positives
impact: LOW-MEDIUM
impactDescription: eliminates 50+ false positives from nginx core
tags: build, valgrind, suppressions, false-positive
---

## Use nginx Valgrind Suppressions to Reduce False Positives

Running nginx under Valgrind produces many false positives from nginx core's intentional uninitialized reads (e.g., in the hash table implementation) and OpenSSL internals. Use Valgrind suppressions to filter these out so real bugs in your module are visible. Compile with `-DNGX_DEBUG_PALLOC=1` to make pool allocations visible to Valgrind, and run with `--suppressions=nginx.supp` to silence known false positives.

**Incorrect (running Valgrind without suppressions, real bugs hidden in noise):**

```c
/*
 * Running Valgrind with no suppressions:
 *
 * $ valgrind --leak-check=full ./objs/nginx -c debug.conf
 *
 * Output is flooded with false positives:
 *
 * ==4827== Conditional jump depends on uninitialised value(s)
 * ==4827==    at 0x44B2C1: ngx_hash_find (ngx_hash.c:24)
 * ==4827==    by 0x455A3F: ngx_hash_find_combined (ngx_hash.c:47)
 * ==4827==
 * ==4827== Conditional jump depends on uninitialised value(s)
 * ==4827==    at 0x44B2E8: ngx_hash_find (ngx_hash.c:26)
 * ==4827==    by 0x455A3F: ngx_hash_find_combined (ngx_hash.c:47)
 * ==4827==
 * ==4827== Use of uninitialised value of size 8
 * ==4827==    at 0x6D3F2A1: ssl3_read_bytes (ssl3_record.c:1462)
 * ==4827==    by 0x6D42103: ssl3_read (ssl3_lib.c:162)
 * ==4827==
 * (50+ reports from nginx core and OpenSSL before any module code)
 * (developer gives up reading output — real module bugs are buried)
 *
 * Also: nginx pools sub-allocate from large blocks, so Valgrind
 * only sees the outer ngx_alloc call — individual ngx_palloc
 * calls that cause bugs are invisible.
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);

    /* BUG: use-after-free hidden in 50+ false positive reports */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "state: %d", ctx->state);

    return NGX_OK;
}
```

**Correct (creating suppressions file and building with NGX_DEBUG_PALLOC):**

```c
/*
 * Step 1: Create a suppressions file (nginx.supp):
 *
 * --- nginx.supp ---
 * {
 *    nginx_hash_find_uninit
 *    Memcheck:Cond
 *    fun:ngx_hash_find
 * }
 * {
 *    nginx_hash_find_value
 *    Memcheck:Value8
 *    fun:ngx_hash_find
 * }
 * {
 *    nginx_init_cycle_hostname
 *    Memcheck:Param
 *    socketcall.getsockname(addr)
 *    fun:getsockname
 *    fun:ngx_connection_local_sockaddr
 * }
 * {
 *    openssl_ssl3_read
 *    Memcheck:Cond
 *    ...
 *    obj:*libssl*
 * }
 * {
 *    openssl_crypto_internal
 *    Memcheck:Value8
 *    ...
 *    obj:*libcrypto*
 * }
 * --- end ---
 *
 * Step 2: Build with NGX_DEBUG_PALLOC to expose pool allocations:
 *
 * ./configure \
 *     --with-debug \
 *     --with-cc-opt='-O0 -g -DNGX_DEBUG_PALLOC=1'
 * make -j$(nproc)
 *
 * Step 3: Run Valgrind with suppressions and gen-suppressions:
 *
 * $ valgrind \
 *     --leak-check=full \
 *     --show-reachable=yes \
 *     --track-origins=yes \
 *     --suppressions=nginx.supp \
 *     --gen-suppressions=all \
 *     ./objs/nginx -c debug.conf
 *
 * --gen-suppressions=all prints suppression blocks for any new
 * false positives so you can add them to nginx.supp incrementally.
 *
 * Clean output — only real module bugs remain:
 *
 * ==4827== Invalid read of size 4
 * ==4827==    at 0x4A3F20: ngx_http_mymodule_handler (mymodule.c:87)
 * ==4827==  Address 0x60b000001a48 is 8 bytes inside a block of size 32 free'd
 * ==4827==    at 0x483CA3F: free (vg_replace_malloc.c:540)
 * ==4827==    by 0x44F2A1: ngx_destroy_pool (ngx_palloc.c:74)
 */

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    my_ctx_t  *ctx;

    ctx = ngx_http_get_module_ctx(r, ngx_http_mymodule_module);
    if (ctx == NULL) {
        ngx_log_error(NGX_LOG_ERR, r->connection->log, 0,
                      "mymodule: ctx is NULL");
        return NGX_HTTP_INTERNAL_SERVER_ERROR;
    }

    /* Valgrind now reports only real bugs in module code */
    ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                  "state: %d", ctx->state);

    return NGX_OK;
}
```

Reference: [nginx Development Guide](https://nginx.org/en/docs/dev/development_guide.html)
