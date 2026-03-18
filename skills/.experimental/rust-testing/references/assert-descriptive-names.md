---
title: Use Self-Documenting Test Function Names
impact: CRITICAL
impactDescription: 2-5x faster failure triage from self-documenting test names
tags: assert, naming, readability, test-organization
---

## Use Self-Documenting Test Function Names

Name test functions to describe the scenario and expected outcome. When a test fails in CI, the function name is the first thing a developer sees. A descriptive name like `test_get_has_changes_with_untracked_change_returns_true` communicates the failure without requiring code inspection.

**Incorrect (vague names require reading test body):**

```rust
#[test]
fn test_git_info() {
    // What aspect of git info? What scenario? What's expected?
}

#[test]
fn test_config_2() {
    // Numbered tests give no context on failure
}
```

**Correct (name describes scenario and expectation):**

```rust
#[test]
fn test_recent_commits_non_git_directory_returns_empty() {
    // Clear: input is non-git dir, expected output is empty
}

#[test]
fn test_collect_git_info_detached_head() {
    // Clear: tests detached HEAD scenario specifically
}

#[test]
fn test_get_has_changes_with_tracked_change_returns_true() {
    // Clear: tracked changes should report has_changes = true
}
```
