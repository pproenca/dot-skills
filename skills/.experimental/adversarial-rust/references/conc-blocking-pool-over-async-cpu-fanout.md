---
title: Offload CPU-bound work to the blocking pool, not a fleet of async tasks
tags: conc, spawn-blocking, cpu-bound, parallelism
---

## Offload CPU-bound work to the blocking pool, not a fleet of async tasks

Spawning a tokio task per chunk to parallelize hashing, compression, or image resizing treats async as a parallelism tool — the JavaScript habit where the event loop is the only concurrency you have. Async buys concurrent *waiting*; CPU-bound tasks never wait, so they occupy the runtime's few worker threads, starve the I/O tasks the runtime exists to serve, and add `JoinHandle`/`.await` ceremony around what is a plain loop. The runtime already has a home for work that won't yield: `spawn_blocking` moves the computation onto the dedicated blocking pool, where it can grind away without stalling a single I/O task — and since each `spawn_blocking` call gets its own thread from that pool, concurrent requests still spread across cores.

**Incorrect (compute squatting on the I/O runtime):**

```rust
async fn thumbnail_all(images: Vec<Image>) -> Vec<Thumbnail> {
    let mut handles = Vec::new();
    for img in images {
        handles.push(tokio::spawn(async move { resize(img) })); // no await inside
    }
    let mut out = Vec::new();
    for h in handles {
        out.push(h.await.unwrap());
    }
    out
}
```

**Correct (compute handed to the blocking pool):**

```rust
async fn thumbnail_all(images: Vec<Image>) -> Vec<Thumbnail> {
    tokio::task::spawn_blocking(move || images.into_iter().map(resize).collect())
        .await
        .expect("thumbnail worker panicked")
}
```

The `expect` is the sanctioned kind: the join fails only if the worker panicked, which is a bug, not an outcome to handle. If one request must saturate every core by itself — a genuinely data-parallel hot loop, not just "work to get off the runtime" — put a rayon `par_iter` inside that single `spawn_blocking` so the compute pool and the I/O runtime each do their own job; most services never reach that point.

Reference: [tokio::task::spawn_blocking](https://docs.rs/tokio/latest/tokio/task/fn.spawn_blocking.html) · [Alice Ryhl — Async: What is blocking?](https://ryhl.io/blog/async-what-is-blocking/)
