---
title: Reap Child Processes to Avoid Zombies
impact: MEDIUM
impactDescription: prevents resource leaks from zombie processes
tags: sig, child, zombie, reap, process
---

## Reap Child Processes to Avoid Zombies

When spawning child processes, always wait for them to complete or they become zombie processes that consume system resources until the parent exits.

**Incorrect (creates zombie processes):**

```rust
use std::process::Command;

async fn spawn_worker() {
    let child = Command::new("worker")
        .spawn()
        .expect("failed to spawn");
    // Child handle dropped without waiting - zombie when child exits!
}
```

**Correct (properly reaps children):**

```rust
use tokio::process::Command;

async fn spawn_worker() -> Result<(), Error> {
    let mut child = Command::new("worker")
        .spawn()
        .expect("failed to spawn");

    let status = child.wait().await?;  // Reaps child when it exits
    println!("Worker exited with: {}", status);
    Ok(())
}
```

**For fire-and-forget with cleanup:**

```rust
async fn spawn_workers(count: usize) {
    let mut children = Vec::new();

    for _ in 0..count {
        let child = Command::new("worker").spawn().expect("spawn failed");
        children.push(child);
    }

    // Reap all children when done
    for mut child in children {
        let _ = child.wait().await;
    }
}
```

**Alternative: use JoinSet for managed child processes:**

```rust
let mut set = JoinSet::new();

for _ in 0..count {
    set.spawn(async {
        let mut child = Command::new("worker").spawn()?;
        child.wait().await
    });
}

while let Some(result) = set.join_next().await {
    // Each child reaped as it completes
}
```

Reference: [tokio::process::Child](https://docs.rs/tokio/latest/tokio/process/struct.Child.html)
