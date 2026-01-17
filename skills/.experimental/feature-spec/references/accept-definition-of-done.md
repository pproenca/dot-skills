---
title: Establish Definition of Done Beyond Code
impact: HIGH
impactDescription: reduces post-launch issues by 60%
tags: accept, definition-of-done, dod, completeness
---

## Establish Definition of Done Beyond Code

Definition of Done (DoD) includes everything required for a feature to be truly complete—not just working code. Missing DoD items like documentation, monitoring, or accessibility become technical debt.

**Incorrect (code-only definition):**

```markdown
## Definition of Done

- [ ] Code written
- [ ] Tests pass
- [ ] Code reviewed

// Missing: Documentation, monitoring, accessibility, security
// Result: "Done" features that break in production, lack docs, exclude users
```

**Correct (comprehensive definition):**

```markdown
## Definition of Done Checklist

### Code Quality
- [ ] Code written and compiles without warnings
- [ ] Unit tests written with > 80% coverage
- [ ] Integration tests for critical paths
- [ ] Code reviewed and approved by 2 team members
- [ ] No known bugs (or documented with tickets)

### Documentation
- [ ] README updated if setup steps changed
- [ ] API documentation updated (OpenAPI/Swagger)
- [ ] User-facing help docs written/updated
- [ ] Changelog entry added

### Testing
- [ ] Manual QA completed and signed off
- [ ] Cross-browser testing (Chrome, Firefox, Safari)
- [ ] Mobile responsive testing completed
- [ ] Accessibility testing (keyboard, screen reader)

### Observability
- [ ] Logging added for key operations
- [ ] Metrics/monitoring dashboards updated
- [ ] Alerts configured for error conditions
- [ ] Feature flag configured (if applicable)

### Security
- [ ] Security review completed (if auth/data changes)
- [ ] No secrets in code
- [ ] Input validation implemented

### Deployment
- [ ] Database migrations tested
- [ ] Rollback plan documented
- [ ] Environment variables documented
- [ ] Deployed to staging and verified

### Sign-off
- [ ] Product owner accepts feature
- [ ] Release notes drafted
```

**DoD per feature type:**
- Bug fix: Code, tests, verification
- New feature: Full checklist above
- Refactor: Code, tests, performance comparison

Reference: [Scrum.org - Definition of Done](https://www.scrum.org/resources/what-definition-done)
