---
title: Provide Both Short and Long Option Names
impact: HIGH
impactDescription: enables both quick typing and discoverability
tags: arg, short, long, options, usability
---

## Provide Both Short and Long Option Names

Use both `short` and `long` attributes for commonly-used options. Short flags enable quick typing; long flags improve script readability.

**Incorrect (long only for common options):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    verbose: bool,  // --verbose every time

    #[arg(long)]
    output: PathBuf,  // --output file.txt
}
// $ myapp --verbose --output result.txt  # Verbose to type
```

**Correct (short and long for common options):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short, long)]
    verbose: bool,  // -v or --verbose

    #[arg(short, long)]
    output: PathBuf,  // -o or --output
}
// $ myapp -v -o result.txt  # Quick
// $ myapp --verbose --output result.txt  # Readable in scripts
```

**Custom short names:**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short = 'n', long)]
    dry_run: bool,  // -n or --dry-run (not -d)

    #[arg(short = 'f', long)]
    force: bool,  // -f or --force
}
```

**When NOT to use short flags:**
- Rarely-used options (long-only is fine)
- Dangerous operations (avoid accidental triggers)

Reference: [Clap Arg Documentation](https://docs.rs/clap/latest/clap/struct.Arg.html)
