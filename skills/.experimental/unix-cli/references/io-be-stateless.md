---
title: Design Stateless Operations
impact: HIGH
impactDescription: enables reliable automation and recovery
tags: io, stateless, idempotent, automation, reliability
---

## Design Stateless Operations

Prefer stateless operations that don't depend on hidden state. Given the same inputs, the tool should produce the same outputs. This enables reliable automation and easy recovery from failures.

**Incorrect (depends on hidden state):**

```c
static int run_count = 0;  // Persisted somewhere

int main(int argc, char *argv[]) {
    load_state(&run_count);
    run_count++;

    if (run_count > 3) {
        fprintf(stderr, "Trial expired\n");
        return 1;
    }

    process(argv[1]);
    save_state(run_count);
}
```

```bash
# Behavior depends on invisible state
$ mytool data.txt    # Works
$ mytool data.txt    # Works
$ mytool data.txt    # Works
$ mytool data.txt    # Fails! But why?
Trial expired
```

**Correct (stateless, deterministic):**

```c
int main(int argc, char *argv[]) {
    // All state comes from explicit inputs
    Config config = parse_config(argc, argv);

    // Same inputs always produce same outputs
    Result result = process(config.input_file, config.options);

    output_result(result, config.output_file);
    return result.success ? 0 : 1;
}
```

```bash
# Deterministic behavior
$ mytool data.txt         # Same result every time
$ mytool data.txt         # Same result every time
$ mytool --format=csv data.txt  # Different options, predictable result

# Easy to automate and retry
$ mytool data.txt || mytool data.txt  # Retry makes sense
```

**When state is necessary:**
- Make it explicit with config files or database
- Document the state location
- Provide `--reset` or `--clean` options
- Consider `--dry-run` to preview without modifying state

Reference: [The Twelve-Factor App - Processes](https://12factor.net/processes)
