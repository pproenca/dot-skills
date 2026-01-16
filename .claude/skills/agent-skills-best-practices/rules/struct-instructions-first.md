---
title: Put Critical Instructions Early in Content
impact: HIGH
impactDescription: prevents critical rule violations from truncation
tags: struct, priority, ordering, truncation
---

## Put Critical Instructions Early in Content

Place the most important instructions in the first 500 lines of SKILL.md. Context windows can truncate long documents, and Claude weighs earlier content more heavily. Burying critical instructions causes inconsistent behavior.

**Incorrect (critical rules buried at the end):**

```markdown
# Code Generator

## Introduction
This skill generates code...

## History
The evolution of code generation...

## Supported Languages
We support Python, JavaScript, TypeScript...

## Examples
Here are 50 examples...

## IMPORTANT: Security Rules
Never generate code that accesses /etc/passwd...
Never include API keys in generated code...
```

```text
# Security rules at line 800+
# May be truncated or deprioritized
# Critical rules applied inconsistently
```

**Correct (critical rules early, details later):**

```markdown
# Code Generator

## Security Rules (MUST FOLLOW)
- Never generate code that accesses system files
- Never include credentials or API keys
- Always sanitize user inputs in generated code

## Quick Start
Generate code by describing what you need...

## Supported Languages
Python, JavaScript, TypeScript...

## Detailed Examples
[Examples can safely be truncated]
```

```text
# Security rules in first 20 lines
# Always loaded and prioritized
# Examples safely truncated if needed
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
