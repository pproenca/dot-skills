---
title: Never Use Blocking Calls in Event Handlers
impact: MEDIUM
impactDescription: prevents freezing worker serving thousands of connections
tags: event, blocking, worker, performance
---

## Never Use Blocking Calls in Event Handlers

nginx workers use a single-threaded event loop that multiplexes thousands of connections. A blocking call -- `connect()`, `sleep()`, synchronous file I/O, or DNS resolution -- freezes the entire worker process, stalling every connection it manages until the blocking call completes or times out.

**Incorrect (blocking connect and synchronous read in handler):**

```c
static void
ngx_http_mymodule_check_backend(ngx_event_t *ev)
{
    int              fd;
    struct sockaddr  sa;
    char             buf[1024];

    /* BUG: blocking connect — freezes worker for up to TCP timeout */
    fd = socket(AF_INET, SOCK_STREAM, 0);
    connect(fd, &sa, sizeof(sa));

    /* BUG: blocking read — worker stalls until data arrives */
    read(fd, buf, sizeof(buf));

    close(fd);
}
```

**Correct (non-blocking I/O through nginx event system):**

```c
static void
ngx_http_mymodule_check_backend(ngx_event_t *ev)
{
    ngx_connection_t  *c = ev->data;
    ngx_int_t          n;

    /* non-blocking read via nginx connection abstraction */
    n = c->recv(c, c->buffer->last,
                c->buffer->end - c->buffer->last);

    if (n == NGX_AGAIN) {
        /* no data yet — re-register and return to event loop */
        ngx_handle_read_event(c->read, 0);
        return;
    }

    if (n == NGX_ERROR || n == 0) {
        ngx_http_mymodule_finalize(c);
        return;
    }

    c->buffer->last += n;
    ngx_http_mymodule_process(c);
}
```
