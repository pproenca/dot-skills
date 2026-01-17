---
title: Reference Workflow Stages in Description
impact: HIGH
impactDescription: 25-40% improvement in workflow-triggered activations
tags: trigger, workflow, stages, context
---

## Reference Workflow Stages in Description

Mention the workflow stage where your skill applies. Users often describe tasks in terms of workflow position ("before deploying", "after writing tests"). Stage references improve activation timing.

**Incorrect (no workflow context):**

```yaml
---
name: code-linter
description: Checks code for style issues and potential bugs.
---
```

```text
# User says "before I commit" - skill doesn't know
# User says "after making changes" - skill doesn't know
# Workflow timing unclear
```

**Correct (workflow stages referenced):**

```yaml
---
name: code-linter
description: Checks code for style issues and potential bugs. This skill should be used before committing changes, during code review, or when preparing a PR for merge.
---
```

```text
# User says "before I commit" - skill activates
# User says "review before merging" - skill activates
# Workflow-aware activation
```

**Common workflow stage phrases:**
| Stage | Trigger phrases |
|-------|-----------------|
| Start | "when starting", "before beginning", "to set up" |
| During | "while working on", "during development" |
| Before commit | "before committing", "pre-commit", "ready to save" |
| Review | "during review", "when reviewing", "checking the PR" |
| Deploy | "before deploying", "ready to ship", "going to production" |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
