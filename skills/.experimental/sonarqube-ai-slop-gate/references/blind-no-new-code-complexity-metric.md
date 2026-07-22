---
title: Gate complexity through rule S3776, because no new-code metric exists
tags: blind, complexity, metrics, quality-gates
---

## Gate complexity through rule S3776, because no new-code metric exists

Over-complex functions are a signature of assistant-generated code — deeply nested handling of cases nobody asked for — so a condition on cognitive complexity of new code is an obvious thing to write. It cannot be written. **There is no `new_cognitive_complexity` metric.**

The Complexity domain contains exactly two metrics, `complexity` (*"A quantitative metric used to calculate the number of paths through the code"*) and `cognitive_complexity` (*"A qualification of how hard it is to understand the code's control flow"*). Neither has a new-code variant, unlike coverage, duplication, and issues, which all do. The metric simply is not in the quality gate dropdown, and a scripted `create_condition` call naming it fails.

Gating on whole-project `cognitive_complexity` is not a substitute. It is a sum over the entire codebase, so on any repository of size the threshold is either so high it never trips or so low it fails permanently on pre-existing code — and either way it says nothing about the change under review.

The mechanism that does work is the rule. `S3776` — *"Cognitive Complexity of methods should not be too high"*, CRITICAL, default threshold **15** — raises an issue on each function that exceeds the threshold. Issues on new code feed `new_violations`, which **is** a gate-eligible new-code metric. So complexity gating runs through the issues pipeline rather than the metrics pipeline:

```bash
# Tighten S3776 in your profile, then let new_violations carry it into the gate.
# Parameter name differs by language: `Threshold` for Java, `threshold` for
# TypeScript and Python.
curl -sf -X POST -H "Authorization: Bearer $SONAR_ADMIN_TOKEN" \
  "$SONAR_HOST_URL/api/qualityprofiles/activate_rule" \
  --data-urlencode "key=checkout-java-profile" \
  --data-urlencode "rule=java:S3776" \
  --data-urlencode "params=Threshold=10"
```

This is the general shape for anything the metrics layer does not expose on new code: find the rule, tune its threshold, and let `new_violations` do the gating. The default Sonar way condition *"No new issues are introduced"* means any activated rule becomes a blocking condition automatically — which is why tightening `S3776` from 15 to 10 is a decision to make deliberately rather than a free win. Every function over the new threshold starts failing the gate the moment the profile changes.

Whole-project `complexity` and `cognitive_complexity` remain useful as tracked trends on the project dashboard. Read them as direction-of-travel, not as gate conditions.

Reference: [Metrics definition](https://docs.sonarsource.com/sonarqube-server/user-guide/code-metrics/metrics-definition) · [Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates)
