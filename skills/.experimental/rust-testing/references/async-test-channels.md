---
title: Use Channels for Testing Async Communication
impact: MEDIUM
impactDescription: enables verifying message ordering and content
tags: async, tokio, channels, mpsc, message-passing
---

## Use Channels for Testing Async Communication

Use channels to capture and verify messages sent between async tasks. This enables testing event-driven systems without side effects.

**Incorrect (cannot verify messages sent):**

```rust
#[tokio::test]
async fn test_event_processor() {
    let processor = EventProcessor::new(RealNotifier::new());

    processor.process(Event::UserCreated { id: 42 }).await;

    // How do we verify the notification was sent correctly?
    // RealNotifier actually sends emails!
}
```

**Correct (channel captures messages):**

```rust
use tokio::sync::mpsc;

struct ChannelNotifier {
    sender: mpsc::Sender<Notification>,
}

impl Notifier for ChannelNotifier {
    async fn send(&self, notification: Notification) -> Result<(), Error> {
        self.sender.send(notification).await.map_err(|_| Error::ChannelClosed)
    }
}

#[tokio::test]
async fn test_user_created_sends_welcome_email() {
    let (tx, mut rx) = mpsc::channel(10);
    let notifier = ChannelNotifier { sender: tx };
    let processor = EventProcessor::new(notifier);

    processor.process(Event::UserCreated { id: 42, email: "alice@example.com".into() }).await;

    let notification = rx.recv().await.unwrap();
    assert_eq!(notification.to, "alice@example.com");
    assert!(notification.subject.contains("Welcome"));
}

#[tokio::test]
async fn test_batch_processing_sends_all_notifications() {
    let (tx, mut rx) = mpsc::channel(100);
    let notifier = ChannelNotifier { sender: tx };
    let processor = EventProcessor::new(notifier);

    let events = vec![
        Event::UserCreated { id: 1, email: "a@test.com".into() },
        Event::UserCreated { id: 2, email: "b@test.com".into() },
        Event::UserCreated { id: 3, email: "c@test.com".into() },
    ];

    processor.process_batch(events).await;

    // Verify all notifications received
    let mut notifications = vec![];
    while let Ok(n) = rx.try_recv() {
        notifications.push(n);
    }
    assert_eq!(notifications.len(), 3);
}
```

**Testing message ordering:**

```rust
#[tokio::test]
async fn test_events_processed_in_order() {
    let (tx, mut rx) = mpsc::channel(10);
    let handler = OrderedHandler::new(tx);

    handler.handle(Command::Start).await;
    handler.handle(Command::Process("data")).await;
    handler.handle(Command::Stop).await;

    assert_eq!(rx.recv().await.unwrap(), Event::Started);
    assert_eq!(rx.recv().await.unwrap(), Event::Processed("data"));
    assert_eq!(rx.recv().await.unwrap(), Event::Stopped);
}
```

**Using oneshot for request-response:**

```rust
use tokio::sync::oneshot;

#[tokio::test]
async fn test_request_response() {
    let (response_tx, response_rx) = oneshot::channel();

    let service = TestService::new();
    service.send_request(Request { id: 42, response_channel: response_tx }).await;

    let response = response_rx.await.unwrap();
    assert_eq!(response.id, 42);
    assert!(response.success);
}
```

Reference: [Tokio - Channels](https://tokio.rs/tokio/tutorial/channels)
