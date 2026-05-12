---
name: bug-review
description: Use this skill when a user asks to review a pull request for bugs, wants AI code review focused on correctness issues, or runs /bug-review. Trigger on PR review, bug finding, code review, "review this PR", "check for bugs", "find issues in this PR". This is a multi-pass review workflow with 5 parallel passes, majority voting, independent Opus validation, and resolution rate tracking. Also trigger on /bug-review:resolve to classify whether findings were fixed at merge time, and /bug-review:report for resolution rate stats. Even if the user just says "review this" while on a PR branch, trigger this skill.
metadata:
  internal: true
---

# Bug Review v2

Multi-pass PR review agent with 5 parallel review passes, majority voting, independent Opus validation, and resolution rate learning. Posts inline PR comments and optionally generates autofix commits. Tracks whether findings get resolved at merge time and uses that signal to improve future reviews.

## When to Apply

- User asks to review a pull request for bugs or correctness issues
- User runs `/bug-review <PR-number-or-URL>`
- User runs `/bug-review:resolve <PR>` to classify resolutions after merge
- User runs `/bug-review:report` for resolution rate statistics
- User asks for code review focused on logic errors, edge cases, or security
- User wants to find bugs in a diff or set of changes

## Setup

On first run, verify:
- `gh` CLI is installed and authenticated (`gh auth status`)
- Current directory is a git repo with a GitHub remote
- `jq` is installed (for JSON processing)
- `bc` is installed (for resolution rate calculations; pre-installed on most systems)

Read [config.json](config.json) for configuration (passes, vote threshold, models, category weights).

## Workflow Overview

```
/bug-review <PR>
  |
  v
Fetch PR context + gather-context.sh
  |
  v
5 parallel passes (shuffled diffs, Sonnet) --> Aggregate & vote (3/5 majority)
  |
  v
Independent Opus validator --> Dedup --> Present findings --> Post + store
  |
  (later, after merge)
  v
/bug-review:resolve <PR> --> Classify resolutions --> Update category weights
```

## Command: /bug-review <PR>

### Step 1: Parse Input & Fetch Context

1. Parse the PR identifier (number, URL, or branch name)
2. **Check cache**: Look for `${CLAUDE_PLUGIN_DATA}/bug-review/cache/pr-{N}/` — if cache exists for the same head commit, offer to resume from the last checkpoint
3. Run `scripts/fetch-pr.sh <pr-identifier>` to get PR diff + metadata as JSON
4. Save the diff to a temp file for shuffling
5. Run `scripts/gather-context.sh <changed-files-json>` to get prioritized context (callers, types, tests, repo rules)
6. Read `.bug-review.md` from repo root if it exists
7. **Save checkpoint**: Write context to `${CLAUDE_PLUGIN_DATA}/bug-review/cache/pr-{N}/context.json`

### Step 2: Run 5 Parallel Review Passes

For each pass (1-5), prepare a shuffled diff:
```bash
scripts/shuffle-diff.sh <pass-number> < pr.diff > pass-<N>.diff
```

Launch **5 Agent subprocesses in parallel**. Read [review-passes.md](references/review-passes.md) for the exact prompt for each pass.

- **Pass 1**: Logic & Edge Cases (seed 1)
- **Pass 2**: Security & Data Integrity (seed 2)
- **Pass 3**: Error Handling & API Contracts (seed 3)
- **Pass 4**: Concurrency & State (seed 4)
- **Pass 5**: Data Flow & Contracts (seed 5)

Use `model` from config.json `agent_model` (default: `"sonnet"`).

Each agent returns a JSON array of findings.

**Save checkpoint**: Write all pass results to `${CLAUDE_PLUGIN_DATA}/bug-review/cache/pr-{N}/pass-results.json`

### Step 3: Aggregate & Vote

1. Collect findings from all 5 passes
2. Group findings by similarity: same file + line within +/-5 + same or related category
3. Count votes per group
4. **Keep only findings with 3+ votes** (majority of 5, configurable via `vote_threshold`)
5. Apply **category weights** from config.json: `final_score = votes × severity_weight × category_weight`
6. Categories with weight < 0.1 are suppressed entirely
7. Rank by final_score descending

If only 1-2 passes found bugs and the others found none, present findings but note they lack consensus.

**Save checkpoint**: Write voted findings to cache.

### Step 4: Independent Validation (Opus)

Launch a **separate Agent** using `validator_model` from config.json (default: `"opus"`).

This agent has NOT seen the review passes. It receives only the voted findings and the original code. Read the Validator section in [review-passes.md](references/review-passes.md) for the prompt.

For each finding, the validator outputs: `{id, verdict: "KEEP"|"DISCARD", confidence, reasoning}`

Remove DISCARDed findings. Multiply each finding's score by the validator's confidence.

Compute each finding's final `confidence` field:
```
confidence = (votes / total_passes) × validator_confidence
```

Findings with confidence < 0.5 are shown with a "low confidence" warning.

**Save checkpoint**: Write validated findings to cache.

### Step 5: Dedup Against Prior Reviews

Run `scripts/dedup.sh <pr-number>` to get existing `[bug-review]` comments.
Match by location proximity (file + line within +/-10) and category — not text similarity.

### Step 6: Present Findings to User

Display a table:

| # | Severity | Confidence | File | Line | Title | Votes |
|---|----------|------------|------|------|-------|-------|

For each finding, show full description, trigger scenario, suggested fix, and validator reasoning.

Ask the user (using AskUserQuestion with multiSelect):
- Which findings to **post as PR comments** (default: all)
- Which findings to **autofix** (default: none)

If no findings survived voting + validation: "No bugs found across 5 review passes. The changes look clean."

### Step 7a: Post PR Review

Write approved findings to a temporary JSON file, then run:
```bash
scripts/post-review.sh <pr-number> <findings-json-file>
```

Then persist findings for resolution tracking:
```bash
scripts/store-findings.sh <pr-number> <findings-json-file> <head-commit-sha>
```

### Step 7b: Autofix (User-Selected Findings)

For each finding selected for autofix:
1. Read the file and understand surrounding context
2. Generate a **minimal fix** (smallest possible change)
3. Apply the fix using the Edit tool
4. **Scope check**: Run `git diff --stat` — verify only the finding's file was modified and diff is under 20 lines. If exceeded, revert and warn.
5. Run existing tests if available (`npm test`, `go test ./...`, `pytest`, etc.)
6. If tests pass: commit with `fix: {title} [bug-review]`
7. If tests fail: revert the fix (`git checkout -- <file>`) and report to user
8. After all fixes: push to the PR branch

Safety: one commit per fix, run tests between fixes, never force-push, scope-validate every fix.

## Command: /bug-review:resolve <PR>

Run after a PR is merged to classify whether findings were resolved.

1. Run `scripts/classify-resolutions.sh <pr-number>`
   - Loads stored findings from `${CLAUDE_PLUGIN_DATA}/bug-review/findings/pr-{N}.json`
   - Checks if PR is merged
   - For each finding: diffs code between review commit and merge commit
   - Classifies each as RESOLVED, UNRESOLVED, or INCONCLUSIVE
   - Updates the stored findings file with resolution data
2. Display resolution summary to user
3. If enough data accumulated (10+ findings, 3+ PRs): run `scripts/update-weights.sh` to adjust category weights

## Command: /bug-review:report

Display resolution rate statistics across all tracked PRs.

Run `scripts/resolution-report.sh` which outputs:
- Overall resolution rate
- Resolution rate by severity
- Resolution rate by category (sorted worst-first to highlight noisy categories)
- Suppressed categories (weight < 0.1)

## Repo-Specific Rules (.bug-review.md)

Teams can create `.bug-review.md` at their repo root:

```markdown
## Focus Areas
- Pay special attention to authentication flows
- Check all database queries for SQL injection

## Ignore
- Don't flag issues in generated files (*.generated.ts)
- Ignore style-only concerns

## Invariants
- All API endpoints must check req.user before accessing user data
- Database migrations must be reversible

## Severity Overrides
- Treat any auth bypass as CRITICAL regardless of category default
```

## How to Use

Read [workflow.md](references/workflow.md) for detailed step-by-step with error handling.
Read [review-passes.md](references/review-passes.md) for all 5 review pass prompts and the validator.
Read [categories.md](references/categories.md) for bug categories and learned weights.

## Related Skills

- Consider creating a **Runbook** skill for investigating bugs found by this review
- Consider creating a **CI/CD** skill to run this review automatically on PR open
