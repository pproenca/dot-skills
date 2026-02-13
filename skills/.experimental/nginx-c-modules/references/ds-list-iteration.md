---
title: Iterate ngx_list_t Using Part-Based Pattern
impact: LOW-MEDIUM
impactDescription: prevents skipping elements in multi-part lists
tags: ds, list, iteration, pattern
---

## Iterate ngx_list_t Using Part-Based Pattern

`ngx_list_t` is a linked list of arrays (parts), not individual elements. Each part holds up to `nalloc` elements. Iterating only the first part's elements misses all entries that overflowed into subsequent parts. The standard nginx iteration pattern tracks both the current part pointer and the element index, resetting the index when crossing part boundaries.

**Incorrect (iterates only the first part, misses overflow elements):**

```c
static ngx_int_t
ngx_http_mymodule_scan_headers(ngx_http_request_t *r)
{
    ngx_table_elt_t  *h;
    ngx_uint_t        i;

    h = r->headers_in.headers.part.elts;

    /* BUG: only iterates first part — if headers overflow into
     * additional parts, those headers are silently skipped */
    for (i = 0; i < r->headers_in.headers.part.nelts; i++) {
        ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                      "header: %V = %V", &h[i].key, &h[i].value);
    }

    return NGX_OK;
}
```

**Correct (traverses all parts using standard nginx pattern):**

```c
static ngx_int_t
ngx_http_mymodule_scan_headers(ngx_http_request_t *r)
{
    ngx_list_part_t  *part;
    ngx_table_elt_t  *h;
    ngx_uint_t        i;

    part = &r->headers_in.headers.part;
    h = part->elts;

    for (i = 0; /* void */; i++) {

        if (i >= part->nelts) {
            if (part->next == NULL) {
                break;  /* end of list */
            }
            part = part->next;
            h = part->elts;
            i = 0;  /* reset index for new part */
        }

        ngx_log_error(NGX_LOG_INFO, r->connection->log, 0,
                      "header: %V = %V", &h[i].key, &h[i].value);
    }

    return NGX_OK;
}
```
