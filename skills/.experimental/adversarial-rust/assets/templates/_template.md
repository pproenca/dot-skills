---
title: {Decision-oriented title — "{Verb} {object} {context}" or "Avoid {real anti-pattern}"}
tags: {prefix}, {concept}, {concept}
---

## {Title — must match frontmatter title exactly}

{WHY — 1-3 sentences. Name the alien mental model (what an engineer ported from
OO/GC/exception-based ecosystems does here) and its concrete consequence in Rust.
Then state what codex-rs actually does instead, with the workspace-level evidence
(a count, a lint, a named type) that proves the prescription is real practice.}

**Incorrect ({the alien pattern, named}):**

```rust
{The ported pattern with production-realistic names — never foo/bar. Keep the
diff to the Correct side minimal so the contrast is the lesson.}
```

**Correct ({the Rust it flattens to — cite how codex-rs ships it}):**

```rust
{The refactored form, adapted from real codex-rs code with real names
(Session, ThreadId, SandboxPolicy, ...). Must compile on Rust 1.86.}
```

**When NOT to use this pattern:** {The real exception codex-rs keeps, with the
named type or site — e.g. "EventSource stays a trait because the real impl is a
live terminal". Only include when a genuine carve-out exists.}

Reference: [codex-rs {path}](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/{path}#L{line})
