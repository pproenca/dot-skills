# Transcript: Threat Model of threat-patch skill

## Task Understanding

The task was to perform a full threat model of the `threat-patch` skill at `skills/.experimental/threat-patch/` using the threat-model skill's 10-phase methodology. The threat-patch skill parses Codex security finding CSVs and generates code patches via an LLM agent. The specific concerns raised were: (1) what happens if someone feeds it a malicious CSV, and (2) whether the patch workflow has unintended side effects.

## Steps Taken

### Phase 0: Diff Analysis (skipped)
No git range was provided. Full codebase analysis mode.

### Phase 1: Codebase Survey
**Tools used:** Read (SKILL.md, config.json, metadata.json, gotchas.md), Bash (ls -la, ls -laR)

Read the threat-patch skill's complete file set:
- `SKILL.md` -- main skill definition, 75 lines, describes a 9-phase patching workflow
- `config.json` -- configuration with `findings_csv_path`, `threat_model_path`, `commit_patches`, `branch_prefix`
- `metadata.json` -- version 0.1.0, type: automation, discipline: composition
- `gotchas.md` -- 3 known issues (python3 requirement, commit hash drift, grouped fix testing)
- `hooks/hooks.json` -- PreToolUse hooks for Edit and Write tools
- `scripts/parse-findings.sh` -- 124-line bash/Python CSV parser
- `references/workflow.md` -- 9-phase detailed patching methodology
- `references/fix-patterns.md` -- fix templates for 9 vulnerability classes
- `references/output-format.md` -- code patch and analysis-only output templates

**Key finding:** The skill is an "agent skill" -- it is a set of instructions and reference documents that guide an LLM agent's behavior, not a standalone application. The only executable code is `parse-findings.sh`. The actual code modifications are performed by the LLM agent using its tool set (Read, Edit, Write, Bash, Grep, Glob).

### Phase 2: Component Mapping
**Tools used:** Read (all files above)

Components identified:
1. **SKILL.md** -- Entry point/trigger, workflow overview, key principles
2. **parse-findings.sh** -- CSV parser (bash + embedded Python), converts CSV to markdown
3. **hooks.json** -- PreToolUse hooks for Edit/Write gating
4. **workflow.md** -- Detailed 9-phase methodology the agent follows
5. **fix-patterns.md** -- Fix templates by vulnerability class (reference only)
6. **output-format.md** -- Output templates for code patches and analysis-only reports
7. **config.json** -- Runtime configuration

Data flow: CSV file -> parse-findings.sh -> markdown output -> LLM agent context -> agent reads code files -> agent designs fix -> agent edits code files -> agent documents output

No cross-language bridges. The bash-to-Python bridge in parse-findings.sh is via heredoc/subprocess, not FFI.

### Phase 3: Asset & Security Goal Identification
**Tools used:** Analysis of Phase 1-2 findings

Assets identified:
1. Host filesystem integrity (agent has Edit/Write/Bash access)
2. Agent behavior integrity (CSV fields enter agent context as natural language)
3. Target codebase integrity (patches should be correct and minimal)
4. Operator trust (skill should faithfully translate findings into fixes)

### Phase 4: Trust Boundaries + Entry Point Mapping
**Tools used:** Bash (trace-data-flows.sh), Grep (multiple pattern searches)

Ran `scripts/trace-data-flows.sh` from the threat-model skill on the threat-patch directory. Results confirmed:
- Entry points: `sys.argv[1]` (csv_path), `sys.argv[2]` (repo_filter), `sys.argv[3]` (severity_filter) in parse-findings.sh
- The references/*.md files contain code examples that match sink patterns but are not executable code -- they are documentation

Manual trust boundary classification:
- **Attacker-controlled:** CSV file contents (all fields), THREAT-MODEL.md contents, inline finding descriptions
- **Operator-controlled:** config.json values, environment (python3, git state)
- **Developer-controlled:** SKILL.md, references/*.md, hooks.json, parse-findings.sh

### Phase 5: Data Flow Tracing (CRITICAL phase)
**Tools used:** Read (parse-findings.sh), Grep (multiple searches for field usage, tool usage, path handling, git operations)

Traced the following data flows:

**TRACE 1: CSV fields -> agent context (prompt injection)**
```
Entry:  CSV file opened by csv.DictReader (parse-findings.sh:74)
   |    row.get("title"), row.get("severity"), etc. (lines 94-98)
   |    pass-through: printed as markdown f-strings (lines 104-108)
   |    pass-through: stdout consumed by LLM agent as context
Sink:   Agent interprets text as instructions during Phase 1 (workflow.md)
Validation: NONE -- no sanitization, escaping, or content filtering between CSV fields and agent context
FINDING: Prompt injection via CSV fields [HIGH]
```

**TRACE 2: relevant_paths -> file read/write**
```
Entry:  row.get("relevant_paths", "") (parse-findings.sh:97)
   |    pass-through: printed as `- **Files**: {paths}` (line 108)
   |    pass-through: agent extracts paths from output
   |    transform: agent uses paths in Read tool calls (workflow.md Phase 3)
Sink:   Read tool opens arbitrary file paths; Edit/Write tool modifies them (Phase 6)
Validation: NONE -- no path containment, no allowlist, no project-root check
FINDING: Arbitrary file read/write via relevant_paths [HIGH]
```

**TRACE 3: description -> fix implementation**
```
Entry:  CSV "description" field (consumed by agent during Phase 1)
   |    pass-through: agent uses description to understand vulnerability
   |    pass-through: agent designs fix based on description (Phase 5)
Sink:   Agent implements code changes via Edit/Write tools (Phase 6)
Validation: Phase 4 "Confirm Vulnerability" provides partial check, but agent may still follow description's instructions
FINDING: Misdirected/backdoor fixes via crafted descriptions [MEDIUM]
```

**TRACE 4: title -> commit message**
```
Entry:  CSV "title" field (parse-findings.sh:94, printed at line 104)
   |    pass-through: agent uses title in commit message (output-format.md)
Sink:   git commit -m "security: ... Fixes: {finding title}" (workflow.md Phase 9)
Validation: NONE -- title included verbatim in commit messages
FINDING: Commit message injection via title field [LOW]
```

**TRACE 5: hooks.json -> tool gating**
```
Entry:  hooks.json loaded by Claude Code harness
   |    PreToolUse matcher for "Edit" and "Write"
   |    command: echo warning message
Sink:   Command exits 0 (always succeeds), harness may or may not block
Validation: Hook is advisory only -- always exits 0, relies on harness behavior
FINDING: Hook bypass in auto-approve mode [MEDIUM]
```

### Phase 6: Attack Surface Enumeration
**Tools used:** Analysis of Phase 5 traces

Documented 6 attack surfaces (see THREAT-MODEL.md Section 3):
- 3.1: CSV parsing and prompt injection via finding fields
- 3.2: Arbitrary file read/write via relevant_paths
- 3.3: Hook bypass and guardrail limitations
- 3.4: Bash command injection via parse-findings.sh (limited)
- 3.5: Agent-directed code changes and patch correctness
- 3.6: Git operations and persistent state changes

### Phase 7: Pattern Clustering
**Tools used:** Analysis of Phase 6 findings

Identified 2 systemic patterns:
1. **No input validation or containment for finding fields** -- 4 instances (3.1, 3.2, 3.5, 3.6). Root cause: CSV field values flow from parse-findings.sh directly into agent context without any validation layer.
2. **No effective blocking gate on agent tool usage** -- 3 instances (3.3, 3.2 read path, 3.1 context injection). Root cause: hooks only cover Edit/Write with advisory-only commands.

### Phase 8: Exploit Chain Construction
**Tools used:** Analysis of Phase 6-7 findings

Constructed 3 exploit chains:
1. **Malicious CSV to arbitrary file read** (High): prompt injection -> relevant_paths read -> exfiltration via output
2. **Malicious CSV to backdoor insertion** (Critical): prompt injection -> misdirected fix -> hook bypass -> backdoor committed
3. **CSV-driven commit message injection** (Medium): title injection -> CI keyword in commit -> unreviewed deployment

### Phase 9: Calibration
**Tools used:** Analysis of all phases

Applied chain-adjusted and systemic severity ratings. Key adjustments:
- Chain 2 (backdoor insertion) rated Critical due to terminal impact of arbitrary code insertion, despite individual findings being Medium
- Systemic findings both rated High due to 3-4 instances and high centralizability
- Scope note added: findings assume attacker can provide/modify CSV; trusted-only CSV sources reduce ratings

### Phase 10: Output
**Tools used:** Write (THREAT-MODEL.md, transcript.md)

Wrote THREAT-MODEL.md following the 6-section output format from the threat-model skill. Wrote this transcript.

## Issues Encountered

1. **`scripts/trace-data-flows.sh` not in project root**: The skill's SKILL.md references `scripts/trace-data-flows.sh` but the actual script is inside the threat-model skill directory, not the project root's `scripts/` directory. Found it via Glob and ran it from its actual location.

2. **Script output mostly matched reference docs, not executable code**: The trace-data-flows.sh script found entry/sink matches primarily in `references/fix-patterns.md`, which contains code examples for documentation purposes, not actual executable code. The only real executable is `parse-findings.sh`. This required shifting to manual data flow tracing through the skill's instruction documents and how they direct the LLM agent's behavior.

3. **Agent-as-runtime analysis challenge**: The threat-patch skill is not a traditional application -- it is an instruction set for an LLM agent. The "code" that executes is the agent following natural language instructions. This means the attack surface is primarily prompt injection and instruction manipulation, rather than traditional code vulnerabilities like buffer overflows or SQL injection. The data flow tracing technique had to be adapted to trace data through the agent's interpretation of instructions, not just through function calls.

## Output Produced

- `/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/threat-model-workspace/iteration-2/eval-2-threat-patch-self-analysis/with_skill/run-1/outputs/THREAT-MODEL.md` -- Full 6-section threat model document
- `/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/threat-model-workspace/iteration-2/eval-2-threat-patch-self-analysis/with_skill/run-1/transcript.md` -- This transcript
