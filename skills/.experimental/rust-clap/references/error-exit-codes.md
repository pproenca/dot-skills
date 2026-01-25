---
title: Use Appropriate Exit Codes
impact: MEDIUM
impactDescription: enables proper error handling in scripts and CI
tags: error, exit-codes, scripting, ci, automation
---

## Use Appropriate Exit Codes

Use meaningful exit codes to communicate error types to calling scripts and CI systems.

**Incorrect (always exit 1 on error):**

```rust
fn main() {
    let cli = Cli::parse();
    if let Err(e) = run(cli) {
        eprintln!("Error: {}", e);
        std::process::exit(1);  // Same code for all errors
    }
}
```

**Correct (distinct exit codes):**

```rust
#[derive(Debug)]
enum ExitCode {
    Success = 0,
    GeneralError = 1,
    ConfigError = 2,
    IoError = 3,
    NetworkError = 4,
}

fn main() {
    let cli = match Cli::try_parse() {
        Ok(cli) => cli,
        Err(e) => {
            e.exit();  // Clap uses exit code 2 for usage errors
        }
    };

    let code = match run(cli) {
        Ok(()) => ExitCode::Success,
        Err(AppError::Config(e)) => {
            eprintln!("Configuration error: {}", e);
            ExitCode::ConfigError
        }
        Err(AppError::Io(e)) => {
            eprintln!("I/O error: {}", e);
            ExitCode::IoError
        }
        Err(AppError::Network(e)) => {
            eprintln!("Network error: {}", e);
            ExitCode::NetworkError
        }
    };

    std::process::exit(code as i32);
}
```

**Common conventions:**
- 0: Success
- 1: General error
- 2: Usage/argument error (clap default)
- 126: Command not executable
- 127: Command not found

Reference: [Clap Error Handling](https://docs.rs/clap/latest/clap/error/struct.Error.html)
