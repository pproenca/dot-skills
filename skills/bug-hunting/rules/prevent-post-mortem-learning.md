---
title: Conduct Blameless Post-Mortems
impact: LOW
impactDescription: prevents recurring incidents through systematic learning
tags: prevent, post-mortem, learning, process
---

## Conduct Blameless Post-Mortems

After significant bugs or outages, conduct a blameless post-mortem to understand what went wrong and how to prevent recurrence. Focus on systems and processes, not individual blame.

**Incorrect (blame-focused incident response):**

```markdown
## Incident Report: Database Outage

What happened: Database ran out of disk space, causing 4-hour outage

Root cause: John forgot to set up disk monitoring

Action item: Remind John to be more careful

Result: Same bug happens 3 months later (different person, same oversight)
```

**Correct (blameless post-mortem):**

```markdown
## Post-Mortem: Database Outage (March 15, 2024)

### Timeline:
- 09:00: Disk usage exceeded 90%
- 11:30: Database stopped accepting writes
- 11:45: Alert received (customers reported errors)
- 13:30: Disk expanded, service restored

### Impact:
- 4 hours of degraded service
- ~500 affected customers
- Estimated revenue impact: $5,000

### Root Cause Analysis (5 Whys):
1. Why did DB stop? → Disk full
2. Why was disk full? → No automatic cleanup of old logs
3. Why no cleanup? → Not in provisioning script
4. Why not in script? → No standard for database provisioning
5. Why no standard? → Rapid growth, tech debt

### Contributing Factors:
- No disk space monitoring alerts
- Manual provisioning process
- No capacity planning review

### Action Items:
| Action | Owner | Due Date |
|--------|-------|----------|
| Add disk monitoring to all databases | SRE team | March 22 |
| Create database provisioning template | Platform | March 29 |
| Quarterly capacity planning review | Leads | Ongoing |
| Add runbook for disk space incidents | On-call | March 22 |

### What Went Well:
- Quick identification of root cause
- Effective cross-team collaboration
- Good communication to customers
```

**Post-mortem principles:**
- Blameless: Focus on systems, not people
- Timely: Conduct within 1 week of incident
- Actionable: Every finding has an owner and deadline
- Shared: Publish learnings to prevent repeat incidents

Reference: [Medium - Scientific Debugging](https://medium.com/machine-words/scientific-debugging-part-1-8890b73b6c4c)
