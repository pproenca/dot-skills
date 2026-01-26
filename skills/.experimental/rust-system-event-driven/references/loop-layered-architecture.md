---
title: Separate I/O from Business Logic
impact: LOW-MEDIUM
impactDescription: enables testing and improves maintainability
tags: loop, architecture, separation, testing, io
---

## Separate I/O from Business Logic

Keep I/O handling (reading/writing streams) separate from business logic. This enables unit testing of logic without network setup and improves code organization.

**Incorrect (I/O mixed with logic):**

```rust
async fn handle_client(mut stream: TcpStream) -> Result<(), Error> {
    let mut buf = [0u8; 1024];
    let n = stream.read(&mut buf).await?;
    let request: Request = serde_json::from_slice(&buf[..n])?;

    // Business logic mixed with I/O
    let user = db.get_user(request.user_id).await?;
    let result = if user.is_admin {
        process_admin_request(&request)
    } else {
        process_user_request(&request)
    };

    let response = serde_json::to_vec(&result)?;
    stream.write_all(&response).await?;
    Ok(())
}
```

**Correct (separated concerns):**

```rust
// Pure business logic - easily testable
fn process_request(request: &Request, user: &User) -> Response {
    if user.is_admin {
        process_admin_request(request)
    } else {
        process_user_request(request)
    }
}

// I/O layer
async fn handle_client(
    mut stream: TcpStream,
    processor: &RequestProcessor,
) -> Result<(), Error> {
    let request = read_request(&mut stream).await?;
    let response = processor.process(&request).await?;
    write_response(&mut stream, &response).await
}

// Service layer coordinates I/O and logic
struct RequestProcessor {
    db: Database,
}

impl RequestProcessor {
    async fn process(&self, request: &Request) -> Result<Response, Error> {
        let user = self.db.get_user(request.user_id).await?;
        Ok(process_request(request, &user))
    }
}

// Tests don't need network
#[test]
fn test_admin_request() {
    let request = Request { /* ... */ };
    let user = User { is_admin: true, /* ... */ };
    let response = process_request(&request, &user);
    assert!(response.is_success());
}
```

Reference: [Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/)
