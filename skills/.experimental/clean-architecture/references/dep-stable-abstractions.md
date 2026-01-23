---
title: Depend on Stable Abstractions Not Volatile Concretions
impact: CRITICAL
impactDescription: reduces change frequency by 5-10×
tags: dep, stability, abstractions, volatility
---

## Depend on Stable Abstractions Not Volatile Concretions

The most flexible systems depend on abstractions, not concretions. Volatile concrete classes are under active development and change frequently; depending on them propagates instability.

**Incorrect (depending on volatile concrete class):**

```go
// services/notification.go
package services

import (
    "myapp/infrastructure/email/sendgrid"
    "myapp/infrastructure/sms/twilio"
)

type NotificationService struct {
    email  *sendgrid.Client  // Concrete SendGrid client
    sms    *twilio.Client    // Concrete Twilio client
}

func (n *NotificationService) NotifyUser(userID string, message string) {
    // When SendGrid API changes, this service must change
    // When migrating to AWS SES, this service must change
    n.email.SendWithTemplate("notify", message)
}
```

**Correct (depending on stable interface):**

```go
// domain/ports/notification.go
package ports

type EmailSender interface {
    Send(to string, subject string, body string) error
}

type SMSSender interface {
    Send(to string, message string) error
}

// services/notification.go
package services

import "myapp/domain/ports"

type NotificationService struct {
    email ports.EmailSender  // Stable abstraction
    sms   ports.SMSSender    // Stable abstraction
}

func (n *NotificationService) NotifyUser(userID string, message string) {
    // Service is immune to email provider changes
    n.email.Send(userID, "Notification", message)
}

// infrastructure/sendgrid/client.go
package sendgrid

type Client struct { /* ... */ }

func (c *Client) Send(to, subject, body string) error {
    // Concrete implementation can change freely
}
```

**Note:** Depending on stable concretions (like standard library classes) is acceptable. Focus inversion on volatile, actively-developed modules.

Reference: [Clean Architecture - Stable Abstractions Principle](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/ch11.xhtml)
