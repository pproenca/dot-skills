---
title: Write Descriptions in Third Person
impact: CRITICAL
impactDescription: 20-40% improvement in skill selection accuracy
tags: desc, voice, grammar, consistency
---

## Write Descriptions in Third Person

Use "This skill should be used when..." rather than "Use this skill when...". Third person helps Claude reason about skill applicability as an external resource rather than a direct command.

**Incorrect (imperative voice):**

```yaml
---
name: code-review
description: Use this skill to review code for security issues. Run it on PRs before merging.
---
# Imperative voice reads as instruction to Claude
# Mixes skill description with usage commands
# Less clear when skill applies vs. direct instructions
```

**Correct (third person declarative):**

```yaml
---
name: code-review
description: Reviews code for security vulnerabilities, performance issues, and style violations. This skill should be used when reviewing PRs, auditing codebases, or checking for bugs before deployment.
---
# Third person describes what skill does
# Clear separation: what it does vs. when to use it
# Claude reasons about applicability more accurately
```

**Pattern to follow:**
1. First sentence: What the skill does (verb phrase)
2. Second sentence: "This skill should be used when..." (triggers)

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
