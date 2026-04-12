---
title: Hand Off to the Personalisation Skill When the Bottleneck Is Personalisation
impact: HIGH
impactDescription: prevents duplicated planning effort
tags: plan, handoff, scope
---

## Hand Off to the Personalisation Skill When the Bottleneck Is Personalisation

This skill covers the retrieval planning layer — intent framing, architecture, OpenSearch index and query design, search relevance, and the meta-methodology for planning and diagnosing. When the diagnostic identifies that the bottleneck is personalisation-specific — impression tracking for a recommender, AWS Personalize schema design, feedback-loop bias, mutual-fit ranking in a marketplace — the next step is the companion skill `marketplace-personalisation`, which has 49 rules specifically about that layer. Recognising the hand-off point is part of planning: do not re-derive rules that already exist in the companion skill.

**Incorrect (trying to solve a personalisation problem inside the search planning skill):**

```python
def improve_homefeed_ranking() -> None:
    audit = run_bottleneck_diagnostic()
    if audit.bottleneck == "impression_tracking":
        write_rule_in_this_skill_about_impressions()
        write_rule_in_this_skill_about_negative_signals()
```

**Correct (bottleneck identified, hand off to the personalisation skill):**

```python
def improve_homefeed_ranking() -> None:
    audit = run_bottleneck_diagnostic()
    if audit.bottleneck in {"impression_tracking", "feedback_loop", "cold_start"}:
        refer_to_skill(
            "marketplace-personalisation",
            playbook="references/playbooks/improving.md",
            reason=f"Retrieval layer is healthy; bottleneck is {audit.bottleneck}",
        )
        return
    run_search_planning_workflow(audit)
```

Reference: [Google — Rules of Machine Learning, Rule 38: Do Not Waste Time on New Features if Unaligned Objectives Become the Issue](https://developers.google.com/machine-learning/guides/rules-of-ml)
