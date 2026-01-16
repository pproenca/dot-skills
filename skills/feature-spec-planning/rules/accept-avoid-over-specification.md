---
title: Avoid Over-Specifying Acceptance Criteria
impact: HIGH
impactDescription: preserves developer flexibility
tags: accept, over-specification, flexibility, intent
---

## Avoid Over-Specifying Acceptance Criteria

Acceptance criteria should specify what, not how. Over-specified criteria constrain developers, stifle better solutions, and create maintenance burden when implementation details change.

**Incorrect (implementation specified):**

```markdown
## Acceptance Criteria

- [ ] Use a modal dialog with class "confirmation-modal"
- [ ] Modal should have a blue #0066CC "Confirm" button on the right
- [ ] Cancel button should be gray #666666 and on the left
- [ ] Modal should use CSS animation "fadeIn" lasting 200ms
- [ ] Store confirmation state in Redux under user.confirmationStatus
- [ ] Call POST /api/v2/confirmations with JSON payload
```

**Correct (intent without implementation):**

```markdown
## Acceptance Criteria

### User Intent
- [ ] User must confirm before destructive actions
- [ ] Confirmation clearly states the consequence
- [ ] User can cancel without any side effects
- [ ] Confirmation state is persisted across page refreshes

### User Experience
- [ ] Confirmation appears immediately (< 100ms)
- [ ] Primary action is visually prominent
- [ ] Escape key dismisses without confirming
- [ ] Focus is trapped within confirmation UI

### Accessibility
- [ ] Confirmation is announced to screen readers
- [ ] Both actions are keyboard accessible
- [ ] Focus returns to trigger element on dismiss

---

_Implementation notes (non-binding):_
_Team may use modal, inline confirmation, or separate page._
_Design system components preferred but not required._
```

**Signs of over-specification:**
- CSS classes or specific styling mentioned
- Specific API endpoints or data formats
- Framework-specific implementation details
- Database column names or schema

**When implementation details are appropriate:**
- Regulatory requirements mandate specific approaches
- Integration with existing systems constrains options
- Team explicitly requests guidance

Reference: [StoriesOnBoard - Acceptance Criteria Examples](https://storiesonboard.com/blog/acceptance-criteria-examples)
