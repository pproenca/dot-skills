---
title: Format Text Reports Correctly
impact: MEDIUM
impactDescription: inconsistent text output breaks grep/awk-based CI scripts and makes reports impossible to compare across runs
tags: report, text, format, summary, output
---

## Text Report Format

The default text report is designed for human consumption in terminal output. Its format is stable so that developers can scan it quickly and grep for specific statuses.

### Spec Requirements

The report starts with one **summary line**:

```text
total=<total> killed=<killed> survived=<survived> errors=<errors>
```

Then one line per result:

```text
<status> <path>: <original> -> <mutated>
```

Status should be **left-aligned to 8 characters** for readability.

For `survived` and `error` results, include available details:

```text
  error: <error text>
  output:
<runner output>
```

### Example

```text
total=2 killed=1 survived=1 errors=0
killed   $.scenarios[0].examples[0].count: 20 -> 27
survived $.scenarios[1].examples[0].status: accepted -> accfpted
  output:
<test runner output>
```

### Why Summary Line First

Developers want the high-level answer first: "how many survived?" Placing the summary before individual results means they can read one line and decide whether to investigate further. This follows the principle of progressive disclosure — summary first, details on demand.

### Why Left-Aligned Status

Fixed-width status alignment (`killed  `, `survived`, `error   `) creates visual columns that make scanning large reports fast. The eye can track the left column to find all "survived" entries without reading each line fully.

### Why Details Only for Survived and Error

Killed mutations are working correctly — they need no investigation. Only survived (test gap) and error (infrastructure issue) results need diagnostic detail. Including output for every killed mutation would bloat the report with noise.

### Examples

**Incorrect (missing summary line and inconsistent status alignment):**

```text
killed $.scenarios[0].examples[0].count: 20 -> 27
survived $.scenarios[1].examples[0].status: accepted -> accfpted
  output:
<test runner output>
```

**Correct (summary line first, statuses left-aligned to 8 characters):**

```text
total=2 killed=1 survived=1 errors=0
killed   $.scenarios[0].examples[0].count: 20 -> 27
survived $.scenarios[1].examples[0].status: accepted -> accfpted
  output:
<test runner output>
```

### Why This Matters

The text report is the primary output developers see in their terminal. A well-structured report reduces the time from "mutation testing finished" to "I know what to fix." The consistent format also enables simple tooling (grep, awk) to extract metrics from the report.
