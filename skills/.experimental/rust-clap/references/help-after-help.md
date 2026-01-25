---
title: Use after_help for Examples and Context
impact: MEDIUM
impactDescription: provides usage examples in help output
tags: help, after-help, examples, documentation, usability
---

## Use after_help for Examples and Context

Use `after_help` or `after_long_help` to add usage examples and additional context at the end of help output.

**Incorrect (help text only describes options):**

```rust
#[derive(Parser)]
#[command(about = "Process data files")]
struct Cli {
    #[arg(short, long)]
    input: PathBuf,

    #[arg(short, long)]
    output: PathBuf,
}
// --help shows options but no examples
```

**Correct (examples in after_help):**

```rust
const EXAMPLES: &str = "\
EXAMPLES:
    # Convert JSON to YAML
    myapp -i data.json -o data.yaml

    # Process multiple files
    myapp -i input/*.json -o output/

    # Read from stdin
    cat data.json | myapp -i - -o result.yaml

ENVIRONMENT:
    MYAPP_CONFIG    Path to config file (optional)
";

#[derive(Parser)]
#[command(about = "Process data files", after_help = EXAMPLES)]
struct Cli {
    #[arg(short, long)]
    input: PathBuf,

    #[arg(short, long)]
    output: PathBuf,
}
```

**Different content for short vs long help:**

```rust
#[derive(Parser)]
#[command(
    after_help = "Run with --help for examples",
    after_long_help = EXAMPLES
)]
struct Cli { /* ... */ }
// -h shows short hint
// --help shows full examples
```

Reference: [Clap Command after_help](https://docs.rs/clap/latest/clap/struct.Command.html#method.after_help)
