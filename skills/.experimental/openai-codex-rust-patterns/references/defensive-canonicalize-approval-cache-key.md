---
title: Canonicalize shell wrappers before hashing approval keys
impact: HIGH
impactDescription: avoids re-prompting users for logically identical commands and blocks cache collisions between wrapped scripts
tags: defensive, canonicalization, approval, security
---

## Canonicalize shell wrappers before hashing approval keys

A naive approval cache keyed on `argv` re-prompts every time the same command arrives with a different shell wrapper — `bash -lc` vs `/bin/bash -lc` vs a heredoc. Codex canonicalizes first: unwrap simple `sh -lc "cargo test"` wrappers into their inner argv, and for unparseable scripts replace the shell path with a sentinel (`__codex_shell_script__`) while keeping the exact script text. The sentinel never collides with a real executable, so a match means "identical script", not "close enough".

**Incorrect (caches on raw argv — re-prompts on every wrapper variation):**

```rust
fn approval_key(command: &[String]) -> String {
    command.join(" ")
}
// "bash -lc 'cargo test'" and "/bin/bash -lc 'cargo test'"
// hash to different keys even though they run the same script.
```

**Correct (unwrap simple wrappers, replace interpreter with sentinel otherwise):**

```rust
// core/src/command_canonicalization.rs
pub(crate) fn canonicalize_command_for_approval(
    command: &[String],
) -> Vec<String> {
    if let Some(parsed) = parse_shell_lc_plain_commands(command)
        && let [single_command] = parsed.as_slice()
    {
        return single_command.clone();
    }
    if let Some((_shell, script)) = extract_bash_command(command) {
        let shell_mode = command.get(1).cloned().unwrap_or_default();
        return vec![
            CANONICAL_BASH_SCRIPT_PREFIX.to_string(),
            shell_mode,
            script.to_string(),
        ];
    }
    command.to_vec()
}
```

The `&& let [single_command] = ...` guard refuses to collapse to an inner argv unless the parse produced exactly one command — a compound script cannot be mistakenly matched against an approval for one of its sub-commands. The sentinel constant `CANONICAL_BASH_SCRIPT_PREFIX` is chosen so it cannot appear as a legitimate binary name.

Reference: `codex-rs/core/src/command_canonicalization.rs:14`.
