---
title: Keep sandbox policy as shared data, not per-platform code
impact: HIGH
impactDescription: prevents three independently-drifting notions of "workspace-write"
tags: sandbox, cross-platform, policy-as-data, architecture
---

## Keep sandbox policy as shared data, not per-platform code

Most cross-platform sandbox implementations grow three parallel `#[cfg(unix)]` / `#[cfg(windows)]` engines — each with its own struct fields, its own validation, and inevitably its own bugs. Codex keeps one platform-neutral `SandboxPolicy` (plus `FileSystemSandboxPolicy`, `NetworkSandboxPolicy`), and each OS backend compiles the shared data into its native vocabulary (Seatbelt s-expressions, bubblewrap argv, Windows restricted token). The core never mentions `landlock`, `sandbox-exec`, or `CreateRestrictedToken`.

**Incorrect (three drifting structs, no shared schema):**

```rust
#[cfg(target_os = "macos")]
struct SeatbeltPolicy { /* custom fields */ }

#[cfg(target_os = "linux")]
struct LinuxPolicy { /* different fields, same concept */ }

// Adding a new "forbid /etc" restriction requires editing BOTH.
```

**Correct (one shared model, backends render):**

```rust
// sandboxing/src/manager.rs
pub enum SandboxType {
    None,
    MacosSeatbelt,
    LinuxSeccomp,
    WindowsRestrictedToken,
}

let (argv, arg0_override) = match sandbox {
    SandboxType::None => (os_argv_to_strings(raw_argv), None),
    #[cfg(target_os = "macos")]
    SandboxType::MacosSeatbelt => {
        let args = create_seatbelt_command_args_for_policies(
            os_argv_to_strings(raw_argv),
            &effective_file_system_policy,
            effective_network_policy,
            sandbox_policy_cwd,
            enforce_managed_network,
            network,
        );
        (args, Some(SEATBELT_ARG0.to_string()))
    }
    SandboxType::LinuxSeccomp => {
        let exe = codex_linux_sandbox_exe
            .ok_or(SandboxTransformError::MissingLinuxSandboxExecutable)?;
        /* render to bwrap argv */
    }
};
```

The shared `SandboxPolicy` is serializable and gets passed through argv to the Linux sandbox helper as JSON — so even sub-processes share the schema. Adding a new constraint is one edit in the shared type plus three backend render patches, not three independent rewrites.

Reference: `codex-rs/sandboxing/src/manager.rs:23`, `codex-rs/sandboxing/src/manager.rs:199`.
