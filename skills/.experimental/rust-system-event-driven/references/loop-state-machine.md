---
title: Model Protocol State as Type-Safe State Machine
impact: LOW-MEDIUM
impactDescription: prevents invalid state transitions at compile time
tags: loop, state-machine, protocol, types, safety
---

## Model Protocol State as Type-Safe State Machine

Use the type system to encode protocol states and valid transitions. Invalid transitions become compile errors instead of runtime bugs.

**Incorrect (runtime state validation):**

```rust
struct Connection {
    state: ConnectionState,
    stream: TcpStream,
}

enum ConnectionState {
    Handshaking,
    Authenticated,
    Ready,
    Closed,
}

impl Connection {
    async fn send_message(&mut self, msg: &[u8]) -> Result<(), Error> {
        if self.state != ConnectionState::Ready {
            return Err(Error::InvalidState);  // Runtime error
        }
        self.stream.write_all(msg).await
    }
}
```

**Correct (type-safe state machine):**

```rust
struct Handshaking {
    stream: TcpStream,
}

struct Authenticated {
    stream: TcpStream,
    user: User,
}

struct Ready {
    stream: TcpStream,
    user: User,
    session: Session,
}

impl Handshaking {
    async fn authenticate(mut self, creds: Credentials) -> Result<Authenticated, (Self, Error)> {
        match verify(&creds).await {
            Ok(user) => Ok(Authenticated { stream: self.stream, user }),
            Err(e) => Err((self, e)),
        }
    }
}

impl Authenticated {
    async fn establish_session(mut self) -> Result<Ready, (Self, Error)> {
        match Session::create(&self.user).await {
            Ok(session) => Ok(Ready { stream: self.stream, user: self.user, session }),
            Err(e) => Err((self, e)),
        }
    }
}

impl Ready {
    // Only Ready state has send_message - compile error if called on other states
    async fn send_message(&mut self, msg: &[u8]) -> Result<(), Error> {
        self.stream.write_all(msg).await
    }
}
```

**Benefits:**
- Invalid state transitions are compile errors
- Each state only exposes valid operations
- State transitions are explicit and documented

Reference: [Type State Pattern in Rust](https://cliffle.com/blog/rust-typestate/)
