---
title: Check the edition each AI feature needs before promising it
tags: plat, editions, ai-codefix, advanced-security
---

## Check the edition each AI feature needs before promising it

"SonarQube's AI features" is not one licensing tier, and the pieces sit further apart than the marketing suggests. Scoping a rollout as though buying one licence unlocks the whole AI story produces a plan that fails at procurement rather than at deployment.

The split as of July 2026:

| Feature | Minimum edition |
|---|---|
| Branch analysis, pull request analysis and decoration | Developer |
| Taint analysis (cross-function, cross-file) | Developer |
| **AI Code Assurance** (project flag, qualified gates, badge) | **Developer** |
| Portfolios | Enterprise |
| **AI CodeFix** (LLM-generated fix suggestions) | **Enterprise** |
| Advanced SAST and dependency risks | Enterprise **paid add-on** |
| Architecture analysis | any commercial edition, from 2026.4 |

Two of these routinely surprise. **AI Code Assurance is Developer-tier**, not Enterprise — the assumption that anything AI-branded is top-shelf leads teams to over-buy or, worse, to conclude the gate is out of reach and skip it. **AI CodeFix is Enterprise or Data Center only**: *"AI CodeFix is only available in SonarQube Server Enterprise and Data Center editions."* And **SonarQube Advanced Security is a separate SKU**, not a tier — *"an Enterprise product that extends SonarQube's capabilities"* — so an Enterprise licence alone does not include Advanced SAST or dependency-risk scanning.

If AI CodeFix is in scope, its provider configuration is worth knowing early because it changes the network story. It is model-agnostic since 2026.2 and accepts a Sonar-hosted OpenAI model, Azure OpenAI, AWS Bedrock, or any OpenAI-compatible self-hosted gateway (*"for example, Ollama, LiteLLM, or vLLM"*) configured with an endpoint and model ID. Contrary to the reasonable assumption that a vendor AI feature must phone home, a fully self-hosted configuration does not: *"For fully self-hosted SonarQube Server configurations, AI CodeFix is designed to operate without outbound internet access."* The instance needs to reach your LLM endpoint and nothing else.

```bash
# Confirm what the running instance is actually licensed for before designing
# around a feature. Server ID, edition, and licence status in one call.
curl -s -H "Authorization: Bearer $SONAR_TOKEN" \
  "$SONAR_HOST_URL/api/system/info" | jq '.System | {Edition, Version, "Server ID"}'
```

Air-gapped deployments should note the inverse case: the *Sonar-hosted* model option does require reaching `api.sonarqube.io`, so it is the one provider choice that breaks an isolated network.

Reference: [Enable AI CodeFix](https://docs.sonarsource.com/sonarqube-server/instance-administration/ai-features/enable-ai-codefix) · [Advanced Security introduction](https://docs.sonarsource.com/sonarqube-server/advanced-security/introduction) · [Plans and pricing](https://www.sonarsource.com/plans-and-pricing/sonarqube/)
