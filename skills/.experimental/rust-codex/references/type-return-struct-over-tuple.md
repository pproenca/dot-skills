---
title: Return Named Structs Over Tuples
impact: CRITICAL
impactDescription: prevents field-order confusion when destructuring
tags: type, structs, tuples, return-types
---

## Return Named Structs Over Tuples

When a function returns multiple values, use a named struct instead of a tuple. Tuple destructuring relies on position, so `(Vec<String>, Vec<OwnedFd>)` and `(Vec<OwnedFd>, Vec<String>)` are silently interchangeable. Named fields make the return contract explicit.

**Incorrect (tuple fields are positional and easily swapped):**

```rust
fn build_sandbox_command(
    cmd: &str,
) -> (Vec<String>, Vec<OwnedFd>, bool) {
    let args = vec![cmd.to_string()];
    let fds = vec![];
    let needs_network = false;
    (args, fds, needs_network)
}

// Caller destructures by position:
let (args, fds, network) = build_sandbox_command("ls");
```

**Correct (named fields prevent misuse):**

```rust
struct SandboxCommand {
    args: Vec<String>,
    preserved_fds: Vec<OwnedFd>,
    needs_network: bool,
}

fn build_sandbox_command(cmd: &str) -> SandboxCommand {
    SandboxCommand {
        args: vec![cmd.to_string()],
        preserved_fds: vec![],
        needs_network: false,
    }
}

let cmd = build_sandbox_command("ls");
// Access via cmd.args, cmd.preserved_fds, cmd.needs_network
```
