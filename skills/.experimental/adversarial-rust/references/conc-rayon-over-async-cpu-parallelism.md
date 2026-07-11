---
title: Use rayon for CPU-bound parallelism, not a fleet of async tasks
tags: conc, rayon, cpu-bound, parallelism
---

## Use rayon for CPU-bound parallelism, not a fleet of async tasks

Spawning a tokio task per chunk to parallelize hashing, compression, or image resizing treats async as a parallelism tool — the JavaScript habit where the event loop is the only concurrency you have. Async buys concurrent *waiting*; CPU-bound tasks never wait, so they occupy the runtime's few worker threads, starve the I/O tasks the runtime exists to serve, and add `JoinHandle`/`.await` ceremony around what is a data-parallel loop. Rayon's work-stealing pool is built for exactly this shape: `par_iter` keeps the code a loop and saturates the cores.

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

**Correct (a parallel loop on a compute pool):**

```rust
use rayon::prelude::*;

fn thumbnail_all(images: Vec<Image>) -> Vec<Thumbnail> {
    images.into_par_iter().map(resize).collect()
}
```

Inside an async service, bridge the two worlds explicitly: run the rayon block under `spawn_blocking` (or send results back over a oneshot channel) so the compute pool and the I/O runtime each do their own job.

Reference: [rayon — crate docs](https://docs.rs/rayon/latest/rayon/) · [Alice Ryhl — Async: What is blocking?](https://ryhl.io/blog/async-what-is-blocking/)
