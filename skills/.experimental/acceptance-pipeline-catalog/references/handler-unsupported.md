---
title: Fail on Unsupported Step Text
impact: HIGH
impactDescription: silently ignoring unsupported steps hides missing handler implementations, producing 100% false-pass rate on unhandled steps
tags: handler, unsupported, fail, missing
---

## Fail on Unsupported Step Text

When the runtime encounters a step whose `text` value does not match any registered handler, the test must fail. Silent skipping would hide incomplete handler implementations and produce false-positive test results.

### Spec Requirements

Unsupported step text must **fail the current test**.

This applies to both:
- Steps that have no handler registered at all.
- Steps whose text was modified by a mutation such that it no longer matches any handler (this is rare since mutations target example values, not step text).

### Why Not Skip or Warn

Skipping an unsupported step means the test suite reports "all tests pass" when in reality some steps were never executed. This is particularly dangerous during initial pipeline setup, where the developer is progressively implementing handlers. A test that silently skips 3 of 5 steps and passes on the remaining 2 gives false confidence.

Warning without failing has the same problem — warnings are routinely ignored in CI output.

### Examples

**Incorrect (silently skips unmatched steps, producing false passes):**

```python
def execute_step(step, handlers):
    handler = handlers.get(step.text)
    if handler is None:
        pass  # skip silently
    else:
        handler(step)
```

**Correct (fails the test when step text has no registered handler):**

```python
def execute_step(step, handlers):
    handler = handlers.get(step.text)
    if handler is None:
        raise StepNotFoundError(f"no handler for: {step.text!r}")
    handler(step)
```

### Why This Matters

The mutation workflow depends on the test suite being **fully connected** to the application. An unsupported step is a disconnected step — it exercises nothing. Failing immediately surfaces the gap and prompts the developer to implement the missing handler, which is exactly what the pipeline is designed to enforce.

This also means that when writing a new feature file, the natural workflow is: write the feature, run the pipeline, see failures for unimplemented handlers, implement handlers one by one until all tests pass.
