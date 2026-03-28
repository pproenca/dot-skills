# Data Flow Tracing

The single most valuable analytical technique for finding real vulnerabilities. Instead of listing what components exist and what could theoretically go wrong, you follow specific untrusted values through actual code paths and find where they reach privileged operations without validation.

## Why This Matters

Most security findings are data flow problems: an untrusted value reaches a privileged operation (file write, exec, allocation, HTML rendering) without being validated, sanitized, or bounded. The current LLM default behavior is to identify attack surfaces by component ("CLI accepts arguments, that's risky"). Data flow tracing replaces that with evidence: "this specific CLI argument flows through these specific functions and reaches this specific privileged operation with no validation checkpoint."

This is the technique that Codex uses to find findings like:
- `--pid` → `DebugAttach.run()` → `session.attach(pid:)` → LLDB attach to ANY process (no PID validation)
- `bundleID` from CLI → `/tmp/agent-sim-extract/\(bundleID)` → `FileManager.removeItem` (path traversal)
- RFC markdown → `marked.parse()` → `innerHTML` assignment (XSS with no sanitization)

## The Technique

### Step 1: Enumerate Entry Points

Use `scripts/trace-data-flows.sh <project-root>` to get an automated inventory, then supplement with manual reading.

Entry points are where attacker-controlled data enters the system:

| System Type | Entry Point Patterns |
|-------------|---------------------|
| CLI tools | `@Argument`, `@Option`, `ArgumentParser`, `process.argv`, `argparse`, `clap` |
| Web services | `req.params`, `req.body`, `req.query`, `req.headers`, `params[:key]`, `request.GET` |
| File processors | `FileManager.contents`, `fs.readFileSync`, `open()`, `JSON.parse(fileContent)` |
| IPC/messaging | `NotificationCenter`, `WebSocket.onmessage`, Redis subscribe callbacks |
| Deserialization | `JSONDecoder.decode`, `JSON.parse`, `pickle.load`, `cJSON_Parse` |

For each entry point, record:
- **Variable name** holding the untrusted value
- **File and line** where it enters
- **What controls it** (CLI user, HTTP client, file author, upstream service)

### Step 2: Trace Each Value Forward

For each entry point variable, grep for its name and follow it through function calls.

**The mechanical process:**
1. Grep for the variable name in the file where it enters
2. Read each usage site — is it passed to another function? Stored in a struct? Used directly?
3. If passed to a function, read that function and repeat from the parameter name
4. At each step, note:
   - **Pass-through**: value forwarded without change (e.g., `self.bundleId = bundleId`)
   - **Transform**: value modified (e.g., `path = "/tmp/" + bundleId` — still tainted!)
   - **Validation**: value checked (e.g., `guard UUID(uuidString: udid) != nil` — removes taint if check is sufficient)
   - **Sink**: value used in a privileged operation (see Step 3)

**Key insight:** Transformations do NOT remove taint. Concatenating an untrusted value into a path makes the path untrusted. Embedding an untrusted value in HTML makes the HTML untrusted. Only explicit validation (checking format, rejecting bad values, escaping for context) removes taint.

### Step 3: Identify Sinks

A sink is a privileged operation where an untrusted value causes harm:

| Sink Category | Operations | Impact |
|--------------|-----------|--------|
| File system | `writeToFile`, `removeItem`, `createDirectory`, `copyItem` | Overwrite, delete, traverse |
| Command execution | `Process()`, `system()`, `exec()`, `popen()`, LLDB `expression` | RCE |
| Memory allocation | `malloc(size)`, `[UInt8](repeating:count:)`, `realloc` | DoS via exhaustion |
| HTML rendering | `innerHTML`, `outerHTML`, `document.write`, template interpolation | XSS |
| SQL/query | String concatenation in queries, unparameterized `WHERE` | Injection |
| Network | `URLSession.data(from:)`, `fetch()`, `Net::HTTP.get` | SSRF |
| Deserialization | `NSKeyedUnarchiver`, `pickle.load`, `eval()` | RCE via gadgets |

### Step 4: Document the Trace

For each entry-to-sink path where the value reaches the sink without sufficient validation, document the complete trace:

```
TRACE: [entry-point-name]
Entry:  CLI --pid argument (DebugAttach.swift:19)
   ↓    pass-through: stored as local `pid` (no validation)
   ↓    pass-through: passed to resolveSimulatorAppPID(pid:bundleId:) — BUT only when bundleId path
   ↓    When pid is provided directly, skips to:
Sink:   session.attach(pid: resolvedPID) (DebugAttach.swift:37)
        Operation: LLDB attaches to process by PID
        Impact: Attaches to ANY process the user can debug, not just simulator apps
Validation: NONE between entry and sink when --pid is provided directly
FINDING: Debug attach allows arbitrary PID debugging and memory access [HIGH]
```

### Step 5: Check Validation Sufficiency

When you find a validation checkpoint, ask:
- **Is it complete?** Does it check all dangerous patterns? (e.g., checking for `..` but not `/`)
- **Is it in the right place?** Is it before or after the dangerous operation?
- **Can it be bypassed?** Is there another code path that reaches the same sink without this check?
- **Is it context-appropriate?** HTML escaping for an HTML context, path validation for a path context, not the wrong escaping for the context

Common insufficient validations:
- Escaping `<>&` but not `"'` (attribute XSS still possible)
- Checking for `..` but not absolute paths
- Validating format but not value range (e.g., checking UUID format but not that it belongs to a simulator)
- Checking in one code path but not in another that reaches the same sink

## Working with the Trace Script

`scripts/trace-data-flows.sh <project-root>` outputs candidate entry-sink pairs:

```
## Entry Points Found
- CLI: @Option pid (Sources/AgentSim/UI/DebugGroup.swift:19)
- CLI: @Option bundleId (Sources/AgentSim/UI/DebugGroup.swift:22)
- CLI: @Option output (Sources/AgentSim/UI/Extract.swift:8)

## Sinks Found
- FileWrite: writeToFile (Sources/AgentSim/Service/ExtractionReport.swift:45)
- Exec: session.attach (Sources/AgentSim/Service/DebugSession.swift:112)
- Alloc: [UInt8](repeating:count:) (Sources/AgentSim/Service/DHParser.swift:205)

## Candidate Traces (same module)
- CLI:pid → Exec:session.attach (both in DebugGroup/DebugSession)
- CLI:output → FileWrite:writeToFile (both in Extract/ExtractionReport)
```

Use these candidates as starting points for manual tracing. The script finds correlations; you verify causation by reading the actual code between entry and sink.

## Common Pitfalls

- **Don't stop at the first function boundary.** The value often passes through 3-5 functions before reaching a sink. Follow it all the way.
- **Transforms preserve taint.** `"/tmp/" + userInput` is still tainted. `URL(string: userInput)` is still tainted. Only explicit validation removes taint.
- **Watch for aliasing.** The value may be stored in a struct field, then accessed later under a different name. Trace through data structures.
- **Check ALL paths to the sink.** A function may have a validated path and an unvalidated path (e.g., `if let bundleId { validated } else { unvalidated }`).
- **Don't trace developer-controlled inputs.** Focus on attacker-controlled and operator-controlled tiers. Tracing source code constants wastes time.
