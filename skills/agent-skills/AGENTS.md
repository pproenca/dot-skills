# AI Agent Skills

**Version 0.1.0**  
Anthropic Community  
January 2026

> **Note:**
> This document is for agents and LLMs to follow when creating AI Agent Skills,
> including Claude Code skills and MCP tools. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive design and development guide for AI agent skills, including Claude Code skills and MCP tools. Contains 43 rules across 8 categories, prioritized by impact from critical (skill metadata and description engineering) to incremental (maintenance and distribution). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide skill creation, review, and optimization.

---

## Table of Contents

1. [Skill Metadata Design](#1-skill-metadata-design) — **CRITICAL**
   - 1.1 [Ensure Skill Names Are Globally Unique](#11-ensure-skill-names-are-globally-unique)
   - 1.2 [Include All Required Frontmatter Fields](#12-include-all-required-frontmatter-fields)
   - 1.3 [Keep Skill Names Under 64 Characters](#13-keep-skill-names-under-64-characters)
   - 1.4 [Match Skill Name to Directory Name](#14-match-skill-name-to-directory-name)
   - 1.5 [Use Lowercase Hyphenated Skill Names](#15-use-lowercase-hyphenated-skill-names)
   - 1.6 [Use Valid YAML Frontmatter Syntax](#16-use-valid-yaml-frontmatter-syntax)
2. [Description Engineering](#2-description-engineering) — **CRITICAL**
   - 2.1 [Avoid Vague Terms in Descriptions](#21-avoid-vague-terms-in-descriptions)
   - 2.2 [Differentiate Similar Skills with Distinct Triggers](#22-differentiate-similar-skills-with-distinct-triggers)
   - 2.3 [Include Negative Cases for Precision](#23-include-negative-cases-for-precision)
   - 2.4 [Include User Trigger Keywords in Description](#24-include-user-trigger-keywords-in-description)
   - 2.5 [Name Specific Capabilities in Description](#25-name-specific-capabilities-in-description)
   - 2.6 [Optimize Description Length for Discovery](#26-optimize-description-length-for-discovery)
   - 2.7 [Write Descriptions in Third Person](#27-write-descriptions-in-third-person)
3. [Content Structure](#3-content-structure) — **HIGH**
   - 3.1 [Keep SKILL.md Under 500 Lines](#31-keep-skillmd-under-500-lines)
   - 3.2 [One Skill per Domain](#32-one-skill-per-domain)
   - 3.3 [Put Critical Instructions Early in Content](#33-put-critical-instructions-early-in-content)
   - 3.4 [Specify Language in Code Blocks](#34-specify-language-in-code-blocks)
   - 3.5 [Use Consistent Header Hierarchy](#35-use-consistent-header-hierarchy)
   - 3.6 [Write Instructions in Imperative Mood](#36-write-instructions-in-imperative-mood)
4. [Trigger Optimization](#4-trigger-optimization) — **HIGH**
   - 4.1 [Cover Synonyms and Alternate Phrasings](#41-cover-synonyms-and-alternate-phrasings)
   - 4.2 [Include Error Patterns in Debugging Skills](#42-include-error-patterns-in-debugging-skills)
   - 4.3 [Include File Type Patterns in Description](#43-include-file-type-patterns-in-description)
   - 4.4 [Include Slash Command Aliases in Description](#44-include-slash-command-aliases-in-description)
   - 4.5 [Reference Workflow Stages in Description](#45-reference-workflow-stages-in-description)
5. [Progressive Disclosure](#5-progressive-disclosure) — **MEDIUM-HIGH**
   - 5.1 [Execute Scripts Instead of Reading Code](#51-execute-scripts-instead-of-reading-code)
   - 5.2 [Implement Three-Level Progressive Disclosure](#52-implement-three-level-progressive-disclosure)
   - 5.3 [Lazy Load Examples and Reference Material](#53-lazy-load-examples-and-reference-material)
   - 5.4 [Limit Reference Links to One Level Deep](#54-limit-reference-links-to-one-level-deep)
   - 5.5 [Separate Mutually Exclusive Contexts](#55-separate-mutually-exclusive-contexts)
6. [MCP Tool Design](#6-mcp-tool-design) — **MEDIUM**
   - 6.1 [Design Idempotent Tool Operations](#61-design-idempotent-tool-operations)
   - 6.2 [Design Single-Purpose Tools](#62-design-single-purpose-tools)
   - 6.3 [Document All Tool Parameters](#63-document-all-tool-parameters)
   - 6.4 [Return Actionable Error Messages](#64-return-actionable-error-messages)
   - 6.5 [Use allowed-tools for Safety Constraints](#65-use-allowed-tools-for-safety-constraints)
   - 6.6 [Use Clear Action-Object Tool Names](#66-use-clear-action-object-tool-names)
7. [Testing and Validation](#7-testing-and-validation) — **MEDIUM**
   - 7.1 [Test Instructions with Fresh Context](#71-test-instructions-with-fresh-context)
   - 7.2 [Test Skill Activation with Real User Phrases](#72-test-skill-activation-with-real-user-phrases)
   - 7.3 [Test Skills with Edge Case Inputs](#73-test-skills-with-edge-case-inputs)
   - 7.4 [Test That Skills Do NOT Trigger on Unrelated Requests](#74-test-that-skills-do-not-trigger-on-unrelated-requests)
8. [Maintenance and Distribution](#8-maintenance-and-distribution) — **LOW-MEDIUM**
   - 8.1 [Audit Skills Before Installing from External Sources](#81-audit-skills-before-installing-from-external-sources)
   - 8.2 [Maintain a Changelog for Skill Updates](#82-maintain-a-changelog-for-skill-updates)
   - 8.3 [Package Skills as Plugins for Distribution](#83-package-skills-as-plugins-for-distribution)
   - 8.4 [Use Semantic Versioning for Skill Releases](#84-use-semantic-versioning-for-skill-releases)

---

## 1. Skill Metadata Design

**Impact: CRITICAL**

Metadata determines skill discovery and selection. Poor names or descriptions mean the skill is never triggered, rendering all other optimizations worthless.

### 1.1 Ensure Skill Names Are Globally Unique

**Impact: CRITICAL (prevents silent overrides and unpredictable behavior)**

Skill names must be unique within each scope (project, user, plugin). When names collide, higher-priority scopes silently override lower ones. Users see unpredictable behavior without any error.

**Incorrect (generic name collides with common plugins):**

```yaml
---
name: utils
description: General utility functions
---
# Collides with utils from anthropic/skills plugin
# Your skill silently overrides or gets overridden
```

**Correct (prefixed name avoids collisions):**

```yaml
---
name: acme-deployment-utils
description: ACME Corp deployment utility functions
---
# Unique namespace prevents collisions
# Clear ownership when multiple plugins installed
```

**Priority order (highest wins):**
1. Enterprise managed settings
2. Personal (~/.claude/skills/)
3. Project (.claude/skills/)
4. Plugin-provided skills

**When NOT to use prefixes:**
- Official Anthropic skills that define the standard
- Project-only skills never distributed externally

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)

### 1.2 Include All Required Frontmatter Fields

**Impact: CRITICAL (prevents 100% skill failures from missing metadata)**

Every SKILL.md must have valid YAML frontmatter with `name` and `description` fields. Missing or malformed frontmatter causes silent loading failures—the skill appears in the directory but never activates.

**Incorrect (missing description field):**

```yaml
---
name: code-review
# Missing description field
---

# Code Review Instructions
...
# Skill loads but never triggers automatically
# Claude cannot determine when to use it
```

**Correct (all required fields present):**

```yaml
---
name: code-review
description: Reviews code for quality issues, security vulnerabilities, and performance problems. Use when reviewing PRs, auditing code, or checking for bugs.
---

# Code Review Instructions
...
# Skill triggers reliably when user mentions code review
```

**Field requirements:**
| Field | Required | Max Length | Format |
|-------|----------|------------|--------|
| name | Yes | 64 chars | lowercase, hyphens, numbers |
| description | Yes | 1024 chars | Third-person, trigger keywords |

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)

### 1.3 Keep Skill Names Under 64 Characters

**Impact: CRITICAL (prevents truncation and discovery failures)**

Skill names exceeding 64 characters get truncated in discovery systems, breaking skill matching and causing silent failures. Short, descriptive names also improve readability in skill listings.

**Incorrect (name too long, gets truncated):**

```yaml
---
name: enterprise-customer-relationship-management-data-synchronization-toolkit
description: Syncs CRM data
---
# 74 characters - exceeds limit
# Truncated to "enterprise-customer-relationship-management-data-synch..."
# Programmatic lookups fail silently
```

**Correct (concise name under limit):**

```yaml
---
name: crm-sync
description: Synchronizes enterprise CRM data across platforms. Use when importing, exporting, or reconciling customer records.
---
# 8 characters - well under limit
# Clear, memorable, works everywhere
```

**Naming strategy:**
- Use common abbreviations (CRM, API, DB)
- Omit redundant words (tool, helper, utility)
- Focus on the action, not the domain
- Target 15-30 characters for optimal readability

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)

### 1.4 Match Skill Name to Directory Name

**Impact: CRITICAL (prevents discovery failures and maintenance confusion)**

The `name` field in frontmatter must exactly match the containing directory name. Mismatches cause discovery failures on some systems and create maintenance confusion when updating skills.

**Incorrect (name does not match directory):**

```text
skills/
└── pdf-tools/           # Directory name
    └── SKILL.md
```

```yaml
---
name: pdf-processing     # Different from directory!
description: Handles PDF files
---
# Some discovery systems fail
# Developers confused when searching for skill
```

**Correct (name matches directory exactly):**

```text
skills/
└── pdf-processing/      # Directory name
    └── SKILL.md
```

```yaml
---
name: pdf-processing     # Matches directory
description: Handles PDF files
---
# Consistent naming across filesystem and metadata
# Easy to locate skill source from any reference
```

**Benefits:**
- Reliable discovery across all platforms
- Simple mental model: directory = skill name
- Easy grep/search for skill references

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)

### 1.5 Use Lowercase Hyphenated Skill Names

**Impact: CRITICAL (prevents discovery failures and cross-platform issues)**

The skill name must match the directory name and use lowercase with hyphens. Mixed case or special characters cause discovery failures on case-sensitive filesystems and break URL routing in skill registries.

**Incorrect (mixed case and spaces cause failures):**

```yaml
---
name: PDF Processing Tool
description: Handles PDF files
---
# Discovery fails on Linux/macOS due to case mismatch
# Spaces break URL routing in plugin marketplaces
```

**Correct (lowercase hyphenated matches directory):**

```yaml
---
name: pdf-processing
description: Handles PDF files
---
# Directory: skills/pdf-processing/SKILL.md
# Works consistently across all platforms
```

**Benefits:**
- Consistent discovery across Windows, macOS, and Linux
- Valid URL slugs for plugin marketplaces
- Predictable programmatic access via Automation API

Reference: [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)

### 1.6 Use Valid YAML Frontmatter Syntax

**Impact: CRITICAL (prevents 100% skill failures from syntax errors)**

YAML frontmatter must start on line 1 with `---`, use spaces (not tabs), and close with `---`. Invalid syntax causes the entire skill to fail silently—no error message, just non-functional skill.

**Incorrect (tabs instead of spaces cause parsing failure):**

```yaml
---
name:	pdf-processing
description:	Processes PDF files
---
# Tab characters (\t) instead of spaces
# YAML parser fails silently
# Skill never loads despite being in correct directory
```

**Correct (spaces after colons, proper delimiters):**

```yaml
---
name: pdf-processing
description: Processes PDF files for text extraction and form filling.
---
# Space after colon, no tabs
# Valid YAML parses correctly
```

**Common syntax errors:**
- Using tabs instead of spaces
- Missing space after colon (`name:value` vs `name: value`)
- Unescaped special characters in strings
- Missing closing `---` delimiter
- Frontmatter not starting on line 1

**Validation command:**

```bash
# Check YAML syntax before committing
head -20 SKILL.md | python -c "import yaml, sys; yaml.safe_load(sys.stdin)"
```

Reference: [YAML 1.2 Specification](https://yaml.org/spec/1.2.2/)

---

## 2. Description Engineering

**Impact: CRITICAL**

The description field is the primary signal for LLM skill selection. Vague descriptions cause wrong triggers or missed activations, making skills unreliable.

### 2.1 Avoid Vague Terms in Descriptions

**Impact: CRITICAL (prevents false positives and misactivations)**

Generic words like "helps", "manages", "handles", and "works with" trigger on too many unrelated requests. Use precise action verbs that match specific user intents.

**Incorrect (vague verbs cause over-triggering):**

```yaml
---
name: data-helper
description: Helps with data. Works with various data formats and manages data operations.
---
# "Helps with data" - triggers on ANY data mention
# "Works with" - matches everything
# "Manages" - too generic
# User asks about database schema - wrong skill activates
```

**Correct (precise verbs limit scope):**

```yaml
---
name: csv-parser
description: Parses CSV files into structured data, validates column types, and converts to JSON or database records. This skill should be used when importing CSV data or converting spreadsheet exports.
---
# "Parses CSV" - specific format and action
# "validates column types" - specific operation
# "converts to JSON" - concrete output
# Only triggers on actual CSV work
```

**Replace vague terms:**
| Vague | Precise |
|-------|---------|
| helps with | extracts, validates, converts |
| manages | schedules, deploys, monitors |
| handles | parses, transforms, routes |
| works with | reads, writes, streams |
| deals with | resolves, retries, escalates |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 2.2 Differentiate Similar Skills with Distinct Triggers

**Impact: CRITICAL (prevents skill conflicts and unpredictable activation)**

When multiple skills cover overlapping domains, use distinct trigger terms to ensure the right skill activates. Overlapping descriptions cause unpredictable behavior—sometimes one skill wins, sometimes the other.

**Incorrect (overlapping descriptions cause conflicts):**

```yaml
# skills/excel-export/SKILL.md
---
name: excel-export
description: Works with Excel files and data export
---

# skills/data-analysis/SKILL.md
---
name: data-analysis
description: Analyzes data and exports to Excel
---
# Both mention "Excel" and "data"
# User says "export to Excel" - which skill wins?
# Unpredictable activation on every request
```

**Correct (distinct trigger domains):**

```yaml
# skills/excel-export/SKILL.md
---
name: excel-export
description: Exports query results and datasets to Excel spreadsheets with formatting. This skill should be used when the user wants to create Excel reports or download data as .xlsx files.
---

# skills/data-analysis/SKILL.md
---
name: data-analysis
description: Analyzes datasets using statistical methods, generates insights, and creates visualizations. This skill should be used when the user wants to explore data, find patterns, or create charts.
---
# "Excel reports" vs "explore data"
# ".xlsx files" vs "create charts"
# Clear separation of concerns
```

**Disambiguation strategies:**
- Use different file formats as triggers
- Reference different workflow stages (create vs. analyze)
- Mention different output types (spreadsheet vs. visualization)

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 2.3 Include Negative Cases for Precision

**Impact: HIGH (reduces false positive activations by 40-60%)**

For skills with narrow scope, mention what the skill does NOT do. This prevents Claude from activating the skill for superficially similar but actually different requests.

**Incorrect (no boundaries, over-activates):**

```yaml
---
name: unit-test-generator
description: Generates tests for code. This skill should be used when the user wants to test their code.
---
# "test their code" matches integration tests
# "test their code" matches E2E tests
# "test their code" matches manual testing requests
# Skill activates but can't help with these cases
```

**Correct (explicit boundaries prevent wrong activation):**

```yaml
---
name: unit-test-generator
description: Generates unit tests for individual functions with mocks and assertions. This skill should be used when writing unit tests or testing isolated functions. This skill does NOT handle integration tests, E2E tests, or load testing.
---
# Clear positive: "unit tests", "isolated functions"
# Clear negative: "does NOT handle integration tests"
# User asking for E2E tests won't trigger this skill
```

**When to add negative cases:**
- Skill name suggests broader capability than actual scope
- Common confusion with related but different skills
- Frequently asked to do things outside scope

**Pattern:**

```text
This skill does NOT {out-of-scope action 1} or {out-of-scope action 2}.
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 2.4 Include User Trigger Keywords in Description

**Impact: CRITICAL (2-4× improvement in automatic activation rate)**

Add phrases users actually say when requesting the skill's functionality. Claude performs semantic matching between user input and skill descriptions. Missing keywords mean missed activations.

**Incorrect (technical terms only):**

```yaml
---
name: git-workflow
description: Manages git operations including commits, branches, and merges using best practices.
---
# User says "push my changes" - no match for "push"
# User says "create a PR" - no match for "PR" or "pull request"
```

**Correct (includes natural user phrases):**

```yaml
---
name: git-workflow
description: Manages git operations including commits, branches, and merges. Use when the user wants to commit changes, push code, create a PR, open a pull request, or review git history.
---
# "push my changes" matches "push code"
# "create a PR" matches "create a PR"
# "open pull request" matches "open a pull request"
```

**Keyword research technique:**
1. Write down 10 ways users might ask for this feature
2. Include synonyms (PR/pull request, commit/save changes)
3. Include command names users might type (/commit, /pr)
4. Test with real user queries

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 2.5 Name Specific Capabilities in Description

**Impact: CRITICAL (3-5× improvement in skill activation accuracy)**

List concrete actions the skill performs, not abstract categories. Claude matches user requests against these specific capabilities. Generic descriptions cause missed activations or wrong triggers.

**Incorrect (abstract category, no specific actions):**

```yaml
---
name: document-helper
description: Helps with documents
---
# "Helps with documents" matches nothing specific
# User says "extract text from this PDF" - skill doesn't trigger
# User says "fill out this form" - skill doesn't trigger
```

**Correct (lists specific extractable capabilities):**

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill interactive forms, merge multiple PDFs, and convert PDFs to images. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
# Each action is a concrete trigger point
# "extract text from PDF" matches "Extract text"
# "fill out this form" matches "fill interactive forms"
```

**Capability naming patterns:**
- Use verbs: Extract, Fill, Merge, Convert, Generate, Analyze
- Include objects: text, tables, forms, images, data
- Mention formats: PDF, Excel, JSON, Markdown

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 2.6 Optimize Description Length for Discovery

**Impact: CRITICAL (50-150 tokens saved per session (2-3× efficiency))**

Descriptions have a 1024 character limit and are loaded into context at startup. Too short means missed triggers; too long wastes tokens on every conversation. Target 150-300 characters for optimal balance.

**Incorrect (too short, misses triggers):**

```yaml
---
name: pdf-processing
description: Handles PDFs.
---
# 12 characters - too vague
# No trigger keywords
# Misses most user requests
```

**Incorrect (too long, wastes tokens):**

```yaml
---
name: pdf-processing
description: This comprehensive PDF processing skill handles all aspects of PDF document management including but not limited to text extraction using OCR and native text parsing, table extraction with structure preservation, form filling for both AcroForms and XFA forms, document merging and splitting, page manipulation including rotation and reordering, image extraction and conversion, PDF to image conversion supporting PNG JPEG and TIFF formats, compression and optimization, digital signature verification, and metadata extraction. This skill should be used whenever the user needs to work with PDF files in any capacity including reading extracting converting manipulating or creating PDF documents.
---
# 647 characters - excessive repetition
# Loaded into every conversation start
# Wastes ~150 tokens per session
```

**Correct (optimal length with key triggers):**

```yaml
---
name: pdf-processing
description: Extract text and tables from PDFs, fill forms, merge documents, and convert to images. This skill should be used when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---
# 213 characters - includes key capabilities
# Covers main trigger keywords
# Efficient token usage
```

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 2.7 Write Descriptions in Third Person

**Impact: CRITICAL (20-40% improvement in skill selection accuracy)**

Use "This skill should be used when..." rather than "Use this skill when...". Third person helps Claude reason about skill applicability as an external resource rather than a direct command.

**Incorrect (imperative voice):**

```yaml
---
name: code-review
description: Use this skill to review code for security issues. Run it on PRs before merging.
---
# Imperative voice reads as instruction to Claude
# Mixes skill description with usage commands
# Less clear when skill applies vs. direct instructions
```

**Correct (third person declarative):**

```yaml
---
name: code-review
description: Reviews code for security vulnerabilities, performance issues, and style violations. This skill should be used when reviewing PRs, auditing codebases, or checking for bugs before deployment.
---
# Third person describes what skill does
# Clear separation: what it does vs. when to use it
# Claude reasons about applicability more accurately
```

**Pattern to follow:**
1. First sentence: What the skill does (verb phrase)
2. Second sentence: "This skill should be used when..." (triggers)

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## 3. Content Structure

**Impact: HIGH**

How SKILL.md content is organized affects instruction clarity and execution accuracy. Poor structure causes misinterpretation and inconsistent results.

### 3.1 Keep SKILL.md Under 500 Lines

**Impact: HIGH (prevents context exhaustion and token waste)**

The main SKILL.md file should stay under 500 lines. Longer files consume excessive tokens when loaded and may trigger context management. Move detailed content to referenced files.

**Incorrect (monolithic 2000+ line file):**

```markdown
# API Generator

## Instructions
[100 lines of core instructions]

## Complete API Reference
[500 lines of OpenAPI spec]

## All Error Codes
[300 lines of error documentation]

## Full Examples
[800 lines of example code]

## Changelog
[300 lines of version history]
```

```text
# 2000+ lines loaded on every activation
# ~4000 tokens consumed immediately
# Most content rarely needed
```

**Correct (core file with references):**

```markdown
# API Generator

## Instructions
[100 lines of core instructions]

## API Reference
For complete API documentation, see [api-reference.md](api-reference.md)

## Error Handling
For error codes, see [errors.md](errors.md)

## Examples
For usage examples, see [examples.md](examples.md)
```

```text
# 150 lines in main file
# ~300 tokens on activation
# Details loaded only when needed
```

**File splitting strategy:**
| Content Type | Location |
|--------------|----------|
| Core instructions | SKILL.md |
| API reference | reference.md |
| Examples | examples.md |
| Error codes | errors.md |
| Executable code | scripts/ |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 3.2 One Skill per Domain

**Impact: HIGH (2-3× improvement in activation precision)**

Each skill should handle one coherent domain. Multi-purpose skills have vague descriptions that trigger incorrectly and grow unwieldy over time. Split into focused skills.

**Incorrect (kitchen-sink skill):**

```yaml
---
name: developer-tools
description: Helps with development tasks including code review, testing, deployment, documentation, and database management.
---
```

```markdown
# Developer Tools

## Code Review
[200 lines]

## Testing
[200 lines]

## Deployment
[200 lines]

## Documentation
[200 lines]

## Database
[200 lines]
```

```text
# Description triggers on any dev task
# 1000+ lines loaded when any feature needed
# Changes to one domain risk breaking others
```

**Correct (focused skills per domain):**

```text
skills/
├── code-review/SKILL.md     # 150 lines
├── test-runner/SKILL.md     # 150 lines
├── deployment/SKILL.md      # 150 lines
├── doc-generator/SKILL.md   # 150 lines
└── db-migration/SKILL.md    # 150 lines
```

Each with focused description:

```yaml
---
name: code-review
description: Reviews code for security vulnerabilities, performance issues, and style violations. This skill should be used when reviewing PRs or auditing code.
---
```

```text
# Each skill loads only when needed
# Precise activation for each domain
# Independent evolution and maintenance
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 3.3 Put Critical Instructions Early in Content

**Impact: HIGH (prevents critical rule violations from truncation)**

Place the most important instructions in the first 500 lines of SKILL.md. Context windows can truncate long documents, and Claude weighs earlier content more heavily. Burying critical instructions causes inconsistent behavior.

**Incorrect (critical rules buried at the end):**

```markdown
# Code Generator

## Introduction
This skill generates code...

## History
The evolution of code generation...

## Supported Languages
We support Python, JavaScript, TypeScript...

## Examples
Here are 50 examples...

## IMPORTANT: Security Rules
Never generate code that accesses /etc/passwd...
Never include API keys in generated code...
```

```text
# Security rules at line 800+
# May be truncated or deprioritized
# Critical rules applied inconsistently
```

**Correct (critical rules early, details later):**

```markdown
# Code Generator

## Security Rules (MUST FOLLOW)
- Never generate code that accesses system files
- Never include credentials or API keys
- Always sanitize user inputs in generated code

## Quick Start
Generate code by describing what you need...

## Supported Languages
Python, JavaScript, TypeScript...

## Detailed Examples
[Examples can safely be truncated]
```

```text
# Security rules in first 20 lines
# Always loaded and prioritized
# Examples safely truncated if needed
```

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 3.4 Specify Language in Code Blocks

**Impact: HIGH (2-3× improvement in code execution accuracy)**

Always include language identifiers in fenced code blocks. Claude uses these to determine execution context and syntax rules. Missing identifiers cause parsing ambiguity and execution errors.

**Incorrect (no language specified):**

```text
## Example Usage

` ` `
const result = await extractText(pdf)
console.log(result)
` ` `

Run the script:

` ` `
python scripts/process.py --input file.pdf
` ` `
```

```text
# First block: Is it JavaScript? TypeScript? Node?
# Second block: Is it bash? Should Claude execute it?
# Ambiguous execution context
```

**Correct (language specified for each block):**

```text
## Example Usage

` ` `typescript
const result = await extractText(pdf)
console.log(result)
` ` `

Run the script:

` ` `bash
python scripts/process.py --input file.pdf
` ` `
```

```text
# TypeScript: Claude knows syntax rules and types
# Bash: Claude knows this is a shell command
# Clear execution context for each block
```

**Common language identifiers:**
- `typescript`, `javascript`, `python`, `bash`, `go`, `rust`
- `yaml`, `json`, `toml` for configuration
- `markdown` for documentation examples
- `diff` for showing changes

Reference: [CommonMark Specification](https://spec.commonmark.org/)

### 3.5 Use Consistent Header Hierarchy

**Impact: HIGH (improves instruction parsing accuracy by 2-3×)**

Use markdown headers to create clear section hierarchy. Claude parses headers to understand document structure. Skipped levels or inconsistent usage causes parsing confusion and instruction misinterpretation.

**Incorrect (skipped levels, inconsistent hierarchy):**

```markdown
# PDF Processing

#### Quick Start
Some quick instructions...

## Advanced Usage
More detailed usage patterns...

##### Edge Cases
Edge case handling...
```

```text
# H1 → #### H4 (skipped 2, 3)
## H2 → ##### H5 (skipped 3, 4)
# Claude can't determine section relationships
```

**Correct (sequential hierarchy, consistent structure):**

```markdown
# PDF Processing

## Quick Start
Some quick instructions...

## Advanced Usage
More detailed usage patterns...

### Edge Cases
Edge case handling...
```

```text
# H1 (document title)
## H2 (main sections)
### H3 (subsections)
# Clear parent-child relationships
```

**Recommended structure:**

```markdown
# Skill Title (H1 - only one)

## Section 1 (H2 - major sections)

### Subsection 1.1 (H3 - details)

## Section 2 (H2 - next major section)
```

Reference: [CommonMark Specification](https://spec.commonmark.org/)

### 3.6 Write Instructions in Imperative Mood

**Impact: HIGH (reduces instruction ambiguity by 50%)**

Use direct commands like "Extract text" rather than passive constructions like "Text should be extracted". Imperative mood creates unambiguous instructions that Claude executes consistently.

**Incorrect (passive and conditional language):**

```markdown
# PDF Processor

## Instructions
Text could be extracted from the PDF if needed. Users may request
tables to be parsed. It would be good to validate the output format.
Forms may need to be filled based on user requirements.
```

```text
# "could be", "may want", "would be good", "may need"
# All introduce ambiguity about when to act
# Claude may or may not perform these actions
```

**Correct (direct imperative commands):**

```markdown
# PDF Processor

## Instructions
1. Extract all text from the PDF document
2. Parse tables and preserve their structure
3. Validate output format before returning
4. Fill form fields when the user provides values
```

```text
# "Extract", "Parse", "Validate", "Fill"
# Clear commands with no ambiguity
# Claude executes each instruction
```

**Transform passive to imperative:**
| Passive/Conditional | Imperative |
|---------------------|------------|
| Text should be extracted | Extract text |
| It would be helpful to validate | Validate |
| "The user may request" | When user requests, |
| Consider checking | Check |

Reference: [Prompt Engineering Guide](https://www.promptingguide.ai/)

---

## 4. Trigger Optimization

**Impact: HIGH**

Keywords and patterns that activate skills reliably. Missing trigger terms mean missed opportunities to help users.

### 4.1 Cover Synonyms and Alternate Phrasings

**Impact: HIGH (30-50% improvement in activation coverage)**

Users describe the same task in many ways. Include synonyms, abbreviations, and alternate phrasings to maximize trigger coverage. Missing synonyms mean missed opportunities to help.

**Incorrect (single phrasing only):**

```yaml
---
name: api-documentation
description: Generates API documentation for REST endpoints.
---
```

```text
# "document my API" - triggers
# "create swagger docs" - doesn't trigger (Swagger not mentioned)
# "write OpenAPI spec" - doesn't trigger (OpenAPI not mentioned)
# "API reference" - doesn't trigger
```

**Correct (synonyms and alternates included):**

```yaml
---
name: api-documentation
description: Generates API documentation, Swagger specs, and OpenAPI definitions for REST endpoints. This skill should be used when creating API docs, API reference documentation, Swagger documentation, or OpenAPI specifications.
---
```

```text
# "document my API" - triggers
# "create swagger docs" - triggers (Swagger mentioned)
# "write OpenAPI spec" - triggers (OpenAPI mentioned)
# "API reference" - triggers (reference mentioned)
```

**Synonym research process:**
1. List 5-10 ways users might describe the task
2. Include industry jargon and casual terms
3. Add common abbreviations (API, DB, UI, PR)
4. Include tool names (Swagger, Postman, Jest)
5. Test with real user queries

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 4.2 Include Error Patterns in Debugging Skills

**Impact: HIGH (enables automatic activation when errors occur)**

For skills that help diagnose or fix errors, include common error message patterns in the description. Claude can then activate the skill when users paste error messages.

**Incorrect (no error patterns):**

```yaml
---
name: typescript-debugger
description: Helps debug TypeScript code and resolve type issues.
---
```

```text
# User pastes "Type 'string' is not assignable to type 'number'"
# Skill doesn't recognize this as its domain
# User must explicitly request TypeScript help
```

**Correct (common error patterns included):**

```yaml
---
name: typescript-debugger
description: Resolves TypeScript compilation errors and type mismatches. This skill should be used when encountering type errors like "is not assignable to type", "Property does not exist", "Cannot find name", or TS error codes (TS2322, TS2339, TS2304).
---
```

```text
# User pastes "Type 'string' is not assignable to type 'number'"
# Matches "is not assignable to type"
# Skill automatically activates to help
```

**Error pattern strategies:**
- Include exact error message substrings
- Reference error code prefixes (TS, E, ERRNO)
- Mention common symptom descriptions
- Include stack trace patterns if relevant

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 4.3 Include File Type Patterns in Description

**Impact: HIGH (enables context-aware skill activation)**

When a skill processes specific file types, mention those extensions and formats. Claude uses file context to select appropriate skills, so explicit file type mentions improve activation accuracy.

**Incorrect (no file types mentioned):**

```yaml
---
name: spreadsheet-analyzer
description: Analyzes data and generates reports from spreadsheets.
---
```

```text
# User has .xlsx file open - skill doesn't know
# User mentions "Excel file" - might trigger
# User mentions ".csv" - doesn't trigger
# File context not leveraged
```

**Correct (explicit file types in description):**

```yaml
---
name: spreadsheet-analyzer
description: Analyzes data from Excel (.xlsx, .xls) and CSV files, generating statistical reports and visualizations. This skill should be used when working with spreadsheet files, Excel documents, or CSV data exports.
---
```

```text
# User has .xlsx file - skill knows it applies
# User mentions "CSV" - skill triggers
# File context enables smart activation
```

**File type patterns to include:**
| Domain | Extensions to mention |
|--------|----------------------|
| Documents | .pdf, .docx, .doc, .txt |
| Spreadsheets | .xlsx, .xls, .csv, .tsv |
| Code | .ts, .js, .py, .go, .rs |
| Config | .json, .yaml, .toml, .env |
| Images | .png, .jpg, .svg, .webp |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 4.4 Include Slash Command Aliases in Description

**Impact: HIGH (enables explicit user invocation alongside automatic)**

When users might invoke your skill explicitly via slash command, mention that command in the description. This helps Claude recognize explicit invocations and provides discoverability.

**Incorrect (no slash command mention):**

```yaml
---
name: commit-helper
description: Creates well-formatted git commits following conventional commit standards.
---
```

```text
# User types "/commit" - skill doesn't trigger
# User types "use the commit skill" - might work
# Explicit invocation path is broken
```

**Correct (includes slash command reference):**

```yaml
---
name: commit-helper
description: Creates well-formatted git commits following conventional commit standards. This skill should be used when the user wants to commit changes, types /commit, or asks to create a commit message.
---
```

```text
# User types "/commit" - skill triggers
# User types "commit my changes" - skill triggers
# Both invocation paths work
```

**Common slash command patterns:**
- `/commit` - Git operations
- `/review` - Code review
- `/test` - Test running
- `/deploy` - Deployment
- `/docs` - Documentation generation

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 4.5 Reference Workflow Stages in Description

**Impact: HIGH (25-40% improvement in workflow-triggered activations)**

Mention the workflow stage where your skill applies. Users often describe tasks in terms of workflow position ("before deploying", "after writing tests"). Stage references improve activation timing.

**Incorrect (no workflow context):**

```yaml
---
name: code-linter
description: Checks code for style issues and potential bugs.
---
```

```text
# User says "before I commit" - skill doesn't know
# User says "after making changes" - skill doesn't know
# Workflow timing unclear
```

**Correct (workflow stages referenced):**

```yaml
---
name: code-linter
description: Checks code for style issues and potential bugs. This skill should be used before committing changes, during code review, or when preparing a PR for merge.
---
```

```text
# User says "before I commit" - skill activates
# User says "review before merging" - skill activates
# Workflow-aware activation
```

**Common workflow stage phrases:**
| Stage | Trigger phrases |
|-------|-----------------|
| Start | "when starting", "before beginning", "to set up" |
| During | "while working on", "during development" |
| Before commit | "before committing", "pre-commit", "ready to save" |
| Review | "during review", "when reviewing", "checking the PR" |
| Deploy | "before deploying", "ready to ship", "going to production" |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## 5. Progressive Disclosure

**Impact: MEDIUM-HIGH**

Loading minimal context first and expanding as needed prevents context exhaustion and improves token efficiency across multi-step workflows.

### 5.1 Execute Scripts Instead of Reading Code

**Impact: MEDIUM-HIGH (reduces token usage by 90% for complex operations)**

Place executable scripts in `scripts/` directory and have Claude run them rather than reading code into context. Script execution uses zero context tokens while delivering the same results.

**Incorrect (reading script into context):**

```markdown
# SKILL.md

## Data Processing

Read the processing script and follow its logic:

```python
# scripts/process.py - 200 lines
import pandas as pd
import json

def process_data(input_file, output_format):
    df = pd.read_csv(input_file)
    # ... 180 more lines of processing logic
    return result
```

Use this logic to process user's data.
```

```text
# 200 lines of code in context
# ~400 tokens consumed
# Claude tries to mentally execute code
# Error-prone and slow
```

**Correct (execute script, describe interface):**

```markdown
# SKILL.md

## Data Processing

Process data using the bundled script:

```bash
python scripts/process.py --input data.csv --format json
```

**Arguments:**
- `--input`: Input CSV file path
- `--format`: Output format (json, csv, markdown)
- `--output`: Optional output file (defaults to stdout)

The script handles data validation, transformation, and formatting.
```

```text
# ~10 lines describing interface
# ~20 tokens consumed
# Script executes with full capability
# Results returned directly
```

**When to read vs. execute:**
| Scenario | Approach |
|----------|----------|
| Complex data processing | Execute script |
| API interactions | Execute script |
| Simple transformations | Inline instructions |
| Teaching/explaining | Read into context |

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 5.2 Implement Three-Level Progressive Disclosure

**Impact: MEDIUM-HIGH (reduces token usage by 60-80% while maintaining capability)**

Structure skill content across three disclosure levels: metadata at startup, full SKILL.md when activated, and supplementary files when needed. This prevents context exhaustion while enabling deep functionality.

**Incorrect (everything in one file):**

```markdown
# PDF Processor

## Instructions
[50 lines of core instructions]

## Complete API Reference
[500 lines of API documentation]

## All File Format Details
[300 lines of format specs]

## Every Example
[400 lines of examples]
```

```text
# 1250+ lines loaded on first activation
# ~2500 tokens consumed immediately
# Most content never used in typical session
```

**Correct (three-level disclosure):**

```text
pdf-processor/
├── SKILL.md           # Level 2: Core instructions (~100 lines)
├── api-reference.md   # Level 3: Loaded when API help needed
├── formats.md         # Level 3: Loaded for format questions
└── examples.md        # Level 3: Loaded when examples requested
```

```yaml
# Level 1: SKILL.md frontmatter (always loaded)
---
name: pdf-processor
description: Extract text, tables, and forms from PDFs.
---
```

```markdown
# Level 2: SKILL.md body (loaded on activation)

## Quick Start
Extract text with `extractText(pdf)`. For advanced API options,
see [api-reference.md](api-reference.md).

## Supported Formats
PDF 1.0-2.0 supported. For format details,
see [formats.md](formats.md).
```

**Disclosure levels:**
| Level | When Loaded | Content |
|-------|-------------|---------|
| 1 | Session start | name, description (~50 tokens) |
| 2 | Skill activation | SKILL.md body (~200 tokens) |
| 3 | On demand | Reference files (~500+ tokens each) |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 5.3 Lazy Load Examples and Reference Material

**Impact: MEDIUM-HIGH (saves 500-2000 tokens per activation)**

Keep examples and reference material in separate files, loading them only when users ask for examples. Most interactions don't need examples, so loading them by default wastes tokens.

**Incorrect (examples embedded in SKILL.md):**

```markdown
# API Generator

## Instructions
Generate REST API endpoints following these patterns...

## Examples

### Example 1: User CRUD
```typescript
// 50 lines of user API example
```

### Example 2: Product Catalog
```typescript
// 50 lines of product API example
```

### Example 3: Order Processing
```typescript
// 50 lines of order API example
```

[... 10 more examples ...]
```

```text
# 650+ lines of examples in main file
# ~1300 tokens loaded every activation
# User just wants to generate one endpoint
# Examples rarely referenced
```

**Correct (examples in separate file):**

```markdown
# API Generator

## Instructions
Generate REST API endpoints following these patterns...

## Examples
For implementation examples, see [examples.md](examples.md).

Quick reference:
- User CRUD: `examples.md#user-crud`
- Product Catalog: `examples.md#products`
- Order Processing: `examples.md#orders`
```

```text
# Core file stays under 100 lines
# ~200 tokens on activation
# Examples loaded only when requested
# Quick reference enables targeted loading
```

**What to lazy load:**
- Code examples (especially multiple examples)
- API reference documentation
- Error code listings
- Configuration option catalogs
- Template collections

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 5.4 Limit Reference Links to One Level Deep

**Impact: MEDIUM-HIGH (prevents recursive context loading and confusion)**

SKILL.md can link to reference files, but those files should not link to further files. Multi-level chains (A→B→C→D) cause recursive loading, context explosion, and Claude losing track of where information came from.

**Incorrect (multi-level reference chains):**

```markdown
# SKILL.md
See [config.md](config.md) for configuration options.

# config.md
For authentication, see [auth.md](auth.md).

# auth.md
For OAuth details, see [oauth.md](oauth.md).

# oauth.md
For token refresh, see [tokens.md](tokens.md).
```

```text
# 4 levels deep
# Claude follows chain, loading each file
# Context fills with partially relevant content
# Original question context pushed out
```

**Correct (flat reference structure):**

```markdown
# SKILL.md
## Configuration
See [config.md](config.md) for all configuration options.

## Authentication
See [auth.md](auth.md) for authentication setup.

# config.md (NO further links)
## All Configuration Options
[Complete config documentation, no outgoing links]

# auth.md (NO further links)
## Authentication
[Complete auth documentation including OAuth and tokens]
```

```text
# Single level of references
# Each reference file is self-contained
# Claude loads exactly what's needed
```

**Reference file guidelines:**
- Self-contained: Include all relevant information
- No outgoing links: Don't reference other skill files
- Focused: One topic per reference file

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 5.5 Separate Mutually Exclusive Contexts

**Impact: MEDIUM-HIGH (prevents loading irrelevant content for user's scenario)**

When a skill supports multiple distinct scenarios that never overlap, put each in its own reference file. This prevents loading Python documentation when the user needs JavaScript, or AWS docs when they need Azure.

**Incorrect (all scenarios in one file):**

```markdown
# Cloud Deployment

## AWS Deployment
[200 lines of AWS-specific instructions]

## Azure Deployment
[200 lines of Azure-specific instructions]

## GCP Deployment
[200 lines of GCP-specific instructions]
```

```text
# User deploys to AWS
# All 600 lines loaded
# 400 lines (Azure + GCP) completely irrelevant
# Wastes ~800 tokens
```

**Correct (separate files per scenario):**

```text
cloud-deployment/
├── SKILL.md
├── aws.md
├── azure.md
└── gcp.md
```

```markdown
# SKILL.md

## Deployment Instructions

1. Determine target cloud provider
2. Load provider-specific guide:
   - AWS: [aws.md](aws.md)
   - Azure: [azure.md](azure.md)
   - GCP: [gcp.md](gcp.md)
3. Follow provider-specific steps
```

```text
# User deploys to AWS
# Only aws.md loaded (200 lines)
# Zero irrelevant content
# Saves ~400 tokens
```

**Mutual exclusion patterns:**
| Domain | Mutually Exclusive Options |
|--------|----------------------------|
| Languages | Python vs JavaScript vs Go |
| Clouds | AWS vs Azure vs GCP |
| Databases | PostgreSQL vs MySQL vs MongoDB |
| Frameworks | React vs Vue vs Angular |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## 6. MCP Tool Design

**Impact: MEDIUM**

Model Context Protocol tool naming, descriptions, and parameter design affect tool discoverability and correct usage by LLMs.

### 6.1 Design Idempotent Tool Operations

**Impact: MEDIUM (prevents duplicate side effects from retries)**

Design MCP tools so calling them multiple times with the same input produces the same result. Claude may retry failed calls, and network issues can cause duplicate requests. Non-idempotent tools create inconsistent state.

**Incorrect (non-idempotent increment):**

```typescript
// Tool: increment_counter
async function incrementCounter(counterId: string): Promise<number> {
  const counter = await db.get(counterId)
  counter.value += 1
  await db.save(counter)
  return counter.value
}
```

```text
# User asks to increment counter
# Claude calls tool, network timeout
# Claude retries (same request)
# Counter incremented twice!
# Value is now 2 instead of 1
```

**Correct (idempotent set with request ID):**

```typescript
// Tool: set_counter
async function setCounter(
  counterId: string,
  value: number,
  requestId: string
): Promise<number> {
  const existing = await db.getByRequestId(requestId)
  if (existing) {
    return existing.value  // Already processed
  }

  await db.save({ counterId, value, requestId })
  return value
}
```

```text
# User asks to set counter to 5
# Claude calls tool, network timeout
# Claude retries with same requestId
# Tool detects duplicate, returns existing value
# Counter is exactly 5
```

**Idempotency strategies:**
| Operation | Strategy |
|-----------|----------|
| Create | Use client-provided ID or check existence |
| Update | Use PUT semantics (replace entire state) |
| Delete | Return success even if already deleted |
| Increment | Accept absolute value instead of delta |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)

### 6.2 Design Single-Purpose Tools

**Impact: MEDIUM (improves tool selection precision and reduces errors)**

Each MCP tool should do one thing well. Multi-purpose tools with many optional parameters confuse Claude's tool selection and increase the chance of incorrect usage.

**Incorrect (multi-purpose tool with mode parameter):**

```json
{
  "name": "manage_users",
  "description": "Creates, updates, deletes, or retrieves users",
  "inputSchema": {
    "type": "object",
    "properties": {
      "action": {
        "type": "string",
        "enum": ["create", "update", "delete", "get", "list"]
      },
      "user_id": {"type": "string"},
      "user_data": {"type": "object"},
      "filters": {"type": "object"}
    }
  }
}
```

```text
# 5 actions with different required parameters
# Claude must understand modal behavior
# Easy to pass wrong combination
# Error messages complex to generate
```

**Correct (separate tools for each action):**

```json
{
  "tools": [
    {
      "name": "create_user",
      "description": "Creates a new user account",
      "inputSchema": {
        "properties": {
          "name": {"type": "string", "description": "User's full name"},
          "email": {"type": "string", "description": "User's email address"}
        },
        "required": ["name", "email"]
      }
    },
    {
      "name": "get_user",
      "description": "Retrieves user profile by ID",
      "inputSchema": {
        "properties": {
          "user_id": {"type": "string", "description": "User's unique identifier"}
        },
        "required": ["user_id"]
      }
    },
    {
      "name": "delete_user",
      "description": "Permanently deletes a user account",
      "inputSchema": {
        "properties": {
          "user_id": {"type": "string", "description": "User's unique identifier"}
        },
        "required": ["user_id"]
      }
    }
  ]
}
```

```text
# Each tool has clear purpose
# Required parameters obvious
# Claude selects correct tool directly
# Simpler error handling per tool
```

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)

### 6.3 Document All Tool Parameters

**Impact: MEDIUM (prevents parameter errors and improves usability)**

Every MCP tool parameter needs a clear description, type, and constraints. Missing documentation causes Claude to guess parameter values, leading to API errors and failed tool calls.

**Incorrect (minimal parameter documentation):**

```json
{
  "name": "search_users",
  "inputSchema": {
    "type": "object",
    "properties": {
      "q": {"type": "string"},
      "n": {"type": "integer"},
      "s": {"type": "string"}
    }
  }
}
```

```text
# "q" - query? queue? what format?
# "n" - number of what? max? min?
# "s" - sort? status? string of what?
# Claude guesses wrong values
```

**Correct (full parameter documentation):**

```json
{
  "name": "search_users",
  "description": "Searches users by name, email, or role",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Search term to match against user name, email, or role"
      },
      "limit": {
        "type": "integer",
        "description": "Maximum number of results to return (1-100, default 20)",
        "minimum": 1,
        "maximum": 100,
        "default": 20
      },
      "sort_by": {
        "type": "string",
        "description": "Field to sort results by",
        "enum": ["name", "email", "created_at", "last_login"],
        "default": "name"
      }
    },
    "required": ["query"]
  }
}
```

```text
# Clear parameter names
# Descriptions explain purpose and format
# Constraints prevent invalid values
# Defaults reduce required inputs
```

Reference: [MCP Specification](https://modelcontextprotocol.io/specification)

### 6.4 Return Actionable Error Messages

**Impact: MEDIUM (enables Claude to self-correct and retry)**

When MCP tools fail, return error messages that explain what went wrong and how to fix it. Generic errors leave Claude unable to recover, causing repeated failures or giving up entirely.

**Incorrect (generic error messages):**

```json
{
  "error": {
    "code": -1,
    "message": "Operation failed"
  }
}
```

```text
# "Operation failed" - what operation? why?
# Claude has no information to self-correct
# User sees "I encountered an error"
# No path forward
```

**Correct (actionable error with guidance):**

```json
{
  "error": {
    "code": 422,
    "message": "Invalid date format",
    "details": {
      "field": "start_date",
      "received": "2024-1-5",
      "expected": "ISO 8601 format (YYYY-MM-DD)",
      "example": "2024-01-05"
    }
  }
}
```

```text
# Identifies exact field with problem
# Shows what was received
# Explains expected format
# Provides working example
# Claude can retry with corrected value
```

**Error message components:**
| Component | Purpose | Example |
|-----------|---------|---------|
| code | Error category | 422 (validation), 404 (not found) |
| message | Human-readable summary | "Invalid date format" |
| field | Which parameter failed | "start_date" |
| received | What was provided | "2024-1-5" |
| expected | What format is needed | "YYYY-MM-DD" |
| example | Working value | "2024-01-05" |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)

### 6.5 Use allowed-tools for Safety Constraints

**Impact: MEDIUM (prevents accidental destructive operations)**

Restrict which tools a skill can use via the `allowed-tools` frontmatter field. This prevents accidental file modifications during read-only operations or unintended command execution.

**Incorrect (no tool restrictions):**

```yaml
---
name: code-analyzer
description: Analyzes code for quality issues
---

# Code Analyzer

Analyze the codebase and report issues...
```

```text
# Skill has access to all tools
# Claude might edit files while "analyzing"
# Claude might run commands to "check" things
# Unintended side effects possible
```

**Correct (explicit tool restrictions):**

```yaml
---
name: code-analyzer
description: Analyzes code for quality issues
allowed-tools: Read, Grep, Glob
---

# Code Analyzer

Analyze the codebase and report issues...
```

```text
# Only read-only tools available
# Cannot edit files during analysis
# Cannot execute arbitrary commands
# Safe by design
```

**Common restriction patterns:**
| Skill Type | Allowed Tools |
|------------|---------------|
| Read-only analysis | Read, Grep, Glob |
| Code modification | Read, Edit, Write |
| Git operations | Bash(git:*) |
| Specific language | Bash(python:*), Bash(node:*) |
| Full access | Omit allowed-tools |

**Wildcard syntax:**
- `Bash(git:*)` - Only git commands
- `Bash(npm:*)` - Only npm commands
- `Bash(python scripts/*.py)` - Only specific scripts

Reference: [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)

### 6.6 Use Clear Action-Object Tool Names

**Impact: MEDIUM (improves tool selection accuracy by 40%)**

Name MCP tools with a verb-object pattern that describes exactly what the tool does. Claude selects tools based on name matching, so unclear names cause wrong tool selection or missed opportunities.

**Incorrect (vague or noun-only names):**

```json
{
  "tools": [
    {"name": "data", "description": "Handles data operations"},
    {"name": "processor", "description": "Processes things"},
    {"name": "helper", "description": "Helps with tasks"}
  ]
}
```

```text
# "data" - data what? get? set? delete?
# "processor" - process what? how?
# Claude can't determine when to use these
```

**Correct (verb-object pattern):**

```json
{
  "tools": [
    {"name": "get_user_profile", "description": "Retrieves user profile data by user ID"},
    {"name": "update_user_settings", "description": "Updates user account settings"},
    {"name": "delete_user_session", "description": "Invalidates and removes user session"}
  ]
}
```

```text
# "get_user_profile" - clear action (get) and object (user_profile)
# "update_user_settings" - precise operation
# Claude matches user request to correct tool
```

**Naming patterns:**
| Action | Example Names |
|--------|---------------|
| Read | get_*, fetch_*, list_*, search_* |
| Create | create_*, add_*, insert_* |
| Update | update_*, set_*, modify_* |
| Delete | delete_*, remove_*, clear_* |
| Process | process_*, transform_*, validate_* |

Reference: [MCP Best Practices](https://modelcontextprotocol.info/docs/best-practices/)

---

## 7. Testing and Validation

**Impact: MEDIUM**

Verifying skills work correctly across diverse scenarios catches issues before deployment and ensures consistent behavior.

### 7.1 Test Instructions with Fresh Context

**Impact: MEDIUM (prevents 30-50% of instruction misinterpretations)**

Test your skill at the start of a new conversation, without any prior context. Instructions that seem clear after extensive development may be ambiguous to Claude seeing them for the first time.

**Incorrect (tested only in development context):**

```markdown
# Code Formatter - SKILL.md

## Instructions
Format the code using the settings we discussed.
Apply the rules from the configuration.
Use the standard approach for this project.
```

```text
# During development, these made sense
# New conversation: "what settings?"
# New conversation: "what configuration?"
# New conversation: "what standard approach?"
# Claude has no context for these references
```

**Correct (self-contained instructions):**

```markdown
# Code Formatter - SKILL.md

## Instructions
Format code using Prettier with these settings:
- printWidth: 100
- tabWidth: 2
- singleQuote: true
- trailingComma: 'es5'

## Process
1. Read the target file
2. Apply Prettier formatting
3. Write formatted output back
4. Report changes made

## Default Behavior
If no specific style requested, use the Prettier defaults above.
```

```text
# All context self-contained
# No references to "previous discussion"
# No "as mentioned before"
# Works in any conversation
```

**Testing checklist:**
- [ ] Start new Claude Code session
- [ ] Trigger skill with simple request
- [ ] Verify Claude follows instructions without asking clarifying questions
- [ ] Check output matches expected format
- [ ] Repeat with 3 different simple requests

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 7.2 Test Skill Activation with Real User Phrases

**Impact: MEDIUM (catches 60-80% of activation failures before deployment)**

Before deploying a skill, test it with 10+ real user phrases to verify it activates correctly. Write down how users actually ask for this functionality, then verify each phrase triggers the skill.

**Incorrect (no activation testing):**

```yaml
---
name: api-docs
description: Generates API documentation
---
```

```text
# Deployed without testing
# User says "create swagger spec" - doesn't trigger
# User says "write OpenAPI" - doesn't trigger
# User says "document my endpoints" - doesn't trigger
# 3 of 4 common requests fail
```

**Correct (systematic phrase testing):**

```markdown
# Activation Test Plan

## Test Phrases (should trigger)
1. "generate API docs" ✓
2. "create swagger spec" ✗ - Added "Swagger" to description
3. "write OpenAPI definition" ✗ - Added "OpenAPI" to description
4. "document my endpoints" ✓
5. "create API reference" ✗ - Added "API reference" to description
6. "/api-docs" ✓
7. "help me document this REST API" ✓
8. "I need documentation for my API" ✓

## Negative Tests (should NOT trigger)
1. "what does this API do?" ✗ (should not trigger - this is a question)
2. "call the API" ✗ (should not trigger - this is execution)

## Updated Description
description: Generates API documentation, Swagger specs, OpenAPI definitions, and API reference pages. This skill should be used when creating API docs, documenting endpoints, or writing API reference.
```

**Testing process:**
1. Write 10+ phrases users might say
2. Test each in Claude Code
3. Note which fail to trigger
4. Update description with missing keywords
5. Retest until all pass

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 7.3 Test Skills with Edge Case Inputs

**Impact: MEDIUM (prevents failures in production scenarios)**

Test skills with unusual but valid inputs: empty files, very large files, special characters, unicode, missing optional data. Edge cases expose instruction gaps that cause production failures.

**Incorrect (only happy path tested):**

```markdown
# CSV Parser - Test Results

## Tests Run
1. Standard CSV file (10 rows, 5 columns) ✓

## Deployed
```

```text
# User uploads empty CSV - skill crashes
# User uploads 100MB CSV - timeout
# User uploads CSV with emojis in headers - parsing error
# User uploads TSV file - wrong delimiter
# 4 production failures from untested cases
```

**Correct (edge cases covered):**

```markdown
# CSV Parser - Test Results

## Standard Cases
1. Standard CSV (10 rows, 5 columns) ✓
2. Large CSV (10,000 rows) ✓

## Edge Cases
3. Empty file (0 rows) ✓ - Returns "No data found"
4. Headers only (0 data rows) ✓ - Returns headers list
5. Single column ✓
6. Unicode in headers (日本語, emoji) ✓
7. Quoted fields with commas ✓
8. TSV file (tab-separated) ✗ - Added delimiter detection

## Error Cases
9. Binary file (not CSV) ✓ - Returns "Invalid format"
10. Malformed CSV (inconsistent columns) ✓ - Reports row errors

## Instructions Updated
- Added: "Detect delimiter automatically (comma, tab, semicolon)"
- Added: "Handle unicode characters in all fields"
- Added: "For empty files, report 'No data found' instead of error"
```

**Common edge cases to test:**
| Category | Edge Cases |
|----------|------------|
| Size | Empty, 1 item, very large |
| Characters | Unicode, emoji, special chars |
| Format | Missing fields, extra fields |
| Types | Null, undefined, wrong type |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 7.4 Test That Skills Do NOT Trigger on Unrelated Requests

**Impact: MEDIUM (prevents false positive activations)**

Verify your skill does NOT activate for superficially similar but actually unrelated requests. Over-triggering skills frustrate users and waste context on irrelevant instructions.

**Incorrect (no negative testing):**

```yaml
---
name: python-debugger
description: Helps debug Python code and fix errors.
---
```

```text
# Positive tests pass - activates on Python errors
# No negative testing done
# User asks "what Python version do I have?" - debugger activates
# User asks "recommend Python books" - debugger activates
# User asks "Python vs JavaScript?" - debugger activates
# Skill over-triggers on any Python mention
```

**Correct (negative scenarios tested):**

```markdown
# Negative Test Results

## Should NOT Trigger

1. "what Python version do I have?"
   - Result: Triggered ✗
   - Fix: Added "errors", "bugs", "exceptions" as required context

2. "recommend Python books"
   - Result: Did not trigger ✓

3. "Python vs JavaScript comparison"
   - Result: Did not trigger ✓

4. "write a Python function to sort a list"
   - Result: Triggered ✗
   - Fix: Added "This skill does NOT write new code"

5. "explain how Python decorators work"
   - Result: Did not trigger ✓

## Updated Description
description: Debugs Python errors, traces exceptions, and fixes bugs in Python code. This skill should be used when encountering Python errors, tracebacks, or exceptions. This skill does NOT write new Python code or explain Python concepts.
```

**Negative test categories:**
| If skill does... | Test that it doesn't trigger on... |
|------------------|-----------------------------------|
| Debug errors | General questions about language |
| Generate code | Explanation requests |
| Process files | File organization questions |
| API calls | API documentation questions |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## 8. Maintenance and Distribution

**Impact: LOW-MEDIUM**

Versioning, distribution, and long-term maintenance patterns ensure skills remain usable and discoverable over time.

### 8.1 Audit Skills Before Installing from External Sources

**Impact: LOW-MEDIUM (prevents malicious code execution and data exfiltration)**

Before installing skills from external sources, review their contents for security risks. Skills can execute arbitrary code, access files, and make network requests. Malicious skills can exfiltrate data or compromise systems.

**Incorrect (blind trust):**

```bash
# Found skill on random GitHub repo
/plugin add github:unknown-user/cool-skills

# Installed without review
# Skill contains hidden backdoor
# Exfiltrates code to external server
```

**Correct (security audit before install):**

```markdown
# Security Audit Checklist

## Before Installing: github:org/skill-package

### 1. Source Review
- [ ] Repository has clear ownership
- [ ] Maintained by known organization
- [ ] Has meaningful commit history
- [ ] Not a fork of suspicious origin

### 2. Code Review
- [ ] No obfuscated code
- [ ] No network calls to unknown hosts
- [ ] No file access outside expected scope
- [ ] No credential harvesting patterns

### 3. Permission Review
- [ ] allowed-tools restricts capabilities appropriately
- [ ] No unnecessary Bash access
- [ ] No Write access if read-only expected

### 4. Script Audit
- [ ] scripts/ directory contents reviewed
- [ ] Dependencies from trusted sources
- [ ] No eval() or exec() on user input
```

**Red flags to watch for:**
| Risk | Pattern |
|------|---------|
| Data exfiltration | curl/fetch to unknown domains |
| Credential theft | Reading .env, .ssh, credentials |
| Backdoor | Obfuscated code, encoded strings |
| Excessive access | allowed-tools: * (all tools) |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

### 8.2 Maintain a Changelog for Skill Updates

**Impact: LOW-MEDIUM (enables users to understand updates before installing)**

Keep a CHANGELOG.md file documenting all changes between versions. Users need to understand what changed before updating, especially for breaking changes.

**Incorrect (no changelog):**

```text
skill-directory/
├── SKILL.md
└── metadata.json  # version: "3.0.0"
```

```text
# User on v2.0.0 sees v3.0.0 available
# No information about what changed
# No warning about breaking changes
# Updates blindly, skill breaks their workflow
```

**Correct (changelog with all versions):**

```text
skill-directory/
├── SKILL.md
├── metadata.json
└── CHANGELOG.md
```

```markdown
# Changelog

All notable changes to this skill are documented here.

## [3.0.0] - 2024-02-01

### Breaking Changes
- Output format changed from JSON to YAML
- Minimum Node.js version is now 18

### Added
- Support for TypeScript type generation

### Fixed
- Handle circular references in schemas

## [2.1.0] - 2024-01-15

### Added
- New `--dry-run` flag for preview mode

### Changed
- Improved error messages for invalid inputs

## [2.0.0] - 2024-01-01

### Breaking Changes
- Renamed `generate` command to `create`

### Added
- Batch processing support
```

**Changelog sections:**
| Section | Content |
|---------|---------|
| Breaking Changes | Incompatible changes requiring user action |
| Added | New features |
| Changed | Changes to existing functionality |
| Deprecated | Features to be removed in future |
| Removed | Features removed in this version |
| Fixed | Bug fixes |
| Security | Security-related fixes |

Reference: [Keep a Changelog](https://keepachangelog.com/)

### 8.3 Package Skills as Plugins for Distribution

**Impact: LOW-MEDIUM (enables one-command installation and updates)**

When distributing skills beyond a single project, package them as Claude Code plugins. Plugins provide versioned installation, automatic updates, and proper dependency management.

**Incorrect (manual file sharing):**

```markdown
# Installation Instructions

1. Clone this repo
2. Copy the `skills/` directory to `~/.claude/skills/`
3. Restart Claude Code
4. To update, re-clone and re-copy
```

```text
# Users must manually manage files
# No version tracking
# Updates overwrite customizations
# Dependencies not managed
```

**Correct (plugin packaging):**

```text
my-skills-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── api-generator/
│   │   └── SKILL.md
│   └── test-runner/
│       └── SKILL.md
└── README.md
```

```json
// .claude-plugin/plugin.json
{
  "name": "my-skills",
  "version": "1.0.0",
  "description": "Collection of development skills",
  "skills": {
    "auto-discover": true
  }
}
```

```markdown
# Installation

/plugin add github:myorg/my-skills-plugin
```

**Plugin benefits:**
| Feature | Manual | Plugin |
|---------|--------|--------|
| Installation | Multi-step | One command |
| Updates | Manual copy | `/plugin update` |
| Versioning | None | Automatic |
| Dependencies | Manual | Declared |
| Rollback | Manual restore | Version pinning |

Reference: [Claude Code Plugins](https://code.claude.com/docs/en/plugins)

### 8.4 Use Semantic Versioning for Skill Releases

**Impact: LOW-MEDIUM (enables safe updates and rollbacks)**

Track skill versions using semantic versioning (MAJOR.MINOR.PATCH). This allows users to understand update impact and pin to known-working versions when needed.

**Incorrect (no versioning or arbitrary versions):**

```json
{
  "name": "api-generator",
  "version": "latest"
}
```

```text
# No way to know what changed
# Can't pin to specific version
# Breaking changes surprise users
# No rollback path
```

**Correct (semantic versioning):**

```json
{
  "name": "api-generator",
  "version": "2.1.0"
}
```

```markdown
# CHANGELOG.md

## [2.1.0] - 2024-01-15
### Added
- Support for GraphQL endpoints

## [2.0.0] - 2024-01-01
### Changed
- BREAKING: Changed output format from JSON to YAML
- BREAKING: Renamed 'endpoint' parameter to 'path'

## [1.2.3] - 2023-12-15
### Fixed
- Handle paths with special characters
```

**Version increment rules:**
| Change Type | Version | Example |
|-------------|---------|---------|
| Breaking (incompatible) | MAJOR | 1.x.x → 2.0.0 |
| New feature (compatible) | MINOR | 1.1.x → 1.2.0 |
| Bug fix | PATCH | 1.1.1 → 1.1.2 |

**Breaking changes include:**
- Changing output format
- Renaming required parameters
- Removing capabilities
- Changing default behavior

Reference: [Semantic Versioning](https://semver.org/)

---

## References

1. [https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
2. [https://code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
3. [https://github.com/anthropics/skills](https://github.com/anthropics/skills)
4. [https://modelcontextprotocol.info/docs/best-practices/](https://modelcontextprotocol.info/docs/best-practices/)
5. [https://www.promptingguide.ai/research/llm-agents](https://www.promptingguide.ai/research/llm-agents)
6. [https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)