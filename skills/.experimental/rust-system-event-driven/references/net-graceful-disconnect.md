---
title: Implement Graceful Connection Shutdown
impact: HIGH
impactDescription: prevents data loss on connection close
tags: net, shutdown, graceful, tcp, close
---

## Implement Graceful Connection Shutdown

Closing a socket abruptly can lose data still in buffers. Use shutdown to signal end-of-stream and wait for the peer to acknowledge.

**Incorrect (abrupt close loses data):**

```rust
async fn handle_connection(mut stream: TcpStream) {
    // Send final response
    stream.write_all(b"goodbye").await?;
    // Connection dropped immediately, data may be lost
}
```

**Correct (graceful shutdown):**

```rust
use tokio::io::AsyncWriteExt;

async fn handle_connection(mut stream: TcpStream) -> Result<(), Error> {
    // Send final response
    stream.write_all(b"goodbye").await?;

    // Flush write buffer
    stream.flush().await?;

    // Signal no more writes, allow peer to finish reading
    stream.shutdown().await?;

    Ok(())
}
```

**For bidirectional protocols:**

```rust
async fn handle_connection(stream: TcpStream) -> Result<(), Error> {
    let (mut reader, mut writer) = stream.into_split();

    // ... handle messages ...

    // Shutdown write side, signaling end of our messages
    writer.shutdown().await?;

    // Read until peer closes their side
    let mut buf = [0u8; 1024];
    while reader.read(&mut buf).await? > 0 {
        // Process remaining incoming data
    }

    Ok(())
}
```

Reference: [AsyncWriteExt::shutdown](https://docs.rs/tokio/latest/tokio/io/trait.AsyncWriteExt.html#method.shutdown)
