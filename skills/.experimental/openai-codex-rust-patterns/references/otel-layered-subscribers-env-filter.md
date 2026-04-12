---
title: Build per-layer EnvFilter instances with boxed fmt layers
impact: MEDIUM
impactDescription: enables independently-filtered sinks without per-layer generic divergence
tags: otel, tracing-subscriber, logging, layers
---

## Build per-layer EnvFilter instances with boxed fmt layers

A single global `EnvFilter` shared across sinks forces every layer to accept the same threshold — so you cannot have INFO stderr logs while JSON-file logs capture TRACE. And swapping format conditionally between pretty and JSON forces you to duplicate the entire registry build because the two fmt layer types diverge. Codex builds one `registry()` with every layer chained via `.with(...)`, gives each layer its own `EnvFilter` via a closure, and uses `.boxed()` inside a `match` on the format enum so both arms produce the same `Layer` trait object.

**Incorrect (shared filter, duplicated registry):**

```rust
let filter = EnvFilter::from_default_env();
if json_logs {
    tracing_subscriber::registry()
        .with(fmt::layer().json().with_filter(filter))
        .init();
} else {
    // Have to rebuild the entire registry — every layer duplicated.
    tracing_subscriber::registry()
        .with(fmt::layer().with_filter(filter))
        .init();
}
```

**Correct (per-layer filters, boxed fmt to unify types):**

```rust
// tui/src/lib.rs
let env_filter = || {
    EnvFilter::try_from_default_env().unwrap_or_else(|_| {
        EnvFilter::new("codex_core=info,codex_tui=info,codex_rmcp_client=info")
    })
};

let file_layer = tracing_subscriber::fmt::layer()
    .with_writer(non_blocking)
    .with_target(true)
    .with_ansi(false)
    .with_span_events(
        tracing_subscriber::fmt::format::FmtSpan::NEW
            | tracing_subscriber::fmt::format::FmtSpan::CLOSE,
    )
    .with_filter(env_filter());

// app-server/src/lib.rs — .boxed() unifies divergent generic types
let stderr_fmt: StderrLogLayer = match log_format_from_env() {
    LogFormat::Json => tracing_subscriber::fmt::layer()
        .json()
        .with_writer(std::io::stderr)
        .with_span_events(FmtSpan::FULL)
        .with_filter(EnvFilter::from_default_env())
        .boxed(),
    LogFormat::Default => tracing_subscriber::fmt::layer()
        .with_writer(std::io::stderr)
        .with_span_events(FmtSpan::FULL)
        .with_filter(EnvFilter::from_default_env())
        .boxed(),
};

let _ = tracing_subscriber::registry()
    .with(stderr_fmt)
    .with(feedback_layer)
    .with(log_db_layer)
    .with(otel_logger_layer)
    .with(otel_tracing_layer)
    .try_init();
```

`FmtSpan::NEW | FmtSpan::CLOSE` emits one record at span entry and one at close — giving timing for every instrumented function without writing any `info!("started")` / `info!("done")` pairs. `try_init` (vs `init`) is used because tests may have already set a subscriber.

Reference: `codex-rs/tui/src/lib.rs:898`, `codex-rs/app-server/src/lib.rs:489`.
