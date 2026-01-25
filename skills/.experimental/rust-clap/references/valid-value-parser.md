---
title: Use value_parser for Custom Validation
impact: HIGH
impactDescription: validates input before business logic with clear errors
tags: valid, value-parser, validation, parsing, custom
---

## Use value_parser for Custom Validation

Use `value_parser` with a custom function to validate and parse arguments into domain types with meaningful error messages.

**Incorrect (validation in main):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    port: u16,
}

fn main() {
    let cli = Cli::parse();
    if cli.port == 0 {
        eprintln!("Error: port cannot be 0");
        std::process::exit(1);  // Validation after parsing
    }
}
```

**Correct (validation during parsing):**

```rust
fn parse_port(s: &str) -> Result<u16, String> {
    let port: u16 = s.parse().map_err(|_| format!("'{}' is not a valid port number", s))?;
    if port == 0 {
        return Err("port cannot be 0".to_string());
    }
    if port < 1024 {
        return Err(format!("port {} requires root privileges, use 1024 or higher", port));
    }
    Ok(port)
}

#[derive(Parser)]
struct Cli {
    #[arg(long, value_parser = parse_port)]
    port: u16,
}

fn main() {
    let cli = Cli::parse();
    // port is guaranteed valid here
}
```

**Built-in range parser:**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, value_parser = clap::value_parser!(u16).range(1..=65535))]
    port: u16,
}
```

Reference: [Clap Value Parser](https://docs.rs/clap/latest/clap/builder/struct.ValueParser.html)
