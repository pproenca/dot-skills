# Agent Skills Collection

A collection of AI agent skills following the [Agent Skills](https://agentskills.io) open format. These skills extend AI coding agents with specialized capabilities and domain knowledge.

## Available Skills

| Skill | Description |
|-------|-------------|
| [example-skill](skills/example-skill) | A demonstration skill showing the Agent Skills format structure |

## Installation

Install skills using Vercel's [add-skill](https://github.com/vercel-labs/add-skill) CLI:

```bash
# Install all skills
npx add-skill pproenca/dot-skills

# List available skills
npx add-skill pproenca/dot-skills --list

# Install a specific skill
npx add-skill pproenca/dot-skills --skill <skill-name>

# Install globally (across all projects)
npx add-skill pproenca/dot-skills --global
```

### Supported Agents

Skills are installed to agent-specific directories:

| Agent | Installation Path |
|-------|------------------|
| Claude Code | `.claude/skills/<name>/` |
| Cursor | `.cursor/skills/<name>/` |
| Codex | `.codex/skills/<name>/` |
| OpenCode | `.opencode/skill/<name>/` |
| Antigravity | `.agent/skills/<name>/` |

## Creating Skills

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on creating new skills.

### Quick Start

1. Copy the template: `cp -r skills/.template skills/my-skill`
2. Rename directory to match your skill name (kebab-case)
3. Edit `SKILL.md` with your skill's frontmatter and instructions
4. Add scripts, references, or assets as needed
5. Test with `npx add-skill . --list`

## Skill Structure

```
skills/
├── my-skill/
│   ├── SKILL.md          # Required: Skill definition and instructions
│   ├── scripts/          # Optional: Executable scripts
│   ├── references/       # Optional: Additional documentation
│   └── assets/           # Optional: Static resources
├── .curated/             # Vetted, production-ready skills
├── .experimental/        # Work-in-progress skills
└── .template/            # Skill template for new skills
```

## License

MIT
