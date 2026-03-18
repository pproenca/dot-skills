---
title: Use Descriptive Context Strings Explaining the Operation
impact: CRITICAL
impactDescription: reduces debugging time by 2-5x with actionable messages
tags: err, context, error-messages, debugging
---

## Use Descriptive Context Strings Explaining the Operation

Context strings must name the operation being performed and include relevant variables. A context string of "error" or "failed" provides no diagnostic value. The string should let a developer identify the failing component without reading a stack trace.

**Incorrect (vague context provides no diagnostic value):**

```rust
let codex_home = find_codex_home()
    .context("failed")?;
let config = load_config(&config_path)
    .context("error")?;
let client = get_mcp_client(server_id)
    .context("could not get client")?;
```

**Correct (names the operation and relevant identifiers):**

```rust
let codex_home = find_codex_home()
    .context("failed to resolve CODEX_HOME")?;
let config = load_config(&config_path)
    .context("failed to load Codex config")?;
let client = get_mcp_client(server_id)
    .context("failed to get client")?;
```
