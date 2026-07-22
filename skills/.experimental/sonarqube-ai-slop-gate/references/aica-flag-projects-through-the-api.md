---
title: Set the AI-code flag through the Web API, not an analysis property
tags: aica, web-api, project-settings, provisioning
---

## Set the AI-code flag through the Web API, not an analysis property

Everything else about a SonarQube project is configurable from `sonar-project.properties`, so the natural move is to reach for a `sonar.ai.*` property and put the AI-code flag in version control alongside the rest of the scanner configuration. No such property exists. The flag is **project state on the server**, not analysis input, and a scanner invocation cannot set it.

This matters because AI Code Assurance does nothing until the flag is on. An instance can have the right gate, the right profile, and a perfectly configured scanner, and still report *"AI Code Assurance is off"* on every project — because the one setting that activates the feature was never applied. The gate still runs; it simply grants no assurance status and shows no badge.

Two supported paths. In the UI: *Your project* > **Project settings** > **AI-generated code** > activate **"Contains AI-generated code"**. For anything repeatable — provisioning a new repository, backfilling an existing fleet — use the Web API:

```bash
AUTH=(-H "Authorization: Bearer $SONAR_ADMIN_TOKEN")

# Mark a project as containing AI-generated code, then bind an AI-qualified gate.
# Both calls are idempotent; run them from project-provisioning automation.
curl -sf -X POST "${AUTH[@]}" "$SONAR_HOST_URL/api/projects/set_contains_ai_code" \
  -d 'contains_ai_code=true&project=checkout-service'

# Resolve the gate by capability, not by name — the name is case-sensitive and
# has changed across versions ("Sonar way for AI code", later "… (legacy)").
GATE=$(curl -s "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/list" \
  | jq -r '[.qualitygates[] | select(.isAiCodeSupported) | .name][0]')

curl -sf -X POST "${AUTH[@]}" "$SONAR_HOST_URL/api/qualitygates/select" \
  --data-urlencode "gateName=$GATE" -d 'projectKey=checkout-service'
```

Because the flag lives on the server rather than in the repository, it drifts. A project created by someone clicking through the UI, or restored from a backup, or provisioned by a path that skips the call, silently reverts to unflagged. Treat `set_contains_ai_code` as part of project creation the same way you treat permission templates — asserted every run, not set once.

The token needs administration rights on the project, which is a different token from the project analysis token CI uses to run scans (see `scan-use-project-analysis-tokens`). Keep them separate: the provisioning token carries administration rights and belongs in the provisioning pipeline, not in every repository's CI secrets.

Reference: [Set up AI Code Assurance](https://docs.sonarsource.com/sonarqube-server/project-administration/ai-features/set-up-ai-code-assurance) · [Monitor projects with AI code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/monitor-projects-with-ai-code)
