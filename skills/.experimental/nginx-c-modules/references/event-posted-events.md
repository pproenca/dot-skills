---
title: Use Posted Events for Deferred Processing
impact: LOW-MEDIUM
impactDescription: prevents deep call stack recursion in event handlers
tags: event, posted, deferred, recursion
---

## Use Posted Events for Deferred Processing

Calling event handlers directly from within other handlers creates deep recursion that can overflow the stack, especially under high concurrency where chains of subrequest completions or cascading I/O triggers compound the depth. `ngx_post_event` defers execution to the next event loop iteration, flattening the call stack and making execution order predictable.

**Incorrect (direct handler call creates deep recursion):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;

    /* process incoming data */
    ngx_http_mymodule_process(c);

    /* BUG: direct call — if write_handler triggers another read,
     * the call stack grows unbounded under load */
    ngx_http_mymodule_write_handler(c->write);
}

static void
ngx_http_mymodule_write_handler(ngx_event_t *wev)
{
    ngx_connection_t  *c = wev->data;

    ngx_http_mymodule_send(c);

    /* BUG: recursive call back to read handler */
    ngx_http_mymodule_read_handler(c->read);
}
```

**Correct (defers processing to next event loop iteration):**

```c
static void
ngx_http_mymodule_read_handler(ngx_event_t *rev)
{
    ngx_connection_t  *c = rev->data;

    /* process incoming data */
    ngx_http_mymodule_process(c);

    /* defer write to next event loop iteration — flat call stack */
    ngx_post_event(c->write, &ngx_posted_events);
}

static void
ngx_http_mymodule_write_handler(ngx_event_t *wev)
{
    ngx_connection_t  *c = wev->data;

    ngx_http_mymodule_send(c);

    /* defer read to next iteration instead of direct call */
    ngx_post_event(c->read, &ngx_posted_events);
}
```
