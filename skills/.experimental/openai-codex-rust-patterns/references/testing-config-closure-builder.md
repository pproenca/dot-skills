---
title: Configure test fixtures with a closure builder
impact: MEDIUM
impactDescription: prevents builders from accreting a setter per obscure config field
tags: testing, builders, fixtures, ergonomics
---

## Configure test fixtures with a closure builder

Integration test fixtures need a configured subject-under-test with one or two knobs tweaked per test. Giving the builder a setter per field grows into 80 setters and still cannot express "if model is X, also set Y". Codex's `TestCodexBuilder` exposes a small stable set of ergonomic setters for the most-used knobs and one `.with_config(|config| { ... })` slot that accepts any `FnOnce(&mut Config) + Send + 'static` and pushes it onto an internal mutator vec. `build()` applies all closures in order.

**Incorrect (builder accretes a setter per field):**

```rust
let codex = TestCodexBuilder::new()
    .with_model("gpt-5.1")
    .with_temperature(0.7)
    .with_sandbox_policy(SandboxPolicy::ReadOnly)
    .with_instructions("...")
    .with_approval_mode(ApprovalMode::Suggest)
    // ... and 75 more setters because the codex Config has 80 fields
    .build()
    .await?;
```

**Correct (closure slot is the primitive, setters are sugar):**

```rust
// core/tests/common/test_codex.rs
type ConfigMutator = dyn FnOnce(&mut Config) + Send;

impl TestCodexBuilder {
    pub fn with_config<T>(mut self, mutator: T) -> Self
    where
        T: FnOnce(&mut Config) + Send + 'static,
    {
        self.config_mutators.push(Box::new(mutator));
        self
    }

    pub fn with_model(self, model: &str) -> Self {
        let new_model = model.to_string();
        self.with_config(move |config| {
            config.model = Some(new_model);
        })
    }
}

// core/tests/suite/truncation.rs
let builder = test_codex()
    .with_model("gpt-5.1")
    .with_config(|config| {
        config.truncation_cutoff_tokens = Some(1024);
        config.instructions = Some("domain-specific prompt".into());
    });
```

`with_model` is itself implemented via `with_config` — the closure form is the primitive, and specialized setters are sugar for the top few knobs. `test_codex()` is a free function so call sites read like English: `test_codex().with_model(...).with_config(|c| ...).build(&server)`.

Reference: `codex-rs/core/tests/common/test_codex.rs:60`, `codex-rs/core/tests/common/test_codex.rs:342`.
