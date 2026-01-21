---
title: Assess User Impact Before Prioritizing
impact: MEDIUM
impactDescription: 10× improvement in value delivered per engineering hour
tags: triage, impact, users, assessment
---

## Assess User Impact Before Prioritizing

Before assigning priority, determine how many users are affected and how severely. A crash affecting 1% of users may be lower priority than a confusing error message affecting 80% of users.

**Incorrect (prioritizing by technical severity alone):**

```markdown
## Triage Decision:

Bug A: Memory leak after 72 hours runtime
- Severity: HIGH (technical complexity)
- Users affected: ~10 (long-running servers)
- Priority assigned: HIGH (based on severity)

Bug B: Confusing error message on signup
- Severity: LOW (just text)
- Users affected: 5,000/day (all new signups)
- Priority assigned: LOW (based on severity)

Result: Team spends week on memory leak while 35,000 users abandon signup
```

**Correct (prioritizing by user impact):**

```markdown
## Triage Decision with Impact Analysis:

Bug A: Memory leak after 72 hours runtime
- Severity: HIGH (technical)
- Users affected: ~10 (long-running servers)
- Business impact: $500/month in restarts
- Priority: MEDIUM (schedule for next sprint)

Bug B: Confusing error message on signup
- Severity: LOW (cosmetic)
- Users affected: 5,000/day
- Business impact: 15% signup abandonment = $50,000/month lost
- Priority: HIGH (fix this sprint)

## Impact Formula:
Impact = (Users Affected) × (Severity per User) × (Revenue/User)
```

**Impact assessment questions:**
- How many users are affected? (1, 100, 10,000?)
- How often does it occur? (Once, daily, every request?)
- What's the workaround cost? (None, minor, major?)
- What's the business cost? (Support tickets, lost revenue, churn?)

Reference: [Marker.io - Bug Triage: How to Organize and Prioritize](https://marker.io/blog/bug-triage)
