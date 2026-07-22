---
title: Disable the fudge factor or small commits bypass duplication and coverage
tags: blind, fudge-factor, quality-gates, duplication
---

## Disable the fudge factor or small commits bypass duplication and coverage

This is the single most damaging default for an AI-slop gate, and nothing surfaces it. A gate can be configured perfectly — duplication at 3%, coverage at 80% — and simply not evaluate either condition, reporting a clean pass.

SonarQube applies a change-size threshold below which two of the four Sonar way conditions are skipped outright:

> "The conditions on duplication are ignored until the *number of new lines* is at least 20."
> "The conditions on coverage are ignored until the *number of new lines to cover* is at least 20."

And it is not opt-in: *"The fudge factor is enabled by default in your instance. This global setting is applied to all new projects."*

The interaction with assistant-generated work is direct. AI-assisted development produces a high rate of small, frequent commits — a helper extracted here, a handler tweaked there — and a large share of them land under twenty new lines. Every one of those changes passes the duplication and coverage conditions **without those conditions being tested**. A pasted-in duplicate of an existing function, at fifteen lines, is exactly the shape of change the gate was bought to catch and exactly the shape it waves through. Nothing in the pull request decoration distinguishes "duplication condition passed" from "duplication condition not evaluated".

The rationale — avoiding noise on trivial edits, where one uncovered line in a three-line change reads as 0% coverage — is reasonable for hand-written code arriving at human pace. It stops being reasonable when the commit stream is machine-paced and duplication is the defect you are hunting.

Turn it off globally, then confirm per project, since project administrators can override the global setting:

```properties
# Administration > Configuration > General Settings > Quality Gates
# "Ignore duplication and coverage on small changes" — BOOLEAN, default `true`.
# Set false to evaluate duplication and coverage on every change.
sonar.qualitygate.ignoreSmallChanges=false
```

This is a **server setting, not an analysis property** — passing it as `-Dsonar.qualitygate.ignoreSmallChanges=false` on the scanner command line does not disable it. Set it in the UI, or through `api/settings/set`, and then confirm per project, since project administrators can override the global value.

Expect the first weeks after disabling it to be noisier, and resist re-enabling it to quiet things down. The noise is the signal that was previously suppressed. If small changes genuinely produce unactionable coverage failures, raise the coverage threshold's scope rather than restoring a rule that blinds duplication too — duplication has no small-change excuse, because a fifteen-line copy is a fifteen-line copy.

Verify the setting took effect on a real project by pushing a deliberate sub-twenty-line duplicate and confirming the gate fails. A gate that has never failed on a change this size has not been proven.

Reference: [Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates)
