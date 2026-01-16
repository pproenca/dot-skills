# Tasks: Setup Multi-Skill Repository

## 1. Repository Structure Setup
- [x] 1.1 Create `skills/` directory as the primary skill container
- [x] 1.2 Create `skills/.curated/` directory for vetted skills (optional, future use)
- [x] 1.3 Create `skills/.experimental/` directory for WIP skills (optional, future use)
- [x] 1.4 Create `.gitkeep` files to preserve empty directories

## 2. Documentation
- [x] 2.1 Create root `README.md` with:
  - Project description
  - Available skills listing
  - Installation instructions (`npx add-skill` commands)
  - Skill development guidelines
  - License information
- [x] 2.2 Create `CONTRIBUTING.md` with skill authoring guidelines
- [x] 2.3 Create skill template in `skills/.template/` showing required structure

## 3. Skill Template Structure
- [x] 3.1 Create `skills/.template/SKILL.md` with frontmatter example
- [x] 3.2 Create `skills/.template/scripts/.gitkeep` placeholder
- [x] 3.3 Create `skills/.template/references/.gitkeep` placeholder
- [x] 3.4 Document SKILL.md frontmatter requirements:
  - `name`: lowercase, hyphenated, matches directory name
  - `description`: what skill does + when to use it
  - Optional: `license`, `compatibility`, `metadata`, `allowed-tools`

## 4. First Skill Setup (Example)
- [x] 4.1 Create first skill directory `skills/example-skill/`
- [x] 4.2 Create `SKILL.md` with proper frontmatter
- [x] 4.3 Add skill-specific content (instructions, scripts, references as needed)
- [x] 4.4 Validate skill with `skills-ref validate` (if available)

## 5. Project Configuration
- [x] 5.1 Update `openspec/project.md` with project conventions for skill development
- [x] 5.2 Add skill naming conventions (kebab-case, 1-64 chars)
- [x] 5.3 Document skill directory structure requirements

## 6. Validation
- [ ] 6.1 Test installation flow: `npx add-skill <repo> --list`
- [ ] 6.2 Test selective install: `npx add-skill <repo> --skill <name>`
- [ ] 6.3 Verify skill activation in supported agents (Claude Code, Cursor, etc.)

## Dependencies
- Tasks 1.x can run in parallel
- Task 2.1 depends on knowing what skills exist (can be templated initially)
- Task 4.x depends on tasks 1.x and 3.x
- Task 6.x depends on all prior tasks and repository being pushed to GitHub
