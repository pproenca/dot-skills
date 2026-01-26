---
title: Use Pipes for Process Communication
impact: MEDIUM
impactDescription: enables streaming data between parent and child processes
tags: io, pipe, process, ipc, streaming
---

## Use Pipes for Process Communication

Connect to child processes via stdin/stdout pipes to stream data without temporary files or size limitations.

**Incorrect (uses temp file for IPC):**

```rust
async fn transform_data(data: &[u8]) -> Result<Vec<u8>, Error> {
    let input_path = "/tmp/input.dat";
    let output_path = "/tmp/output.dat";

    tokio::fs::write(input_path, data).await?;

    Command::new("transformer")
        .args(&[input_path, output_path])
        .status()
        .await?;

    tokio::fs::read(output_path).await
}
```

**Correct (streams via pipes):**

```rust
use tokio::process::Command;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

async fn transform_data(data: &[u8]) -> Result<Vec<u8>, Error> {
    let mut child = Command::new("transformer")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    let mut stdin = child.stdin.take().unwrap();
    let mut stdout = child.stdout.take().unwrap();

    // Write input in background while reading output
    let write_task = tokio::spawn(async move {
        stdin.write_all(data).await?;
        stdin.shutdown().await  // Signal EOF
    });

    let mut output = Vec::new();
    stdout.read_to_end(&mut output).await?;

    write_task.await??;
    child.wait().await?;

    Ok(output)
}
```

**For streaming large data:**

```rust
async fn stream_transform(
    mut input: impl AsyncRead + Unpin,
    mut output: impl AsyncWrite + Unpin,
) -> Result<(), Error> {
    let mut child = Command::new("transformer")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    let mut stdin = child.stdin.take().unwrap();
    let mut stdout = child.stdout.take().unwrap();

    let (_, _) = tokio::try_join!(
        tokio::io::copy(&mut input, &mut stdin),
        tokio::io::copy(&mut stdout, &mut output),
    )?;

    child.wait().await?;
    Ok(())
}
```

Reference: [tokio::process::Command](https://docs.rs/tokio/latest/tokio/process/struct.Command.html)
