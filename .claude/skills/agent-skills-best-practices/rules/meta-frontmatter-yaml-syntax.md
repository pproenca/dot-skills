---
title: Use Valid YAML Frontmatter Syntax
impact: CRITICAL
impactDescription: prevents 100% skill failures from syntax errors
tags: meta, yaml, frontmatter, syntax
---

## Use Valid YAML Frontmatter Syntax

YAML frontmatter must start on line 1 with `---`, use spaces (not tabs), and close with `---`. Invalid syntax causes the entire skill to fail silently—no error message, just non-functional skill.

**Incorrect (tabs instead of spaces cause parsing failure):**

```yaml
---
name:	pdf-processing
description:	Processes PDF files
---
# Tab characters (\t) instead of spaces
# YAML parser fails silently
# Skill never loads despite being in correct directory
```

**Correct (spaces after colons, proper delimiters):**

```yaml
---
name: pdf-processing
description: Processes PDF files for text extraction and form filling.
---
# Space after colon, no tabs
# Valid YAML parses correctly
```

**Common syntax errors:**
- Using tabs instead of spaces
- Missing space after colon (`name:value` vs `name: value`)
- Unescaped special characters in strings
- Missing closing `---` delimiter
- Frontmatter not starting on line 1

**Validation command:**

```bash
# Check YAML syntax before committing
head -20 SKILL.md | python -c "import yaml, sys; yaml.safe_load(sys.stdin)"
```

Reference: [YAML 1.2 Specification](https://yaml.org/spec/1.2.2/)
