# Review Verdict — {{TARGET_SHORT_DESCRIPTION}}

- **Target:** {{TARGET_REF_OR_PATHS}}
- **Target manifest (frozen ref):** {{COMMIT_SHA_OR_STASH_OR_SAVED_DIFF}}
- **Gate status:** {{RENDERED_OR_VOID_WITH_REASON}} <!-- a dispatched gate always ends RENDERED, GATE NOT APPLICABLE, or "VOID — <reason>"; never silence -->
- **Rules:** this gate's rules ({{RULES_APPLIED_COUNT}} applied)
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

<!-- Omit this section when nothing applies. If a rule's verdict flips across
     re-reviews of an unchanged target, or a human overrides a verdict after
     reading the evidence, append an entry to gotchas.md naming the rule and
     the ambiguity — that is a decidability bug to fix in the rule, not by
     overriding the gate. -->

## What's Missing for a PASS

<!-- Omit this section on overall PASS. Aggregate the reviewer's "missing for PASS"
     suggestions, dedupe, keep locations, order by category importance
     (state → update → identity → task → list → anim → access).
     Completeness: every rule whose verdict is FAIL appears here exactly
     once, each with a change concrete enough to apply as written — if the reviewer
     only restated the violation, derive the fix from the rule's Correct example
     before rendering. -->

{{FOR_EACH FIX in FIX_LIST}}
1. **{{FIX.rule_title}}** — {{FIX.change_and_location}}
{{END_FOR_EACH}}

## Out-of-Scope Observations

<!-- Omit when empty. Violations the reviewer noticed outside the declared target
     manifest. Reported for a future gate invocation — never fixed under this
     verdict, never counted in it. -->

{{FOR_EACH OBS in OUT_OF_SCOPE_OBSERVATIONS}}
- **{{OBS.rule_title}}** — {{OBS.location_and_note}}
{{END_FOR_EACH}}
