# OpenAI Codex Rust Patterns — Skill Repository

## Overview

This skill distills non-obvious Rust coding patterns from [`openai/codex`](https://github.com/openai/codex) — specifically the `codex-rs/` workspace, a 72-crate, 1,418-file Rust codebase that implements the Codex CLI coding agent. Every rule here is extracted from actual production code written by the codex team (Michael Bolin, jif-oai, Ahmed Ibrahim, Eric Traut, Pavel Krymets, and others) and cites the exact file where the pattern lives.

Unlike most Rust "best practices" skills, the rules here are not copied from the Rust book or tutorial sites. They come from reading the code of people who ship a production coding agent that must survive LLM-generated input, cross-platform sandboxing, bursty streaming, and a 75-crate workspace — and they encode judgment that isn't obvious until you've been burned.

## Getting Started

```bash
pnpm install
pnpm build
pnpm validate
```

The skill is read by Claude Code automatically when it triggers. Agents can also browse `references/` directly to read individual rules.

To regenerate `AGENTS.md` after adding rules:

```bash
node /Users/pedroproenca/.claude/plugins/marketplaces/dot-claude/plugins/dev-skill/scripts/build-agents-md.js ~/.claude/skills/.experimental/openai-codex-rust-patterns
```

To validate the skill after changes:

```bash
node /Users/pedroproenca/.claude/plugins/marketplaces/dot-claude/plugins/dev-skill/scripts/validate-skill.js ~/.claude/skills/.experimental/openai-codex-rust-patterns
```

## Creating a New Rule

1. Pick a category prefix from `references/_sections.md` (e.g. `async`, `defensive`, `errors`).
2. Create `references/{prefix}-{slug}.md` — filename is all lowercase kebab-case.
3. Fill in the frontmatter: `title`, `impact`, `impactDescription`, `tags` (first tag must equal the category prefix).
4. Write the body: H2 heading matching the title, a 2–4 sentence explanation of the WHY, then `**Incorrect (annotation):**` and `**Correct (annotation):**` code blocks with language specifiers.
5. Re-run `build-agents-md.js` and `validate-skill.js`.

## Rule File Structure

Every rule file has this shape:

```markdown
---
title: Imperative Verb + Noun Phrase
impact: CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM | LOW-MEDIUM | LOW
impactDescription: Quantified outcome (e.g., "prevents silent data loss on cancel")
tags: {prefix}, {technique}, {tool}, {concept}
---

## Imperative Verb + Noun Phrase

Explanation of the pattern and why it works — the reasoning the reader should
internalize so they can apply it to novel situations. 2–4 sentences.

**Incorrect (describes the failure mode):**

```rust
// naive / broken version
```

**Correct (describes the benefit):**

```rust
// the codex-rs pattern — cited with file:line in the explanation
```

Reference: `codex-rs/{crate}/src/{path}.rs`
```

## File Naming Convention

- Directory: `references/`
- Pattern: `{prefix}-{slug}.md`
- Example: `async-abort-on-drop-handle.md`
- The prefix must match one of the category prefixes defined in `references/_sections.md`.
- Slugs are lowercase kebab-case, ideally short enough to read in a TOC.

## Impact Levels

The skill uses six levels, ordered highest to lowest:

| Level | When to use |
|-------|-------------|
| CRITICAL | Pattern prevents a class of production outages or silent corruption. The reader should never ship without it. |
| HIGH | Pattern saves meaningful debugging time, prevents common correctness bugs, or unblocks a whole architecture. |
| MEDIUM-HIGH | Pattern is load-bearing for a specific concern (tests, protocols) and is non-obvious. |
| MEDIUM | Pattern cleans up a real friction point. The codebase suffers without it but does not crash. |
| LOW-MEDIUM | Pattern is specific to a UI layer or tooling surface; broadly applicable but narrower in scope. |
| LOW | Minor stylistic or convention-level guidance. |

Impact inflation is a red flag — the distillation rubric expects at most 1–2 CRITICAL categories.

## Scripts

| Script | Purpose |
|--------|---------|
| `dev-skill/scripts/validate-skill.js` | Runs structural + substance validation. |
| `dev-skill/scripts/build-agents-md.js` | Regenerates `AGENTS.md` from rule files. |

Both scripts live in the dev-skill plugin, not inside the skill itself.

## Contributing

Additions should:

1. Come from real production code, not invented examples.
2. Cite the exact `codex-rs/` file path for traceability.
3. Explain the WHY the pattern matters — what goes wrong without it.
4. Include both an incorrect and a correct example that differ minimally.
5. Pass `validate-skill.js` with zero errors before submission.

Rules that merely restate Rust book material (use Result, prefer enums, avoid unwrap) are rejected — the quality bar is "surprising to a mid-level Rust engineer".
