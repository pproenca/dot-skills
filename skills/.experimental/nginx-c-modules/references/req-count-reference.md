---
title: Increment Request Count Before Async Operations
impact: HIGH
impactDescription: prevents premature request destruction during async work
tags: req, reference-count, async, lifecycle
---

## Increment Request Count Before Async Operations

nginx uses `r->main->count` as a reference counter. Before starting async operations (subrequests, timers, external I/O), increment the count to prevent the request from being destroyed while async work is pending. Forgetting this causes use-after-free when the timer or callback fires on a freed request.

**Incorrect (timer callback on freed request):**

```c
static void
ngx_http_mymodule_timer_handler(ngx_event_t *ev)
{
    ngx_http_request_t  *r = ev->data;

    /* BUG: r may already be freed — count was never incremented */
    ngx_http_finalize_request(r, NGX_OK);
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_event_t  *wev;

    /* BUG: no r->main->count++ — request can be destroyed before timer */
    wev = r->connection->write;
    wev->handler = ngx_http_mymodule_timer_handler;
    wev->data = r;
    ngx_add_timer(wev, 5000);

    return NGX_DONE;
}
```

**Correct (increment count before async, decrement on completion):**

```c
static void
ngx_http_mymodule_timer_handler(ngx_event_t *ev)
{
    ngx_http_request_t  *r = ev->data;

    /* count was incremented — r is guaranteed alive */
    ngx_http_finalize_request(r, NGX_OK);
    /* finalize decrements count internally */
}

static ngx_int_t
ngx_http_mymodule_handler(ngx_http_request_t *r)
{
    ngx_event_t  *wev;

    /* keep request alive while timer is pending */
    r->main->count++;

    wev = r->connection->write;
    wev->handler = ngx_http_mymodule_timer_handler;
    wev->data = r;
    ngx_add_timer(wev, 5000);

    return NGX_DONE;
}
```
