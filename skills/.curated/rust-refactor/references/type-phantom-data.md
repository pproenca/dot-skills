---
title: Use PhantomData for Type-Level State
impact: CRITICAL
impactDescription: encodes state machines in types, prevents invalid state transitions
tags: type, phantom-data, state-machine, generics, typestate
---

## Use PhantomData for Type-Level State

Use `PhantomData` with type parameters to encode state machines at the type level. Invalid state transitions become compile errors.

**Incorrect (runtime state checks):**

```rust
struct Connection {
    is_connected: bool,
}

impl Connection {
    fn send(&self, data: &[u8]) -> Result<(), &'static str> {
        if !self.is_connected {
            return Err("Not connected");  // Runtime error
        }
        // Send data
        Ok(())
    }
}
```

**Correct (compile-time state enforcement):**

```rust
use std::marker::PhantomData;

struct Disconnected;
struct Connected;

struct Connection<State> {
    _state: PhantomData<State>,
}

impl Connection<Disconnected> {
    fn new() -> Self {
        Connection { _state: PhantomData }
    }

    fn connect(self) -> Connection<Connected> {
        // Perform connection
        Connection { _state: PhantomData }
    }
}

impl Connection<Connected> {
    fn send(&self, data: &[u8]) {
        // send() only exists on Connected state
    }

    fn disconnect(self) -> Connection<Disconnected> {
        Connection { _state: PhantomData }
    }
}

fn example() {
    let conn = Connection::new();
    // conn.send(&[]);  // Compile error: method not found
    let conn = conn.connect();
    conn.send(&[1, 2, 3]);  // Works
}
```

**Benefits:**
- Invalid states are unrepresentable
- State transitions are explicit and enforced
- Zero runtime overhead

Reference: [Type-Driven API Design in Rust](https://willcrichton.net/rust-api-type-patterns/)
