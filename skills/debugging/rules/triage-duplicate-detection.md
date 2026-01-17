---
title: Detect and Link Duplicate Bug Reports
impact: MEDIUM
impactDescription: prevents duplicate investigation effort
tags: triage, duplicates, linking, efficiency
---

## Detect and Link Duplicate Bug Reports

Before investigating a new bug, search for existing reports of the same issue. Duplicates waste effort and fragment information. Link them to a single canonical issue to consolidate context.

**Incorrect (investigating duplicates independently):**

```markdown
## Bug Database:

JIRA-101: "Login fails on Firefox" (Team A investigating)
JIRA-205: "Can't sign in with Firefox browser" (Team B investigating)
JIRA-312: "Authentication broken in FF" (Team C investigating)

Result: 3 teams, 3 weeks of parallel investigation
All three are the same bug: session cookie SameSite issue
```

**Correct (duplicate detection and linking):**

```markdown
## Bug Database with Duplicate Detection:

JIRA-101: "Login fails on Firefox"
- Status: In Progress
- Root cause: SameSite cookie not set

JIRA-205: "Can't sign in with Firefox browser"
- Status: Duplicate of JIRA-101
- Note: Additional reproduction steps added to JIRA-101

JIRA-312: "Authentication broken in FF"
- Status: Duplicate of JIRA-101
- Note: Affected user count updated in JIRA-101

## Duplicate Detection Checklist:
Before creating/investigating new bug:
1. Search by error message keywords
2. Search by affected component/feature
3. Search by similar user reports in last 30 days
4. Check recent deploys for related changes
```

**Duplicate indicators:**
- Same error message or stack trace
- Same feature/page affected
- Same browser/device/environment
- Reported around the same time (often after a deploy)

Reference: [Quash - Bug Triage Defect Priority vs Severity](https://quashbugs.com/blog/bug-triage-defect-priority-vs-severity)
