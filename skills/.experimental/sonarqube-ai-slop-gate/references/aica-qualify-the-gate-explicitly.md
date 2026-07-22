---
title: Qualify a quality gate for AI Code Assurance explicitly
tags: aica, quality-gates, qualification, migration
---

## Qualify a quality gate for AI Code Assurance explicitly

The intuitive model is that a strict enough gate earns assurance — tighten the conditions, and SonarQube recognises the project as assured. It does not work that way. Qualification is a **flag an administrator sets on the gate**, through the gate's action menu option **"Qualify for AI Code Assurance"**. A custom gate with conditions stricter than every built-in one grants no assurance status until someone flips that switch.

The trap that catches upgrades is that **plain "Sonar way" is not a qualified gate**. It was briefly treated as one: *"In SonarQube Server version 10.7, the Sonar way quality gate was enforced on projects marked as containing AI Code."* That enforcement was removed — *"The use of the Sonar way quality gate is no longer enforced on projects marked as containing AI code"* — and the migration note is explicit that the status disappears: *"If you're migrating from this version, projects using this quality gate will lose their AI Code Assurance status until a new, AI-qualified quality gate is applied."*

So an instance upgraded from 10.7 shows a fleet of projects that used to be assured and now are not, with no change to any project's configuration and nothing in the analysis log to explain it. The fix is to bind an AI-qualified gate — either the built-in **"Sonar way for AI code"** or a custom gate you have qualified.

The resulting status is one of four, and the difference between two of them is the thing worth checking after any migration:

| Status | Meaning |
|---|---|
| AI Code Assurance passed | Flagged project, AI-qualified gate, gate passing |
| AI Code Assurance failed | Flagged project, AI-qualified gate, gate failing |
| AI Code Assurance is on | Qualified gate applied, status not yet computed |
| **AI Code Assurance is off** | Project not flagged **and/or** gate not AI-qualified |

`off` is the one that masquerades as fine. It is not a neutral state — it means the feature is inert, and it reads identically whether the cause is a missing project flag or an unqualified gate.

```bash
# After any upgrade or bulk gate change, report which projects are bound to a
# gate that is NOT AI-qualified — the ones that silently lost assurance status.
AUTH=(-H "Authorization: Bearer $SONAR_ADMIN_TOKEN")

# Every qualified gate, resolved by capability rather than by name.
QUALIFIED=$(curl -s "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/list" \
  | jq -r '[.qualitygates[] | select(.isAiCodeSupported) | .name]')

curl -s "${AUTH[@]}" "$SONAR_HOST_URL/api/projects/search?ps=500" \
  | jq -r '.components[].key' \
  | while read -r key; do
      gate=$(curl -s --get "${AUTH[@]}" \
        "$SONAR_HOST_URL/api/qualitygates/get_by_project" \
        --data-urlencode "project=$key" | jq -r '.qualityGate.name')
      echo "$QUALIFIED" | jq -e --arg g "$gate" 'index($g)' >/dev/null \
        || printf 'NOT ASSURED\t%s\t%s\n' "$key" "$gate"
    done
```

Reference: [Quality gates for AI code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-gates-for-ai-code) · [Monitor projects with AI code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/monitor-projects-with-ai-code)
