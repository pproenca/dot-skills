---
title: Document System Context and Dependencies
impact: MEDIUM
impactDescription: reduces integration surprises by 60%
tags: tech, architecture, dependencies, integration
---

## Document System Context and Dependencies

Before detailing feature implementation, document the system context. Show where the feature fits in the larger architecture, what it depends on, and what depends on it. Missing context leads to integration failures.

**Incorrect (isolated feature spec):**

```markdown
## Feature: User Notifications

### Implementation
- Add NotificationService class
- Store notifications in database
- Send via email and push

// Missing: How does this relate to existing systems?
// What services does it depend on?
// What other features need notifications?
```

**Correct (system context documented):**

```markdown
## Feature: User Notifications

### System Context Diagram

```text
┌─────────────────────────────────────────────────────────────┐
│                     External Services                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │ SendGrid │  │ Firebase │  │  Twilio  │                  │
│  │  (Email) │  │  (Push)  │  │  (SMS)   │                  │
│  └────▲─────┘  └────▲─────┘  └────▲─────┘                  │
│       │             │             │                         │
└───────┼─────────────┼─────────────┼─────────────────────────┘
        │             │             │
┌───────┴─────────────┴─────────────┴─────────────────────────┐
│                  Notification Service                        │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              NotificationDispatcher                  │    │
│  │  - Route to appropriate channel                      │    │
│  │  - Handle retries and failures                       │    │
│  │  - Rate limiting                                     │    │
│  └─────────────────────▲───────────────────────────────┘    │
│                        │                                     │
└────────────────────────┼─────────────────────────────────────┘
                         │
┌────────────────────────┼─────────────────────────────────────┐
│  Internal Services (Producers)                               │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │ Orders │  │ Auth   │  │Payments│  │ Social │            │
│  └────────┘  └────────┘  └────────┘  └────────┘            │
└──────────────────────────────────────────────────────────────┘
```

### Dependencies (This Feature Needs)

| Dependency | Version | Purpose | Failure Impact |
|------------|---------|---------|----------------|
| SendGrid API | v3 | Email delivery | Degraded (queue) |
| Firebase FCM | Current | Push notifications | Degraded (skip) |
| PostgreSQL | 14+ | Notification storage | Critical (block) |
| Redis | 6+ | Rate limiting cache | Degraded (allow all) |
| User Service | Internal | User preferences | Critical (block) |

### Dependents (Need This Feature)

| Service | Use Case | Integration Point |
|---------|----------|-------------------|
| Order Service | Order status updates | Event: order.status.changed |
| Auth Service | Login alerts | Event: auth.suspicious.login |
| Payment Service | Payment receipts | Event: payment.completed |
| Marketing | Campaign notifications | API: POST /notifications/bulk |

### Integration Contracts

**Event Schema (consumed):**
```json
{
  "event_type": "order.status.changed",
  "user_id": "uuid",
  "payload": { "order_id": "string", "status": "string" },
  "timestamp": "ISO8601"
}
```

**API Contract (exposed):**
```http
POST /api/v1/notifications
Authorization: Bearer {service_token}
Content-Type: application/json
```
```

**Context documentation checklist:**
- System boundaries clearly defined
- All dependencies identified with versions
- Failure modes documented
- Integration contracts specified

Reference: [Arc42 - Software Architecture Documentation](https://arc42.org/overview)
