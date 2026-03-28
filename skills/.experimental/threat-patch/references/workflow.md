# Patching Methodology

Detailed approach for turning security findings into minimal, correct code patches.

## Phase 1: Ingest Findings

**Goal**: Parse the input into a structured set of findings with actionable details.

**Input formats (in priority order)**:

1. **findings.json** (from threat-model): Read directly — already structured with data flow traces, systemic groupings, exploit chains, and severity ratings. This is the richest input.
2. **Codex CSV**: Use `scripts/parse-findings.sh` to extract title, description, severity, relevant_paths, commit_hash per finding.
3. **THREAT-MODEL.md**: Extract risks from the Criticality Calibration section, cross-referenced with Attack Surface subsections for affected files.
4. **Individual descriptions**: User provides finding text directly.

### When input is findings.json

Read the file and use its structured data directly:
- `findings[].trace` provides the data flow from entry to sink — this tells you exactly which code path to fix
- `findings[].relevant_paths` lists affected files
- `findings[].recommended_fix` suggests the fix approach
- `systemic[]` groups findings by root cause — fix the systemic root cause first, which resolves multiple findings at once
- `chains[]` identifies multi-step attack paths — prioritize chain-breaking fixes
- `findings[].status` tells you which findings are already `patched` or `closed` — skip them

### When input is Codex CSV or other formats

**For each finding, extract**:
| Field | Source |
|-------|--------|
| Title | CSV `title` or threat model risk bullet |
| Severity | CSV `severity` or calibration level |
| Affected files | CSV `relevant_paths` or threat model file references |
| Description | CSV `description` or attack surface detail |
| Commit hash | CSV `commit_hash` (for tracing when the issue was introduced) |

## Phase 2: Triage & Group

**Goal**: Prioritize work and identify findings that share a root cause.

### Priority order
Process findings by severity: critical → high → medium → low. Within each level, prioritize by:
1. Findings that affect shared/centralized code (fixing one location fixes multiple findings)
2. Findings with clear, mechanical fixes (input validation, bounds checking)
3. Findings that require design decisions (defer to analysis-only output)

### Grouping related findings
Look for findings that share a root cause or fix pattern:

| Grouping signal | Example | Fix approach |
|----------------|---------|--------------|
| Same file, same pattern | Multiple predictable `/tmp` paths in ExtractionCapture.swift | One helper for secure temp dirs |
| Same vulnerability, multiple call sites | PID resolution duplicated in attach/watch/await | Extract shared validation helper |
| Same missing sanitization | Path traversal via bundleID in multiple commands | One validation function, applied everywhere |

Grouped findings get a single patch that addresses the root cause rather than individual patches per symptom.

## Phase 3: Read Affected Code

**Goal**: Understand the vulnerable code in its full context before attempting a fix.

**Actions**:
1. Open each file listed in `relevant_paths`
2. Read the surrounding context — not just the vulnerable line, but the function, the callers, and the data flow
3. Identify the trust boundary: where does attacker-controlled data enter this code path?
4. Check if there are existing validation/sanitization functions nearby that could be reused
5. Understand the component's error handling conventions (does it throw, return nil, log and continue?)

**Why context matters**: A patch that doesn't match the codebase's conventions will be rejected or cause regressions. The finding's description identifies the vulnerability; the code context tells you how to fix it idiomatically.

## Phase 4: Confirm Vulnerability

**Goal**: Verify the issue is still present in HEAD before writing a fix.

The finding may reference a specific commit hash. Between that commit and HEAD, the code may have:
- Been refactored (vulnerability moved or renamed)
- Been fixed independently (finding is stale)
- Changed enough that the finding's description no longer applies

**Actions**:
1. Check if the affected code is still at the paths listed in the finding
2. If the file has moved, search for the relevant function/pattern
3. Verify the vulnerable pattern described in the finding is still present
4. If the issue is fixed or the code no longer exists, skip this finding and note it as "resolved" or "not applicable"

**Output**: One of:
- **Confirmed**: The vulnerability is present at the described location
- **Moved**: The vulnerability exists but the code has been relocated to `{new path}`
- **Resolved**: The issue has been fixed since the finding was filed
- **Not applicable**: The code no longer exists or the preconditions no longer hold

## Phase 5: Design Fix

**Goal**: Determine the minimal correct fix before writing code.

### Fix design principles

1. **Fix the vulnerability, not the architecture.** A security patch is not a refactoring opportunity. The goal is the smallest change that eliminates the risk.

2. **Validate at the entry point.** When untrusted input crosses a trust boundary, validate it there — not deep inside the call chain. This prevents the same vulnerability from appearing in new callers.

3. **Centralize shared fixes.** If three call sites have the same vulnerability, extract a shared helper. This is the one case where adding a function is part of the minimal fix, because duplicating the validation three times is worse.

4. **Match existing patterns.** If the codebase already has input validation helpers, escaping functions, or secure temp dir creation, use them. Don't introduce a new pattern when an existing one serves.

5. **Add explicit error types.** When rejecting input, add a specific error case with a clear message. Not "invalid input" but "PID \(pid) is not a running simulator app."

6. **Fail closed.** The default behavior when validation fails should be to reject/error, not to proceed with a warning.

### Consult fix patterns
Read [fix-patterns.md](fix-patterns.md) for the standard fix approach per vulnerability class. Match the finding's vulnerability type to a pattern, then adapt to the specific codebase.

### Confirm with user before implementing
Before writing any code, present the fix design to the user:
- Which files will be changed
- What the fix approach is (e.g., "extract a shared validation helper," "add bounds check")
- Whether multiple findings are addressed by this fix

Wait for user approval before proceeding to Phase 6. This is a guardrail — security patches modify source code and must be reviewed before application.

## Phase 6: Implement

**Goal**: Write the code changes.

### Implementation rules

- **One logical fix per patch.** Even if multiple lines change, the fix should address exactly one vulnerability or group of related findings.
- **Minimal diff.** Don't reformat, rename, or clean up code outside the fix. The diff should be reviewable in under 2 minutes.
- **Preserve function signatures when possible.** If the fix can be done inside the existing function, don't change its interface. If a new parameter is needed (e.g., an allowed-PIDs set), prefer a new helper over modifying all callers.
- **New helpers go near the code they protect.** A `resolveSimulatorAppPID` function goes in the same file as the commands that use it, marked `private`. Don't create a new file for one function.
- **Test the fix compiles.** If possible, run a build after the change. If build tools are unavailable, note this limitation.

## Phase 7: Document

**Goal**: Write the structured documentation for the patch.

Use the templates in [output-format.md](output-format.md). Two modes:

### Code patch documentation
Write when you produced a code fix:
1. **Summary**: What vulnerability was confirmed, what the fix does (2-3 sentences)
2. **Testing**: Specific build/test commands. If the environment can't run them, document the commands and the limitation with a warning marker
3. **Diff**: The actual code changes

### Analysis-only documentation
Write when the fix needs user decision or architectural changes:
1. **Summary**: What was confirmed
2. **Validation**: Checklist of how to verify the issue exists
3. **Attack-path analysis**: Path diagram, Likelihood, Impact, Assumptions, Controls, Blindspots

## Phase 8: Test

**Goal**: Verify the fix works and doesn't break existing functionality.

**Actions**:
1. Identify the relevant test suite or test filter for the affected code
2. Run the tests if possible
3. If the environment prevents running tests (missing tools, dependencies), document:
   - The exact test command to run
   - What the limitation is
   - Use the `⚠️` marker to signal the limitation

**Common testing patterns**:
| Language | Test command pattern |
|----------|-------------------|
| Swift/SPM | `swift test --filter {TestSuiteName}` |
| Rust | `cargo test {test_name}` |
| Node.js | `npm test -- --grep "{pattern}"` |
| Python | `pytest {path}::{test_name}` |
| Go | `go test ./... -run {TestName}` |
| Ruby/Rails | `bundle exec rspec {path}` |

## Phase 9: Output

**Goal**: Deliver the patches in a consistent format.

For each finding or group:
1. Output the documentation (Summary + Testing + Diff, or Analysis-only)
2. If the user wants commits, create one commit per logical fix with a descriptive message
3. If multiple findings were grouped, note which findings are addressed by the patch

### Commit message format
```
security: {brief description of fix}

Fixes: {finding title}
Severity: {level}
```

### Reverting patches
If a patch needs to be undone:
- **With commits** (`commit_patches: true`): `git revert <commit>` or `git reset --soft HEAD~1`
- **Without commits** (default): `git checkout -- <files>` to discard working tree changes, or `git stash` to save them for later review
- **Review before discarding**: Always run `git diff` before reverting to confirm which changes will be lost

### When to skip a finding
- **Already fixed**: Note "Resolved — fixed in {commit}" and move on
- **Not applicable**: Note "Not applicable — {reason}" and move on
- **Needs user decision**: Produce analysis-only documentation and ask the user
- **Out of scope**: If the fix requires changes to a different repository or system, note the dependency

## Phase 10: Update Finding State

**Goal**: Close the loop by updating findings.json with patch results.

If the input was a `findings.json` file:

1. For each finding that was patched, update its status:
   ```json
   {
     "status": "patched",
     "resolved_at": "2026-03-28T14:00:00Z",
     "resolved_by": "commit-hash-of-fix"
   }
   ```

2. For systemic findings where ALL child findings are patched, update the systemic finding status too.

3. For findings that were skipped (already fixed, not applicable), update status to `closed` or `wont_fix` with a reason.

4. Write the updated findings.json back to its original location.

This enables the threat-model → threat-patch feedback loop:
```
threat-model produces findings.json (status: open)
     ↓
threat-patch applies fixes, updates findings.json (status: patched)
     ↓
threat-model --diff re-analyzes, verifies fixes (status: verified)
```

If the input was NOT findings.json (Codex CSV, inline description), this phase is skipped.
