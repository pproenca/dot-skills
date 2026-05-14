---
title: Parse Placeholder Values from Examples
impact: HIGH
impactDescription: silent value coercion hides bugs that mutation testing is designed to catch, causing 100% false-pass rate on coerced mutations
tags: handler, values, parsing, placeholder, type-conversion
---

## Parse Placeholder Values from Examples

Step handlers receive string values from example objects and must convert them to project types. This conversion is where the pipeline's string-everywhere design meets the project's actual type system. Strict handling ensures mutations are detectable.

### Spec Requirements

1. Handlers must **fetch placeholder values by name** from the current example object.
2. Handlers must **parse string values into project types** as needed (e.g., `"42"` to integer, `"true"` to boolean).
3. **Missing** values must fail the current test.
4. **Malformed** values must fail the current test.
5. **Semantically invalid** values must fail the current test.

### Why Strict Failure

The mutation model depends on handlers detecting bad values. When the mutator changes `"42"` to `"49"`, the handler that parses this integer and feeds it to the application must produce a different outcome. If the handler silently coerces `"49"` to `"42"` (via clamping, default values, or error swallowing), the mutation survives — and the survived mutation report correctly identifies a weak test.

But if the handler silently accepts **any** string without type checking, mutations like `"42"` to `"4z2"` (string dithering) would also pass silently, making the entire mutation testing model ineffective.

### Examples

**Incorrect (silently coerces malformed values, hiding mutations):**

```python
def handle_count(world, example):
    raw = example.get("count", "0")  # default hides missing
    count = int(raw) if raw.isdigit() else 0  # coercion hides mutation
    world["count"] = count
```

**Correct (strict parsing fails on missing or malformed values):**

```python
def handle_count(world, example):
    if "count" not in example:
        raise ValueError("missing placeholder 'count'")
    raw = example["count"]
    try:
        count = int(raw)
    except ValueError:
        raise ValueError(f"malformed integer: {raw!r}")
    world["count"] = count
```

### Why This Matters

Value handling is the bridge between the portable string-based IR and the project's strongly-typed domain. Every shortcut here — default values, silent coercion, ignored parse errors — creates a blind spot that mutation testing cannot probe. Strict failure on bad values is not pedantic; it is what makes the mutation model work.
