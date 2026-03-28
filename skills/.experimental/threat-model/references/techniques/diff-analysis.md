# Incremental / Diff-Based Analysis

Analyze what changed, not the whole codebase. Accept a git range and focus on newly introduced attack surface. This is how Codex operates — it scans each commit for security regressions rather than re-analyzing the entire project.

## When to Use

- PR review: "Is this change safe?"
- Post-incident: "What changed between the last known-good state and now?"
- Periodic review: "What new attack surface was added this sprint?"
- Regression check: "Did this security fix introduce any new issues?"

## The Technique

### Step 1: Get the Diff

```bash
# Last N commits
git diff HEAD~10..HEAD --stat
git diff HEAD~10..HEAD -- '*.swift' '*.c' '*.m' '*.js' '*.ts' '*.rb' '*.py'

# Specific PR/branch
git diff main...feature-branch --stat

# Between tags
git diff v1.0..v1.1 --stat
```

Focus on source files, not generated/vendored code. Use `--stat` first to identify which files changed, then read the actual diffs for security-relevant files.

### Step 2: Classify Changes

For each changed file, classify the change:

| Classification | What It Means | Analysis Priority |
|---------------|--------------|-------------------|
| **New entry point** | New CLI command, HTTP endpoint, file parser | HIGH — trace all new inputs |
| **New sink** | New file write, exec call, HTML render | HIGH — check what reaches it |
| **Modified validation** | Changed input validation or escaping | HIGH — check if weakened |
| **New bridge/FFI** | New cross-language boundary | HIGH — full bridge analysis |
| **New dependency** | Added library or framework | MEDIUM — check for known CVEs |
| **Removed validation** | Deleted or relaxed a security check | CRITICAL — why was it removed? |
| **Refactored code path** | Same logic, different structure | MEDIUM — check data flow preserved |
| **New data model** | New struct/class handling untrusted data | MEDIUM — check field validation |
| **Config change** | Modified deployment, auth, or security config | MEDIUM — check for weakening |
| **Test/doc only** | No runtime code changed | LOW — skip unless test reveals intent |

### Step 3: Trace New Data Flows

For each new entry point or sink introduced in the diff:

1. If **new entry point**: Trace forward to find what sinks it can reach. Use the data flow tracing technique from [data-flow-tracing.md](data-flow-tracing.md).
2. If **new sink**: Trace backward to find what entry points can reach it. Grep for callers of the function containing the sink.
3. If **modified validation**: Check if the modification weakened the validation. Compare old vs new: does the new version accept inputs the old version rejected?

### Step 4: Cross-Reference with Existing Threat Model

If a `THREAT-MODEL.md` exists from a previous analysis:

1. **New surfaces**: Findings in the diff that weren't in the previous model → add them
2. **Resolved surfaces**: Previous findings whose vulnerable code was fixed in the diff → mark resolved
3. **Modified surfaces**: Previous findings whose code changed but vulnerability status is unclear → re-analyze
4. **Regression**: A fix for one finding that introduces a new finding → flag as regression

### Step 5: Check for Common Regression Patterns

| Pattern | What to Check |
|---------|--------------|
| Fix moved the bug | Did the fix eliminate the vulnerability or just move it to a different code path? |
| Fix introduced new entry point | Did the fix refactor code in a way that exposes a new entry point? |
| Fix weakened existing control | Did the fix disable or relax a validation that was protecting against something else? |
| New feature copies vulnerable pattern | Did new code copy-paste from code with known issues? |
| Dependency update | Did the update change behavior in security-relevant ways? |

### Step 6: Output as Delta

Structure the output as changes to the threat model:

```markdown
## Diff Analysis: {git range}
### Files Changed: {count}
### Security-Relevant Changes: {count}

### New Findings
{Findings introduced by this change}

### Resolved Findings
{Previous findings fixed by this change}

### Modified Findings
{Previous findings whose status changed}

### Regressions
{New issues introduced by security fixes}
```

## Practical Tips

- **Start with `--stat`** to identify which files changed, then prioritize by classification
- **Skip vendored/generated code** — filter with `git diff -- ':!vendor' ':!node_modules' ':!*.min.js'`
- **Read the commit messages** — they often explain intent, which helps distinguish intentional security changes from accidental ones
- **Check for reverted security fixes** — `git log --all --grep="security"` to find previous security commits, then check if any were reverted in the diff range
- **Large diffs (100+ files)**: Focus only on files classified as HIGH priority in Step 2. Don't try to analyze everything.
