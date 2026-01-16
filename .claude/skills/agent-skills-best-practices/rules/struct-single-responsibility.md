---
title: One Skill per Domain
impact: HIGH
impactDescription: 2-3× improvement in activation precision
tags: struct, separation, modularity, design
---

## One Skill per Domain

Each skill should handle one coherent domain. Multi-purpose skills have vague descriptions that trigger incorrectly and grow unwieldy over time. Split into focused skills.

**Incorrect (kitchen-sink skill):**

```yaml
---
name: developer-tools
description: Helps with development tasks including code review, testing, deployment, documentation, and database management.
---
```

```markdown
# Developer Tools

## Code Review
[200 lines]

## Testing
[200 lines]

## Deployment
[200 lines]

## Documentation
[200 lines]

## Database
[200 lines]
```

```text
# Description triggers on any dev task
# 1000+ lines loaded when any feature needed
# Changes to one domain risk breaking others
```

**Correct (focused skills per domain):**

```text
skills/
├── code-review/SKILL.md     # 150 lines
├── test-runner/SKILL.md     # 150 lines
├── deployment/SKILL.md      # 150 lines
├── doc-generator/SKILL.md   # 150 lines
└── db-migration/SKILL.md    # 150 lines
```

Each with focused description:

```yaml
---
name: code-review
description: Reviews code for security vulnerabilities, performance issues, and style violations. This skill should be used when reviewing PRs or auditing code.
---
```

```text
# Each skill loads only when needed
# Precise activation for each domain
# Independent evolution and maintenance
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
