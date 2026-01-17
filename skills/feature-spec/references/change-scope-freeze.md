---
title: Implement Scope Freeze Periods
impact: MEDIUM
impactDescription: reduces late-stage changes by 85%
tags: change, freeze, deadline, stability
---

## Implement Scope Freeze Periods

Establish scope freeze periods before major milestones. Continuous changes up until launch create instability, testing gaps, and team burnout. Freeze scope to allow stabilization.

**Incorrect (changes until launch day):**

```markdown
## Project Timeline

Week 1-4: Development
Week 5: Testing
Week 6: Launch

// Reality:
// Week 5 (testing): "Can we also add this small thing?"
// Week 5.5: New code merged during testing
// Week 6 (launch day): "One more tiny change"
// Result: Untested code in production, launch day bugs
```

**Correct (defined freeze periods):**

```markdown
## Scope Freeze Policy

### Freeze Levels

| Level | Allowed Changes | Approval Required |
|-------|-----------------|-------------------|
| **Green** (Normal) | Any approved changes | Standard process |
| **Yellow** (Soft Freeze) | Bug fixes, critical issues only | Engineering Lead |
| **Red** (Hard Freeze) | Blocking bugs only | VP Engineering |
| **Black** (Code Freeze) | Emergency hotfixes only | CTO |

### Project Timeline with Freeze Periods

```text
Week 1    ████████████████ Development      [GREEN]
Week 2    ████████████████ Development      [GREEN]
Week 3    ████████████████ Development      [GREEN]
Week 4    ████████████████ Feature Complete [YELLOW starts]
Week 5    ████████████████ Testing/QA       [RED starts]
Week 6    ██████░░░░░░░░░░ Final Testing    [BLACK starts]
Week 6.5  ░░░░░░██████████ Launch           [BLACK]
Week 7    ████████████████ Post-launch      [Return to GREEN]
```

### Freeze Entry Criteria

**Yellow (Soft Freeze) - 2 weeks before launch:**
- [ ] All planned features code complete
- [ ] No open P1 bugs
- [ ] All integrations working
- [ ] Performance targets met

**Red (Hard Freeze) - 1 week before launch:**
- [ ] All features tested and approved
- [ ] No open P1 or P2 bugs
- [ ] Load testing passed
- [ ] Security review complete
- [ ] Documentation complete

**Black (Code Freeze) - 3 days before launch:**
- [ ] Release candidate tagged
- [ ] Staging environment matches production
- [ ] Rollback plan tested
- [ ] On-call schedule confirmed

### Change Approval During Freeze

**Yellow Freeze - Change Request:**
```yaml
request_type: soft_freeze_change
requestor: Developer Name
change_description: |
  Fix timezone handling in date picker

justification: |
  Users in non-US timezones see wrong dates.
  Affects 30% of user base.

risk_assessment: |
  Low risk - isolated change, well-tested
  Rollback: Revert single commit

testing_plan: |
  - Unit tests added
  - Manual testing in 5 timezones
  - Staging verification

approval: Engineering Lead
```

**Red Freeze - Blocking Bug Only:**
```yaml
request_type: hard_freeze_change
requestor: Developer Name
bug_id: BUG-1234
severity: P1 - Blocking

bug_description: |
  Payment processing fails for amounts > $10,000

business_impact: |
  - Enterprise customers cannot complete purchases
  - $50K+ revenue at risk per day

fix_description: |
  Integer overflow in amount calculation
  One-line fix in payment_processor.py

testing_completed:
  - [ ] Unit tests pass
  - [ ] Integration tests pass
  - [ ] Manual verification on staging
  - [ ] Regression suite green

rollback_plan: |
  Revert commit abc123
  Tested: Yes, verified rollback works

approval_chain:
  - Engineering Lead: Pending
  - VP Engineering: Pending
```

### Exceptions Process

Even during Black Freeze, some changes may be necessary:

```markdown
## Emergency Change Protocol

1. **Identify:** Is this truly blocking launch?
   - Data loss risk? → Yes
   - Security vulnerability? → Yes
   - Feature doesn't work perfectly? → No (launch anyway)

2. **Assess:** What's the minimum fix?
   - Fix the symptom, not root cause
   - Smallest possible change
   - No refactoring

3. **Approve:** Who needs to sign off?
   - CTO for any Black Freeze change
   - Security Lead for security issues
   - Legal for compliance issues

4. **Execute:** How to deploy safely?
   - Feature flag if possible
   - Staged rollout (1% → 10% → 100%)
   - Monitoring for 30 minutes between stages

5. **Document:** Post-incident review
   - Why was this missed earlier?
   - How to prevent in future?
```

### Communication

```yaml
# Freeze Announcement Template
to: all-engineering, stakeholders
subject: "[Dashboard] Entering YELLOW FREEZE"
body: |
  Effective: Monday, March 18

  What this means:
  - No new features will be added
  - Only bug fixes and critical issues
  - All changes require Eng Lead approval

  Current status:
  - Features complete: 12/12 ✓
  - Open P1 bugs: 0 ✓
  - Open P2 bugs: 3 (being addressed)

  Next milestone: RED FREEZE on March 25
```
```

**Scope freeze requirements:**
- Define freeze levels with clear criteria
- Establish freeze timeline in project plan
- Document approval process for each level
- Communicate freeze transitions to all
- Post-mortem any freeze violations

Reference: [Atlassian - Release Management Best Practices](https://www.atlassian.com/software/jira/guides/release-management)
