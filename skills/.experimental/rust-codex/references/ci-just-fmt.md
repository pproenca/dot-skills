---
title: Run just fmt After Rust Changes
impact: LOW-MEDIUM
impactDescription: prevents formatting CI failures
tags: ci, formatting, rustfmt, just
---

## Run just fmt After Rust Changes

Run `just fmt` in the `codex-rs` directory automatically after finishing Rust code changes. Do not ask for approval to run it. CI checks formatting and will reject changes that differ from `rustfmt` output. Running `just fmt` is a no-approval-needed step that must happen before committing.

**Incorrect (submitting unformatted code):**

```rust
// Before formatting - inconsistent style
fn process_event(event:Event,config:&Config)->Result<()>{
    match event{
        Event::Start{id}=>{ start_session(id,config)?; }
        Event::Stop=>{ stop_all()?; }
    }
    Ok(())
}
// CI fails: rustfmt diff detected
```

**Correct (running just fmt before committing):**

```rust
// After just fmt - consistent style
fn process_event(event: Event, config: &Config) -> Result<()> {
    match event {
        Event::Start { id } => {
            start_session(id, config)?;
        }
        Event::Stop => {
            stop_all()?;
        }
    }
    Ok(())
}
```
