# AI Agent Skills

**Version 0.2.0**  
Anthropic Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive design and development guide for AI agent skills, including Claude Code skills and MCP tools. Contains 46 rules across 8 categories, prioritized by impact from critical (skill metadata and description engineering) to incremental (maintenance and distribution). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide skill creation, review, and optimization. Validated against the official skills-ref library specification.

---

## Table of Contents

1. [Skill Metadata Design](references/_sections.md#1-skill-metadata-design) — **CRITICAL**
   - 1.1 [Avoid Consecutive Hyphens in Names](references/meta-name-no-consecutive-hyphens.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.2 [Ensure Skill Names Are Globally Unique](references/meta-name-uniqueness.md) — CRITICAL (prevents silent overrides and unpredictable behavior)
   - 1.3 [Include All Required Frontmatter Fields](references/meta-required-frontmatter.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.4 [Keep Skill Names Under 64 Characters](references/meta-name-length.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.5 [Match Skill Name to Directory Name](references/meta-directory-match.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.6 [Never Start or End Names with Hyphens](references/meta-name-hyphen-boundaries.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.7 [Only Use Allowed Frontmatter Fields](references/meta-allowed-frontmatter-fields.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.8 [Use Lowercase Hyphenated Skill Names](references/meta-name-format.md) — CRITICAL (100% skill rejection by skills-ref validator)
   - 1.9 [Use Valid YAML Frontmatter Syntax](references/meta-frontmatter-yaml-syntax.md) — CRITICAL (prevents 100% skill failures from syntax errors)
2. [Description Engineering](references/_sections.md#2-description-engineering) — **CRITICAL**
   - 2.1 [Avoid Vague Terms in Descriptions](references/desc-avoid-vague-terms.md) — CRITICAL (prevents false positives and misactivations)
   - 2.2 [Differentiate Similar Skills with Distinct Triggers](references/desc-differentiate-similar-skills.md) — CRITICAL (prevents skill conflicts and unpredictable activation)
   - 2.3 [Include Negative Cases for Precision](references/desc-include-negative-cases.md) — HIGH (reduces false positive activations by 40-60%)
   - 2.4 [Include User Trigger Keywords in Description](references/desc-trigger-keywords.md) — CRITICAL (2-4× improvement in automatic activation rate)
   - 2.5 [Name Specific Capabilities in Description](references/desc-specific-capabilities.md) — CRITICAL (3-5× improvement in skill activation accuracy)
   - 2.6 [Optimize Description Length for Discovery](references/desc-length-optimization.md) — CRITICAL (100% rejection if over 1024 chars, 50-150 tokens saved per session)
   - 2.7 [Write Descriptions in Third Person](references/desc-third-person-voice.md) — CRITICAL (20-40% improvement in skill selection accuracy)
3. [Content Structure](references/_sections.md#3-content-structure) — **HIGH**
   - 3.1 [Keep SKILL.md Under 500 Lines](references/struct-line-limit.md) — HIGH (prevents context exhaustion and token waste)
   - 3.2 [One Skill per Domain](references/struct-single-responsibility.md) — HIGH (2-3× improvement in activation precision)
   - 3.3 [Put Critical Instructions Early in Content](references/struct-instructions-first.md) — HIGH (prevents critical rule violations from truncation)
   - 3.4 [Specify Language in Code Blocks](references/struct-code-blocks-with-language.md) — HIGH (2-3× improvement in code execution accuracy)
   - 3.5 [Use Consistent Header Hierarchy](references/struct-header-hierarchy.md) — HIGH (improves instruction parsing accuracy by 2-3×)
   - 3.6 [Write Instructions in Imperative Mood](references/struct-imperative-instructions.md) — HIGH (reduces instruction ambiguity by 50%)
4. [Trigger Optimization](references/_sections.md#4-trigger-optimization) — **HIGH**
   - 4.1 [Cover Synonyms and Alternate Phrasings](references/trigger-synonym-coverage.md) — HIGH (30-50% improvement in activation coverage)
   - 4.2 [Include Error Patterns in Debugging Skills](references/trigger-error-patterns.md) — HIGH (enables automatic activation when errors occur)
   - 4.3 [Include File Type Patterns in Description](references/trigger-file-type-patterns.md) — HIGH (enables context-aware skill activation)
   - 4.4 [Include Slash Command Aliases in Description](references/trigger-slash-command-aliases.md) — HIGH (enables explicit user invocation alongside automatic)
   - 4.5 [Reference Workflow Stages in Description](references/trigger-workflow-stages.md) — HIGH (25-40% improvement in workflow-triggered activations)
5. [Progressive Disclosure](references/_sections.md#5-progressive-disclosure) — **MEDIUM-HIGH**
   - 5.1 [Execute Scripts Instead of Reading Code](references/prog-scripts-execute-not-read.md) — MEDIUM-HIGH (reduces token usage by 90% for complex operations)
   - 5.2 [Implement Three-Level Progressive Disclosure](references/prog-three-level-disclosure.md) — MEDIUM-HIGH (reduces token usage by 60-80% while maintaining capability)
   - 5.3 [Lazy Load Examples and Reference Material](references/prog-lazy-load-examples.md) — MEDIUM-HIGH (saves 500-2000 tokens per activation)
   - 5.4 [Limit Reference Links to One Level Deep](references/prog-one-level-deep-links.md) — MEDIUM-HIGH (prevents recursive context loading and confusion)
   - 5.5 [Separate Mutually Exclusive Contexts](references/prog-mutual-exclusion.md) — MEDIUM-HIGH (prevents loading irrelevant content for user's scenario)
6. [MCP Tool Design](references/_sections.md#6-mcp-tool-design) — **MEDIUM**
   - 6.1 [Design Idempotent Tool Operations](references/mcp-idempotent-operations.md) — MEDIUM (prevents duplicate side effects from retries)
   - 6.2 [Design Single-Purpose Tools](references/mcp-tool-scope.md) — MEDIUM (improves tool selection precision and reduces errors)
   - 6.3 [Document All Tool Parameters](references/mcp-parameter-descriptions.md) — MEDIUM (prevents parameter errors and improves usability)
   - 6.4 [Return Actionable Error Messages](references/mcp-error-messages.md) — MEDIUM (enables Claude to self-correct and retry)
   - 6.5 [Use allowed-tools for Safety Constraints](references/mcp-allowed-tools.md) — MEDIUM (prevents accidental destructive operations)
   - 6.6 [Use Clear Action-Object Tool Names](references/mcp-tool-naming.md) — MEDIUM (improves tool selection accuracy by 40%)
7. [Testing and Validation](references/_sections.md#7-testing-and-validation) — **MEDIUM**
   - 7.1 [Test Instructions with Fresh Context](references/test-instruction-clarity.md) — MEDIUM (prevents 30-50% of instruction misinterpretations)
   - 7.2 [Test Skill Activation with Real User Phrases](references/test-trigger-phrases.md) — MEDIUM (catches 60-80% of activation failures before deployment)
   - 7.3 [Test Skills with Edge Case Inputs](references/test-edge-cases.md) — MEDIUM (prevents failures in production scenarios)
   - 7.4 [Test That Skills Do NOT Trigger on Unrelated Requests](references/test-negative-scenarios.md) — MEDIUM (prevents false positive activations)
8. [Maintenance and Distribution](references/_sections.md#8-maintenance-and-distribution) — **LOW-MEDIUM**
   - 8.1 [Audit Skills Before Installing from External Sources](references/maint-audit-security.md) — LOW-MEDIUM (prevents malicious code execution and data exfiltration)
   - 8.2 [Maintain a Changelog for Skill Updates](references/maint-changelog.md) — LOW-MEDIUM (enables users to understand updates before installing)
   - 8.3 [Package Skills as Plugins for Distribution](references/maint-plugin-packaging.md) — LOW-MEDIUM (enables one-command installation and updates)
   - 8.4 [Use Semantic Versioning for Skill Releases](references/maint-semantic-versioning.md) — LOW-MEDIUM (enables safe updates and rollbacks)

---

## References

1. [https://github.com/agentskills/agentskills/tree/main/skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref)
2. [https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
3. [https://code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
4. [https://github.com/anthropics/skills](https://github.com/anthropics/skills)
5. [https://modelcontextprotocol.info/docs/best-practices/](https://modelcontextprotocol.info/docs/best-practices/)
6. [https://www.promptingguide.ai/research/llm-agents](https://www.promptingguide.ai/research/llm-agents)
7. [https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |