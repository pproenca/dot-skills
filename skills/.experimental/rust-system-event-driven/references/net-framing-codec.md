---
title: Use Framing for Message-Based Protocols
impact: HIGH
impactDescription: prevents partial reads and message corruption
tags: net, framing, codec, protocol, tokio
---

## Use Framing for Message-Based Protocols

TCP is a stream protocol with no message boundaries. Use length-prefixed framing or delimiter-based parsing to ensure complete messages are read.

**Incorrect (assumes one read = one message):**

```rust
async fn read_message(stream: &mut TcpStream) -> Result<Message, Error> {
    let mut buf = vec![0u8; 1024];
    let n = stream.read(&mut buf).await?;
    // BUG: May read partial message or multiple messages!
    serde_json::from_slice(&buf[..n])
}
```

**Correct (length-prefixed framing):**

```rust
use tokio::io::{AsyncReadExt, AsyncWriteExt};

async fn read_message(stream: &mut TcpStream) -> Result<Message, Error> {
    // Read 4-byte length prefix
    let len = stream.read_u32().await? as usize;
    if len > MAX_MESSAGE_SIZE {
        return Err(Error::MessageTooLarge);
    }

    // Read exact message bytes
    let mut buf = vec![0u8; len];
    stream.read_exact(&mut buf).await?;
    serde_json::from_slice(&buf)
}

async fn write_message(stream: &mut TcpStream, msg: &Message) -> Result<(), Error> {
    let data = serde_json::to_vec(msg)?;
    stream.write_u32(data.len() as u32).await?;
    stream.write_all(&data).await?;
    Ok(())
}
```

**Alternative with tokio-util codec:**

```rust
use tokio_util::codec::{Framed, LengthDelimitedCodec};

let framed = Framed::new(stream, LengthDelimitedCodec::new());
// Now use framed.send() and framed.next() for messages
```

Reference: [tokio-util LengthDelimitedCodec](https://docs.rs/tokio-util/latest/tokio_util/codec/length_delimited/)
