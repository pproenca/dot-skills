---
title: Mount /dev/null over the first missing path component
impact: HIGH
impactDescription: prevents mkdir-and-write escapes through non-existent protected paths
tags: sandbox, linux, bwrap, toctou
---

## Mount /dev/null over the first missing path component

A naive read-only allowlist that says "`.codex/` is read-only inside the writable workspace" has a gap: if `.codex/` does not exist at sandbox setup time, there is nothing to bind-mount over, and a child process can `mkdir .codex` and write whatever it wants. Codex walks the protected path, finds the first non-existent component, and bind-mounts `/dev/null` onto it. That turns the would-be directory into an unwritable character device, so `mkdir` fails with `ENOTDIR`.

**Incorrect (only mounts existing paths — gap on non-existent ones):**

```rust
if subpath.exists() {
    args.push("--ro-bind".to_string());
    args.push(path_to_string(subpath));
    args.push(path_to_string(subpath));
}
// Else: child can mkdir the protected name and write freely.
```

**Correct (mount /dev/null over the first missing component):**

```rust
// linux-sandbox/src/bwrap.rs
if !subpath.exists() {
    if let Some(first_missing_component) =
        find_first_non_existent_component(subpath)
        && is_within_allowed_write_paths(
            &first_missing_component,
            allowed_write_paths,
        )
    {
        args.push("--ro-bind".to_string());
        args.push("/dev/null".to_string());
        args.push(path_to_string(&first_missing_component));
    }
    return;
}

// The file-fd-mount variant for unreadable carveouts:
if preserved_files.is_empty() {
    preserved_files.push(File::open("/dev/null")?);
}
let null_fd = preserved_files[0].as_raw_fd().to_string();
args.push("--perms".to_string());
args.push("000".to_string());
args.push("--ro-bind-data".to_string());
args.push(null_fd);
args.push(path_to_string(unreadable_root));
```

The file-fd side uses `preserved_files: Vec<File>` to keep the `/dev/null` handle alive across the spawn. The equivalent Seatbelt policy blocks the same hole via `(require-not (literal ...))` alongside `(require-not (subpath ...))` because Seatbelt's `(subpath)` predicate does not cover first-time creation of the directory itself.

Reference: `codex-rs/linux-sandbox/src/bwrap.rs:513`, `codex-rs/linux-sandbox/src/bwrap.rs:605`.
