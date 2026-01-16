# Change: Setup Multi-Skill Repository with Vercel Add-Skill Support

## Why

This project needs to serve as a centralized repository for multiple AI agent skills that users can install using Vercel's `add-skill` CLI utility (`npx add-skill`). Following the established Agent Skills format from agentskills.io enables:

- **Discoverability**: Skills follow a standardized format that AI agents can automatically detect
- **Easy installation**: Users install skills with a single command: `npx add-skill <owner>/dot-skills`
- **Multi-agent support**: Skills work across Claude Code, Cursor, Codex, OpenCode, and Antigravity
- **Scalability**: Structure supports adding new skills over time without restructuring

## What Changes

### Repository Structure
- **ADDED**: `skills/` directory as the primary location for all skill modules
- **ADDED**: Root `README.md` documenting available skills and installation instructions
- **ADDED**: Standard skill structure template with `SKILL.md`, optional `scripts/`, `references/`, and `assets/` directories
- **ADDED**: Project-level configuration following vercel-labs/agent-skills patterns

### Skill Organization
- Each skill lives in `skills/<skill-name>/` with its own `SKILL.md` frontmatter
- Skills are self-contained and can be installed individually via `--skill` flag
- Supports curated, experimental, and system skill categories (`.curated/`, `.experimental/`, `.system/`)

### Installation Flow
- Primary: `npx add-skill <owner>/dot-skills` installs all skills
- Selective: `npx add-skill <owner>/dot-skills --skill <name>` installs specific skill
- List: `npx add-skill <owner>/dot-skills --list` shows available skills

## Impact

- **Affected specs**: New `skill-repository` capability
- **Affected code**: Root directory structure, new `skills/` directory
- **Dependencies**: Requires adherence to Agent Skills specification (agentskills.io/specification)
- **Breaking changes**: None (greenfield setup)

## References

- Agent Skills Specification: https://agentskills.io/specification
- Vercel add-skill CLI: https://github.com/vercel-labs/add-skill
- Reference implementation: https://github.com/vercel-labs/agent-skills
