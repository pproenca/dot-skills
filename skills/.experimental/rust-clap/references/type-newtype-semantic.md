---
title: Use Newtypes for Semantic Distinction
impact: HIGH
impactDescription: prevents argument confusion and enables domain validation
tags: type, newtype, semantic, domain, validation
---

## Use Newtypes for Semantic Distinction

Wrap primitive types in newtypes when arguments have different semantic meanings. This prevents accidentally swapping arguments and enables domain-specific validation.

**Incorrect (primitive types easily confused):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    port: u16,

    #[arg(long)]
    timeout_ms: u16,  // Same type as port, easy to confuse
}

fn connect(port: u16, timeout: u16) {  // Which is which?
    // ...
}

fn main() {
    let cli = Cli::parse();
    connect(cli.timeout_ms, cli.port);  // Swapped! Compiles fine.
}
```

**Correct (newtypes prevent confusion):**

```rust
#[derive(Clone)]
struct Port(u16);

#[derive(Clone)]
struct TimeoutMs(u16);

impl std::str::FromStr for Port {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let port: u16 = s.parse().map_err(|e| format!("{}", e))?;
        if port == 0 {
            return Err("port cannot be 0".to_string());
        }
        Ok(Port(port))
    }
}

#[derive(Parser)]
struct Cli {
    #[arg(long)]
    port: Port,

    #[arg(long)]
    timeout_ms: TimeoutMs,
}

fn connect(port: Port, timeout: TimeoutMs) {  // Types are distinct
    // ...
}
```

**Benefits:**
- Compiler prevents argument swapping
- Domain validation in FromStr implementation
- Self-documenting code

Reference: [Clap Custom Value Parsing](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html)
