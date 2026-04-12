---
title: Prefer Named Flags Over Positional Arguments
impact: HIGH
impactDescription: prevents argument-order guessing and future breakage
tags: input, flags, positional, self-documenting
---

## Prefer Named Flags Over Positional Arguments

Positional arguments are opaque: `mycli deploy staging v1.2.3 3` requires the agent to remember which slot means what. Named flags are self-documenting: `mycli deploy --env staging --tag v1.2.3 --replicas 3` tells the agent (and the reader of a script) exactly what each value is. Positional args also break when you need to add an optional value later — flags allow additive growth. Reserve positional args for at most one primary operand (like `cp source dest`).

**Incorrect (four positional arguments the agent must order correctly):**

```go
package main

import (
    "fmt"
    "os"
)

func main() {
    if len(os.Args) != 5 {
        fmt.Fprintln(os.Stderr, "usage: deploy <env> <tag> <replicas> <region>")
        os.Exit(2)
    }
    env, tag, replicas, region := os.Args[1], os.Args[2], os.Args[3], os.Args[4]
    runDeploy(env, tag, replicas, region)
}

// Agent must memorize: deploy staging v1.2.3 3 us-east-1
// Swapping two positions silently works but deploys wrong thing
```

**Correct (flags are self-documenting and order-independent):**

```go
package main

import (
    "flag"
    "fmt"
    "os"
)

func main() {
    env := flag.String("env", "", "target environment (staging|production)")
    tag := flag.String("tag", "", "image tag to deploy")
    replicas := flag.Int("replicas", 3, "replica count")
    region := flag.String("region", "us-east-1", "target region")
    flag.Parse()

    if *env == "" || *tag == "" {
        fmt.Fprintln(os.Stderr, "Error: --env and --tag are required.")
        fmt.Fprintln(os.Stderr, "  deploy --env staging --tag v1.2.3")
        os.Exit(2)
    }
    runDeploy(*env, *tag, *replicas, *region)
}

// Agent invokes: deploy --env staging --tag v1.2.3
// Any order works, and --region has a sensible default
```

**When NOT to use this pattern:**
- A single primary operand is fine as positional: `cp source dest`, `rm file`, `cat file`
- Variadic inputs like `rm file1 file2 file3` are clearer positional than `rm --file a --file b`

Reference: [clig.dev — Prefer flags to arguments](https://clig.dev/#arguments-and-flags)
