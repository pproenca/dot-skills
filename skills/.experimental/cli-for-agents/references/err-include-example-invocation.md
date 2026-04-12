---
title: Include a Correct Example Invocation in Error Messages
impact: HIGH
impactDescription: reduces re-reads of --help after a failed command
tags: err, messages, examples, usage
---

## Include a Correct Example Invocation in Error Messages

When a flag is missing or wrong, the agent's next move is to re-read `--help` to find the right shape. Short-circuit that by including a complete, correct example invocation in the error itself. "Error: --tag required. Example: mycli deploy --env staging --tag v1.2.3" gives the agent everything it needs without another tool call.

**Incorrect (error is the error text only):**

```rust
use clap::Parser;

#[derive(Parser)]
struct Args {
    #[arg(long)]
    env: String,
    #[arg(long)]
    tag: String,
}

fn main() {
    let args = Args::parse();
    // clap default: "error: the following required arguments were not provided: --tag"
    deploy(&args.env, &args.tag);
}
```

**Correct (error includes a complete example):**

```rust
use clap::{Parser, CommandFactory};

#[derive(Parser)]
struct Args {
    #[arg(long, help = "target environment (staging|production)")]
    env: Option<String>,
    #[arg(long, help = "image tag to deploy")]
    tag: Option<String>,
}

fn main() {
    let args = Args::parse();
    let (Some(env), Some(tag)) = (args.env.as_deref(), args.tag.as_deref()) else {
        eprintln!("Error: --env and --tag are required.");
        eprintln!("  mycli deploy --env staging --tag v1.2.3");
        eprintln!("  mycli deploy --env production --tag $(mycli build --output tag-only)");
        std::process::exit(2);
    };
    deploy(env, tag);
}
```

**Benefits:**
- Agent copies the example verbatim on retry
- Multiple examples teach variation without listing every flag
- No round-trip to `--help` after a failed command

Reference: [clig.dev — Errors should suggest fixes](https://clig.dev/#errors)
