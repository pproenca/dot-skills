---
title: Establish Stakeholder Communication Cadence
impact: MEDIUM-HIGH
impactDescription: reduces stakeholder surprises by 80%
tags: stake, communication, updates, transparency
---

## Establish Stakeholder Communication Cadence

Define how and when stakeholders will receive updates. Ad-hoc communication leads to some stakeholders being surprised while others are over-informed. A defined cadence sets expectations.

**Incorrect (ad-hoc updates):**

```markdown
## Communication Approach

"We'll update stakeholders when there's something to share"

// Reality:
// Week 1: Lots of updates (excitement)
// Week 2-4: Radio silence (heads down)
// Week 5: Stakeholder asks "What's happening?"
// Week 6: Panic update before demo
// Result: Stakeholders feel out of the loop, trust erodes
```

**Correct (defined communication plan):**

```markdown
## Stakeholder Communication Plan

### Update Channels

| Channel | Audience | Frequency | Content |
|---------|----------|-----------|---------|
| Slack #proj-payments | All stakeholders | Daily | Quick wins, blockers |
| Weekly email digest | Exec sponsors | Weekly | Progress %, risks, decisions needed |
| Sprint demo | Technical + Product | Bi-weekly | Working software |
| Steering committee | Exec + leads | Monthly | Milestones, budget, timeline |

### Communication Templates

**Daily Slack Update (async)**
```text
🟢 Yesterday: Completed payment form validation
🔵 Today: Starting Stripe integration
🔴 Blocked: Waiting on API credentials from Finance
```

**Weekly Email Digest**
```text
Subject: [Payments] Week 3 Update - On Track

## Progress: 45% complete
- ✅ Completed: Payment form, validation, test suite
- 🚧 In progress: Stripe integration
- ⏳ Upcoming: Error handling, receipts

## Risks
- API credentials delayed (Medium risk, mitigation in place)

## Decisions Needed
- Approve receipt email template by Friday

## Next Demo
Thursday 2pm - Payment flow end-to-end
```

### Escalation Triggers
Stakeholders will be notified immediately if:
- Timeline slips > 1 week
- Budget exceeds 10%
- Critical blocker emerges
- Scope change requested
```

Reference: [APU - Scope Creep Project Management Tips](https://www.apu.apus.edu/area-of-study/information-technology/resources/scope-screep-5-essential-project-management-tips/)
