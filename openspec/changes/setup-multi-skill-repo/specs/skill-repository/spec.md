## ADDED Requirements

### Requirement: Skill Directory Structure
The repository SHALL organize skills in a `skills/` directory at the repository root, with each skill in its own subdirectory named after the skill.

#### Scenario: Standard skill location
- **WHEN** a user runs `npx add-skill <owner>/dot-skills --list`
- **THEN** the CLI discovers all skills in the `skills/` directory

#### Scenario: Individual skill structure
- **WHEN** a skill is created at `skills/<skill-name>/`
- **THEN** it MUST contain a valid `SKILL.md` file with proper frontmatter

### Requirement: SKILL.md Frontmatter Format
Each skill SHALL have a `SKILL.md` file containing YAML frontmatter with required fields `name` and `description`.

#### Scenario: Valid skill metadata
- **WHEN** a skill is defined with frontmatter
- **THEN** the `name` field MUST be lowercase alphanumeric with hyphens (1-64 chars)
- **THEN** the `name` field MUST match the parent directory name
- **THEN** the `description` field MUST describe what the skill does and when to use it (1-1024 chars)

#### Scenario: Optional metadata fields
- **WHEN** a skill requires additional configuration
- **THEN** optional fields `license`, `compatibility`, `metadata`, and `allowed-tools` MAY be included

### Requirement: Skill Installation via add-skill CLI
The repository SHALL support installation through Vercel's `add-skill` CLI utility.

#### Scenario: Install all skills
- **WHEN** a user runs `npx add-skill <owner>/dot-skills`
- **THEN** all skills in the `skills/` directory are available for installation
- **THEN** skills are installed to the appropriate agent-specific directory

#### Scenario: Install specific skill
- **WHEN** a user runs `npx add-skill <owner>/dot-skills --skill <name>`
- **THEN** only the specified skill is installed

#### Scenario: List available skills
- **WHEN** a user runs `npx add-skill <owner>/dot-skills --list`
- **THEN** all available skills are displayed with their names and descriptions

### Requirement: Multi-Agent Compatibility
Skills SHALL be installable across multiple supported AI coding agents.

#### Scenario: Agent-specific installation paths
- **WHEN** a skill is installed for Claude Code
- **THEN** it is placed in `.claude/skills/<name>/`
- **WHEN** a skill is installed for Cursor
- **THEN** it is placed in `.cursor/skills/<name>/`
- **WHEN** a skill is installed for Codex
- **THEN** it is placed in `.codex/skills/<name>/`
- **WHEN** a skill is installed for OpenCode
- **THEN** it is placed in `.opencode/skill/<name>/`

### Requirement: Skill Content Structure
Each skill SHALL place optional content in designated subdirectories for scripts, references, and assets when such content is needed.

#### Scenario: Optional directories
- **WHEN** a skill needs executable code
- **THEN** scripts SHALL be placed in `scripts/` subdirectory
- **WHEN** a skill needs reference documentation
- **THEN** references SHALL be placed in `references/` subdirectory
- **WHEN** a skill needs static resources
- **THEN** assets SHALL be placed in `assets/` subdirectory

### Requirement: Project Documentation
The repository SHALL include documentation for users and contributors.

#### Scenario: User documentation
- **WHEN** a user visits the repository
- **THEN** a root `README.md` MUST list available skills and installation instructions

#### Scenario: Contributor guidance
- **WHEN** a contributor wants to add a skill
- **THEN** documentation MUST explain the skill structure and authoring requirements
