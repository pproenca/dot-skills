---
title: Use env for Environment Variable Fallback
impact: HIGH
impactDescription: enables 12-factor app configuration patterns
tags: arg, env, environment, configuration, twelve-factor
---

## Use env for Environment Variable Fallback

Use the `env` attribute to allow arguments to be set via environment variables. This enables flexible configuration in different environments.

**Incorrect (CLI-only configuration):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    database_url: String,  // Must always pass on command line
}

// Production requires: myapp --database-url postgres://...
// Every invocation needs the full connection string
```

**Correct (environment variable fallback):**

```rust
#[derive(Parser)]
struct Cli {
    /// Database connection URL
    #[arg(long, env = "DATABASE_URL")]
    database_url: String,
}

// Can set once: export DATABASE_URL=postgres://...
// Then just run: myapp
// Or override: myapp --database-url sqlite://local.db
```

**With prefix convention:**

```rust
#[derive(Parser)]
#[command(name = "myapp")]
struct Cli {
    #[arg(long, env = "MYAPP_LOG_LEVEL", default_value = "info")]
    log_level: String,

    #[arg(long, env = "MYAPP_PORT", default_value_t = 3000)]
    port: u16,
}
```

**Benefits:**
- CLI args take precedence over env vars
- Works with Docker, systemd, and cloud platforms
- `--help` shows the env var name

Reference: [Clap Environment Variables](https://docs.rs/clap/latest/clap/struct.Arg.html#method.env)
