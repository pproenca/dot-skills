---
title: Understand Accept Mutex Impact on Connection Distribution
impact: MEDIUM
impactDescription: prevents thundering herd on new connections across workers
tags: worker, accept-mutex, thundering-herd, distribution
---

## Understand Accept Mutex Impact on Connection Distribution

When `accept_mutex` is off (the default since nginx 1.11.3), every worker process is notified of a new connection on a shared listen socket, causing all of them to wake and race to `accept()` -- only one succeeds, and the rest waste CPU cycles returning to sleep. Module code that registers its own listen sockets or connection handlers must be aware of this behavior: if the module assumes exclusive ownership of incoming connections without coordinating through the accept mutex, it will either duplicate work or silently drop connections under high concurrency.

**Incorrect (all workers wake and race to accept on shared socket):**

```c
static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_listening_t  *ls;
    ngx_connection_t *c;

    ls = ngx_http_mymodule_get_listening(cycle);

    c = ngx_get_connection(ls->fd, cycle->log);
    if (c == NULL) {
        return NGX_ERROR;
    }

    c->log = cycle->log;
    c->read->handler = ngx_http_mymodule_accept_handler;

    /* BUG: every worker adds the listen fd to its own epoll set
     * without checking accept_mutex — all workers wake on every
     * incoming connection (thundering herd), wasting CPU */
    if (ngx_add_event(c->read, NGX_READ_EVENT, 0) == NGX_ERROR) {
        ngx_close_connection(c);
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Correct (respects accept mutex to serialize accept() across workers):**

```c
static ngx_int_t
ngx_http_mymodule_init_process(ngx_cycle_t *cycle)
{
    ngx_listening_t  *ls;
    ngx_connection_t *c;

    ls = ngx_http_mymodule_get_listening(cycle);

    c = ngx_get_connection(ls->fd, cycle->log);
    if (c == NULL) {
        return NGX_ERROR;
    }

    c->log = cycle->log;
    c->read->handler = ngx_http_mymodule_accept_handler;
    c->listening = ls;

    /* register the listen socket through nginx's event framework;
     * NGX_USE_ACCEPT_MUTEX_EVENT tells the event system to defer
     * adding this fd to epoll until the worker acquires the accept
     * mutex — only one worker polls the socket at a time */
    if (ngx_use_accept_mutex) {
        return NGX_OK;  /* ls will be added during ngx_trylock_accept_mutex */
    }

    /* accept_mutex is off — add directly but use EPOLLEXCLUSIVE
     * (NGX_EXCLUSIVE_EVENT) so the kernel wakes only one worker */
    if (ngx_add_event(c->read, NGX_READ_EVENT,
                      ngx_event_flags & NGX_USE_EPOLL_EVENT
                      ? NGX_EXCLUSIVE_EVENT : 0)
        == NGX_ERROR)
    {
        ngx_close_connection(c);
        return NGX_ERROR;
    }

    return NGX_OK;
}
```

**Note:** On Linux kernels 4.5+ with epoll, `EPOLLEXCLUSIVE` provides kernel-level thundering-herd avoidance without the accept mutex overhead. The correct approach checks for epoll availability via `ngx_event_flags` and falls back gracefully.
