---
title: Set TCP_NODELAY for Low-Latency Protocols
impact: HIGH
impactDescription: reduces latency by 40ms on small messages
tags: net, tcp, nodelay, nagle, latency
---

## Set TCP_NODELAY for Low-Latency Protocols

Nagle's algorithm delays small packets to coalesce them, adding up to 40ms latency. Disable it with TCP_NODELAY for interactive or request-response protocols.

**Incorrect (Nagle's algorithm adds latency):**

```rust
async fn handle_connection(stream: TcpStream) {
    let mut stream = BufWriter::new(stream);

    loop {
        let request = read_request(&mut stream).await?;
        let response = process(request);
        stream.write_all(&response).await?;
        stream.flush().await?;  // Flush helps, but Nagle still delays
    }
}
```

**Correct (disable Nagle for low latency):**

```rust
async fn handle_connection(stream: TcpStream) {
    stream.set_nodelay(true)?;  // Disable Nagle's algorithm

    let mut stream = BufWriter::new(stream);

    loop {
        let request = read_request(&mut stream).await?;
        let response = process(request);
        stream.write_all(&response).await?;
        stream.flush().await?;  // Sends immediately
    }
}
```

**When to keep Nagle enabled:**
- Bulk data transfer (throughput matters more than latency)
- Applications that already batch writes efficiently
- High-bandwidth scenarios where small packets are inefficient

Reference: [TcpStream::set_nodelay](https://doc.rust-lang.org/std/net/struct.TcpStream.html#method.set_nodelay)
