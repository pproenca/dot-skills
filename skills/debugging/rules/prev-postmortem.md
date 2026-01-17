---
title: Conduct Blameless Postmortems
impact: LOW-MEDIUM
impactDescription: Prevents recurrence through systemic fixes; builds team debugging culture
tags: prev, postmortem, incident, learning, culture
---

## Conduct Blameless Postmortems

After significant bugs or incidents, conduct a blameless postmortem focused on systemic improvements, not individual blame. This transforms bugs from failures into learning opportunities.

**Incorrect (blame-focused):**

```markdown
## Incident Review: Production Database Deleted

### What happened
John accidentally ran DROP TABLE in production.

### Who's responsible
John. He should have been more careful.

### Action items
- Talk to John about being more careful
- John loses production access

# Result: Team fears reporting issues
# No systemic improvements made
# Similar incident happens 3 months later with different person
```

**Correct (blameless postmortem):**

```markdown
## Postmortem: Production Database Table Drop Incident

### Summary
On 2024-01-15, the users table was dropped in production,
causing 2 hours of downtime. Data was restored from backup.

### Timeline
- 14:23 - Engineer connects to database to run migration
- 14:25 - DROP TABLE executed against wrong database
- 14:26 - Errors reported by monitoring
- 14:30 - Incident declared, rollback initiated
- 16:30 - Service restored from backup

### Root Cause Analysis
1. Production and staging connection strings are similar
2. No prompt/confirmation when connecting to production
3. No safeguard against destructive commands in production
4. Local environment defaults to production credentials

### What Went Well
- Monitoring detected issue within 1 minute
- Backup was recent (< 1 hour data loss)
- Team responded quickly

### What Could Be Improved
- No visual distinction between prod/staging terminals
- Destructive commands don't require confirmation
- Easy to accidentally use production credentials

### Action Items
| Item | Owner | Due Date |
|------|-------|----------|
| Add color-coded terminal prompts for production | Team | Jan 22 |
| Implement SQL safeguards requiring confirmation | DevOps | Jan 29 |
| Rotate production credentials, require VPN | Security | Feb 5 |
| Update onboarding docs with safety procedures | Docs | Jan 25 |
```

**Blameless postmortem principles:**
1. **Assume good intent** - People tried to do the right thing
2. **Focus on systems** - What allowed error to happen?
3. **Share openly** - Publish findings to whole team
4. **Follow up** - Track action items to completion
5. **Celebrate learning** - Finding issues is valuable

**When to conduct postmortems:**
- Production incidents affecting users
- Bugs that took >1 day to resolve
- Issues that revealed systemic weaknesses
- Near-misses that could have been serious

Reference: [Google SRE - Postmortem Culture](https://sre.google/sre-book/postmortem-culture/)
