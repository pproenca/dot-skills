---
title: Use tokio_test for Mocking Async IO
impact: HIGH
impactDescription: enables testing network code without real connections
tags: async, tokio, mock-io, networking, testing
---

## Use tokio_test for Mocking Async IO

Use `tokio_test::io::Builder` to mock `AsyncRead` and `AsyncWrite` streams. This enables testing protocol implementations without real network connections.

**Incorrect (requires real network):**

```rust
#[tokio::test]
async fn test_http_parser() {
    // Requires running a real server
    let stream = TcpStream::connect("localhost:8080").await.unwrap();
    let mut parser = HttpParser::new(stream);

    let request = parser.read_request().await.unwrap();
    assert_eq!(request.method, "GET");
}
```

**Correct (mocked IO):**

```rust
use tokio_test::io::Builder;

#[tokio::test]
async fn test_http_parser_reads_request() {
    let mock_io = Builder::new()
        .read(b"GET /index.html HTTP/1.1\r\n")
        .read(b"Host: example.com\r\n")
        .read(b"\r\n")
        .build();

    let mut parser = HttpParser::new(mock_io);
    let request = parser.read_request().await.unwrap();

    assert_eq!(request.method, "GET");
    assert_eq!(request.path, "/index.html");
    assert_eq!(request.headers.get("Host"), Some(&"example.com".to_string()));
}

#[tokio::test]
async fn test_http_parser_writes_response() {
    let mock_io = Builder::new()
        .write(b"HTTP/1.1 200 OK\r\n")
        .write(b"Content-Length: 5\r\n")
        .write(b"\r\n")
        .write(b"Hello")
        .build();

    let mut writer = HttpWriter::new(mock_io);
    writer.write_response(Response::ok("Hello")).await.unwrap();
}

#[tokio::test]
async fn test_protocol_request_response() {
    let mock_io = Builder::new()
        // Client sends request
        .write(b"PING\n")
        // Server responds
        .read(b"PONG\n")
        .build();

    let mut client = ProtocolClient::new(mock_io);
    let response = client.ping().await.unwrap();

    assert_eq!(response, "PONG");
}
```

**Testing error conditions:**

```rust
use std::io::{Error, ErrorKind};

#[tokio::test]
async fn test_handles_connection_reset() {
    let mock_io = Builder::new()
        .read(b"partial data")
        .read_error(Error::new(ErrorKind::ConnectionReset, "connection reset"))
        .build();

    let mut parser = HttpParser::new(mock_io);
    let result = parser.read_request().await;

    assert!(matches!(result, Err(ParseError::ConnectionLost)));
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
tokio-test = "0.4"
```

Reference: [tokio_test::io](https://docs.rs/tokio-test/latest/tokio_test/io/index.html)
