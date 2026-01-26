---
title: Add Timeouts to All Network Operations
impact: HIGH
impactDescription: prevents indefinite hangs on network failures
tags: net, timeout, resilience, tokio, error-handling
---

## Add Timeouts to All Network Operations

Network operations can hang indefinitely if the remote end stops responding. Always wrap network I/O with timeouts to ensure your application remains responsive.

**Incorrect (can hang forever):**

```rust
async fn fetch_data(stream: &mut TcpStream) -> Result<Data, Error> {
    let mut buf = vec![0u8; 1024];
    stream.read_exact(&mut buf).await?;  // Hangs if peer stops sending
    parse_data(&buf)
}
```

**Correct (timeout on operations):**

```rust
use tokio::time::{timeout, Duration};

async fn fetch_data(stream: &mut TcpStream) -> Result<Data, Error> {
    let mut buf = vec![0u8; 1024];

    timeout(Duration::from_secs(30), stream.read_exact(&mut buf))
        .await
        .map_err(|_| Error::Timeout)??;

    parse_data(&buf)
}
```

**Timeout on connection establishment:**

```rust
async fn connect_with_timeout(addr: &str) -> Result<TcpStream, Error> {
    timeout(Duration::from_secs(5), TcpStream::connect(addr))
        .await
        .map_err(|_| Error::ConnectionTimeout)?
        .map_err(Error::Connection)
}
```

**For HTTP clients:**

```rust
let client = reqwest::Client::builder()
    .connect_timeout(Duration::from_secs(5))
    .timeout(Duration::from_secs(30))
    .build()?;
```

Reference: [tokio::time::timeout](https://docs.rs/tokio/latest/tokio/time/fn.timeout.html)
