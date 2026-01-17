---
title: Include User Trigger Keywords in Description
impact: CRITICAL
impactDescription: 2-4× improvement in automatic activation rate
tags: desc, triggers, keywords, natural-language
---

## Include User Trigger Keywords in Description

Add phrases users actually say when requesting the skill's functionality. Claude performs semantic matching between user input and skill descriptions. Missing keywords mean missed activations.

**Incorrect (technical terms only):**

```yaml
---
name: git-workflow
description: Manages git operations including commits, branches, and merges using best practices.
---
# User says "push my changes" - no match for "push"
# User says "create a PR" - no match for "PR" or "pull request"
```

**Correct (includes natural user phrases):**

```yaml
---
name: git-workflow
description: Manages git operations including commits, branches, and merges. Use when the user wants to commit changes, push code, create a PR, open a pull request, or review git history.
---
# "push my changes" matches "push code"
# "create a PR" matches "create a PR"
# "open pull request" matches "open a pull request"
```

**Keyword research technique:**
1. Write down 10 ways users might ask for this feature
2. Include synonyms (PR/pull request, commit/save changes)
3. Include command names users might type (/commit, /pr)
4. Test with real user queries

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
