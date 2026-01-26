---
title: Flush Writes Before Expecting Responses
impact: MEDIUM
impactDescription: prevents deadlocks from unflushed buffers
tags: io, flush, buffer, deadlock, protocol
---

## Flush Writes Before Expecting Responses

Buffered writers don't send data until the buffer is full or explicitly flushed. Always flush after writing a request before waiting for a response.

**Incorrect (deadlock from unflushed write):**

```rust
use tokio::io::{AsyncBufReadExt, AsyncWriteExt, BufReader, BufWriter};

async fn request_response(stream: TcpStream) -> Result<String, Error> {
    let (reader, writer) = stream.into_split();
    let mut reader = BufReader::new(reader);
    let mut writer = BufWriter::new(writer);

    writer.write_all(b"REQUEST\n").await?;
    // Data still in buffer! Server never receives it.

    let mut response = String::new();
    reader.read_line(&mut response).await?;  // Deadlock: waiting for response that was never sent
    Ok(response)
}
```

**Correct (flush before reading response):**

```rust
async fn request_response(stream: TcpStream) -> Result<String, Error> {
    let (reader, writer) = stream.into_split();
    let mut reader = BufReader::new(reader);
    let mut writer = BufWriter::new(writer);

    writer.write_all(b"REQUEST\n").await?;
    writer.flush().await?;  // Ensures data is sent

    let mut response = String::new();
    reader.read_line(&mut response).await?;
    Ok(response)
}
```

**Alternative: use unbuffered writer for small messages:**

```rust
async fn request_response(mut stream: TcpStream) -> Result<String, Error> {
    // Unbuffered write sends immediately
    stream.write_all(b"REQUEST\n").await?;

    let mut reader = BufReader::new(stream);
    let mut response = String::new();
    reader.read_line(&mut response).await?;
    Ok(response)
}
```

Reference: [AsyncWriteExt::flush](https://docs.rs/tokio/latest/tokio/io/trait.AsyncWriteExt.html#method.flush)
