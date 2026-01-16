---
name: bug-hunting-best-practices
description: Systematic bug hunting and debugging guidelines for software engineers. This skill should be used when investigating bugs, debugging code, triaging issues, or reviewing debugging approaches. Triggers on tasks involving bug investigation, debugging sessions, root cause analysis, or incident response.
---

# Software Engineering Bug Hunting Best Practices

Comprehensive bug hunting and debugging guide for software engineers, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact to guide systematic debugging and issue resolution.

## When to Apply

Reference these guidelines when:
- Investigating a reported bug or unexpected behavior
- Debugging code during development
- Triaging incoming bug reports and prioritizing fixes
- Conducting root cause analysis for incidents
- Reviewing code for common bug patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Systematic Reproduction | CRITICAL | `repro-` |
| 2 | Hypothesis-Driven Investigation | CRITICAL | `hypo-` |
| 3 | Root Cause Analysis | HIGH | `rca-` |
| 4 | Strategic Logging | HIGH | `log-` |
| 5 | Debugger Mastery | MEDIUM-HIGH | `debug-` |
| 6 | Bug Triage and Classification | MEDIUM | `triage-` |
| 7 | Common Bug Patterns | MEDIUM | `pattern-` |
| 8 | Prevention and Verification | LOW | `prevent-` |

## Quick Reference

### 1. Systematic Reproduction (CRITICAL)

- `repro-document-exact-steps` - Document exact reproduction steps
- `repro-isolate-variables` - Isolate variables systematically
- `repro-minimal-reproduction` - Create minimal reproduction cases
- `repro-capture-environment` - Capture full environmental context
- `repro-intermittent-bugs` - Make intermittent bugs deterministic

### 2. Hypothesis-Driven Investigation (CRITICAL)

- `hypo-form-before-investigate` - Form hypothesis before investigation
- `hypo-make-predictions` - Make testable predictions from hypotheses
- `hypo-binary-search` - Use binary search to localize bugs
- `hypo-one-change-at-a-time` - Change one thing at a time
- `hypo-record-experiments` - Record all debugging experiments

### 3. Root Cause Analysis (HIGH)

- `rca-five-whys` - Apply Five Whys to find root cause
- `rca-fishbone-diagram` - Use Fishbone diagrams for complex bugs
- `rca-backtrack-from-symptom` - Backtrack from symptom to source
- `rca-distinguish-symptom-cause` - Distinguish symptoms from causes
- `rca-verify-before-closing` - Verify root cause before declaring fixed

### 4. Strategic Logging (HIGH)

- `log-use-structured-logging` - Use structured logging for debugging
- `log-correlation-ids` - Add correlation IDs across services
- `log-appropriate-levels` - Use appropriate log levels
- `log-context-not-noise` - Log context not noise
- `log-include-error-context` - Include full context in error logs

### 5. Debugger Mastery (MEDIUM-HIGH)

- `debug-breakpoint-strategically` - Place breakpoints strategically
- `debug-conditional-breakpoints` - Use conditional breakpoints for specific cases
- `debug-watch-expressions` - Use watch expressions to track state
- `debug-step-over-into-out` - Master step over, into, and out
- `debug-call-stack-inspection` - Inspect the call stack for context
- `debug-time-travel` - Use time-travel debugging when available

### 6. Bug Triage and Classification (MEDIUM)

- `triage-severity-vs-priority` - Separate severity from priority
- `triage-user-impact-assessment` - Assess user impact before prioritizing
- `triage-reproducibility-matters` - Factor reproducibility into triage
- `triage-quick-wins-first` - Identify and ship quick wins first
- `triage-duplicate-detection` - Detect and link duplicate bug reports

### 7. Common Bug Patterns (MEDIUM)

- `pattern-null-pointer` - Recognize null pointer patterns
- `pattern-off-by-one` - Spot off-by-one errors
- `pattern-race-condition` - Identify race condition symptoms
- `pattern-memory-leak` - Detect memory leak patterns
- `pattern-type-coercion` - Watch for type coercion bugs
- `pattern-async-await-errors` - Catch async/await error handling mistakes
- `pattern-timezone-issues` - Recognize timezone and date bugs

### 8. Prevention and Verification (LOW)

- `prevent-regression-tests` - Add regression tests for every fix
- `prevent-defensive-assertions` - Use assertions for invariant checking
- `prevent-code-review-checks` - Include bug-prevention checks in code review
- `prevent-post-mortem-learning` - Conduct blameless post-mortems

## How to Use

Read individual rule files for detailed explanations and code examples:

```
rules/repro-minimal-reproduction.md
rules/hypo-binary-search.md
rules/_sections.md
```

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
