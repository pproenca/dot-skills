# Pattern Clustering

After enumerating individual attack surfaces, step back and look for patterns. When 3+ findings share a root cause, that's a systemic weakness worth more attention than any individual finding.

## Why This Matters

Individual findings are symptoms. Patterns reveal the disease. Codex found 8 predictable-tmp findings in agent-sim — each medium severity. But the root cause is a single architectural gap: the project has no secure temporary directory abstraction. Fixing that one gap resolves all 8 findings. Rating and recommending systemic fixes is more valuable than listing 8 individual patches.

## The Technique

### Step 1: Categorize Findings by Vulnerability Class

After Phase 6 (Attack Surface Enumeration), tag each finding with its vulnerability class:

| Class | Pattern | Example |
|-------|---------|---------|
| `PREDICTABLE_TMP` | Fixed paths under `/tmp` without unique naming | `/tmp/agent-sim-extract/<bundleID>` |
| `PATH_TRAVERSAL` | Unsanitized user input in path construction | `bundleID` with `../` in path concatenation |
| `SYMLINK_RACE` | File ops at predictable paths without link checks | `writeToFile` at `/tmp/known-name.json` |
| `XSS_NO_SANITIZE` | Untrusted data in HTML without escaping | `marked.parse()` → `innerHTML` |
| `INJECTION` | Untrusted input interpolated into commands/queries | String interpolation into LLDB expressions |
| `UNBOUNDED_ALLOC` | Allocation sized by untrusted value without cap | `realloc(buf, untrusted_size)` |
| `LIFETIME_RACE` | Resource used after owning scope ends | Async block using freed session |
| `MISSING_AUTH` | Mutation endpoint without auth middleware | Rails controller without `before_action` |
| `INFO_DISCLOSURE` | Internal data exposed without access control | Status endpoints returning telemetry |

### Step 2: Count Instances Per Class

| Class | Count | Files |
|-------|-------|-------|
| PREDICTABLE_TMP | 8 | ExtractionCapture, ExtractionCatalog, LLDBExtractor, ... |
| XSS_NO_SANITIZE | 4 | ExtractionReport, DesignHTMLBuilder, viewer.html |
| PATH_TRAVERSAL | 3 | AppResigner, Update, Manifest |
| SYMLINK_RACE | 6 | ExtractionCapture, ScreenExtractor, ... |

### Step 3: Identify Root Causes (groups with 3+ instances)

For each group with 3+ findings, identify the shared root cause — the missing abstraction, policy, or validation that if added would resolve all instances:

**Template:**
```
SYSTEMIC FINDING: {root cause description}
Instances: {count} individual findings
Root cause: {what's missing — the abstraction, policy, or helper}
Recommended fix: {single change that resolves all instances}
Affected files: {list}
Systemic severity: {see rating below}
```

**Example:**
```
SYSTEMIC FINDING: No secure temporary directory abstraction
Instances: 8 individual findings (PREDICTABLE_TMP × 5, SYMLINK_RACE × 3)
Root cause: Every component creates its own temp paths using hardcoded `/tmp/`
  prefixes. No shared helper enforces unique naming, restrictive permissions,
  or cleanup.
Recommended fix: Create a `secureTemporaryDirectory(prefix:)` function that:
  1. Uses `mkdtemp` or UUID-based naming under NSTemporaryDirectory()
  2. Sets permissions to 0700
  3. Returns the path for use, with cleanup handled by the caller
  Replace all 8 hardcoded /tmp/ paths with calls to this helper.
Affected files: ExtractionCapture.swift, ExtractionCatalog.swift,
  LLDBExtractor.swift, AppResigner.swift, ScreenExtractor.swift
Systemic severity: HIGH (8 instances × medium individual severity × high centralizability)
```

### Step 4: Rate Systemic Severity

Systemic findings get a severity boost based on:

| Factor | Low | Medium | High |
|--------|-----|--------|------|
| Instance count | 3-4 | 5-7 | 8+ |
| Individual severity | Low | Medium | High/Critical |
| Fix centralizability | Hard (different root causes) | Moderate (shared pattern) | Easy (one helper fixes all) |

**Rating formula:** Take the highest individual severity, then adjust up if:
- 5+ instances AND high centralizability → bump one level (medium → high)
- 8+ instances AND the pattern is expanding (new instances in recent commits) → bump one level

A systemic finding should never be rated LOWER than its highest individual instance.

### Step 5: Distinguish Systemic from Individual

In the output, present systemic findings BEFORE individual findings in the Criticality Calibration section. Systemic findings are more important because:
1. They fix multiple vulnerabilities with one change
2. They prevent future instances of the same pattern
3. They indicate an architectural gap, not just a bug

Individual findings that belong to a cluster should reference their systemic parent:
```
- Path traversal via bundleID in AppResigner.swift [medium]
  → Part of systemic finding: "No input validation for path components"
```

## When NOT to Cluster

- **2 findings**: Not enough for a pattern. List individually.
- **Different root causes**: 3 XSS findings might have different root causes (one is missing escaping, another is missing CSP, a third is using `eval`). Only cluster if the fix is genuinely shared.
- **Different components**: Findings in completely separate subsystems that happen to share a vulnerability class but don't share code paths. These are coincidences, not systemic issues.
