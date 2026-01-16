---
title: Include Bug-Prevention Checks in Code Review
impact: LOW
impactDescription: reduces production bugs by 30-50%
tags: prevent, code-review, verification, quality
---

## Include Bug-Prevention Checks in Code Review

Code review is an effective bug-prevention tool when reviewers know what to look for. Create a checklist of common bug patterns to catch issues before they ship.

**Incorrect (superficial code review):**

```markdown
## PR Review: Add user authentication

Reviewer comments:
- "LGTM" (Looks Good To Me)
- "Nice work!"

Merged without checking for:
- SQL injection
- Password storage security
- Session management issues
- Error message information leakage
```

**Correct (bug-focused code review):**

```markdown
## PR Review: Add user authentication

### Security Checklist:
- [x] SQL injection: Uses parameterized queries ✓
- [ ] Password storage: Using bcrypt? **ISSUE: Using MD5**
- [x] Session management: Regenerates session ID on login ✓
- [ ] Error messages: **ISSUE: "Invalid password for user X" leaks usernames**

### Common Bug Checklist:
- [x] Null checks on database results ✓
- [x] Input validation on all user data ✓
- [ ] Error handling: **ISSUE: Missing try/catch on line 45**
- [x] Logging includes correlation IDs ✓

### Test Coverage:
- [x] Happy path tested
- [ ] **MISSING: Test for SQL injection attempts**
- [ ] **MISSING: Test for invalid session handling**

Blocking merge until security issues resolved.
```

**Code review bug checklist:**
- [ ] Null/undefined handling
- [ ] Error handling and recovery
- [ ] Input validation and sanitization
- [ ] SQL injection, XSS, CSRF prevention
- [ ] Race conditions in concurrent code
- [ ] Resource cleanup (connections, file handles)
- [ ] Edge cases (empty arrays, zero values)

Reference: [BrowserStack - Root Causes for Software Defects](https://www.browserstack.com/guide/root-causes-for-software-defects-and-its-solutions)
