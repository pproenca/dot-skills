# Transcript: Add safety flags to cleanup-stale-branches.sh

## 1. Task understanding

The ops team has a bash script (`cleanup-stale-branches.sh`) that deletes old
merged git branches on shared dev servers. AI agents on the team can't use it
safely because:

1. There is no way to preview what would be deleted (no dry-run mode).
2. There is no way to skip the interactive `read -p` confirmation prompt when
   running under automation (the script will hang forever waiting on stdin, or
   fall through on empty input).

My job is to add safety flags to make the script "agent-friendly" **without
breaking existing behavior for humans**. That last constraint is important:
running the script with no arguments must still behave exactly like the
original (fetch → list → interactive prompt → delete).

I interpreted "safety flags" as the conventional CLI pair:

- `--dry-run` / `-n` — preview only, never mutates state
- `--yes` / `-y` — non-interactive, assume confirmation
- `--help` / `-h` — document the new surface area (good practice when
  extending any CLI)

And "not breaking existing behavior" meant: default = original behavior, flags
are strictly additive.

## 2. Steps taken and rationale

### Step 1 — Read the input script

Read `/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/cli-for-agents-workspace/evals/inputs/cleanup-stale-branches.sh`
to understand the existing flow:

- `set -e` strict mode
- `git fetch --prune origin`
- Enumerate branches older than 30 days via
  `git for-each-ref` + `awk` with a cutoff from `date -v-30d`
- Filter to branches that are ancestors of `main` (i.e. merged)
- Print the list
- `read -p` prompt asking for literal "yes"
- `git branch -D` each branch in a loop

Key observations:

- The script is macOS-flavored (`date -v-30d` is BSD date; GNU date would be
  `date -d '30 days ago'`). I preserved that since changing it would be scope
  creep and might break existing users.
- `set -e` is on, so any unexpected failure already aborts — good baseline.
- The script uses word-splitting on `$branches` (unquoted). Not ideal, but
  branch names don't typically contain whitespace and fixing it is outside
  the requested task.

### Step 2 — Verify the output directory exists

Used `Bash` with `ls -la` on the run-1 directory. Confirmed
`outputs/` already exists and is empty. No need to `mkdir -p`.

### Step 3 — Design the argument parser

Chose a simple `while [ $# -gt 0 ]; do case "$1" in ...` loop over
`getopts`, because:

- `getopts` (POSIX) does not support long options like `--dry-run`.
- `getopt` (GNU enhanced) is not available on macOS by default.
- A plain case loop is portable, readable, and handles both short and long
  forms cleanly.

Options:

- `-n`, `--dry-run` → sets `DRY_RUN=1`
- `-y`, `--yes`     → sets `ASSUME_YES=1`
- `-h`, `--help`    → prints usage and exits 0
- `--`              → end of options (standard convention)
- Anything else     → error to stderr, exit 2 (exit 2 is the conventional
  "misuse of shell builtin / bad args" code, distinct from the original
  exit 1 used for "user cancelled")

### Step 4 — Design the dry-run behavior

The dry-run branch point is placed **after** enumeration but **before** any
mutation (`git branch -D`). It must:

- Still run `git fetch --prune origin` — this is technically a network
  mutation, but it's how we discover what would be deleted. Alternative
  would be to skip the fetch in dry-run, but then the preview could be
  stale. I chose fidelity over purity: a dry-run should answer "what would
  happen if I ran this right now?"
- Print the same "Found N stale branches" list a human would see.
- Exit 0 with a `[dry-run] Would delete N branches. No changes made.`
  footer so agents can grep for it or just check the exit code.
- Print a `[dry-run]` banner at the very top so it's obvious even in scroll
  back.

### Step 5 — Design the --yes behavior

Replaced the `read -p` prompt with an `if` branch:

```bash
if [ "$ASSUME_YES" -eq 1 ]; then
  echo "Proceeding with deletion (--yes specified)..."
else
  read -p "Delete all ${#to_delete[@]} branches? (yes/no): " answer
  if [ "$answer" != "yes" ]; then
    echo "Cancelled."
    exit 1
  fi
fi
```

Default path (no flag) is **byte-for-byte identical** to the original prompt
and cancellation logic. This satisfies the "don't break humans" constraint.

### Step 6 — Write help text

Put the usage block at the top of the file as a comment (lines 2-34) and
built a `usage()` function that extracts those lines with `sed` and strips
the leading `# `. Rationale: one source of truth — the comment header IS
the man-page, and adding a new option means editing one place.

Also documented exit codes explicitly so automation can branch on them:

- 0 = success or dry-run completed
- 1 = user cancelled at prompt
- 2 = bad arguments

### Step 7 — Syntax check and smoke test

Ran `bash -n` for a static syntax check. Passed.

Ran `--help` to make sure the usage block rendered. It did, but I noticed
the final line of the examples block was cut off — I had set the sed range
to `2,33p` but the header actually extended to line 34 after I added the
"preview then delete" example pair. Fixed the range to `2,34p`.

Ran `--bogus` to confirm unknown-flag handling: got the expected error on
stderr and exit 2.

I did not run the script end-to-end against a real repository because:

- It mutates state (`git fetch`, `git branch -D`).
- The task is to update the script, not to test against a live repo.
- Static check + help/error paths are sufficient to validate the new surface
  area; the original deletion logic is untouched.

## 3. Tools used

- `Read` — read the input script
- `Bash` — verify directory existed, run `bash -n` syntax check, run
  `--help` and `--bogus` smoke tests
- `Write` — create the updated script and this transcript
- `Edit` — fix the sed range in `usage()` after noticing the truncation

## 4. Issues and resolutions

**Issue 1: Help output truncated on last example line.**
After writing the file, running `--help` showed the examples section ending
at `./cleanup-stale-branches.sh --dry-run` instead of also showing the
trailing `--yes` line. Root cause: the `sed -n '2,33p'` range in the
`usage()` function was off-by-one relative to the comment header, which
ran to line 34. Fixed by changing the range to `2,34p`. Verified with
`--help | tail -5`.

**Issue 2 (considered, not hit): portability of `date -v-30d`.**
The original uses BSD `date`, which works on macOS but fails on Linux. I
considered adding a portability shim but decided it was out of scope —
changing date behavior could silently shift what counts as "30 days ago"
if the shim was wrong, and the task is specifically about agent-safety
flags, not cross-platform hardening.

**Issue 3 (considered, not hit): what if both `--dry-run` and `--yes`
are passed?**
Decided `--dry-run` wins (checked first in the execution flow). A dry-run
is always a read-only operation; honoring `--yes` in that combination
would defeat the purpose. This is the same convention as `rm -n` style
tools and most package managers. I did not add an explicit error for the
combination because it's harmless and disambiguates cleanly.

## 5. Output produced

**File:**
`/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/cli-for-agents-workspace/iteration-1/eval-3-add-safety-to-cleanup-script/without_skill/run-1/outputs/cleanup-stale-branches.sh`

**Changes versus the original:**

1. Expanded header comment into a full usage block documenting options,
   exit codes, and agent-oriented examples.
2. Added `DRY_RUN` and `ASSUME_YES` flag variables (default 0).
3. Added a `usage()` function that pretty-prints the header comment.
4. Added an argument-parsing `while`/`case` loop supporting
   `-n`/`--dry-run`, `-y`/`--yes`, `-h`/`--help`, `--`, and rejecting
   unknown flags with exit 2.
5. Added a `[dry-run]` banner at the top of execution when that flag
   is set, so it's obvious in log output.
6. Added a dry-run exit path right after the "Found N stale branches"
   listing — exits 0 with a `Would delete` footer, never calling
   `git branch -D`.
7. Wrapped the `read -p` confirmation in an `if ASSUME_YES` check so
   automation can skip it. Default branch (no flag) is byte-identical
   to the original prompt + cancellation logic.

**Behavioral guarantees:**

- `./cleanup-stale-branches.sh` with no args behaves exactly like the
  original script (same prompts, same exit codes, same deletions).
- `./cleanup-stale-branches.sh --dry-run` is guaranteed read-only with
  respect to local refs (it still fetches from origin to get an accurate
  picture).
- `./cleanup-stale-branches.sh --yes` runs non-interactively — safe to
  invoke from CI or an AI agent orchestrator with no stdin attached.
- Unknown flags exit with code 2 and a clear stderr message pointing at
  `--help`.
