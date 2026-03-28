---
name: threat-model
description: Use this skill whenever performing security threat modeling, attack surface mapping, or trust boundary analysis on a codebase. Triggers on 'threat model', 'security review', 'attack surface', 'trust boundaries', or when assessing a project's security posture. Also trigger when the user is about to build security-sensitive features (auth, crypto, file I/O, network services, native bridges) and needs to understand the threat landscape first — even if they don't explicitly say "threat model." Also triggers on 'what changed' or 'diff analysis' for incremental security review of recent commits.
---

# Threat Model

Produces structured, evidence-backed security threat models for any codebase. Goes beyond surface enumeration by tracing untrusted data through actual code paths, clustering findings by root cause, and constructing exploit chains that combine individual findings into higher-severity attack paths.

## When to Apply

- User asks to threat model, security review, or map attack surfaces for a codebase
- Starting work on security-sensitive features (auth, crypto, file I/O, networking, native bridges)
- Evaluating a new codebase or major architectural change for security implications
- Reviewing a PR or recent commits for security regressions (incremental/diff mode)
- After a security incident to reassess the threat landscape

## Workflow Overview

```
Phase 0 (conditional): Diff Analysis — if git range provided, scope to changed code
Phase 1:  Codebase Survey        → Understand what the project is and does
Phase 2:  Component Mapping      → Identify components, data flows, and language bridges
Phase 3:  Asset Identification   → Determine what needs protecting
Phase 4:  Trust Boundaries       → Classify inputs by trust level, inventory entry points
Phase 5:  Data Flow Tracing      → Follow untrusted values from entry to sink ← key technique
Phase 6:  Attack Surface Enum    → Document surfaces with traced evidence
Phase 7:  Pattern Clustering     → Group 3+ similar findings by root cause
Phase 8:  Exploit Chains         → Combine findings into multi-step attack paths
Phase 9:  Calibration            → Rate with chain-adjusted and systemic severity
Phase 10: Output                 → Write structured THREAT-MODEL.md
```

## How to Use

1. Read [methodology](references/methodology.md) for the detailed approach at each phase
2. Read [output format](references/output-format.md) for the document structure (6 sections)
3. Consult [attack patterns](references/attack-patterns.md) for technology-specific patterns
4. Run `scripts/trace-data-flows.sh <project-root>` to inventory entry points and sinks
5. Optionally run `scripts/scan-patterns.sh <project-root>` for security-relevant code patterns

## Analytical Techniques

These techniques are the skill's core value — they encode analytical methods that produce findings the model wouldn't generate from general knowledge alone.

| Technique | When to Read | What It Adds |
|-----------|-------------|-------------|
| [Data Flow Tracing](references/techniques/data-flow-tracing.md) | Phase 5 — always | Traces untrusted input from entry to sink through actual code. Produces evidence-backed findings instead of theoretical risks |
| [Pattern Clustering](references/techniques/pattern-clustering.md) | Phase 7 — after enumeration | Groups related findings by root cause. Recommends systemic fixes instead of individual patches |
| [Exploit Chains](references/techniques/exploit-chains.md) | Phase 8 — after clustering | Combines findings into multi-step attack paths rated by terminal impact |
| [Bridge Analysis](references/techniques/bridge-analysis.md) | Phase 6 — when FFI/bridges found | Systematic checklist for cross-language boundaries (Swift↔C, Rust↔C, Rails↔NGINX) |
| [Diff Analysis](references/techniques/diff-analysis.md) | Phase 0 — for incremental review | Scopes analysis to changed code, identifies regressions |

## Key Principles

- **Evidence over speculation**: Every finding should include a data flow trace showing how untrusted input reaches the vulnerable operation. "XSS is possible" is speculation. "RFC markdown → marked.parse() → innerHTML at line 917 with no sanitizer" is evidence.
- **Systemic over individual**: When 3+ findings share a root cause, the systemic finding is more important than any individual finding. Fix the root cause, not the symptoms.
- **Chains over singletons**: Rate combined attack paths by their terminal impact. Three medium findings that chain into critical impact are a critical finding.
- **Existing mitigations matter**: Document what's already protected, not just what's missing.
- **Context-aware calibration**: Severity depends on deployment context. Always include scope notes.

## Output

Produces **two files** (configurable via config.json):

- **`findings.json`** — Structured, machine-readable findings. Source of truth. Consumed by `threat-patch` for automated remediation. Tracks finding state across runs (open → patched → verified → closed).
- **`THREAT-MODEL.md`** — Human-readable view generated from findings.json. 6 sections: Overview, Trust Boundaries, Attack Surfaces, Systemic Findings, Exploit Chains, Criticality Calibration.

### Pipeline Integration

```
threat-model → findings.json → threat-patch (consumes findings, generates fixes)
     ↑                                          ↓
     └── threat-model --diff (re-analyzes, updates finding status) ←── git commits
```

When `findings.json` exists from a prior run, the skill reads it to:
- Track which findings are still open vs patched
- Calibrate severity against prior ratings
- Detect regressions (fixed findings that reappeared)

## Two Modes

| Mode | Trigger | What It Does |
|------|---------|-------------|
| **Full analysis** | "threat model this codebase" | Analyzes entire codebase, produces fresh findings.json + THREAT-MODEL.md |
| **Diff analysis** | "what changed since last review" / git range provided | Scopes to changed code, updates existing findings.json with new/resolved/regressed findings |

Diff mode is the daily driver for ongoing projects. Full mode runs once (or periodically).

## References

| File | When to Read |
|------|-------------|
| [references/methodology.md](references/methodology.md) | Before starting — the 10-phase workflow |
| [references/output-format.md](references/output-format.md) | When writing output — 6-section template |
| [references/findings-schema.md](references/findings-schema.md) | When writing findings.json — structured schema |
| [references/attack-patterns.md](references/attack-patterns.md) | When enumerating surfaces — technology patterns |
| [references/techniques/](references/techniques/) | During specific phases — analytical techniques |
