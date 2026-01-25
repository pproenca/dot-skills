---
title: Use try_parse for Graceful Error Handling
impact: MEDIUM-HIGH
impactDescription: enables custom error recovery instead of immediate exit
tags: valid, try-parse, error-handling, recovery, graceful
---

## Use try_parse for Graceful Error Handling

Use `try_parse()` instead of `parse()` when you need to handle parsing errors gracefully rather than exiting immediately.

**Incorrect (parse exits on error):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    config: PathBuf,
}

fn main() {
    let cli = Cli::parse();  // Exits process on error
    // Cannot do cleanup or custom error formatting
}
```

**Correct (try_parse for custom handling):**

```rust
use clap::Parser;

#[derive(Parser)]
struct Cli {
    #[arg(long)]
    config: PathBuf,
}

fn main() {
    let cli = match Cli::try_parse() {
        Ok(cli) => cli,
        Err(e) => {
            // Log to file before showing error
            log_error(&e);

            // Custom error formatting
            if e.kind() == clap::error::ErrorKind::MissingRequiredArgument {
                eprintln!("Try 'myapp --help' for more information");
            }

            e.exit();  // Exit with proper code
        }
    };
}
```

**Use cases for try_parse:**
- Custom error formatting or styling
- Logging errors before exit
- Cleanup actions on failure
- Integration with error handling frameworks

Reference: [Clap Parser Trait](https://docs.rs/clap/latest/clap/trait.Parser.html#method.try_parse)
