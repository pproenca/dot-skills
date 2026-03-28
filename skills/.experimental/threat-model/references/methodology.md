# Threat Modeling Methodology

Follow these phases sequentially. Each builds on the previous one. Phases 5, 7, and 8 are the analytical core — they encode techniques that distinguish this analysis from a generic security review.

## Phase 0: Diff Analysis (conditional)

**When to use**: If the user provides a git range, commit hash, or asks about "what changed" — scope the analysis to the diff instead of the full codebase.

Read [techniques/diff-analysis.md](techniques/diff-analysis.md) and follow its workflow. Skip Phases 1-4 (use the existing threat model for context) and start at Phase 5 with only the changed code.

## Phase 1: Codebase Survey

**Goal**: Understand what the project is, how it's deployed, and what its primary security concerns are.

**Actions**:
1. Read README, CLAUDE.md, architecture docs, and any existing security documentation
2. List the top-level directory structure to understand project organization
3. Identify the primary language(s), frameworks, and build system
4. Check for network endpoints, CLI entry points, config file formats, and deployment targets
5. Read dependency manifests (Package.swift, package.json, Cargo.toml, go.mod, Gemfile, requirements.txt)

**Why this matters**: The deployment model determines which threats are relevant. A local CLI tool has fundamentally different threats than a multi-tenant web service.

**Output**: A 2-3 paragraph overview describing what the project does, its key components, and its deployment model.

## Phase 2: Component Mapping + Bridge Identification

**Goal**: Identify the distinct runtime components, how data flows between them, and where cross-language bridges exist.

**Actions**:
1. Map each major module/package/service to its role (UI layer, service layer, data layer, bridge code)
2. Identify data flows: what data enters the system, how it's processed, and where it exits
3. Note privilege levels — what can each component access? (filesystem, network, other processes, system APIs)
4. **Identify all cross-language bridges** — C/ObjC from Swift, JNI from Java, FFI from Rust, shared memory between services. For each bridge, note what types cross the boundary and who manages memory.

If bridges are found, read [techniques/bridge-analysis.md](techniques/bridge-analysis.md) and apply its systematic checklist during Phase 6.

## Phase 3: Asset & Security Goal Identification

**Goal**: Define what needs protecting and what a successful attack looks like.

**Think about**:
- **Host integrity**: Can the tool be used to compromise the machine it runs on?
- **Data confidentiality**: What sensitive data does the system handle?
- **Data integrity**: Can an attacker corrupt stored data or outputs?
- **Availability**: Can the system be crashed or rendered unusable?
- **Downstream trust**: Do other systems trust this system's output?

## Phase 4: Trust Boundaries + Entry Point Mapping

**Goal**: Classify every input by who controls it, and build a concrete inventory of entry points for data flow tracing.

### Trust tiers (from most dangerous to least)

**Attacker-controlled**: Data an adversary can directly influence — CLI arguments, HTTP requests, file contents from untrusted sources, data from apps under test.

**Operator-controlled**: Configuration set by the deployer — config files, environment variables, deployment manifests. Can become attacker-controlled if the operator environment is compromised.

**Developer-controlled**: Source code, build scripts, packaged assets. Only a threat if the supply chain is compromised.

### Entry point inventory

For each attacker-controlled input, record:
- **Variable name** holding the untrusted value
- **File and line** where it enters the system
- **What controls it** (CLI user, HTTP client, file author, upstream service)

Run `scripts/trace-data-flows.sh <project-root>` to automate the initial inventory. This feeds directly into Phase 5.

## Phase 5: Data Flow Tracing

**This is the highest-value analytical phase.** Instead of listing what components exist and what could theoretically go wrong, you follow specific untrusted values through actual code and find where they reach privileged operations without validation.

Read [techniques/data-flow-tracing.md](techniques/data-flow-tracing.md) for the complete technique.

**The core loop**:
1. Take each entry point from Phase 4
2. Grep for the variable name, follow it through function calls
3. At each step: is the value validated? transformed? passed through unchanged?
4. If it reaches a sink (file write, exec, allocation, HTML render) without validation → FINDING
5. Document the complete trace: `entry → [fn: no validation] → [fn: transforms] → sink`

**Why this matters**: This is the technique that Codex uses to find findings like `--pid` → unvalidated → LLDB attach to any process, or `bundleID` → unvalidated → path traversal in `/tmp/`. The model's default behavior is to identify surfaces by component; data flow tracing follows the actual code paths and produces evidence-backed findings.

## Phase 6: Attack Surface Enumeration

**Goal**: For each significant component, document concrete attack surfaces using evidence from data flow tracing.

Each finding from Phase 5 becomes an attack surface subsection. For surfaces not discovered by tracing (e.g., configuration issues, missing auth, information disclosure), enumerate them here using the operation-to-risk mapping:

| Data Operation | Risk Class |
|---------------|------------|
| Concatenate into path | Path traversal, symlink attacks |
| Concatenate into command/query | Injection (SQL, command, LLDB) |
| Embed in HTML/template | XSS (reflected, stored, DOM) |
| Deserialize/parse | Memory corruption, DoS, type confusion |
| Write to predictable location | Symlink race, file overwrite |
| Allocate based on untrusted size | Memory exhaustion, DoS |
| Execute as code | RCE, privilege escalation |

For each surface, document: **Surface** (specific files/functions), **Risks** (what goes wrong), **Mitigations/controls** (what's already there), **Attacker story** (concrete scenario with preconditions).

If cross-language bridges were identified in Phase 2, apply [techniques/bridge-analysis.md](techniques/bridge-analysis.md) to each bridge now.

## Phase 7: Pattern Clustering

**Goal**: Group findings that share a root cause into systemic findings worth more attention than individual bugs.

Read [techniques/pattern-clustering.md](techniques/pattern-clustering.md) for the complete technique.

**The core process**:
1. Tag each finding from Phase 6 with its vulnerability class
2. Count instances per class
3. Groups with 3+ instances → identify the shared root cause (the missing abstraction, policy, or helper)
4. Rate systemic findings higher than individual findings (they fix more with one change)
5. Recommend the single fix that resolves the entire cluster

**Why this matters**: 8 predictable-tmp findings in agent-sim are symptoms. The root cause is "no secure temporary directory abstraction." Systemic findings guide better remediation and prevent future instances.

## Phase 8: Exploit Chain Construction

**Goal**: Identify multi-step attack paths where individual findings combine into worse outcomes.

Read [techniques/exploit-chains.md](techniques/exploit-chains.md) for the complete technique.

**The core process**:
1. For each finding, identify what access/information it PROVIDES and what it REQUIRES
2. If finding A's output satisfies finding B's input → chain A→B
3. Rate the chain by its terminal impact, not its weakest link
4. Identify chain-breaking controls — which single fix breaks the most chains

**Why this matters**: Path traversal (medium) + predictable tmp (medium) + symlink race (medium) = arbitrary file overwrite with attacker content (critical). Individual ratings miss the combined risk.

## Phase 9: Calibration

**Goal**: Rate all findings — individual, systemic, and chain — by severity.

### Calibration framework

| Level | Criteria |
|-------|----------|
| **Critical** | Host compromise, arbitrary code execution, complete data breach, critical exploit chains |
| **High** | Significant data exfiltration, major functionality bypass, widespread DoS, systemic findings with 5+ instances |
| **Medium** | Limited DoS, constrained data leaks, bypasses with preconditions |
| **Low** | Edge cases, minor reliability issues, theoretical risks |

### Severity adjustments

- **Chains**: Rate by terminal impact. A chain of mediums reaching critical impact is critical.
- **Systemic findings**: Bump one level if 5+ instances AND highly centralizable fix.
- **Context**: Adjust for deployment model. Always include scope notes.

### Out-of-scope

Include an explicit "Out-of-scope / not applicable" subsection listing threat classes that don't apply and why.

### Historical calibration

If a `findings.json` exists from a prior run, read it before calibrating:
- **Consistency**: If the same finding was rated medium last time, rate it medium again unless something changed. Document the reason if you deviate.
- **State tracking**: Findings that were `patched` or `verified` in the prior run should be checked — are they still fixed, or did a regression reintroduce them?
- **Severity trends**: If the prior run's severity for a category was adjusted by user feedback, inherit that calibration.

## Phase 10: Output

Produce **two files**:

### findings.json (source of truth)

Write structured findings using the schema in [findings-schema.md](findings-schema.md). This file:
- Is consumed by `threat-patch` for automated remediation
- Tracks finding state across runs (open → patched → verified → closed)
- Enables incremental analysis (diff mode updates the same file)
- Contains data flow traces, systemic groupings, and exploit chains as structured data

When updating an existing findings.json (diff mode or re-analysis):
- Preserve `status`, `resolved_at`, `resolved_by` for findings that haven't changed
- Add new findings with `status: "open"`
- Mark removed findings as `status: "closed"` (don't delete — preserve history)

### THREAT-MODEL.md (human view)

Write the human-readable document using the format in [output-format.md](output-format.md). This is generated FROM the findings.json data — the two files should be consistent.

**Final checks**:
- findings.json and THREAT-MODEL.md contain the same findings (no drift)
- Every finding has a `trace` with entry, steps, and sink
- Systemic findings reference their child finding IDs
- Chains reference their constituent finding IDs
- Calibration considers deployment context and chain-adjusted severity
- Out-of-scope section is explicit
