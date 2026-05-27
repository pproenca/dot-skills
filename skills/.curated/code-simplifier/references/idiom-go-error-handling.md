---
title: Handle Errors Immediately After the Call
impact: LOW-MEDIUM
impactDescription: Prevents error masking, ensures 100% of error paths are explicitly handled
tags: idiom, go, error-handling, explicit-errors
---

## Handle Errors Immediately After the Call

Go's explicit error handling is a feature, not a burden. Always check errors immediately after a function call returns—don't defer error checks or accumulate them. This pattern makes control flow explicit and ensures errors are handled in context where you have the most information.

**Incorrect (deferred or accumulated error checking):**

```go
// Bad: errors accumulate, hard to know which failed
func processFiles(paths []string) error {
    var lastErr error

    for _, path := range paths {
        data, err := os.ReadFile(path)
        if err != nil {
            lastErr = err // Previous errors lost
        }

        result, err := process(data)
        if err != nil {
            lastErr = err
        }

        err = save(result)
        if err != nil {
            lastErr = err
        }
    }

    return lastErr
}

// Bad: ignoring error
func quickRead(path string) []byte {
    data, _ := os.ReadFile(path) // Silent failure
    return data
}
```

**Correct (handle immediately with context):**

```go
func processFiles(paths []string) error {
    for _, path := range paths {
        data, err := os.ReadFile(path)
        if err != nil {
            return fmt.Errorf("reading %s: %w", path, err)
        }

        result, err := process(data)
        if err != nil {
            return fmt.Errorf("processing %s: %w", path, err)
        }

        if err := save(result); err != nil {
            return fmt.Errorf("saving result for %s: %w", path, err)
        }
    }

    return nil
}

// When you need to continue despite errors, collect them explicitly
func processAllFiles(paths []string) error {
    var errs []error

    for _, path := range paths {
        if err := processFile(path); err != nil {
            errs = append(errs, fmt.Errorf("%s: %w", path, err))
            continue // Explicit decision to continue
        }
    }

    return errors.Join(errs...) // Go 1.20+
}
```

### Wrapping Errors for Context

```go
// Always add context when propagating
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("load config: %w", err)
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config %s: %w", path, err)
    }

    return &cfg, nil
}
```

### When Ignoring Errors is Acceptable

```go
// Explicitly document why it's safe to ignore
_ = writer.Close() // Best effort cleanup, already returning another error

// Or use a helper for intentional ignores
func must[T any](v T, err error) T {
    if err != nil {
        panic(err)
    }
    return v
}
```

### Benefits

- Errors handled with full context available
- Control flow is explicit and linear
- Error wrapping builds informative stack traces
- No hidden failures or silent data corruption
