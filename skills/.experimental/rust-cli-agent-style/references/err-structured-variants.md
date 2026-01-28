---
title: Use structured error variants with fields
impact: HIGH
impactDescription: Structured errors enable better debugging and programmatic error handling
tags: err, thiserror, debugging
---

# Use structured error variants with fields

Include relevant data in error variants for debugging. Named fields are preferred over positional.

## Why This Matters

- Provides context for debugging production issues
- Enables programmatic error handling
- Error messages include relevant data
- Pattern matching can extract error details

**Incorrect (avoid this pattern):**

```rust
#[derive(Debug, Error)
pub enum GitError {
    #[error("git command failed")
    CommandFailed,  // No details!

    #[error("branch not found")
    BranchNotFound,  // Which branch?

    #[error("merge conflict")
    MergeConflict,  // Which files?
}
```

**Correct (recommended):**

```rust
#[derive(Debug, Error)
pub enum GitError {
    #[error("git command `{command}` failed: {stderr}")
    CommandFailed {
        command: String,
        stderr: String,
        exit_code: i32,
    },

    #[error("branch `{branch}` not found in repository")
    BranchNotFound { branch: String },

    #[error("merge conflict in {file_count} files")
    MergeConflict {
        file_count: usize,
        files: Vec<PathBuf>,
    },

    #[error("failed to clone {url}: {reason}")
    CloneFailed { url: String, reason: String },
}

// Usage
fn checkout_branch(branch: &str) -> Result<(), GitError> {
    // ...
    Err(GitError::BranchNotFound {
        branch: branch.to_string(),
    })
}

// Pattern matching
match error {
    GitError::CommandFailed { exit_code, .. } if exit_code == 128 => {
        // Handle specific exit code
    }
    _ => {}
}
```
