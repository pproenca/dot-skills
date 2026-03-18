---
title: Use Enums to Represent State Machines
impact: HIGH
impactDescription: eliminates invalid state combinations at compile time
tags: safe, enum, state-machine, type-safety, exhaustive
---

## Use Enums to Represent State Machines

Model stateful processes as enums where each variant holds only the data valid for that state. This makes invalid states unrepresentable and forces callers to handle every transition via exhaustive matching.

**Incorrect (boolean flags allow invalid combinations):**

```rust
struct ConnectionState {
    is_connected: bool,
    is_authenticated: bool,
    auth_token: Option<String>,
    retry_count: u32,
}
// is_authenticated=true but auth_token=None is representable
```

**Correct (each state carries only its valid data):**

```rust
enum ConnectionState {
    Disconnected { retry_count: u32 },
    Connected { socket: TcpStream },
    Authenticated {
        socket: TcpStream,
        auth_token: String,
    },
}
```
