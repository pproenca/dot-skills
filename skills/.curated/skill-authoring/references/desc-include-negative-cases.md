---
title: Include Negative Cases for Precision
impact: HIGH
impactDescription: reduces false positive activations by 40-60%
tags: desc, precision, negative-cases, disambiguation
---

## Include Negative Cases for Precision

For skills with narrow scope, mention what the skill does NOT do. This prevents Claude from activating the skill for superficially similar but actually different requests.

**Incorrect (no boundaries, over-activates):**

```yaml
---
name: unit-test-generator
description: Generates tests for code. This skill should be used when the user wants to test their code.
---
# "test their code" matches integration tests
# "test their code" matches E2E tests
# "test their code" matches manual testing requests
# Skill activates but can't help with these cases
```

**Correct (explicit boundaries prevent wrong activation):**

```yaml
---
name: unit-test-generator
description: Generates unit tests for individual functions with mocks and assertions. This skill should be used when writing unit tests or testing isolated functions. This skill does NOT handle integration tests, E2E tests, or load testing.
---
# Clear positive: "unit tests", "isolated functions"
# Clear negative: "does NOT handle integration tests"
# User asking for E2E tests won't trigger this skill
```

**When to add negative cases:**
- Skill name suggests broader capability than actual scope
- Common confusion with related but different skills
- Frequently asked to do things outside scope

**Pattern:**

```text
This skill does NOT {out-of-scope action 1} or {out-of-scope action 2}.
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
