---
name: agent-skills-best-practices
description: AI agent skill design and development best practices. This skill should be used when creating, reviewing, or refactoring Claude Code skills, MCP tools, or LLM agent capabilities. Triggers on tasks involving skill metadata, SKILL.md files, tool descriptions, progressive disclosure, trigger optimization, or agent skill testing.
---

# Anthropic Community Agent Skills Best Practices

Comprehensive design and development guide for AI agent skills, including Claude Code skills and MCP tools. Contains 46 rules across 8 categories, prioritized by impact to guide skill creation, review, and optimization. Validated against the official [skills-ref library](https://github.com/agentskills/agentskills/tree/main/skills-ref) specification.

## When to Apply

Reference these guidelines when:
- Creating new Claude Code skills or MCP tools
- Writing SKILL.md metadata and descriptions
- Optimizing skill trigger reliability
- Structuring skill content for progressive disclosure
- Testing skill activation and behavior
- Validating skills against skills-ref specification

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Skill Metadata Design | CRITICAL | `meta-` |
| 2 | Description Engineering | CRITICAL | `desc-` |
| 3 | Content Structure | HIGH | `struct-` |
| 4 | Trigger Optimization | HIGH | `trigger-` |
| 5 | Progressive Disclosure | MEDIUM-HIGH | `prog-` |
| 6 | MCP Tool Design | MEDIUM | `mcp-` |
| 7 | Testing and Validation | MEDIUM | `test-` |
| 8 | Maintenance and Distribution | LOW-MEDIUM | `maint-` |

## Quick Reference

### 1. Skill Metadata Design (CRITICAL)

- `meta-name-format` - Use lowercase hyphenated skill names
- `meta-name-hyphen-boundaries` - Never start or end names with hyphens
- `meta-name-no-consecutive-hyphens` - Avoid consecutive hyphens in names
- `meta-name-uniqueness` - Ensure skill names are globally unique
- `meta-required-frontmatter` - Include all required frontmatter fields
- `meta-allowed-frontmatter-fields` - Only use allowed frontmatter fields
- `meta-frontmatter-yaml-syntax` - Use valid YAML frontmatter syntax
- `meta-name-length` - Keep skill names under 64 characters
- `meta-directory-match` - Match skill name to directory name

### 2. Description Engineering (CRITICAL)

- `desc-specific-capabilities` - Name specific capabilities in description
- `desc-trigger-keywords` - Include user trigger keywords in description
- `desc-third-person-voice` - Write descriptions in third person
- `desc-length-optimization` - Optimize description length for discovery
- `desc-avoid-vague-terms` - Avoid vague terms in descriptions
- `desc-differentiate-similar-skills` - Differentiate similar skills with distinct triggers
- `desc-include-negative-cases` - Include negative cases for precision

### 3. Content Structure (HIGH)

- `struct-header-hierarchy` - Use consistent header hierarchy
- `struct-instructions-first` - Put critical instructions early in content
- `struct-imperative-instructions` - Write instructions in imperative mood
- `struct-code-blocks-with-language` - Specify language in code blocks
- `struct-line-limit` - Keep SKILL.md under 500 lines
- `struct-single-responsibility` - One skill per domain

### 4. Trigger Optimization (HIGH)

- `trigger-slash-command-aliases` - Include slash command aliases in description
- `trigger-file-type-patterns` - Include file type patterns in description
- `trigger-workflow-stages` - Reference workflow stages in description
- `trigger-error-patterns` - Include error patterns in debugging skills
- `trigger-synonym-coverage` - Cover synonyms and alternate phrasings

### 5. Progressive Disclosure (MEDIUM-HIGH)

- `prog-three-level-disclosure` - Implement three-level progressive disclosure
- `prog-one-level-deep-links` - Limit reference links to one level deep
- `prog-scripts-execute-not-read` - Execute scripts instead of reading code
- `prog-lazy-load-examples` - Lazy load examples and reference material
- `prog-mutual-exclusion` - Separate mutually exclusive contexts

### 6. MCP Tool Design (MEDIUM)

- `mcp-tool-naming` - Use clear action-object tool names
- `mcp-parameter-descriptions` - Document all tool parameters
- `mcp-error-messages` - Return actionable error messages
- `mcp-tool-scope` - Design single-purpose tools
- `mcp-allowed-tools` - Use allowed-tools for safety constraints
- `mcp-idempotent-operations` - Design idempotent tool operations

### 7. Testing and Validation (MEDIUM)

- `test-trigger-phrases` - Test skill activation with real user phrases
- `test-edge-cases` - Test skills with edge case inputs
- `test-negative-scenarios` - Test that skills do NOT trigger on unrelated requests
- `test-instruction-clarity` - Test instructions with fresh context

### 8. Maintenance and Distribution (LOW-MEDIUM)

- `maint-semantic-versioning` - Use semantic versioning for skill releases
- `maint-changelog` - Maintain a changelog for skill updates
- `maint-plugin-packaging` - Package skills as plugins for distribution
- `maint-audit-security` - Audit skills before installing from external sources

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- Reference files: `references/{prefix}-{slug}.md`

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
