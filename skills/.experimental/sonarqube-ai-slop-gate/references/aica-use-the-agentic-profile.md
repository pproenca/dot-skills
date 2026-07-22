---
title: Use the Sonar agentic AI profile where it exists, Sonar way elsewhere
tags: aica, quality-profiles, agentic, rules
---

## Use the Sonar agentic AI profile where it exists, Sonar way elsewhere

Setting up an AI-code gate invites a hunt for AI-specific rules — a tag to filter on, a ruleset that detects assistant-authored patterns. For AI Code Assurance itself there is none. The recommended profile is the ordinary one: *"The Sonar way quality profile is recommended for projects containing AI-generated code."* The AI-specific artifact is the **gate**, not the rules, and the profile choice does not affect assurance status: *"Choosing a different quality profile will not affect your AI Code Assurance status."*

That changed partially in **2026.3**, which added a built-in profile aimed squarely at this problem: *"A new built-in quality profile, Sonar agentic AI, is now available for Java, JavaScript/TypeScript, and Python."* Its stated design target is the failure modes this skill exists to catch — *"The profile selects rules tuned for code produced by AI coding agents, focusing on the failure modes and recurring patterns most often introduced by agentic workflows."*

So the profile decision is per-language rather than global: **Sonar agentic AI** for Java, JS/TS, and Python; **Sonar way** for everything else, because no agentic profile exists for it.

```bash
# Per-language assignment. A project analyzed in Go or C# keeps Sonar way —
# there is no agentic profile for those languages to fall back to.
for lang in java js ts py; do
  curl -sf -X POST -H "Authorization: Bearer $SONAR_ADMIN_TOKEN" \
    "$SONAR_HOST_URL/api/qualityprofiles/add_project" \
    --data-urlencode "language=$lang" \
    --data-urlencode "qualityProfile=Sonar agentic AI" \
    --data-urlencode "project=checkout-service"
done
```

Whichever profile applies, the rules that matter most for assistant-generated code are the ones flagging output nobody read: unused locals and unnecessary imports (`S1481`, `S1128`), commented-out code (`S125`), ignored exceptions (`S2486`, or `S108` for empty blocks in Java), duplicated string literals (`S1192`, default threshold 3), and cognitive complexity (`S3776`, default threshold 15). These are active in Sonar way already — the value in naming them is that they are the levers to tune, and `S3776` in particular is the only route to gating complexity on new code (`blind-no-new-code-complexity-metric`).

Two spelling traps if you script rule activation: the `S3776` parameter is `Threshold` for Java but `threshold` for TypeScript and Python, and `java:S2486` does not exist — Java's empty-catch coverage is `java:S108`.

Reference: [Quality profiles for AI code](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/ai-code-assurance/quality-profiles-for-ai-code) · [Release notes](https://docs.sonarsource.com/sonarqube-server/server-update-and-maintenance/release-notes)
