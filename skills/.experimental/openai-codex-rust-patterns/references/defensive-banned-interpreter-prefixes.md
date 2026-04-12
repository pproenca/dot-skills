---
title: Avoid learning allowlist rules for general-purpose interpreters
impact: CRITICAL
impactDescription: prevents approval amendments from green-lighting arbitrary interpreter flags
tags: defensive, allowlist, security, command-approval
---

## Avoid learning allowlist rules for general-purpose interpreters

When a system learns approvals and offers "always allow commands with this prefix", a single careless click on `python3 -c "import os; os.system(...)"` would green-light arbitrary code execution forever. Codex keeps a `BANNED_PREFIX_SUGGESTIONS` list of interpreter prefixes that the amendment suggester refuses to propose, using exact-length-and-sequence matching rather than `starts_with`, so legitimate rules like `python3 myscript.py` remain allowable while escape hatches like `python3 -c` are blocked.

**Incorrect (learns an unbounded allowlist rule):**

```rust
// User approved "python3 -c 'print(1)'", offer to remember the prefix
fn derive_amendment_from_approval(argv: &[String]) -> Option<Rule> {
    let prefix = argv.iter().take(2).cloned().collect();
    Some(Rule::allow_prefix(prefix))  // allows EVERY `python3 -c ...` forever
}
```

**Correct (explicit interpreter denylist, exact-sequence match):**

```rust
// core/src/exec_policy.rs
static BANNED_PREFIX_SUGGESTIONS: &[&[&str]] = &[
    &["python3", "-c"], &["python", "-c"],
    &["bash", "-lc"], &["sh", "-c"], &["sh", "-lc"],
    &["pwsh", "-Command"], &["node", "-e"],
    &["perl", "-e"], &["ruby", "-e"], &["osascript"],
];

if BANNED_PREFIX_SUGGESTIONS.iter().any(|banned| {
    prefix_rule.len() == banned.len()
        && prefix_rule.iter().map(String::as_str).eq(banned.iter().copied())
}) {
    return None; // refuse to suggest a permanent allow rule
}
```

The match is exact-length and exact-sequence — `python3 script.py` is still policy-able (different length), but `python3 -c` is not. Adding a new interpreter takes one line in a central list, not a code audit across every call site.

Reference: `codex-rs/core/src/exec_policy.rs:50`, `codex-rs/core/src/exec_policy.rs:711`.
