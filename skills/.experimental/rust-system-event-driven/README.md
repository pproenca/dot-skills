# Rust System Event-Driven Best Practices

Comprehensive best practices guide for event-driven system programming in Rust, covering async runtimes, channels, threading, sockets, terminals, signals, and streaming I/O.

## Overview/Structure

```
rust-system-event-driven/
├── SKILL.md                    # Entry point with quick reference
├── README.md                   # This file
├── metadata.json               # Version, org, references
├── references/
│   ├── _sections.md            # Category definitions
│   ├── async-*.md              # Async runtime patterns (6 rules)
│   ├── chan-*.md               # Channel communication (5 rules)
│   ├── sync-*.md               # Threading & synchronization (6 rules)
│   ├── net-*.md                # Socket & network I/O (6 rules)
│   ├── term-*.md               # Terminal & TTY handling (5 rules)
│   ├── sig-*.md                # Signal & process control (4 rules)
│   ├── io-*.md                 # File I/O streaming (5 rules)
│   └── loop-*.md               # Event loop architecture (5 rules)
└── assets/
    └── templates/
        └── _template.md        # Rule template for extensions
```

## Getting Started

```bash
# Install dependencies (if using in a skill project)
pnpm install

# Build the compiled document
pnpm build

# Validate skill structure
pnpm validate
```

## Creating a New Rule

1. Choose the appropriate category based on the rule's domain
2. Create a new file: `references/{prefix}-{descriptive-name}.md`
3. Use the template from `assets/templates/_template.md`
4. Add the rule to the Quick Reference section in `SKILL.md`

### Category Prefixes

| Prefix | Category | Impact |
|--------|----------|--------|
| `async-` | Async Runtime Patterns | CRITICAL |
| `chan-` | Channel Communication | CRITICAL |
| `sync-` | Threading & Synchronization | HIGH |
| `net-` | Socket & Network I/O | HIGH |
| `term-` | Terminal & TTY Handling | MEDIUM-HIGH |
| `sig-` | Signal & Process Control | MEDIUM |
| `io-` | File I/O Streaming | MEDIUM |
| `loop-` | Event Loop Architecture | LOW-MEDIUM |

## Rule File Structure

Each rule file follows this structure:

```markdown
---
title: Rule Title
impact: CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM|LOW
impactDescription: Quantified impact (e.g., "prevents deadlocks")
tags: prefix, technique, related-concepts
---

## Rule Title

Brief explanation of why this matters.

**Incorrect (what's wrong):**

\`\`\`rust
// Bad example
\`\`\`

**Correct (what's right):**

\`\`\`rust
// Good example
\`\`\`

Reference: [Link](url)
```

## File Naming Convention

Files follow the pattern: `{prefix}-{descriptive-slug}.md`

- `prefix`: Category identifier (see table above)
- `descriptive-slug`: Kebab-case description of the rule

Examples:
- `async-spawn-blocking.md` - Use spawn_blocking for CPU-bound work
- `chan-bounded-backpressure.md` - Use bounded channels for backpressure
- `net-timeout-all-io.md` - Add timeouts to all network operations

## Impact Levels

| Level | Description |
|-------|-------------|
| CRITICAL | Causes deadlocks, data loss, or system crashes |
| HIGH | Significant performance impact or resource exhaustion |
| MEDIUM-HIGH | Important for reliability or user experience |
| MEDIUM | Improves code quality and maintainability |
| LOW-MEDIUM | Architectural patterns and best practices |

## Scripts

- `pnpm validate` - Validate skill structure against guidelines
- `pnpm build` - Generate compiled AGENTS.md document

## Contributing

1. Follow the rule template exactly
2. Provide production-realistic code examples
3. Quantify impact where possible
4. Include authoritative references
5. Keep incorrect/correct examples minimal diff

## Acknowledgments

- [Tokio Documentation](https://tokio.rs/tokio/tutorial)
- [The Rust Async Book](https://rust-lang.github.io/async-book/)
- [Alice Ryhl - Actors with Tokio](https://ryhl.io/blog/actors-with-tokio/)
- [crossterm Documentation](https://docs.rs/crossterm/latest/crossterm/)
