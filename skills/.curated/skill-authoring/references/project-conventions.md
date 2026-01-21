---
title: dot-skills Project Conventions
impact: LOW
impactDescription: Documentation clarity for contributors and users
tags: meta, conventions, structure, documentation
---

## dot-skills Project Conventions

This project extends the base Anthropic skill specification with additional conventions for internal consistency and contributor workflows. Understanding these deviations helps when creating skills for different contexts.

### Standard Anthropic Skill Structure

The official Anthropic skill specification requires only:

```
skill-name/
├── SKILL.md          (required - main skill file)
├── scripts/          (optional - executable utilities)
├── references/       (optional - supporting documentation)
└── assets/           (optional - templates, examples)
```

### dot-skills Extended Structure

This project adds:

```
skill-name/
├── SKILL.md          (required - skill entry point)
├── metadata.json     (extension - project metadata)
├── references/
│   ├── _sections.md  (extension - category definitions)
│   └── *.md          (standard - rule files)
└── assets/templates/ (standard - templates)
```

**Extension files explained:**

| File | Purpose |
|------|---------|
| `metadata.json` | Version, organization, build metadata |
| `_sections.md` | Category definitions and ordering |

### When Creating Skills for Distribution

If creating a skill for distribution **outside** dot-skills:
- Follow only the standard Anthropic specification
- Include only `SKILL.md` and essential bundled resources
- Avoid `README.md`, `AGENTS.md`, and project-specific metadata

If creating a skill **within** dot-skills:
- Follow the extended structure for consistency
- Use the reference frontmatter schema with impact levels
- Include `_sections.md` for category organization

### Reference File Frontmatter Schema

dot-skills uses structured frontmatter in reference files:

```yaml
---
title: Rule Title Here
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact statement
tags: prefix, technique, related-concepts
---
```

This schema is project-specific and not required by the Anthropic specification.

Reference: [Anthropic Skill Creator](https://github.com/anthropics/claude-code/tree/main/skills)
