---
title: Treat the built-in AI gate as a floor and add the missing conditions
tags: aica, quality-gates, conditions, coverage
---

## Treat the built-in AI gate as a floor and add the missing conditions

The name suggests a gate purpose-built to catch AI-generated defects. Reading the conditions is deflating: it is the default **Sonar way** gate plus three conditions on overall code, and one of those three is set to a rating most teams would not accept.

The documentation states the seven conditions only as prose bullets and never publishes the metric keys. Read off a live instance, they are:

| Scope | Metric key | Condition |
|---|---|---|
| New code | `new_violations` | `GT 0` — no new issues |
| New code | `new_security_hotspots_reviewed` | `LT 100` — all reviewed |
| New code | `new_coverage` | `LT 80` |
| New code | `new_duplicated_lines_density` | `GT 3` |
| Overall | `software_quality_security_rating` | `GT 1` — Security rating A |
| Overall | `security_hotspots_reviewed` | `LT 100` |
| Overall | `software_quality_reliability_rating` | **`GT 3`** — Reliability rating C |

The first four are exactly the default Sonar way gate. Sonar's rationale for reaching back to overall code generalises well: *"AI assistants might have been used to generate code in your projects even before you defined your NCD. Therefore, it's essential to also apply conditions to Overall Code."* New-code-only gating assumes the pre-baseline codebase was written under review; for AI-assisted work that assumption fails.

The lenient part is **Reliability rating C**, which permits existing major bugs indefinitely. And there is no coverage condition on overall code at all — Sonar's own page recommends *"adding a coverage condition with suitable threshold on overall code"*, which is an unusual thing for a vendor to say about its own built-in gate.

Note the metric family. These are the **MQR-mode** keys (`software_quality_reliability_rating`), not the Standard Experience keys (`reliability_rating`). Both exist, and adding a condition from the wrong family produces a mixed-mode gate whose conditions the instance hides depending on its active mode. Match whichever family the gate you copied already uses.

```bash
AUTH=(-H "Authorization: Bearer $SONAR_ADMIN_TOKEN")

# Resolve the AI-qualified gate by capability rather than hardcoding its name —
# it is "Sonar way for AI code", the lookup is case-sensitive, and recent
# versions rename it with a "(legacy)" suffix alongside a new agentic gate.
SRC=$(curl -s "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/list" \
  | jq -r '[.qualitygates[] | select(.isAiCodeSupported) | .name][0]')
GATE="AI code (checkout org)"

curl -sf -X POST "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/copy" \
  --data-urlencode "sourceName=$SRC" --data-urlencode "name=$GATE"

# Reliability A on overall code, not C. Ratings are 1=A, 2=B, 3=C, 4=D, 5=E.
curl -sf -X POST "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/create_condition" \
  --data-urlencode "gateName=$GATE" \
  -d 'metric=software_quality_reliability_rating&op=GT&error=1'

# The overall-code coverage floor the built-in gate omits.
curl -sf -X POST "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/create_condition" \
  --data-urlencode "gateName=$GATE" -d 'metric=coverage&op=LT&error=60'

# Confirm what you actually created.
curl -s --get "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/show" \
  --data-urlencode "name=$GATE" | jq '{hasMQRConditions, hasStandardConditions, conditions}'
```

A copied gate is **not** qualified for AI Code Assurance — qualification does not survive the copy. Set it explicitly afterwards, or the tightened gate grants no assurance status at all (`aica-qualify-the-gate-explicitly`).

Recent builds also ship a **"Sonar way for Agentic AI"** gate, which drops the ratings in favour of per-severity conditions (`new_reliability_issue_severity`, `new_maintainability_issue_severity`, `new_sca_severity_any_issue`). It is documented for SonarQube Cloud; check `api/qualitygates/list` on your own instance rather than assuming your Server version has it.

Reference: [Quality gates for AI code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-gates-for-ai-code) · [Introduction to quality gates](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-gates/introduction-to-quality-gates)
