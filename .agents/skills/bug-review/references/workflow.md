# Bug Review v2 Workflow — Detailed Reference

Complete step-by-step workflow with error handling, caching, and resolution tracking.

## Prerequisites

1. `gh` CLI installed and authenticated: `gh auth status`
2. `jq` installed: `jq --version`
3. Current directory is a git repo with a GitHub remote
4. Target PR must exist and be open (for review) or merged (for resolve)

## /bug-review <PR> — Full Review Flow

### 1. Parse Input

Accepts: PR number (`42`), URL (`https://github.com/owner/repo/pull/42`), or branch name.

**Cache check**: Before fetching, look for `${CLAUDE_PLUGIN_DATA}/bug-review/cache/pr-{N}/`. If cache exists and the PR head commit matches, offer to resume from last checkpoint.

### 2. Fetch PR Context

Run: `bash scripts/fetch-pr.sh <pr-identifier>`

Outputs JSON: `{number, title, body, baseRefName, headRefName, files[{path, additions, deletions}], additions, deletions, diff}`

Save diff to temp file for shuffling.

### 3. Gather Extended Context

Run: `bash scripts/gather-context.sh <changed-files-json> [max-files]`

Outputs JSON: `{files[{path, relevance, reason}], stats}`

Priority order: changed files → callers (5) → type definitions (3) → test files (3) → .bug-review.md

### 4. Shuffle Diffs & Launch 5 Passes

For each pass 1-5:
```bash
scripts/shuffle-diff.sh <pass-number> < pr.diff > pass-<N>.diff
```

Launch 5 Agent subprocesses in parallel. Each receives its shuffled diff, context, categories, and repo rules.

**Error handling**:
- If 1-2 agents fail: proceed with remaining passes' findings
- If 3+ agents fail: abort
- If all 5 return empty: "No bugs found" (valid outcome)

### 5. Aggregate & Vote

1. Flatten findings from all passes
2. Group by: same file + line within ±5 + same/related category
3. Count votes per group
4. Apply category weights: `final_score = votes × severity_weight × category_weight`
5. Keep findings with votes >= `vote_threshold` (default: 3)
6. Suppress categories with weight < 0.1 entirely

### 6. Independent Validation

Launch a separate Opus agent (configurable via `validator_model`) with the Validator prompt from review-passes.md.

For each finding: verdict (KEEP/DISCARD), confidence (0-1), reasoning.

Compute final confidence: `confidence = (votes / total_passes) × validator_confidence`

### 7. Dedup

Run: `bash scripts/dedup.sh <pr-number>`

Match by file + line proximity (±10) + category — not text similarity.

### 8. Present & Post

Show findings table with confidence scores. Get user approval.

Post via: `bash scripts/post-review.sh <pr-number> <findings-json-file>`
Store via: `bash scripts/store-findings.sh <pr-number> <findings-json-file> <head-commit>`

### 9. Autofix (Optional)

Per finding: apply fix → scope check (1 file, <20 lines) → test → commit → push.

## /bug-review:resolve <PR> — Resolution Tracking

Run after PR merge:
```bash
scripts/classify-resolutions.sh <pr-number>
```

For each stored finding: diff review commit vs merge commit at the finding's location.
Classify as RESOLVED (code changed at location), UNRESOLVED (no change), or INCONCLUSIVE (file changed but not near finding).

Then update weights:
```bash
scripts/update-weights.sh
```

Requires: 10+ findings across 3+ PRs before adjusting weights.

## /bug-review:report — Resolution Statistics

```bash
scripts/resolution-report.sh         # markdown output
scripts/resolution-report.sh --json  # JSON output
```

Shows: overall rate, by severity, by category (worst-first), suppressed categories.

## Caching & Resumability

Checkpoints saved to `${CLAUDE_PLUGIN_DATA}/bug-review/cache/pr-{N}/`:
- `context.json` — after Step 3
- `pass-results.json` — after Step 4
- `voted.json` — after Step 5
- `validated.json` — after Step 6

Cache is invalidated when the PR head commit changes.

## Troubleshooting

| Problem | Cause | Fix |
|---------|-------|-----|
| "No PR found" | Wrong number or closed | `gh pr list` |
| "gh: not authenticated" | Not logged in | `gh auth login` |
| All passes empty | Well-written code | Normal |
| Too many false positives | Noisy categories | Run /bug-review:resolve after merges to train weights |
| Review fails to post | No write permission | Check gh token: needs `repo` scope |
| Autofix scope exceeded | Fix too broad | Fix is warned, not applied |
| "Insufficient data for weights" | <10 findings or <3 PRs | Keep reviewing and resolving |
| Slow execution | Large PR | Reduce `max_context_files` in config.json |

## Dismissing a Posted Review

```bash
gh api "repos/{owner}/{repo}/pulls/<PR>/reviews" | \
  jq '.[] | select(.body | contains("[bug-review]")) | {id, state}'

gh api "repos/{owner}/{repo}/pulls/<PR>/reviews/<REVIEW_ID>/dismissals" \
  --method PUT -f message="Dismissed: incorrect findings"
```
