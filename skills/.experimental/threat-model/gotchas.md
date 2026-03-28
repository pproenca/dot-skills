# Gotchas

### Data flow tracing can exhaust context on large codebases
Following every entry point through every function call generates a lot of reads. On large codebases (1000+ source files), prioritize: trace attacker-controlled inputs first, skip developer-controlled inputs, and focus on modules where the `trace-data-flows.sh` script identifies overlapping entry points and sinks.
Added: 2026-03-28

### Over-chaining produces implausible attack paths
Limit chains to 4 steps maximum. Each step must be independently exploitable. If a chain requires 5+ steps or unrealistic preconditions (physical access, root, timing window < 1ms), it's theoretical, not practical. Rate-limit your chain construction to avoid diluting real findings with noise.
Added: 2026-03-28

### Pattern clustering threshold: 3+ instances, not 2
Two findings of the same class is coincidence, not a systemic pattern. Only cluster when you find 3+ instances AND they share the same root cause (missing abstraction, helper, or policy). Two XSS findings from different causes (one missing escaping, one missing CSP) are not a cluster.
Added: 2026-03-28

### The scan and trace scripts require ripgrep (rg)
Both `scan-patterns.sh` and `trace-data-flows.sh` depend on `rg` (ripgrep) for pattern matching. If `rg` is not installed, the scripts will exit with an error. Install via `brew install ripgrep` (macOS) or `apt install ripgrep` (Debian/Ubuntu).
Added: 2026-03-28

### Large codebases may exceed context limits during analysis
If the codebase is too large to read entirely, focus data flow tracing on files where the trace script identifies both entry points and sinks. Skip vendored/generated code. For incremental analysis, use diff mode (Phase 0) to scope to recent changes.
Added: 2026-03-28

### Bridge analysis only applies when cross-language boundaries exist
Don't force bridge analysis on single-language projects. The technique is high-value for Swift↔C, Rust↔C, Ruby↔C, Node.js↔C++ codebases but irrelevant for pure-language projects.
Added: 2026-03-28
