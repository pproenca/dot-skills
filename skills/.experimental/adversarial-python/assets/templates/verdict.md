# Review Verdict — {{TARGET_SHORT_DESCRIPTION}}

- **Target:** {{TARGET_REF_OR_PATHS}}
- **Python floor:** {{PYTHON_FLOOR}} ({{FLOOR_SOURCE}}){{DELTA_BRIEFING_NOTE}}
<!-- DELTA_BRIEFING_NOTE: when a version-delta briefing was composed, append
     "; delta briefing applied for 3.X (rules verified against {{VERIFIED_PYTHON}})".
     Otherwise omit. -->
- **Rules:** this gate's rules ({{RULES_APPLIED_COUNT}} applied, {{RULES_NA_COUNT}} N/A — version gates and absent shapes)
- **Reviewers:** 2 independent blind reviewers, identical prompt, dispatched in parallel

## Overall Verdict: {{PASS_OR_FAIL}}

<!-- PASS only if both reviewers returned overall PASS. Any FAIL or contested rule → FAIL. -->

## Per-Rule Results

| Rule | Reviewer A | Reviewer B | Final | Evidence |
|------|-----------|-----------|-------|----------|
{{FOR_EACH RULE in RULES}}
| {{RULE.title}} | {{RULE.verdict_a}} | {{RULE.verdict_b}} | {{RULE.final}} | {{RULE.evidence}} |
{{END_FOR_EACH}}

<!-- Final column: PASS (both pass), FAIL (both fail), CONTESTED (split — counts as FAIL),
     N/A (both N/A; a PASS/N/A split resolves to PASS, a FAIL/N/A split is CONTESTED). -->

## Contested Rules

<!-- Omit this section when no rule was contested. -->

{{FOR_EACH RULE in CONTESTED_RULES}}
### {{RULE.title}}
- **Reviewer A ({{RULE.verdict_a}}):** {{RULE.rationale_a}}
- **Reviewer B ({{RULE.verdict_b}}):** {{RULE.rationale_b}}
{{END_FOR_EACH}}

A contested rule counts as FAIL. If the same rule is contested across repeated reviews, the rule is under-specified — sharpen it rather than overriding the gate.

## What's Missing for a PASS

<!-- Omit this section on overall PASS. Aggregate every reviewer's "missing for PASS"
     suggestions, dedupe, keep locations, order by category importance (disp → model →
     alt → typing → std → flow). Every FAIL and CONTESTED rule must appear with a change
     concrete enough to apply as written — if a reviewer's suggestion only restates the
     violation, derive the fix from the rule's correct example before rendering. -->

{{FOR_EACH FIX in FIX_LIST}}
1. **{{FIX.rule_title}}** — {{FIX.change_and_location}}
{{END_FOR_EACH}}
