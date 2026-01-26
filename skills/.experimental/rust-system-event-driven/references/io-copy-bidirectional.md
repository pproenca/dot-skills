---
title: Use copy_bidirectional for Proxying
impact: MEDIUM
impactDescription: prevents orphaned tasks and resource leaks
tags: io, copy, proxy, bidirectional, tokio
---

## Use copy_bidirectional for Proxying

When proxying between two streams (e.g., TCP proxy), use `copy_bidirectional` to efficiently copy data in both directions simultaneously.

**Incorrect (manual bidirectional copy):**

```rust
async fn proxy(client: TcpStream, server: TcpStream) {
    let (client_read, client_write) = client.into_split();
    let (server_read, server_write) = server.into_split();

    let client_to_server = tokio::io::copy(&mut client_read, &mut server_write);
    let server_to_client = tokio::io::copy(&mut server_read, &mut client_write);

    // If one direction fails, the other keeps running
    tokio::select! {
        _ = client_to_server => {}
        _ = server_to_client => {}
    }
    // One direction may be orphaned
}
```

**Correct (copy_bidirectional handles both):**

```rust
use tokio::io::copy_bidirectional;

async fn proxy(mut client: TcpStream, mut server: TcpStream) -> Result<(), Error> {
    let (client_bytes, server_bytes) = copy_bidirectional(&mut client, &mut server).await?;

    tracing::info!(
        client_to_server = client_bytes,
        server_to_client = server_bytes,
        "proxy connection closed"
    );

    Ok(())
}
```

**With buffered I/O for better performance:**

```rust
use tokio::io::{copy_bidirectional, BufReader, BufWriter};

async fn proxy(client: TcpStream, server: TcpStream) -> Result<(), Error> {
    let (client_read, client_write) = client.into_split();
    let (server_read, server_write) = server.into_split();

    let mut client = tokio::io::join(BufReader::new(client_read), BufWriter::new(client_write));
    let mut server = tokio::io::join(BufReader::new(server_read), BufWriter::new(server_write));

    copy_bidirectional(&mut client, &mut server).await?;
    Ok(())
}
```

Reference: [tokio::io::copy_bidirectional](https://docs.rs/tokio/latest/tokio/io/fn.copy_bidirectional.html)
