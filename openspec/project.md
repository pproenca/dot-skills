# Project Context

## Purpose

A collection of AI agent skills following the [Agent Skills](https://agentskills.io) open format. This repository hosts multiple skills that users can install via Vercel's `add-skill` CLI utility to extend AI coding agents with specialized capabilities.

## Tech Stack

- Markdown (SKILL.md files with YAML frontmatter)
- Shell scripts (optional skill scripts)
- Python/JavaScript (optional skill scripts)

## Project Conventions

### Skill Naming

- Use kebab-case: `my-skill-name`
- Lowercase alphanumeric with hyphens only
- 1-64 characters
- No leading, trailing, or consecutive hyphens
- Directory name MUST match the `name` field in SKILL.md frontmatter

### Skill Structure

```
skills/<skill-name>/
├── SKILL.md              # Required: Frontmatter + instructions
├── scripts/              # Optional: Executable code
├── references/           # Optional: Additional documentation
└── assets/               # Optional: Static resources
```

### SKILL.md Requirements

Required frontmatter fields:
- `name`: Must match directory name
- `description`: What it does + when to trigger (1-1024 chars)

Optional frontmatter fields:
- `license`: License identifier
- `compatibility`: Environment requirements
- `metadata`: Custom key-value pairs (author, version)
- `allowed-tools`: Pre-approved tools

### Content Guidelines

- Keep SKILL.md under 500 lines
- Move detailed reference material to `references/`
- Include clear trigger keywords in description
- Provide usage examples

## Architecture Patterns

Skills are self-contained modules that:
1. Define agent capabilities via SKILL.md
2. Optionally include executable scripts
3. Optionally include reference documentation
4. Are discovered and installed by `add-skill` CLI

## Testing Strategy

- Validate with `npx add-skill . --list`
- Test installation with `npx add-skill . --skill <name>`
- Verify activation in target agents (Claude Code, Cursor, etc.)

## Git Workflow

- Main branch: `main`
- Feature branches for new skills
- PR required for merging

## Domain Context

This project follows the Agent Skills specification from agentskills.io. Skills are portable across multiple AI coding agents including Claude Code, Cursor, Codex, OpenCode, and Antigravity.

## External Dependencies

- [Agent Skills Specification](https://agentskills.io/specification)
- [Vercel add-skill CLI](https://github.com/vercel-labs/add-skill)
