# Contributing Skills

This guide explains how to create and contribute skills to this repository.

## Skill Requirements

### Directory Structure

Each skill must be in its own directory under `skills/`:

```
skills/my-skill/
├── SKILL.md              # Required
├── scripts/              # Optional
├── references/           # Optional
└── assets/               # Optional
```

### SKILL.md Format

Every skill requires a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: my-skill
description: What this skill does and when to use it. Include keywords for discovery.
license: MIT
metadata:
  author: your-name
  version: "1.0.0"
---
```

#### Required Fields

| Field | Rules |
|-------|-------|
| `name` | Lowercase alphanumeric with hyphens, 1-64 chars, must match directory name |
| `description` | 1-1024 chars, describe what it does AND when to trigger it |

#### Optional Fields

| Field | Purpose |
|-------|---------|
| `license` | License identifier (e.g., MIT, Apache-2.0) |
| `compatibility` | Environment requirements (specific agents, system packages) |
| `metadata` | Custom key-value pairs (author, version, etc.) |
| `allowed-tools` | Pre-approved tools the skill may use |

### Naming Conventions

**Valid names:**
- `pdf-processing`
- `code-review`
- `data-analysis`

**Invalid names:**
- `PDF-Processing` (no uppercase)
- `-my-skill` (no leading hyphen)
- `my--skill` (no consecutive hyphens)

## Writing Effective Skills

### Description Best Practices

**Good:**
```yaml
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDFs or when user mentions document extraction.
```

**Poor:**
```yaml
description: Helps with PDFs.
```

### Content Guidelines

1. **Keep SKILL.md under 500 lines** - Move detailed content to `references/`
2. **Include clear triggers** - When should the agent activate this skill?
3. **Provide examples** - Show expected inputs and outputs
4. **Document edge cases** - Help agents handle unusual situations

### Optional Directories

#### `scripts/`
Executable code the agent can run:
- Keep scripts self-contained
- Document dependencies clearly
- Include helpful error messages

#### `references/`
Additional documentation loaded on demand:
- `REFERENCE.md` - Detailed technical reference
- Domain-specific files (e.g., `api.md`, `examples.md`)

#### `assets/`
Static resources:
- Templates
- Configuration files
- Data files

## Testing Your Skill

1. **Validate structure:**
   ```bash
   npx add-skill . --list
   ```

2. **Test installation:**
   ```bash
   npx add-skill . --skill my-skill
   ```

3. **Verify activation** in your preferred agent

## Submitting Skills

1. Create your skill in `skills/your-skill-name/`
2. Ensure `SKILL.md` has valid frontmatter
3. Test locally with `add-skill`
4. Submit a pull request

### PR Checklist

- [ ] Skill name follows naming conventions
- [ ] `SKILL.md` has required frontmatter fields
- [ ] Description includes trigger keywords
- [ ] Tested with `npx add-skill . --list`
- [ ] No sensitive data or credentials included
