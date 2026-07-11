---
title: Run CPU-bound fan-out on a bounded thread pool behind one spawn_blocking
tags: conc, cpu-bound, thread-pool, cancellation
---

## Run CPU-bound fan-out on a bounded thread pool behind one spawn_blocking

Async fan-out — spawning a tokio task per item of CPU work — is the JavaScript reflex applied to computation: async buys *concurrent waiting*, and CPU work never waits, so the tasks just occupy runtime workers and starve I/O. codex-rs contains no rayon and no async CPU fan-out; its one genuinely parallel CPU workload (fuzzy file search: directory walk + scoring) runs on dedicated OS threads — the `ignore` crate's parallel walker plus worker threads over crossbeam channels — bounded by `cores.min(MAX_THREADS)`, cancellable through a shared flag polled by workers, and the async world reaches it through a single `spawn_blocking` call.

```rust
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;

struct FileSearchResults {
    matches: Vec<String>,
}

/// Synchronous, thread-pooled search — the async runtime never sees the CPU work.
fn run_search(query: String, threads: usize, cancel_flag: Arc<AtomicBool>) -> FileSearchResults {
    let workers: Vec<_> = (0..threads)
        .map(|_| {
            let cancel = Arc::clone(&cancel_flag);
            let query = query.clone();
            std::thread::spawn(move || {
                let mut matches = Vec::new();
                while !cancel.load(Ordering::Relaxed) {
                    matches.push(query.clone());
                    break; // walk/score work elided
                }
                matches
            })
        })
        .collect();
    let matches = workers.into_iter().filter_map(|w| w.join().ok()).flatten().collect();
    FileSearchResults { matches }
}

/// The single async entry point — how codex-rs invokes fuzzy file search.
async fn fuzzy_file_search(query: String, cancel_flag: Arc<AtomicBool>) -> FileSearchResults {
    let threads = std::thread::available_parallelism().map_or(2, |n| n.get()).min(8);
    tokio::task::spawn_blocking(move || run_search(query, threads, cancel_flag))
        .await
        .unwrap_or(FileSearchResults { matches: Vec::new() })
}
```

The three load-bearing choices: thread count bounded by cores (unbounded fan-out buys contention, not speed), cancellation as a shared `AtomicBool` the workers poll (async cancellation cannot reach into compute threads), and exactly one `spawn_blocking` bridge so the runtime schedules around the whole computation as a single blocking unit.

Reference: [codex-rs file-search/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/file-search/src/lib.rs#L205), [codex-rs app-server/src/fuzzy_file_search.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/fuzzy_file_search.rs#L41)
