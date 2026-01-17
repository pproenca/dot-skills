---
title: Limit Reference Links to One Level Deep
impact: MEDIUM-HIGH
impactDescription: prevents recursive context loading and confusion
tags: prog, references, links, depth
---

## Limit Reference Links to One Level Deep

SKILL.md can link to reference files, but those files should not link to further files. Multi-level chains (A→B→C→D) cause recursive loading, context explosion, and Claude losing track of where information came from.

**Incorrect (multi-level reference chains):**

```markdown
# SKILL.md
See [config.md](config.md) for configuration options.

# config.md
For authentication, see [auth.md](auth.md).

# auth.md
For OAuth details, see [oauth.md](oauth.md).

# oauth.md
For token refresh, see [tokens.md](tokens.md).
```

```text
# 4 levels deep
# Claude follows chain, loading each file
# Context fills with partially relevant content
# Original question context pushed out
```

**Correct (flat reference structure):**

```markdown
# SKILL.md
## Configuration
See [config.md](config.md) for all configuration options.

## Authentication
See [auth.md](auth.md) for authentication setup.

# config.md (NO further links)
## All Configuration Options
[Complete config documentation, no outgoing links]

# auth.md (NO further links)
## Authentication
[Complete auth documentation including OAuth and tokens]
```

```text
# Single level of references
# Each reference file is self-contained
# Claude loads exactly what's needed
```

**Reference file guidelines:**
- Self-contained: Include all relevant information
- No outgoing links: Don't reference other skill files
- Focused: One topic per reference file

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
