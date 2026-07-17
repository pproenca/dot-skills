# Review Verdict — {{TARGET_SHORT_DESCRIPTION}}

- **Target:** {{TARGET_REF_OR_PATHS}}
- **Target manifest (frozen ref):** {{COMMIT_SHA_OR_STASH_OR_SAVED_DIFF}}
- **Gate status:** {{RENDERED_OR_VOID_WITH_REASON}} <!-- a dispatched gate always ends RENDERED, GATE NOT APPLICABLE, or "VOID — <reason>"; never silence -->
- **Toolchain / deployment target:** {{SWIFT_VERSION_AND_MIN_OS}}
- **Rules:** this gate's rules ({{RULES_APPLIED_COUNT}} applied)
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
- **Missing for PASS (failing reviewer):** {{RULE.fix_from_failing_reviewer}}
- **Gotchas entry:** {{RULE.id_plus_the_ambiguity_that_split_the_reviewers}}
{{END_FOR_EACH}}

A contested rule counts as FAIL. Append every Gotchas entry above to gotchas.md before rendering — a rendered verdict with contested rules and no gotchas entries is a protocol violation. If the same rule is contested across repeated reviews, the rule is under-specified — sharpen it rather than overriding the gate.

## What's Missing for a PASS

<!-- Omit this section on overall PASS. Aggregate every reviewer's "missing for PASS"
     suggestions, dedupe, keep locations, order by category importance
     (conc > prop > err > enum > api > coll > flow).
     Completeness: every rule whose Final is FAIL or CONTESTED appears here exactly
     once, each with a change concrete enough to apply as written — if a reviewer
     only restated the violation, derive the fix from the rule's Correct example
     before rendering. -->

{{FOR_EACH FIX in FIX_LIST}}
1. **{{FIX.rule_title}}** — {{FIX.change_and_location}}
{{END_FOR_EACH}}

## Out-of-Scope Observations

<!-- Omit when empty. Violations reviewers noticed outside the declared target
     manifest. Reported for a future gate invocation — never fixed under this
     verdict, never counted in it. -->

{{FOR_EACH OBS in OUT_OF_SCOPE_OBSERVATIONS}}
- **{{OBS.rule_title}}** — {{OBS.location_and_note}}
{{END_FOR_EACH}}
