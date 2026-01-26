---
title: Split Sockets into Reader and Writer Halves
impact: HIGH
impactDescription: enables concurrent bidirectional I/O
tags: net, split, socket, bidirectional, tokio
---

## Split Sockets into Reader and Writer Halves

To read and write on a socket concurrently, split it into separate reader and writer halves. This avoids needing a mutex around the entire socket.

**Incorrect (mutex blocks concurrent I/O):**

```rust
async fn handle_connection(stream: TcpStream) {
    let stream = Arc::new(Mutex::new(stream));

    let read_handle = tokio::spawn({
        let stream = stream.clone();
        async move {
            let mut buf = [0u8; 1024];
            let mut guard = stream.lock().await;
            guard.read(&mut buf).await  // Blocks writer!
        }
    });

    let write_handle = tokio::spawn({
        let stream = stream.clone();
        async move {
            let mut guard = stream.lock().await;
            guard.write_all(b"hello").await
        }
    });
}
```

**Correct (split for concurrent I/O):**

```rust
async fn handle_connection(stream: TcpStream) {
    let (reader, writer) = stream.into_split();

    let read_handle = tokio::spawn(async move {
        let mut reader = BufReader::new(reader);
        let mut line = String::new();
        reader.read_line(&mut line).await
    });

    let write_handle = tokio::spawn(async move {
        let mut writer = BufWriter::new(writer);
        writer.write_all(b"hello").await?;
        writer.flush().await
    });

    let _ = tokio::try_join!(read_handle, write_handle);
}
```

**Note:** Use `split()` for borrowed halves, `into_split()` for owned halves that can be sent to different tasks.

Reference: [Tokio TcpStream::into_split](https://docs.rs/tokio/latest/tokio/net/struct.TcpStream.html#method.into_split)
