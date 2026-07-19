# Review Verdict — {{TARGET_SHORT_DESCRIPTION}}

- **Target:** {{TARGET_REF_OR_PATHS}}
- **Python floor:** {{PYTHON_FLOOR}} ({{FLOOR_SOURCE}}){{DELTA_BRIEFING_NOTE}}
<!-- DELTA_BRIEFING_NOTE: when a version-delta briefing was composed, append
     "; delta briefing applied for 3.X (rules verified against {{VERIFIED_PYTHON}})".
     Otherwise omit. -->
- **Rules:** this gate's rules ({{RULES_APPLIED_COUNT}} applied, {{RULES_NA_COUNT}} N/A — version gates and absent shapes)
- **Reviewer:** one blind reviewer, self-contained prompt

## Overall Verdict: {{PASS_OR_FAIL}}

<!-- PASS only when every rule is PASS or N/A; any single FAIL fails the gate. -->

## Per-Rule Results

| Rule | Verdict | Evidence |
|------|---------|----------|
{{FOR_EACH RULE in RULES}}
| {{RULE.title}} | {{RULE.verdict}} | {{RULE.evidence}} |
{{END_FOR_EACH}}

## Verdict Instability

<!-- If a rule's verdict flips across re-reviews of an unchanged target, or a human
     overrides a verdict after reading the evidence, append an entry to gotchas.md
     naming the rule and the ambiguity — that is a decidability bug to fix in the rule,
     not by overriding the gate. -->

## What's Missing for a PASS

<!-- Omit this section on overall PASS. Aggregate the reviewer's "missing for PASS"
     suggestions, dedupe, keep locations, order by category importance (disp → model →
     alt → typing → std → flow). Every FAIL rule must appear with a change concrete
     enough to apply as written — if the reviewer's suggestion only restates the
     violation, derive the fix from the rule's correct example before rendering. -->

{{FOR_EACH FIX in FIX_LIST}}
1. **{{FIX.rule_title}}** — {{FIX.change_and_location}}
{{END_FOR_EACH}}
