---
title: Use Watch Channels for Shared State
impact: CRITICAL
impactDescription: eliminates polling and ensures latest value delivery
tags: chan, watch, state, tokio, configuration
---

## Use Watch Channels for Shared State

When multiple tasks need access to shared state that changes over time (configuration, connection status), use watch channels. Receivers always get the latest value.

**Incorrect (polling shared state):**

```rust
async fn worker(config: Arc<RwLock<Config>>) {
    loop {
        let config = config.read().await.clone();
        if config.enabled {
            do_work(&config).await;
        }
        tokio::time::sleep(Duration::from_secs(1)).await;  // Wasteful polling
    }
}
```

**Correct (watch channel for updates):**

```rust
async fn worker(mut config_rx: watch::Receiver<Config>) {
    loop {
        let config = config_rx.borrow_and_update().clone();
        if config.enabled {
            do_work(&config).await;
        }
        // Waits efficiently until config changes
        if config_rx.changed().await.is_err() {
            break;  // Sender dropped
        }
    }
}

// Config updater
async fn config_loader(config_tx: watch::Sender<Config>) {
    loop {
        let new_config = load_config().await;
        config_tx.send_replace(new_config);
        tokio::time::sleep(Duration::from_secs(60)).await;
    }
}
```

**Benefits:**
- No polling overhead
- Receivers always see the latest value
- Multiple receivers share efficiently

Reference: [tokio::sync::watch](https://docs.rs/tokio/latest/tokio/sync/watch/)
