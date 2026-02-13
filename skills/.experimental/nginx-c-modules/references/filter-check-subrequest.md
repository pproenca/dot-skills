---
title: Distinguish Main Request from Subrequest in Filters
impact: MEDIUM
impactDescription: prevents applying transformations to subrequest responses
tags: filter, subrequest, main-request, conditional
---

## Distinguish Main Request from Subrequest in Filters

Filters execute for ALL requests including subrequests (SSI includes, auth subrequests, etc.). Applying transformations unconditionally corrupts subrequest responses or double-processes content. Always check `r == r->main` to determine if the current request is the main client request.

**Incorrect (modifies headers for every request including subrequests):**

```c
static ngx_int_t
ngx_http_myfilter_header_filter(ngx_http_request_t *r)
{
    /* BUG: overwrites content-type on auth subrequests and SSI includes */
    r->headers_out.content_type_len = sizeof("text/html") - 1;
    ngx_str_set(&r->headers_out.content_type, "text/html");

    r->headers_out.content_length_n = -1;
    ngx_http_clear_content_length(r);

    return ngx_http_next_header_filter(r);
}
```

**Correct (only transforms main request responses):**

```c
static ngx_int_t
ngx_http_myfilter_header_filter(ngx_http_request_t *r)
{
    /* skip subrequests — only transform the main client response */
    if (r != r->main) {
        return ngx_http_next_header_filter(r);
    }

    r->headers_out.content_type_len = sizeof("text/html") - 1;
    ngx_str_set(&r->headers_out.content_type, "text/html");

    r->headers_out.content_length_n = -1;
    ngx_http_clear_content_length(r);

    return ngx_http_next_header_filter(r);
}
```
