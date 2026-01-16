---
title: Record All Debugging Experiments
impact: CRITICAL
impactDescription: prevents repeating failed approaches
tags: hypo, documentation, experiments, debugging-log
---

## Record All Debugging Experiments

Keep a debugging log of every hypothesis tested, the experiment run, and the result. This prevents wasted time re-trying failed approaches and builds knowledge for similar future bugs.

**Incorrect (no record of debugging attempts):**

```markdown
// Day 1: Try some stuff, doesn't work
// Day 2: Try same stuff again, forgot what I tried
// Day 3: Coworker suggests something I already tried
// Day 4: Finally fix it, can't remember what worked
```

**Correct (debugging log with experiments and results):**

```markdown
## Bug: Order emails not sending (JIRA-1234)

### Hypothesis 1: SMTP credentials expired
**Experiment:** Check SMTP connection with telnet
**Result:** Connection successful, credentials valid
**Conclusion:** Not a credentials issue

### Hypothesis 2: Email queued but worker not processing
**Experiment:** Check Redis queue length and worker logs
**Result:** Queue has 5000 emails, worker shows "memory limit exceeded"
**Conclusion:** Worker crashing before processing emails

### Hypothesis 3: Worker memory leak in email template rendering
**Experiment:** Profile memory during template rendering
**Result:** Memory grows 50MB per email due to leaked DOM references
**Conclusion:** ROOT CAUSE FOUND

### Fix Applied:
- Added cleanup in template rendering (commit abc123)
- Emails now processing successfully
- Monitoring added for queue depth
```

**Benefits:**
- Never repeat failed experiments
- Shareable knowledge with team
- Evidence for post-mortems and documentation

Reference: [SciTools Blog - The Science of Debugging](https://blog.scitools.com/the-science-of-debugging/)
