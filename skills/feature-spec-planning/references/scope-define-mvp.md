---
title: Define MVP Separately from Full Vision
impact: CRITICAL
impactDescription: enables faster time-to-value
tags: scope, mvp, iteration, incremental-delivery
---

## Define MVP Separately from Full Vision

Separate the Minimum Viable Product (MVP) from the complete feature vision. This enables faster delivery of core value while deferring nice-to-have functionality to later iterations.

**Incorrect (all-or-nothing feature):**

```markdown
## Feature: Notification System

### Requirements
- Email notifications
- Push notifications (iOS, Android, Web)
- SMS notifications
- In-app notification center
- Notification preferences UI
- Digest/batching options
- Template management system
- Analytics and delivery tracking

### Timeline
6 sprints to deliver complete system
```

**Correct (MVP vs full vision):**

```markdown
## Feature: Notification System

### MVP (Sprints 1-2)
**Goal:** Users receive critical notifications via email

- Email notifications for key events only:
  - Account creation
  - Password reset
  - Payment confirmation
- Basic unsubscribe link
- Hardcoded templates (no management UI)

**Success criteria:** 95% delivery rate, <5 min latency

---

### Phase 2 (Sprints 3-4)
- In-app notification center
- Read/unread status tracking
- Notification preferences UI

### Phase 3 (Sprints 5-6)
- Push notifications (mobile + web)
- Digest/batching options

### Future Backlog
- SMS notifications
- Template management system
- Analytics dashboard

---

### Why This Ordering
1. Email covers 80% of notification use cases
2. In-app center reduces email volume
3. Push is additive, not blocking
```

**MVP definition checklist:**
- [ ] Delivers core value to users
- [ ] Can be shipped independently
- [ ] Enables learning before over-investing
- [ ] Clear success criteria defined

Reference: [Product School - PRD Template](https://productschool.com/blog/product-strategy/product-template-requirements-document-prd)
