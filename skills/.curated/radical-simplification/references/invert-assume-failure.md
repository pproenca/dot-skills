---
title: Assume the design failed and find the most likely cause
tags: invert, munger, premortem
---

## Assume the design failed and find the most likely cause

Jacobi's rule, popularized by Munger: **invert, always invert**. Designs reviewed for "what makes this succeed?" enumerate features and look complete. The same design reviewed as "imagine it is six months from now and this is the postmortem — what was the most likely root cause?" exposes the failure modes that the success-side review missed. The two reviews catch different bugs.

```text
Deploy script review.

Success-side question: "What does this do?"
  Build, test, push image, update service, watch metrics for 5min, done.
  Looks fine.

Inverted question: "It's six months from now. We're in a postmortem
because a deploy took prod down. What is the most likely chain?"

  Most likely root causes, in observed-frequency order:
    1. Health check passed because /health was hard-coded to 200, even
       though the service was broken. → add real readiness probe.
    2. Canary metric window was too short; regression appeared at 6min,
       script returned at 5min. → widen window, or compare against the
       previous deploy's same-time window.
    3. Rollback didn't actually roll back because the previous image
       had been GC'd. → pin previous N images.
    4. Two deploys raced; the second one overwrote the first's rollback
       target. → serialize, or use deploy IDs.

These four failure modes are all invisible to the "what does this do?"
review and obvious to the inverted one.
```

A useful prompt: write the postmortem before writing the design, in the form "On {date}, X happened because Y, which our pre-deploy checks missed because Z." The Zs are the holes to fill.

Reference: [Munger — A Lesson on Elementary, Worldly Wisdom (USC Business School, 1994)](https://fs.blog/great-talks/a-lesson-on-elementary-worldly-wisdom/)
