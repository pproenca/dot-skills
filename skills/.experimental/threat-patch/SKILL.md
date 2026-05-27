---
name: threat-patch
description: Use this skill to remediate security findings by producing minimal, surgical code patches. Triggers on 'patch security findings', 'fix vulnerabilities', 'remediate findings', 'threat patch', or when the user provides a findings.json (from threat-model), a Codex security findings CSV, a THREAT-MODEL.md, or individual vulnerability descriptions and wants them fixed. Also trigger when reviewing code flagged by a security scanner and the user wants actionable fixes rather than just reports.
---

# Threat Patch

Reads security findings and produces minimal, surgical code patches with structured documentation. Fixes are code-grounded — each patch targets specific files and functions identified in the finding. Output includes a summary, validation steps, and the code changes.

## When to Apply

- User provides a `findings.json` (from threat-model) and wants fixes
- User provides a Codex security findings CSV and wants fixes
- User has a THREAT-MODEL.md and wants to remediate identified risks
- User describes a specific vulnerability and wants a patch
- Reviewing security scanner output and needs actionable fixes
- After a security audit, turning findings into code changes

## Input Sources (priority order)

| Source | What It Provides | How to Use |
|--------|-----------------|-----------|
| **findings.json** (from threat-model) | Structured findings with data flow traces, systemic groupings, exploit chains, and severity ratings | Read directly — richest input, already triaged and grouped |
| **Codex CSV** | Title, description, severity, relevant_paths per finding | Run `scripts/parse-findings.sh <csv-path>` to extract structured output |
| **THREAT-MODEL.md** | Human-readable threat model | Extract findings from Criticality Calibration section |
| **Inline description** | User describes a specific vulnerability | Parse from conversation context |

When `findings.json` is available, it's the preferred input — it includes data flow traces (entry → chain → sink) that directly inform where to apply fixes, and systemic groupings that suggest centralized fixes over individual patches.

## Workflow Overview

```
1. Ingest Findings   → Read findings.json / CSV / descriptions
2. Triage & Group    → Sort by severity, use systemic groupings if available
3. For each finding:
   a. Read Code      → Open relevant_paths, understand the pattern
   b. Confirm        → Verify issue is still present in HEAD
   c. Design Fix     → Determine minimal fix approach
   d. Implement      → Write the code changes
   e. Document       → Summary + Validation + Attack-path (if needed)
   f. Test           → Run relevant tests
4. Output            → Per-patch deliverable with summary and diff
5. Update State      → Mark patched findings in findings.json (if present)
```

## How to Use

1. Read [workflow](references/workflow.md) for the detailed patching methodology at each step
2. Read [fix patterns](references/fix-patterns.md) when designing fixes — common patterns by vulnerability class
3. Read [output format](references/output-format.md) for the documentation template per patch
4. If input is findings.json: read it directly — it's already structured
5. If input is Codex CSV: run `scripts/parse-findings.sh <csv-path>` to extract structured output

## Key Principles

- **Minimal diff**: Fix the vulnerability, don't refactor surrounding code. The smallest correct patch is the best patch
- **Centralize over duplicate**: When multiple code paths share the same vulnerability pattern, extract a shared helper rather than patching each site independently
- **Explicit error paths**: Add specific error types for rejected inputs with clear operator feedback, not silent failures or generic errors
- **Confirm before fixing**: Always verify the finding is still present in HEAD — code may have moved or been refactored since the finding was detected
- **User approval before edits**: Present the fix design (files to change, approach) and wait for approval before modifying source code. Hooks gate Edit/Write tool calls for additional safety
- **Document even failures**: When a fix can't be tested due to environment limitations, document the test command and the limitation

## Guardrails

This skill modifies source code. Safety measures:
- **PreToolUse hooks** on Edit and Write tools prompt for confirmation before each file change
- **Confirmation gate** in the workflow between fix design and implementation
- **Revert path**: Without commits (default), use `git checkout -- <files>` to undo. With commits, use `git revert`

## Output Modes

**Code patch** — when a fix is implemented:
- Summary of what was confirmed and what the fix does
- Testing section with build/test commands
- The actual code changes

**Analysis only** — when the fix needs user decision or architectural changes:
- Summary of what was confirmed
- Validation checklist
- Attack-path analysis (path, likelihood, impact, assumptions, controls, blindspots)

## References

| File | When to Read |
|------|-------------|
| [references/workflow.md](references/workflow.md) | Before starting — detailed approach for each patching phase |
| [references/fix-patterns.md](references/fix-patterns.md) | When designing fixes — patterns by vulnerability class |
| [references/output-format.md](references/output-format.md) | When documenting — templates for both output modes |
