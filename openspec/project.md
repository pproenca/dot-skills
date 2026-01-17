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
skills/
├── .curated/             # Vetted, production-ready skills
│   └── <skill-name>/
├── .experimental/        # Work-in-progress skills
│   └── <skill-name>/
└── .template/            # Skill template (SKILL.md.template)

# Per-skill structure:
<skill-name>/
├── SKILL.md              # Required: Frontmatter + summary instructions
├── AGENTS.md             # Optional: Full compiled rules document
├── README.md             # Optional: Human-readable documentation
├── CHANGELOG.md          # Optional: Version history
├── metadata.json         # Optional: Structured metadata
├── scripts/              # Optional: Executable code
├── references/           # Optional: Individual rule/reference files
│   └── _sections.md      # Category structure and impact levels
└── assets/               # Optional: Static resources
    └── templates/        # Templates for rules or code
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
- Move detailed reference material to `references/` (one file per rule)
- Include clear trigger keywords in description (file extensions, error codes, CLI commands)
- Provide a "When to Apply" section with usage contexts
- Include "Rule Categories by Priority" table with impact levels
- Use rule prefixes for namespacing (e.g., `type-`, `async-`, `module-`)
- Compile full rules into AGENTS.md for agents that need expanded context

## Architecture Patterns

Skills are self-contained modules that:
1. Define agent capabilities via SKILL.md with trigger-rich descriptions
2. Organize rules by priority/category for progressive disclosure
3. Optionally include executable scripts for automation
4. Optionally include detailed reference files for on-demand loading
5. Are discovered and installed by `add-skill` CLI

### Skill Maturity Levels

- **`.curated/`**: Production-ready skills with 40+ rules, comprehensive coverage
- **`.experimental/`**: Work-in-progress skills, may have incomplete coverage

### Rule Organization Pattern

Best-practice skills follow a consistent structure:
1. SKILL.md: Summary with quick reference (trigger keywords, rule index)
2. references/: Individual rule files with detailed explanations and examples
3. AGENTS.md: Compiled full document for agents needing expanded context
4. metadata.json: Structured metadata for tooling

## Testing Strategy

- Validate with `npx add-skill . --list`
- Test installation with `npx add-skill . --skill <name>`
- Verify activation in target agents (Claude Code, Cursor, etc.)

## Git Workflow

- Main branch: `master`
- Feature branches for new skills
- PR required for merging

## Domain Context

This project follows the Agent Skills specification from agentskills.io. Skills are portable across multiple AI coding agents including Claude Code, Cursor, Codex, OpenCode, and Antigravity.

### Current Skill Portfolio

**Curated (Production-Ready):**
- **Core TypeScript/React**: `typescript`, `react-19`, `nextjs-16-app-router`
- **UI Libraries**: `shadcn-ui`, `frontend-design`, `terminal-ui`
- **Forms & Validation**: `react-hook-form`, `zod`
- **Data Fetching**: `tanstack-query`, `nuqs`
- **Testing**: `test-vitest`, `test-playwright`, `test-tdd`, `test-msw`
- **Development Practices**: `debugging`, `refactoring`, `feature-architecture`
- **Meta**: `agent-skills` (skill authoring guidelines)
- **Mobile**: `expo`

**Experimental (Work-in-Progress):**
- `feature-spec`, `orval`, `pulumi`

### Technology Focus

Primary focus on modern React/TypeScript web development ecosystem with emphasis on:
- Type-safe development patterns
- Testing best practices (unit, integration, E2E)
- Performance optimization
- Clean architecture and refactoring

## External Dependencies

- [Agent Skills Specification](https://agentskills.io/specification)
- [Vercel add-skill CLI](https://github.com/vercel-labs/add-skill)
