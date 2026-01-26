---
title: Use Actor Pattern for Stateful Components
impact: LOW-MEDIUM
impactDescription: eliminates lock contention and deadlock risk
tags: loop, actor, state, concurrency, pattern
---

## Use Actor Pattern for Stateful Components

The actor pattern encapsulates state behind message-passing, eliminating shared mutable state and making concurrent code easier to reason about.

**Incorrect (shared state with locks):**

```rust
struct ConnectionManager {
    connections: Arc<Mutex<HashMap<u64, TcpStream>>>,
}

impl ConnectionManager {
    async fn add(&self, id: u64, conn: TcpStream) {
        self.connections.lock().await.insert(id, conn);
    }

    async fn remove(&self, id: u64) {
        self.connections.lock().await.remove(&id);
    }

    async fn broadcast(&self, msg: &[u8]) {
        let guard = self.connections.lock().await;
        for (_, conn) in guard.iter() {
            // Can't await while holding lock!
        }
    }
}
```

**Correct (actor with message passing):**

```rust
enum ConnectionCommand {
    Add { id: u64, conn: TcpStream, reply: oneshot::Sender<()> },
    Remove { id: u64 },
    Broadcast { msg: Bytes },
}

struct ConnectionActor {
    connections: HashMap<u64, TcpStream>,
    rx: mpsc::Receiver<ConnectionCommand>,
}

impl ConnectionActor {
    async fn run(mut self) {
        while let Some(cmd) = self.rx.recv().await {
            match cmd {
                ConnectionCommand::Add { id, conn, reply } => {
                    self.connections.insert(id, conn);
                    let _ = reply.send(());
                }
                ConnectionCommand::Remove { id } => {
                    self.connections.remove(&id);
                }
                ConnectionCommand::Broadcast { msg } => {
                    for (_, conn) in &mut self.connections {
                        let _ = conn.write_all(&msg).await;
                    }
                }
            }
        }
    }
}

// Client handle
struct ConnectionHandle {
    tx: mpsc::Sender<ConnectionCommand>,
}

impl ConnectionHandle {
    async fn add(&self, id: u64, conn: TcpStream) {
        let (reply_tx, reply_rx) = oneshot::channel();
        self.tx.send(ConnectionCommand::Add { id, conn, reply: reply_tx }).await.unwrap();
        reply_rx.await.unwrap();
    }
}
```

Reference: [Alice Ryhl - Actors with Tokio](https://ryhl.io/blog/actors-with-tokio/)
