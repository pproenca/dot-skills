---
title: Cap subprocess output with a head-and-tail ring buffer
impact: CRITICAL
impactDescription: prevents OOM on runaway output and preserves the most informative tail lines
tags: defensive, resource-limits, ring-buffer, subprocess
---

## Cap subprocess output with a head-and-tail ring buffer

Trailing truncation (`output[..MAX]`) is wrong twice: it OOMs before the cap because you buffer everything first, and it discards the last lines — usually the most informative, containing errors and stack traces. Codex streams output into a fixed head budget plus a ring-buffer tail, tracks `omitted_bytes` between them, and uses `saturating_*` arithmetic everywhere so oversized chunks cannot panic. The reader also keeps consuming bytes past the cap so the child process does not deadlock on a full pipe.

**Incorrect (trailing truncate loses the tail and still OOMs):**

```rust
let mut collected = Vec::new();
while let Ok(read_count) = reader.read(&mut chunk_buf).await {
    if read_count == 0 { break; }
    collected.extend_from_slice(&chunk_buf[..read_count]);
}
collected.truncate(MAX_OUTPUT_BYTES); // last lines silently dropped
```

**Correct (bounded head, ring-buffer tail, keeps draining after cap):**

```rust
// core/src/unified_exec/head_tail_buffer.rs
pub(crate) fn push_chunk(&mut self, chunk: Vec<u8>) {
    if self.max_bytes == 0 {
        self.omitted_bytes = self.omitted_bytes.saturating_add(chunk.len());
        return;
    }
    if self.head_bytes < self.head_budget {
        let remaining_head = self.head_budget.saturating_sub(self.head_bytes);
        if chunk.len() <= remaining_head {
            self.head_bytes = self.head_bytes.saturating_add(chunk.len());
            self.head.push_back(chunk);
            return;
        }
        /* split head / tail */
    }
    /* push into ring buffer tail, updating omitted_bytes */
}

// core/src/exec.rs — keep draining after cap to avoid back-pressure
fn append_capped(dst: &mut Vec<u8>, src: &[u8], max_bytes: usize) {
    if dst.len() >= max_bytes { return; }
    let remaining = max_bytes.saturating_sub(dst.len());
    let take = remaining.min(src.len());
    dst.extend_from_slice(&src[..take]);
}
```

The "keep draining after cap" rule is load-bearing: stop reading and a long-running child process deadlocks on its own full pipe, hanging the agent forever.

Reference: `codex-rs/core/src/unified_exec/head_tail_buffer.rs:65`, `codex-rs/core/src/exec.rs:747`.
