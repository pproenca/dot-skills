---
title: Use the 5 Whys Technique
impact: HIGH
impactDescription: Reaches true root cause instead of surface symptoms; prevents recurrence
tags: rca, five-whys, root-cause, analysis, technique
---

## Use the 5 Whys Technique

Ask "why" repeatedly (typically 5 times) to drill past symptoms to root causes. Each answer becomes the subject of the next question until you reach a cause you can actually fix permanently.

**Incorrect (stopping at first answer):**

```markdown
Problem: Users can't log in

Why? → The authentication service returns 500 errors
Fix: Restart the auth service

# Service restarted, works for a day, then fails again
# Never found out WHY it was returning 500s
```

**Correct (5 Whys to root cause):**

```markdown
Problem: Users can't log in

Why 1: The authentication service returns 500 errors
Why 2: The auth service runs out of database connections
Why 3: Connections are not being released after use
Why 4: A try/finally block is missing in the auth code
Why 5: The developer copied code from a tutorial that didn't include cleanup

ROOT CAUSE: Missing connection cleanup in auth module
ACTUAL FIX: Add proper connection release in finally block
PREVENTION: Add code review checklist item for resource cleanup
```

**5 Whys template:**

```markdown
## 5 Whys Analysis

**Problem Statement:** [Clear description of the bug]

**Why 1:** [First-level cause]
**Why 2:** [Why does Why 1 happen?]
**Why 3:** [Why does Why 2 happen?]
**Why 4:** [Why does Why 3 happen?]
**Why 5:** [Why does Why 4 happen?] ← Usually the root cause

**Root Cause:** [The fundamental issue to fix]
**Corrective Action:** [How to fix the root cause]
**Preventive Action:** [How to prevent similar issues]
```

**Tips for effective 5 Whys:**
- Don't accept "human error" as a cause - ask why the error was possible
- Multiple valid paths may exist - explore each branch
- Stop when you reach something actionable and preventable
- Include technical AND process causes

**When NOT to use this pattern:**
- Trivial bugs with obvious immediate causes
- Time-critical fixes (do 5 Whys afterward)
- When multiple independent factors combined

Reference: [Root Cause Analysis Guide](https://www.softwaretestinghelp.com/root-cause-analysis/)
