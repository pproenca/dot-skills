---
title: Label AI projects deliberately rather than relying on autodetection
tags: aica, autodetection, deprecation, copilot
---

## Label AI projects deliberately rather than relying on autodetection

"SonarQube can autodetect AI-generated code" is true, was never as broad as it sounds, and is on its way out. Designing a rollout around it produces a setup that covers a fraction of the fleet today and stops working entirely at some future release.

Three constraints, all documented. It is **GitHub Copilot only** — *"SonarQube Server can autodetect AI-generated code in projects using GitHub Copilot."* It requires a bound GitHub organisation with Copilot Business and a GitHub App granted read-only Copilot permission, so a repository whose AI code came from any other assistant is invisible to it. And it is **deprecated as of the 2026.1 LTA**, with the release notes stating: *"Autodetect AI-Generated Code has been deprecated"*, and the feature page adding *"still available in SonarQube Server 2026.1 LTA and will be removed in a future release."*

Sonar's stated reasoning is the useful part, because it tells you what the durable design looks like: *"Sonar will adjust the AI Code Assurance offering to adapt to the industry changes with high AI adoption."* The premise that AI-authored code is a detectable minority worth flagging automatically has stopped holding. When most changes in a repository have some assistant involvement, per-project detection buys nothing that a blanket policy does not.

So label deliberately, and label broadly. For most organisations in 2026 the honest answer to "which projects contain AI-generated code" is "all of them", which makes this a provisioning default rather than a per-project judgement:

```bash
# Flag every project as containing AI code, as part of fleet provisioning.
# Cheaper and more accurate than auditing which repositories used an assistant.
curl -s -H "Authorization: Bearer $SONAR_ADMIN_TOKEN" \
  "$SONAR_HOST_URL/api/projects/search?ps=500" \
  | jq -r '.components[].key' \
  | while read -r key; do
      curl -sf -X POST -H "Authorization: Bearer $SONAR_ADMIN_TOKEN" \
        "$SONAR_HOST_URL/api/projects/set_contains_ai_code?contains_ai_code=true&project=$key" \
        && echo "flagged $key"
    done
```

Flagging everything has a real cost worth naming: every project then carries the stricter AI-qualified gate, including the overall-code conditions described in `aica-the-builtin-ai-gate-is-lenient`. On a legacy codebase those overall-code conditions can fail on debt that predates any assistant. That is a reason to stage the rollout, not a reason to hunt for which repositories an assistant touched.

Reference: [Autodetect AI code](https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/autodetect-ai-code) · [Release notes](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/release-notes)
