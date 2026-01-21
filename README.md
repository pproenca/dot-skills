# Agent Skills Collection

A collection of AI agent skills following the [Agent Skills](https://agentskills.io) open format. These skills extend AI coding agents with specialized capabilities and domain knowledge.

## Available Skills

<!-- SKILLS-TABLE:START -->
### Curated Skills

| Skill | Description |
|-------|-------------|
| [debug](skills/.curated/debug) | Comprehensive debugging methodology for finding and fixing bugs |
| [expo](skills/.curated/expo) | Expo React Native performance optimization guidelines |
| [feature-arch](skills/.curated/feature-arch) | React feature-based architecture guidelines for scalable applications |
| [msw](skills/.curated/msw) | MSW (Mock Service Worker) best practices for API mocking in tests |
| [mui-base](skills/.curated/mui-base) | MUI Base UI style guidelines for building headless React component libraries |
| [nextjs](skills/.curated/nextjs) | Next.js 16 App Router performance optimization guidelines |
| [nuqs](skills/.curated/nuqs) | nuqs (type-safe URL query state) best practices for Next.js applications |
| [playwright](skills/.curated/playwright) | Playwright testing best practices for Next.js applications |
| [python](skills/.curated/python) | Python 3.11+ performance optimization guidelines |
| [react-hook-form](skills/.curated/react-hook-form) | React Hook Form performance optimization for client-side form validation using useForm,.. |
| [react](skills/.curated/react) | React 19 performance optimization guidelines for concurrent rendering, Server Components,.. |
| [refactor](skills/.curated/refactor) | Code refactoring best practices based on Martin Fowler's catalog and Clean Code principles |
| [rust](skills/.curated/rust) | Rust performance optimization guidelines |
| [shadcn](skills/.curated/shadcn) | shadcn/ui component library best practices and patterns |
| [skill-authoring](skills/.curated/skill-authoring) | AI agent skill design and development best practices |
| [tailwind](skills/.curated/tailwind) | Tailwind CSS v4 performance optimization and best practices guidelines |
| [tanstack-query](skills/.curated/tanstack-query) | TanStack Query v5 performance optimization for data fetching, caching, mutations, and query patterns |
| [tdd](skills/.curated/tdd) | Test-Driven Development methodology and red-green-refactor workflow |
| [terminal-ui](skills/.curated/terminal-ui) | Terminal User Interface (TUI) performance and UX guidelines for TypeScript applications using.. |
| [typescript](skills/.curated/typescript) | This skill should be used when the user asks to "optimize TypeScript performance", "speed up tsc.. |
| [ui-design](skills/.curated/ui-design) | UI/UX and frontend design best practices guidelines |
| [vitest](skills/.curated/vitest) | Vitest testing framework patterns for test setup, async testing, mocking with vi.*, snapshots,.. |
| [zod](skills/.curated/zod) | Zod schema validation best practices for type safety, parsing, and error handling |

### Experimental Skills

| Skill | Description |
|-------|-------------|
| [chrome-ext](skills/.experimental/chrome-ext) | Chrome Extensions (Manifest V3) performance optimization guidelines |
| [codemod](skills/.experimental/codemod) | Codemod (JSSG, ast-grep, workflows) best practices for writing efficient, safe, and maintainable.. |
| [feature-spec](skills/.experimental/feature-spec) | Feature specification and planning guidelines for software engineers |
| [humanize](skills/.experimental/humanize) | Remove signs of AI-generated writing from text |
| [js-google](skills/.experimental/js-google) | JavaScript style and best practices based on Google's official JavaScript Style Guide |
| [jscodeshift](skills/.experimental/jscodeshift) | jscodeshift codemod development best practices from Facebook/Meta |
| [orval](skills/.experimental/orval) | Orval OpenAPI TypeScript client generation best practices |
| [pulumi](skills/.experimental/pulumi) | Pulumi infrastructure as code performance and reliability guidelines |
| [rust-idioms](skills/.experimental/rust-idioms) | Rust refactoring and idiomatic patterns guidelines from the Rust Community |
| [shell](skills/.experimental/shell) | Shell scripting best practices for writing safe, portable, and maintainable bash/sh scripts |
| [ts-google](skills/.experimental/ts-google) | Google TypeScript style guide for writing clean, consistent, type-safe code |
| [vhs](skills/.experimental/vhs) | VHS terminal recording best practices from Charmbracelet |
<!-- SKILLS-TABLE:END -->

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
2. Rename the template file: `mv skills/my-skill/SKILL.md.template skills/my-skill/SKILL.md`
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
└── .template/            # Skill template (SKILL.md.template)
```

## License

MIT
