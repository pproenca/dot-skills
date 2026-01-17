---
title: Use Formal Change Request Process
impact: MEDIUM
impactDescription: reduces uncontrolled scope growth by 70%
tags: change, process, governance, control
---

## Use Formal Change Request Process

All scope changes after requirements sign-off must go through a formal process. Without a process, changes sneak in through casual conversations, and scope creeps invisibly until deadlines slip.

**Incorrect (informal change acceptance):**

```markdown
## How Changes Happen (Informally)

Stakeholder in Slack: "Hey, can we also add export to Excel?"
Developer: "Sure, shouldn't be too hard"

// No impact assessment
// No timeline adjustment
// No formal approval
// Result: 2-week delay discovered at deadline
```

**Correct (formal change request process):**

```markdown
## Change Request Process

### Change Request Form

```yaml
# CR-2024-042: Add Excel Export
requester: Sarah Chen (Sales)
date_submitted: 2024-03-15
priority: Medium

## Change Description
Add ability to export report data to Excel format (.xlsx)
in addition to current CSV export.

## Business Justification
Enterprise customers (representing 40% of revenue) require
Excel format for their internal reporting workflows.
3 deals worth $150K are blocked without this.

## Current Scope Reference
PRD v2.1, Section 4.2: "Reports can be exported as CSV"

## Proposed Change
Add Excel (.xlsx) export option alongside CSV.

## Acceptance Criteria
- [ ] Export button shows CSV and Excel options
- [ ] Excel file opens correctly in Excel 2016+
- [ ] Formulas preserved where applicable
- [ ] Same data as CSV export
```

### Impact Assessment (Completed by Team)

```yaml
# Impact Assessment: CR-2024-042

## Effort Estimate
development: 3 days
testing: 1 day
documentation: 0.5 days
total: 4.5 days

## Resource Impact
- Requires: 1 backend developer, 0.5 QA
- Conflicts with: None
- Dependencies: xlsx library evaluation

## Timeline Impact
- Current deadline: April 15
- With this change: April 19 (4-day slip)
- Alternative: Defer to v2.1 (no slip)

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Library security issues | Low | High | Use well-maintained lib |
| Large file memory issues | Medium | Medium | Streaming export |
| Excel version compat | Low | Low | Test matrix |

## Cost
development_cost: $4,500 (3 dev days × $1,500)
opportunity_cost: Delays feature X by 1 week

## Recommendation
APPROVE with v2.1 deferral (no deadline impact)
```

### Approval Workflow

```text
┌──────────────────┐
│ Change Request   │
│ Submitted        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Impact Assessment│ ← Team Lead (2 business days)
│ Completed        │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────┐
│ Review Board     │────▶│ Rejected     │
│ (PM + Eng Lead)  │     │ (with reason)│
└────────┬─────────┘     └──────────────┘
         │ Approved
         ▼
┌──────────────────┐     ┌──────────────┐
│ Timeline/Budget  │────▶│ Stakeholder  │
│ Impact > 10%?    │ Yes │ Approval     │
└────────┬─────────┘     └──────┬───────┘
         │ No                    │
         ▼                       ▼
┌──────────────────────────────────────┐
│ Change Incorporated into Plan        │
│ - Update PRD version                 │
│ - Adjust timeline/resources          │
│ - Notify all stakeholders            │
└──────────────────────────────────────┘
```

### Decision Record

| CR ID | Description | Decision | Date | Decider | Impact |
|-------|-------------|----------|------|---------|--------|
| CR-041 | Add dark mode | Rejected | 3/10 | PM | Out of scope |
| CR-042 | Excel export | Approved (v2.1) | 3/16 | PM | Deferred |
| CR-043 | Mobile support | Approved | 3/18 | Director | +2 weeks |
```

**Change request criteria:**
- All post-signoff changes require formal request
- Impact assessment before approval
- Clear approval authority defined
- Decision and rationale documented
- Stakeholders notified of timeline changes

Reference: [PMI - Integrated Change Control](https://www.pmi.org/learning/library/integrated-change-control-process-9549)
