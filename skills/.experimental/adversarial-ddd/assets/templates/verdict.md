# Review Verdict — {{TARGET_SHORT_DESCRIPTION}}

- **Target:** {{TARGET_REF_OR_PATHS}}
- **Rules:** this gate's rules ({{RULES_APPLIED_COUNT}} applied)
- **Glossary:** {{GLOSSARY_PATH_OR_NONE}}
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
     suggestions, dedupe, keep locations, order by category importance
     (gloss → lang → model → ctx → dsl). Glossary edits come first: creating or
     correcting the recorded language is the change that makes the rest checkable. -->

{{FOR_EACH FIX in FIX_LIST}}
1. **{{FIX.rule_title}}** — {{FIX.change_and_location}}
{{END_FOR_EACH}}
