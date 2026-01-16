---
title: Write Specific and Measurable Requirements
impact: CRITICAL
impactDescription: reduces interpretation disputes by 80%
tags: req, specificity, measurable, smart
---

## Write Specific and Measurable Requirements

Requirements must be specific enough that two developers would implement them the same way. Vague requirements like "fast" or "user-friendly" lead to interpretation disputes and rework.

**Incorrect (vague requirements):**

```markdown
## Requirements

- The page should load fast
- The search should be user-friendly
- The system should handle many users
- Error messages should be helpful
- The UI should be responsive
```

**Correct (specific and measurable):**

```markdown
## Requirements

### Performance
- Page load time: < 2 seconds on 3G connection
- Search results: < 500ms for 95th percentile
- Concurrent users: Support 10,000 simultaneous sessions

### Search UX
- Auto-complete suggestions appear after 2 characters
- Results update as user types (debounced 300ms)
- "No results" state shows 3 suggested alternatives
- Recent searches displayed (last 5, persisted locally)

### Error Handling
- Network errors: Show retry button with "Check your connection"
- Validation errors: Highlight field + inline message
- Server errors: Show error ID for support reference

### Responsive Design
- Breakpoints: 320px (mobile), 768px (tablet), 1024px+ (desktop)
- Touch targets: Minimum 44x44px on mobile
- Navigation: Hamburger menu below 768px
```

**SMART criteria for requirements:**
- **S**pecific: Clear, unambiguous language
- **M**easurable: Quantified where possible
- **A**chievable: Technically feasible
- **R**elevant: Tied to user or business need
- **T**ime-bound: Clear delivery expectation

Reference: [DesignRush - How To Write Clear Software Requirements](https://www.designrush.com/agency/software-development/trends/software-requirements-specification)
