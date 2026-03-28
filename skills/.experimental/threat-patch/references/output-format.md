# Output Format

Each patched finding produces one of two output formats: a **code patch** or an **analysis-only** report.

---

## Code Patch Format

Use when you produced a working code fix.

### Template

```markdown
## Summary
{What vulnerability was confirmed and what the fix does. 2-3 sentences maximum.
State the core change: "Confirmed X was still present in HEAD; implemented Y."}

{Optional: 1-2 sentences on the approach — what helper was added, what validation
was introduced, what error type was created.}

## Testing

{Warning marker if environment prevents running tests:}
⚠️ {test command} (environment limitation: {what's missing and why}).

{Or if tests can run:}
✅ {test command} — {result summary}

## Diff

{File change summary: N files edited, +X, -Y}

{The actual unified diff or description of edits made}
```

### Guidelines

**Summary**:
- Lead with confirmation: "Confirmed the vulnerability was still present in HEAD by reviewing..."
- State the fix, not just the finding: "The resolution now routes all PID resolution through a single helper that validates..."
- If the fix introduces a new error type, mention it: "Added an explicit error case for rejected host/non-simulator PIDs"

**Testing**:
- Always include the specific test command, even if it can't run
- Use `⚠️` for environment limitations, `✅` for successful runs
- State the limitation clearly: "script depends on lockf, which is unavailable here"
- If multiple test commands are relevant, list each on its own line

**Diff**:
- Show the full diff for the affected files
- Keep the diff minimal — if you changed 3 lines, don't show the entire 500-line file

---

## Analysis-Only Format

Use when the fix needs user decision, requires architectural changes, or when you've confirmed the vulnerability but the remediation is complex.

### Template

```markdown
## Summary
{What vulnerability was confirmed. 1-2 sentences.}

{Description of the vulnerable code path and why a code fix isn't straightforward.}

## Validation
{Checklist of steps to verify the issue exists:}
- [ ] {Step 1: Build with specific flags or config}
- [ ] {Step 2: Trigger the vulnerable code path}
- [ ] {Step 3: Observe the symptom}
- [ ] {Step 4: Use tool X to capture evidence}
- [ ] Code review confirms {specific pattern} in {file}:{lines}

{Optional: Validation artifact reference}
Validation artifact: {path to PoC, test case, or captured evidence}

## Attack-path analysis

{Assessment of real-world exploitability}

**Path**
{Step-by-step exploitation flow using arrow notation:}
{Input source} → {processing step} → {vulnerable operation} → {impact}

**Likelihood**
{Low/Medium/High} — {1-2 sentences justifying the rating with specific preconditions}

**Impact**
{Low/Medium/High} — {1-2 sentences describing the concrete damage}

**Assumptions**
- {What must be true for the attack to work}
- {What access the attacker needs}

**Controls**
- {Existing controls that limit the attack}
- {Factors that reduce likelihood or impact}

**Blindspots**
- {What you couldn't verify due to environment limitations}
- {Unknowns that affect the risk assessment}
```

### Guidelines

**Validation**:
- Steps should be reproducible by another engineer
- Include specific file references and line numbers
- If you have a PoC artifact, reference its path

**Attack-path analysis**:
- The Path should read like a chain: each step feeds the next
- Likelihood and Impact ratings should be consistent with the finding's severity
- Assumptions must state attacker preconditions explicitly
- Controls include EXISTING mitigations in the codebase
- Blindspots are honest about what you couldn't test

---

## Grouping Multiple Findings

When multiple findings share a root cause and are fixed together, use:

```markdown
## Summary
{What shared vulnerability pattern was confirmed and what the centralized fix does.}

Addresses findings:
- {Finding 1 title} ({severity})
- {Finding 2 title} ({severity})
- {Finding 3 title} ({severity})

## Testing
{Test commands}

## Diff
{The combined diff}
```

---

## Commit Message Format

When committing patches:

```
security: {brief description of fix}

Fixes: {finding title}
Severity: {level}
```

For grouped findings:

```
security: {brief description of centralized fix}

Fixes:
- {Finding 1 title} ({severity})
- {Finding 2 title} ({severity})
Severity: {highest level in group}
```
