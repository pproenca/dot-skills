---
name: systematic-debugging
description: Comprehensive debugging methodology and best practices for finding and fixing bugs systematically. This skill should be used when debugging code, investigating errors, troubleshooting issues, or reviewing debugging approaches. Triggers on tasks involving bug fixes, error investigation, debugging sessions, or troubleshooting.
---

# Systematic Debugging Best Practices

Comprehensive debugging methodology guide for software engineers, containing 42 rules across 8 categories prioritized by impact. Based on research from Andreas Zeller's "Why Programs Fail" and academic debugging curricula.

## When to Apply

Reference these guidelines when:
- Investigating a bug or unexpected behavior
- Code produces wrong results or crashes
- Performance issues need root cause analysis
- Reviewing someone's debugging approach
- Teaching debugging techniques

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Problem Definition | CRITICAL | `prob-` |
| 2 | Hypothesis-Driven Search | CRITICAL | `hypo-` |
| 3 | Observation Techniques | HIGH | `obs-` |
| 4 | Root Cause Analysis | HIGH | `rca-` |
| 5 | Tool Mastery | MEDIUM-HIGH | `tool-` |
| 6 | Fix Verification | MEDIUM | `verify-` |
| 7 | Anti-Patterns | MEDIUM | `anti-` |
| 8 | Prevention & Learning | LOW-MEDIUM | `prev-` |

## Quick Reference

### 1. Problem Definition (CRITICAL)

- `prob-reproduce-before-debug` - Reproduce the bug before investigating
- `prob-minimal-reproduction` - Create minimal reproduction cases
- `prob-document-symptoms` - Document symptoms precisely
- `prob-separate-symptoms-causes` - Separate symptoms from causes
- `prob-state-expected-actual` - State expected vs actual behavior
- `prob-recent-changes` - Check recent changes first

### 2. Hypothesis-Driven Search (CRITICAL)

- `hypo-scientific-method` - Apply the scientific method
- `hypo-binary-search` - Use binary search to localize bugs
- `hypo-one-change-at-time` - Test one hypothesis at a time
- `hypo-where-not-what` - Find WHERE before asking WHAT
- `hypo-rule-out-obvious` - Rule out obvious causes first
- `hypo-rubber-duck` - Explain the problem aloud

### 3. Observation Techniques (HIGH)

- `obs-strategic-logging` - Use strategic logging
- `obs-log-inputs-outputs` - Log function inputs and outputs
- `obs-breakpoint-strategy` - Use breakpoints strategically
- `obs-stack-trace-reading` - Read stack traces bottom to top
- `obs-watch-expressions` - Use watch expressions for state
- `obs-trace-data-flow` - Trace data flow through system

### 4. Root Cause Analysis (HIGH)

- `rca-five-whys` - Use the 5 Whys technique
- `rca-fault-propagation` - Trace fault propagation chains
- `rca-last-known-good` - Find the last known good state
- `rca-question-assumptions` - Question your assumptions
- `rca-examine-boundaries` - Examine system boundaries

### 5. Tool Mastery (MEDIUM-HIGH)

- `tool-conditional-breakpoints` - Use conditional breakpoints
- `tool-logpoints` - Use logpoints instead of modifying code
- `tool-step-commands` - Master step over/into/out
- `tool-call-stack-navigation` - Navigate the call stack
- `tool-memory-inspection` - Inspect memory and object state
- `tool-exception-breakpoints` - Use exception breakpoints

### 6. Fix Verification (MEDIUM)

- `verify-reproduce-fix` - Verify with original reproduction
- `verify-regression-check` - Check for regressions
- `verify-understand-why-fix-works` - Understand why fix works
- `verify-add-test` - Add test to prevent recurrence

### 7. Anti-Patterns (MEDIUM)

- `anti-shotgun-debugging` - Avoid shotgun debugging
- `anti-quick-patch` - Avoid quick patches without understanding
- `anti-tunnel-vision` - Avoid tunnel vision on initial hypothesis
- `anti-debug-fatigue` - Recognize debugging fatigue
- `anti-blame-tool` - Don't blame the tool too quickly

### 8. Prevention & Learning (LOW-MEDIUM)

- `prev-document-solution` - Document bug solutions
- `prev-postmortem` - Conduct blameless postmortems
- `prev-defensive-coding` - Add defensive code at boundaries
- `prev-improve-error-messages` - Improve error messages

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/prob-reproduce-before-debug.md
rules/hypo-binary-search.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
