---
name: rust-write-tests
description: Skill for writing expert-level Rust tests. Teaches the "What Could Break?" framework, five transformations from superficial to expert tests, flake hunting protocol, intent-based assertions, naming conventions, and a mandatory self-review checklist. Triggers on writing Rust tests, designing test cases, improving test quality, or reviewing test coverage.
---

# Rust Test Writing Skill

Write tests that catch real bugs. Every test must guard a specific invariant -- not just prove the code "works."

## The "What Could Break?" Framework

Before writing any test, answer these four questions:

1. **What invariant does this code maintain?** (e.g., "deserialized config always has a default profile")
2. **What edge case would violate it?** (e.g., "empty TOML table, missing key, extra unknown key")
3. **What platform difference could surface?** (e.g., "path separators, case sensitivity, symlink behavior")
4. **What would a future refactor accidentally break?** (e.g., "field added to struct but not to Display impl")

If you can only answer #1, your test is a happy-path test. Answer all four and you have a regression suite.

## The 5 Test Transformations

Each transformation shows a superficial test pattern and its expert replacement.

### Transformation 1: Weak assertions -> whole-object comparison

```rust
// BEFORE: proves nothing about the rest of the struct
let result = parse_config(input)?;
assert!(result.is_ok());

// AFTER: catches any unexpected field change
use pretty_assertions::assert_eq;
let result = parse_config(input)?;
assert_eq!(result, Config {
    name: "default".into(),
    timeout: Duration::from_secs(30),
    retries: 3,
    verbose: false,
});
```

### Transformation 2: Single happy-path -> targeted test suite

```rust
// BEFORE: one test, one path
#[test]
fn test_parse_config() {
    let cfg = parse("valid input").unwrap();
    assert!(cfg.is_valid());
}

// AFTER: 3-6 tests covering happy, error, edge, platform
#[test]
fn parse_config_returns_defaults_for_minimal_input() { .. }
#[test]
fn parse_config_rejects_negative_timeout() { .. }
#[test]
fn parse_config_preserves_unknown_fields_as_extensions() { .. }
#[test]
fn parse_config_handles_empty_string_gracefully() { .. }
#[cfg(windows)]
#[test]
fn parse_config_normalizes_backslash_paths() { .. }
```

### Transformation 3: Inline test module -> sibling `_tests.rs` file

```rust
// BEFORE: tests pollute the production file diff
// foo.rs
pub fn compute() -> u32 { 42 }
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn it_works() { assert_eq!(compute(), 42); }
}

// AFTER: production code and test code in sibling files
// foo.rs
pub fn compute() -> u32 { 42 }
#[cfg(test)]
#[path = "foo_tests.rs"]
mod tests;

// foo_tests.rs
use super::*;
#[test]
fn compute_returns_expected_value() { assert_eq!(compute(), 42); }
```

For `mod.rs` modules, use `mod_tests.rs`.

### Transformation 4: String-based test data -> typed struct construction

```rust
// BEFORE: silent breakage when fields change
let input: Config = serde_json::from_str(r#"{"name":"test","timeout":30}"#)?;

// AFTER: compile-time safety for field additions/renames
fn make_config(name: &str, timeout_secs: u64) -> Config {
    Config {
        name: name.to_string(),
        timeout: Duration::from_secs(timeout_secs),
        retries: 0,
        verbose: false,
    }
}
let input = make_config("test", 30);
```

Factory functions for domain objects let each test construct exactly the fixture it needs. No shared mutable state. No JSON parsing at test time.

### Transformation 5: `HashMap` in fixtures -> `BTreeMap` for determinism

```rust
// BEFORE: test passes 99% of the time, flakes in CI
let mut map = HashMap::new();
map.insert("b", 2);
map.insert("a", 1);
assert_eq!(format!("{map:?}"), r#"{"a": 1, "b": 2}"#); // order not guaranteed

// AFTER: deterministic iteration order
let mut map = BTreeMap::new();
map.insert("b", 2);
map.insert("a", 1);
assert_eq!(format!("{map:?}"), r#"{"a": 1, "b": 2}"#); // always this order
```

Use `BTreeMap` whenever output order affects assertions or snapshots.

## Test Flake Hunting Protocol

Bolin's single most frequent pattern (97+ references across 30+ commits). When a test is flaky, follow this exact protocol:

1. **Identify the race window** -- read the event-emission code, find where timing assumptions break. Locate the exact line where the test assumes an event has arrived or a state has changed without proof.
2. **Replace timing with event-driven sync** -- wait for a specific event instead of sleeping or assuming order. Never use `sleep` as a synchronization primitive.
3. **Make assertions order-independent** -- sort collected values, use sets, or match by content not position. Non-deterministic event ordering is not a bug; asserting on it is.
4. **Stress-test the fix** -- run with the exact command: `cargo nextest run -p <crate> -j 2 --no-fail-fast --stress-count 50 --status-level leak`
5. **Document the non-determinism** in the commit message -- explain why the timing assumption was wrong and what synchronization replaced it.

```rust
// BEFORE (timing-dependent):
tokio::time::sleep(Duration::from_millis(100)).await;
assert_eq!(events.len(), 2);
assert_eq!(events[0].type_name, "item.create");
assert_eq!(events[1].type_name, "audio.delta");

// AFTER (event-driven, order-independent):
wait_for_event(&rx, |e| e.type_name == "item.create").await;
wait_for_event(&rx, |e| e.type_name == "audio.delta").await;
// OR: collect, sort, compare
let mut types: Vec<_> = events.iter().map(|e| &e.type_name).collect();
types.sort();
assert_eq!(types, vec!["audio.delta", "item.create"]);
```

Common flake sources to watch for:
- `turn/started` emitted optimistically before state is actually ready
- Event ordering across async channels (mpsc, broadcast)
- HashMap iteration order in serialized output
- Test harness Drop racing with child process shutdown (close stdin first, then wait, then kill)

## Intent-Based Assertions

Replace exact command-string matching with intent-based semantic matching. Check that the test observes the right INTENT (operation + target) rather than a specific command format that varies across platforms or refactors.

```rust
// BEFORE: brittle -- breaks if command formatting changes
assert_eq!(cmd.to_string(), "rm -rf /tmp/workspace/build");

// AFTER: intent-based -- asserts the operation and target
assert_eq!(cmd.operation(), Operation::Remove);
assert!(cmd.target().ends_with("workspace/build"));
assert!(cmd.is_recursive());
```

When exact strings are unavoidable, assert on the semantically meaningful parts (path suffix, flag presence) rather than the full formatted string.

## Test Naming Convention

Pattern: `{subject}_{scenario}_{expected_outcome}`

A failed test name must be an actionable bug description. When it fails in CI, the name alone tells you what broke. The name should read as a specification: if it fails, you know exactly what invariant was violated.

Exemplary names:

```
sandbox_detection_requires_keywords
sandbox_detection_ignores_non_sandbox_mode
aggregate_output_rebalances_when_stderr_is_small
parse_config_rejects_negative_timeout
permissions_profiles_reject_writes_outside_workspace_root
permissions_profiles_allow_network_enablement
legacy_sandbox_mode_config_builds_split_policies_without_drift
under_development_features_are_disabled_by_default
usage_limit_reached_error_formats_free_plan
unexpected_status_cloudflare_html_is_simplified
root_write_plus_carveouts_still_requires_platform_sandbox
explicit_unreadable_paths_prevent_auto_approval_for_external_sandbox
denied_hosts_take_priority_over_allowed_hosts_glob
```

Anti-pattern names: `test_parse`, `it_works`, `test_config_1`, `happy_path`.

## Testing Stack Quick Reference

| Scenario | Tool |
|----------|------|
| HTTP mocking | `wiremock::MockServer` |
| Filesystem isolation | `TempDir` (`tempfile` crate) |
| Async tests | `#[tokio::test]` |
| UI / output snapshots | `insta::assert_snapshot!` |
| Struct comparison | `pretty_assertions::assert_eq` |
| Enum variant checks | `assert_matches!` |
| Deterministic collections | `BTreeMap` over `HashMap` |
| Flake stress-testing | `cargo nextest run --stress-count 50` |

### When to use each

- **wiremock**: Any test that would hit a real HTTP endpoint. Mount responses with `Mock::given().respond_with()`. Assert request bodies after the test.
- **TempDir**: Every test that touches disk. Never mutate the process environment. Never hardcode `/tmp` or `C:\`.
- **insta**: TUI widgets, CLI output, error messages -- anything where the exact text matters. Render to a buffer, snapshot with `assert_snapshot!`.
- **pretty_assertions**: Default for all `assert_eq!` calls. Gives colored diffs on failure. Import at the top of every test file.
- **nextest stress**: After fixing any flaky test. Always run with `-j 2 --no-fail-fast --stress-count 50` to confirm the fix holds under concurrency.

## Self-Review Checklist

After writing tests, verify every item. Fix every violation before presenting the tests.

```
[ ] Uses pretty_assertions::assert_eq (not std assert_eq)
[ ] Compares entire objects, not individual fields
[ ] Each test guards a specific invariant (not just "it works")
[ ] Test names follow {subject}_{scenario}_{expected_outcome}
[ ] Test names encode the invariant being guarded
[ ] TempDir for any filesystem tests (no hardcoded paths)
[ ] No process environment mutation (no std::env::set_var)
[ ] Error paths tested (not just happy path)
[ ] At least 3 tests for any non-trivial function
[ ] BTreeMap used where iteration order affects assertions
[ ] Test file is a sibling _tests.rs, not inline mod tests {}
[ ] No timing-dependent assertions (no sleep -> assert)
[ ] Order-independent where event order is non-deterministic
[ ] String assertions use intent matching, not exact format
```
