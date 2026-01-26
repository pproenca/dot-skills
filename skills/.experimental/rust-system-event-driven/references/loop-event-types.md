---
title: Use Typed Events Over Dynamic Dispatch
impact: LOW-MEDIUM
impactDescription: avoids heap allocation and catches missing handlers
tags: loop, events, types, enum, pattern
---

## Use Typed Events Over Dynamic Dispatch

Define events as enums rather than trait objects. This provides compile-time exhaustiveness checking and avoids allocation overhead.

**Incorrect (dynamic dispatch, no exhaustiveness):**

```rust
trait Event: Send + 'static {
    fn handle(&self, state: &mut State);
}

struct EventLoop {
    rx: mpsc::Receiver<Box<dyn Event>>,
}

impl EventLoop {
    async fn run(&mut self, state: &mut State) {
        while let Some(event) = self.rx.recv().await {
            event.handle(state);  // No compile-time check for new event types
        }
    }
}
```

**Correct (typed enum, exhaustive matching):**

```rust
enum AppEvent {
    Connection(ConnectionEvent),
    Message(MessageEvent),
    Timer(TimerEvent),
    Shutdown,
}

enum ConnectionEvent {
    Accepted { id: u64, stream: TcpStream },
    Closed { id: u64, reason: CloseReason },
}

struct EventLoop {
    rx: mpsc::Receiver<AppEvent>,
}

impl EventLoop {
    async fn run(&mut self, state: &mut State) {
        while let Some(event) = self.rx.recv().await {
            match event {
                AppEvent::Connection(e) => self.handle_connection(e, state).await,
                AppEvent::Message(e) => self.handle_message(e, state).await,
                AppEvent::Timer(e) => self.handle_timer(e, state).await,
                AppEvent::Shutdown => break,
            }
            // Compiler error if new variant added without handler
        }
    }
}
```

**Benefits:**
- Compiler catches unhandled event types
- No heap allocation per event
- Pattern matching enables exhaustive handling
- Better performance from static dispatch

Reference: [Rust Book - Enums](https://doc.rust-lang.org/book/ch06-01-defining-an-enum.html)
