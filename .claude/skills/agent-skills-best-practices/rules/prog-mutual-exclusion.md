---
title: Separate Mutually Exclusive Contexts
impact: MEDIUM-HIGH
impactDescription: prevents loading irrelevant content for user's scenario
tags: prog, mutual-exclusion, context, separation
---

## Separate Mutually Exclusive Contexts

When a skill supports multiple distinct scenarios that never overlap, put each in its own reference file. This prevents loading Python documentation when the user needs JavaScript, or AWS docs when they need Azure.

**Incorrect (all scenarios in one file):**

```markdown
# Cloud Deployment

## AWS Deployment
[200 lines of AWS-specific instructions]

## Azure Deployment
[200 lines of Azure-specific instructions]

## GCP Deployment
[200 lines of GCP-specific instructions]
```

```text
# User deploys to AWS
# All 600 lines loaded
# 400 lines (Azure + GCP) completely irrelevant
# Wastes ~800 tokens
```

**Correct (separate files per scenario):**

```text
cloud-deployment/
├── SKILL.md
├── aws.md
├── azure.md
└── gcp.md
```

```markdown
# SKILL.md

## Deployment Instructions

1. Determine target cloud provider
2. Load provider-specific guide:
   - AWS: [aws.md](aws.md)
   - Azure: [azure.md](azure.md)
   - GCP: [gcp.md](gcp.md)
3. Follow provider-specific steps
```

```text
# User deploys to AWS
# Only aws.md loaded (200 lines)
# Zero irrelevant content
# Saves ~400 tokens
```

**Mutual exclusion patterns:**
| Domain | Mutually Exclusive Options |
|--------|----------------------------|
| Languages | Python vs JavaScript vs Go |
| Clouds | AWS vs Azure vs GCP |
| Databases | PostgreSQL vs MySQL vs MongoDB |
| Frameworks | React vs Vue vs Angular |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
