---
title: Delete Timers Before Freeing Associated Data
impact: MEDIUM
impactDescription: prevents use-after-free when timer fires after cleanup
tags: event, timer, cleanup, lifecycle
---

## Delete Timers Before Freeing Associated Data

Timer events are stored in a global red-black tree. If the data structure associated with a timer is freed while the timer remains registered, the timer eventually fires and dereferences freed memory -- causing segfaults, corruption, or silent data mangling. Always call `ngx_del_timer` before destroying the timer's context.

**Incorrect (frees connection without deleting pending timer):**

```c
static void
ngx_http_mymodule_close(ngx_connection_t *c)
{
    ngx_http_mymodule_ctx_t  *ctx = c->data;

    /* BUG: timer still in rbtree — will fire and access freed ctx */
    ngx_pfree(c->pool, ctx);
    ngx_close_connection(c);
}
```

**Correct (deletes timer before freeing associated data):**

```c
static void
ngx_http_mymodule_close(ngx_connection_t *c)
{
    ngx_http_mymodule_ctx_t  *ctx = c->data;

    /* remove timer from rbtree before freeing its context */
    if (c->read->timer_set) {
        ngx_del_timer(c->read);
    }

    if (c->write->timer_set) {
        ngx_del_timer(c->write);
    }

    ngx_pfree(c->pool, ctx);
    ngx_close_connection(c);
}
```
