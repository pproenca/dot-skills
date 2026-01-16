---
title: Use Fishbone Diagrams for Complex Bugs
impact: HIGH
impactDescription: prevents missed causes in complex bugs
tags: rca, fishbone, ishikawa, cause-effect
---

## Use Fishbone Diagrams for Complex Bugs

When a bug has multiple potential causes across different domains (code, infrastructure, data, process), use a Fishbone (Ishikawa) diagram to systematically map and explore all contributing factors.

**Incorrect (jumping to conclusions):**

```markdown
Bug: Checkout fails for 5% of users
Assumption: Must be a code bug
Action: Spend 3 days reviewing checkout code
Result: No bug found in code—problem was elsewhere
```

**Correct (systematic cause exploration):**

```markdown
## Fishbone Diagram: Checkout Failures (5% of users)

                    ┌─────────────────────────────────────────┐
                    │       Checkout Failures (5%)            │
                    └─────────────────────────────────────────┘
                                        │
    ┌───────────────┬───────────────────┼───────────────┬───────────────┐
    │               │                   │               │               │
    ▼               ▼                   ▼               ▼               ▼
  Code          Infrastructure       Data           Process         People
    │               │                   │               │               │
    ├─ Validation   ├─ Database         ├─ Corrupt      ├─ Timeout     ├─ Training
    │   logic       │   timeouts        │   cart data   │   config     │   gaps
    │               │                   │               │               │
    ├─ Race         ├─ CDN cache ←────────────────────────────── ROOT CAUSE
    │   condition   │   stale assets   │               │
    │               │                   │               │
    └─ Edge cases   └─ Network          └─ Invalid      └─ Rollback
                        latency             state           process

## Investigation Results:
- Code: No issues found
- Infrastructure: CDN serving stale JavaScript (cache TTL too high)
- Root cause: Old checkout.js cached for users who visited recently
- Fix: Invalidate CDN cache, add cache-busting hashes to assets
```

**When to use Fishbone diagrams:**
- Bug affects only some users/requests
- Multiple teams or systems involved
- Initial investigation yields no clear cause

Reference: [ProSolvr - Software Bugs Root Cause Analysis](https://www.prosolvr.tech/knowledgebase/software-bugs-root-cause-analysis.html)
