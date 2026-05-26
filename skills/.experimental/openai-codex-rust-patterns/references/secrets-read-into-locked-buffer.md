---
title: Read a secret into a zeroized stack buffer, then mlock it — never through stdin()
impact: HIGH
impactDescription: guarantees exactly one in-memory copy of an API key, locked out of swap and core dumps
tags: secrets, zeroize, mlock, api-key
---

## Read a secret into a zeroized stack buffer, then mlock it — never through stdin()

The obvious way to read an API key leaves copies everywhere: `io::stdin().read_to_string()` keeps the bytes in `Stdin`'s internal `BufReader` with no way to zero them, and every intermediate `String`/`format!` is another heap copy the allocator may later hand to unrelated code. Codex's responses-api proxy reads the key with a single `read(2)` into a fixed stack buffer, zeroizes that buffer on **every** exit path, builds exactly one heap `String`, then `leak()`s it to `&'static str` and `mlock(2)`s the page so it can never be swapped to disk or captured in a core dump.

**Incorrect (multiple un-scrubbable copies):**

```rust
// stdin()'s BufReader keeps a copy; `key` and `header` are un-zeroed heap allocations
let mut key = String::new();
std::io::stdin().read_to_string(&mut key)?;
let header = format!("Bearer {key}");
```

**Correct (one copy, zeroized buffer, mlock'd result):**

```rust
// responses-api-proxy/src/read_api_key.rs — read(2) into a stack buffer
let mut buf = [0u8; BUFFER_SIZE];
buf[..AUTH_HEADER_PREFIX.len()].copy_from_slice(AUTH_HEADER_PREFIX); // "Bearer "
// ... fill buf via read_fn, breaking on newline/EOF; on any error: buf.zeroize() then return ...

let header_value = String::from(header_str); // the only heap copy
buf.zeroize();                               // scrub the stack buffer immediately

let leaked: &'static mut str = header_value.leak();
mlock_str(leaked); // pin the page: no swap, no core-dump capture
Ok(leaked)
```

Every early return zeroizes first (`buf.zeroize(); return Err(...)`), so a parse failure can't leave the key on the stack. `read(2)` is chosen explicitly over `stdin()` because `Stdin`'s `BufReader` would retain an unreachable copy. See [[secrets-ctor-pre-main-hardening]] for the process-level hardening that protects this buffer.

Reference: `codex-rs/responses-api-proxy/src/read_api_key.rs:72`, `codex-rs/responses-api-proxy/src/read_api_key.rs:159`.
