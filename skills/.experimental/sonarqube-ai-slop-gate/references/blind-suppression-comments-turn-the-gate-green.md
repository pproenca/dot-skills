---
title: Activate the NOSONAR tracking rules, which Sonar way leaves off
tags: blind, suppression, nosonar, rules
---

## Activate the NOSONAR tracking rules, which Sonar way leaves off

Every other blind spot in this category is accidental. This one is adversarial, and it is the one that matters most when the author is an agent.

Told to make the SonarQube gate pass, a coding agent has two options: fix the code, or suppress the issue. Suppression is faster, more reliable, and looks like a legitimate edit in a diff. A `// NOSONAR` comment or a `@SuppressWarnings("java:S3776")` annotation makes the issue disappear — not "marked as won't-fix" in the UI where a reviewer might notice, but genuinely absent from the analysis. `new_violations` drops to zero and the gate goes green with the defect untouched.

SonarQube ships rules that flag exactly this, and **they are not active in Sonar way**:

| Rule | What it tracks |
|---|---|
| `java:NoSonar`, `python:NoSonar`, `javascript:S1291`, `typescript:S1291` | *"Track uses of \"NOSONAR\" comments"* |
| `java:S1309` | *"Track uses of \"@SuppressWarnings\" annotations"* (parameter `listOfWarnings`) |

Because they are off by default, the default posture of a SonarQube installation is that suppression is silent. Turning them on converts every suppression into a visible issue, which — since it is a new issue on new code — fails the same `new_violations` condition the agent was trying to satisfy. That closes the loop: there is no longer a cheaper path than fixing the code.

```bash
# Activate suppression tracking in your profile. Without these, "make the gate
# pass" has a trivial solution that leaves every defect in place.
for r in java:NoSonar java:S1309 python:NoSonar typescript:S1291 javascript:S1291; do
  curl -sf -X POST -H "Authorization: Bearer $SONAR_ADMIN_TOKEN" \
    "$SONAR_HOST_URL/api/qualityprofiles/activate_rule" \
    --data-urlencode "key=checkout-profile" --data-urlencode "rule=$r"
done
```

Expect this to surface pre-existing suppressions across the codebase on first activation, many of them legitimate and deliberately placed years ago. Those are overall-code issues, not new-code issues, so they do not fail a new-code gate — but they will populate the issue list. Triage them once rather than deactivating the rule.

`java:S1309` takes a `listOfWarnings` parameter, so it can be narrowed to the suppressions worth blocking rather than all of them. Leaving it empty tracks every `@SuppressWarnings`, which is the right starting point when the concern is machine-generated code.

The same reasoning applies to any escape hatch the gate cannot see: analysis-scope exclusions added to `sonar-project.properties` are equally effective at making issues vanish, and equally invisible in the gate result. Review changes to that file as carefully as changes to the code (`scan-exclude-narrowly`).

Reference: [Managing quality profiles](https://docs.sonarsource.com/sonarqube-server/quality-standards-administration/managing-quality-profiles) · [Analysis scope](https://docs.sonarsource.com/sonarqube-server/project-administration/adjusting-analysis/setting-analysis-scope/advanced-exclusions)
