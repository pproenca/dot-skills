---
title: Stream Large Files Instead of Loading Entirely
impact: MEDIUM
impactDescription: reduces memory usage from O(file_size) to O(buffer_size)
tags: io, stream, memory, large-files, buffering
---

## Stream Large Files Instead of Loading Entirely

Reading entire files into memory fails for large files and wastes memory for any file. Stream files in chunks for constant memory usage regardless of file size.

**Incorrect (loads entire file into memory):**

```rust
async fn process_log(path: &Path) -> Result<Stats, Error> {
    let contents = tokio::fs::read_to_string(path).await?;  // OOM on large files!
    let mut stats = Stats::default();
    for line in contents.lines() {
        stats.process_line(line);
    }
    Ok(stats)
}
```

**Correct (streams line by line):**

```rust
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::fs::File;

async fn process_log(path: &Path) -> Result<Stats, Error> {
    let file = File::open(path).await?;
    let reader = BufReader::new(file);
    let mut lines = reader.lines();

    let mut stats = Stats::default();
    while let Some(line) = lines.next_line().await? {
        stats.process_line(&line);
    }
    Ok(stats)
}
```

**For binary data, stream in chunks:**

```rust
use tokio::io::AsyncReadExt;

async fn hash_file(path: &Path) -> Result<Hash, Error> {
    let mut file = File::open(path).await?;
    let mut hasher = Sha256::new();
    let mut buffer = [0u8; 8192];

    loop {
        let n = file.read(&mut buffer).await?;
        if n == 0 {
            break;
        }
        hasher.update(&buffer[..n]);
    }

    Ok(hasher.finalize())
}
```

Reference: [tokio::io::AsyncBufReadExt](https://docs.rs/tokio/latest/tokio/io/trait.AsyncBufReadExt.html)
