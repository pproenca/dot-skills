---
title: Ensure All Criteria Are Testable
impact: HIGH
impactDescription: enables objective verification of completion
tags: accept, testable, verification, qa
---

## Ensure All Criteria Are Testable

Every acceptance criterion must be verifiable with a true/false answer. Subjective criteria like "user-friendly" or "fast" cannot be tested objectively and lead to disputes about whether work is complete.

**Incorrect (untestable criteria):**

```markdown
## Acceptance Criteria

- The interface should be user-friendly
- The system should perform well
- Errors should be handled gracefully
- The design should look modern
- The experience should be intuitive
```

**Correct (objectively testable criteria):**

```markdown
## Acceptance Criteria

### Usability (Testable)
- [ ] All form fields have visible labels
- [ ] Error messages appear within 2px of the invalid field
- [ ] Tab order follows visual layout (left-to-right, top-to-bottom)
- [ ] All interactive elements have focus indicators
- [ ] Forms can be submitted using Enter key

### Performance (Testable)
- [ ] Page loads in < 2 seconds on 3G (WebPageTest)
- [ ] Time to first byte < 200ms
- [ ] No layout shifts after initial render (CLS < 0.1)
- [ ] Search results appear within 500ms of typing

### Error Handling (Testable)
- [ ] Network errors show retry button + message
- [ ] Form validation errors are shown before submission
- [ ] 500 errors display error ID for support
- [ ] All errors are logged with stack traces

### Visual Design (Testable)
- [ ] Matches Figma design with < 5px variance
- [ ] Uses only colors from design system palette
- [ ] Typography matches style guide (font, size, weight)
- [ ] Icons are from approved icon library
```

**Testability checklist:**
- Can a machine verify this? (automation potential)
- Can two people agree if it passes? (objectivity)
- Is there a clear pass/fail threshold? (measurability)
- Can it be verified in isolation? (independence)

Reference: [ProductPlan - Acceptance Criteria Definition](https://www.productplan.com/glossary/acceptance-criteria/)
