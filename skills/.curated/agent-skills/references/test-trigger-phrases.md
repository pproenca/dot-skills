---
title: Test Skill Activation with Real User Phrases
impact: MEDIUM
impactDescription: catches 60-80% of activation failures before deployment
tags: test, activation, phrases, validation
---

## Test Skill Activation with Real User Phrases

Before deploying a skill, test it with 10+ real user phrases to verify it activates correctly. Write down how users actually ask for this functionality, then verify each phrase triggers the skill.

**Incorrect (no activation testing):**

```yaml
---
name: api-docs
description: Generates API documentation
---
```

```text
# Deployed without testing
# User says "create swagger spec" - doesn't trigger
# User says "write OpenAPI" - doesn't trigger
# User says "document my endpoints" - doesn't trigger
# 3 of 4 common requests fail
```

**Correct (systematic phrase testing):**

```markdown
# Activation Test Plan

## Test Phrases (should trigger)
1. "generate API docs" ✓
2. "create swagger spec" ✗ - Added "Swagger" to description
3. "write OpenAPI definition" ✗ - Added "OpenAPI" to description
4. "document my endpoints" ✓
5. "create API reference" ✗ - Added "API reference" to description
6. "/api-docs" ✓
7. "help me document this REST API" ✓
8. "I need documentation for my API" ✓

## Negative Tests (should NOT trigger)
1. "what does this API do?" ✗ (should not trigger - this is a question)
2. "call the API" ✗ (should not trigger - this is execution)

## Updated Description
description: Generates API documentation, Swagger specs, OpenAPI definitions, and API reference pages. This skill should be used when creating API docs, documenting endpoints, or writing API reference.
```

**Testing process:**
1. Write 10+ phrases users might say
2. Test each in Claude Code
3. Note which fail to trigger
4. Update description with missing keywords
5. Retest until all pass

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
