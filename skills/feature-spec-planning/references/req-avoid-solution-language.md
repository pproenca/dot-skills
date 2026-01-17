---
title: State Requirements Without Prescribing Solutions
impact: CRITICAL
impactDescription: enables optimal technical solutions
tags: req, intent, solution-agnostic, flexibility
---

## State Requirements Without Prescribing Solutions

Requirements should describe what the system must do, not how to implement it. Prescribing solutions constrains developers and may result in suboptimal implementations.

**Incorrect (solution prescribed):**

```markdown
## Requirements

- Use Redis to cache user sessions
- Implement a modal dialog for confirmations
- Store files in AWS S3 buckets
- Use websockets for real-time updates
- Add a dropdown menu for category selection
```

**Correct (intent without solution):**

```markdown
## Requirements

### Session Management
- Sessions must persist across page refreshes
- Sessions must expire after 24 hours of inactivity
- Session data must be accessible from any server instance

_Implementation note: Team to decide caching solution (Redis, Memcached, database-backed)_

### Confirmation UX
- User must confirm before destructive actions (delete, cancel)
- Confirmation must clearly state the consequence
- User must be able to cancel without data loss

_Implementation note: Modal, inline confirmation, or separate page—team decides based on context_

### File Storage
- Uploaded files must be accessible for 7 days minimum
- Files must be retrievable via unique URL
- Maximum file size: 50MB

_Implementation note: Storage provider selection is a technical decision_

### Real-time Updates
- Users must see new messages within 5 seconds
- No manual refresh required for updates
- Updates must work on mobile networks

_Implementation note: Websockets, SSE, or polling—based on infrastructure constraints_
```

**When to specify implementation:**
- Regulatory/compliance requirements mandate specific technology
- Existing infrastructure constrains options
- Team has explicitly requested guidance

Reference: [Jama Software - How to Write an Effective PRD](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/how-to-write-an-effective-product-requirements-document/)
