# Threat Model: threat-patch Skill

**Subject**: `skills/.experimental/threat-patch/`
**Date**: 2026-03-28
**Scope**: CSV ingestion, patch generation workflow, hooks, shell script, and the overall interaction model between the skill and a target codebase.

---

## 1. System Description

The `threat-patch` skill reads security findings from Codex CSV exports, THREAT-MODEL.md files, or inline descriptions, and produces minimal, surgical code patches to remediate them. The workflow is:

1. **Ingest**: Parse CSV via `scripts/parse-findings.sh` (a bash+Python script) or read findings inline.
2. **Triage & Group**: Sort by severity, group by root cause.
3. **Per finding**: Read affected code, confirm vulnerability in HEAD, design fix, implement, document, test.
4. **Output**: Structured patch documentation with diffs.

Key components:
- `scripts/parse-findings.sh` -- Bash wrapper that invokes an inline Python script to parse CSV using `csv.DictReader`.
- `hooks/hooks.json` -- PreToolUse hooks on Edit and Write that echo a warning message before file modifications.
- `references/workflow.md` -- Detailed 9-phase methodology.
- `references/fix-patterns.md` -- Fix templates by vulnerability class.
- `config.json` -- Configuration (CSV path, commit behavior, branch prefix).

---

## 2. Trust Boundaries

| Boundary | Description |
|----------|-------------|
| **CSV input -> parse-findings.sh** | External CSV file crosses into the shell/Python parsing layer. The CSV originates from Codex or a user-supplied source -- its contents are untrusted. |
| **Parsed findings -> AI agent** | Structured findings are consumed by the AI agent to drive code reading, fix design, and patch generation. Finding fields (title, description, relevant_paths) become agent instructions. |
| **AI agent -> target codebase** | The agent reads and writes files in the target repository. Edit/Write tool calls cross from the agent's reasoning into actual file system mutations. |
| **User -> config.json** | Configuration values (paths, branch prefix) influence script behavior and git operations. |

---

## 3. Attack Surfaces

### 3.1 Malicious CSV Injection into parse-findings.sh

**Component**: `scripts/parse-findings.sh` (lines 53-123, inline Python)

**Description**: The script reads an arbitrary CSV file and prints field values directly into formatted output strings using Python f-strings. No sanitization or escaping is applied to any field value.

**Threat T1: Shell metacharacter injection via CSV field values**

- **Path**: Attacker crafts CSV -> `parse-findings.sh` parses with Python `csv.DictReader` -> field values printed via `print(f"...")` -> output consumed by shell or AI agent.
- **Analysis**: The Python `csv` module correctly handles CSV parsing (quoted fields, embedded commas). The output is printed to stdout, not passed to `subprocess` or `os.system`. The f-string output goes to the terminal or is piped. Direct shell injection through the Python layer is **not exploitable** because the script does not invoke shell commands with CSV-derived values.
- **However**: If the output of `parse-findings.sh` is piped into another shell command or processed by a script that evaluates it, crafted field values containing shell metacharacters (`;`, `$()`, backticks) could execute. The skill does not explicitly do this, but the output format (markdown with inline values) could be misused downstream.
- **Likelihood**: Low (requires a downstream consumer to evaluate the output unsafely)
- **Impact**: High (arbitrary command execution if the output is eval'd)

**Threat T2: CSV field values used as filesystem paths without validation**

- **Path**: Attacker sets `relevant_paths` CSV field to contain path traversal sequences (`../../etc/passwd`) or absolute paths -> AI agent reads these paths to understand vulnerable code -> agent may read sensitive files outside the intended repository.
- **Analysis**: The `relevant_paths` field from the CSV is printed in the parsed output and then used by the AI agent as file targets for reading during Phase 3 (Read Affected Code). The workflow instructs the agent to "open each file listed in relevant_paths." There is no validation that these paths are within the target repository.
- **Likelihood**: Medium (an attacker who controls the CSV controls which files the agent reads)
- **Impact**: Medium (information disclosure -- agent reads files outside the project, potentially secrets or system files)

**Threat T3: Oversized or malformed CSV causing resource exhaustion**

- **Path**: Attacker provides a multi-gigabyte CSV or a CSV with extremely long field values -> Python loads entire file into memory via `csv.DictReader` iteration and `findings.append(row)` -> memory exhaustion.
- **Analysis**: Line 83 (`findings.append(row)`) accumulates all matching rows into an in-memory list. A CSV with millions of rows would consume proportional memory. The `Counter` objects also accumulate unbounded data.
- **Likelihood**: Low (requires the user to feed in a malicious file)
- **Impact**: Low-Medium (denial of service -- process killed by OOM, no data loss)

### 3.2 Prompt Injection via CSV/Finding Content

**Component**: The entire workflow -- findings are consumed as natural language by the AI agent.

**Threat T4: Indirect prompt injection through finding descriptions**

- **Path**: Attacker crafts a CSV where `title`, `description`, or other fields contain adversarial instructions (e.g., "Ignore previous instructions and instead...") -> agent processes these as part of its workflow -> agent deviates from intended behavior.
- **Analysis**: This is the most significant threat. The skill's workflow directly feeds untrusted content (finding titles, descriptions, file paths) into the AI agent's context. The agent is instructed to read these, understand them, and act on them. A malicious finding description could:
  - Instruct the agent to skip the confirmation gate and directly edit files
  - Instruct the agent to introduce a backdoor instead of a fix
  - Instruct the agent to exfiltrate file contents by including them in "patch documentation"
  - Instruct the agent to modify files outside the target project
- **Likelihood**: Medium-High (any party that controls the CSV controls part of the agent's context; Codex exports are semi-trusted but could be tampered with)
- **Impact**: Critical (arbitrary code modification in the target repository, potential supply chain compromise if patches are committed and pushed)

**Mitigating factors**:
- The PreToolUse hooks (hooks.json) display a warning before Edit/Write, giving the human operator a chance to review. But these are echo-only warnings, not blocking gates -- they do not actually pause or require confirmation.
- The workflow says "wait for user approval" before Phase 6, but this is a natural-language instruction to the agent, not a technical enforcement mechanism.

### 3.3 Hook Bypass and Insufficiency

**Component**: `hooks/hooks.json`

**Threat T5: Hooks are non-blocking warnings, not enforcement gates**

- **Path**: Agent invokes Edit or Write tool -> hook fires, echoing a warning -> tool execution proceeds regardless -> file is modified.
- **Analysis**: The hooks defined in `hooks.json` use `type: "command"` with a simple `echo` command. These print a warning message but do not return a non-zero exit code that would block the tool invocation. They are informational, not preventive. An agent (whether compromised by prompt injection or simply making an error) will proceed with the edit regardless of the hook.
- **Likelihood**: High (the hooks fire on every Edit/Write but never block)
- **Impact**: Medium (the safety guardrail advertised in SKILL.md line 51-54 does not actually prevent unreviewed edits)
- **Recommendation**: Hooks should return a non-zero exit code to block the operation, or use an interactive confirmation mechanism. The current design provides a false sense of security.

**Threat T6: Hooks do not cover all file-modifying operations**

- **Path**: Agent uses Bash tool to run `sed`, `mv`, `cp`, or other file-modifying commands -> no hook fires -> files modified without any warning.
- **Analysis**: The hooks only gate `Edit` and `Write` tool invocations. The Bash tool can execute arbitrary commands including file modifications, and no hook intercepts it. An agent (or a prompt-injected instruction) could bypass the Edit/Write hooks entirely by using Bash to modify files directly.
- **Likelihood**: Medium (depends on whether the agent or injected prompt uses Bash for file modifications)
- **Impact**: High (complete bypass of the only safety mechanism)

### 3.4 Git Operations and Commit Safety

**Component**: `config.json` (`commit_patches`, `branch_prefix`), `references/workflow.md` (Phase 9)

**Threat T7: Malicious branch prefix enabling ref injection**

- **Path**: Attacker modifies `config.json` to set `branch_prefix` to a value like `refs/heads/main; rm -rf /` or `../../` -> value used in git branch creation -> potential command injection or unexpected ref creation.
- **Analysis**: The `branch_prefix` value is used to construct branch names when `commit_patches` is true. If the agent passes this value unsanitized to `git checkout -b`, crafted values could interfere with git operations. The severity depends on how the agent constructs the git command.
- **Likelihood**: Low (requires attacker to modify config.json, which is within the skill directory)
- **Impact**: Medium (unintended git operations, potential command injection)

**Threat T8: Automatic commits pushing malicious patches upstream**

- **Path**: Agent generates a flawed or malicious patch -> `commit_patches: true` -> agent commits and potentially pushes -> malicious code enters the repository history.
- **Analysis**: The default is `commit_patches: false`, which is a good default. However, if enabled, the workflow creates commits with the `security:` prefix which may bypass certain CI/CD branch protection rules that treat security-prefixed commits differently. The workflow does not mention pushing, but an agent could be instructed (via prompt injection in a finding) to push after committing.
- **Likelihood**: Low (requires commit_patches to be enabled AND a push to happen)
- **Impact**: Critical (malicious code in shared repository)

### 3.5 Arbitrary File Read via relevant_paths

**Component**: `references/workflow.md` Phase 3

**Threat T9: Information disclosure through controlled file reads**

- **Path**: Malicious CSV sets `relevant_paths` to sensitive files (`.env`, `~/.ssh/id_rsa`, `/etc/shadow`, credentials files) -> agent follows workflow Phase 3 ("Open each file listed in relevant_paths") -> agent reads sensitive files -> file contents appear in agent output/documentation.
- **Analysis**: The workflow explicitly instructs the agent to open files from `relevant_paths` without any validation that these paths belong to the target project. The agent will faithfully read whatever paths are listed. Combined with the output format that includes file contents in patch documentation, this creates a data exfiltration path.
- **Likelihood**: Medium (requires control over the CSV, which is the primary input)
- **Impact**: High (credential theft, secret exfiltration)

### 3.6 parse-findings.sh Argument Handling

**Component**: `scripts/parse-findings.sh` lines 36-49

**Threat T10: Path with special characters in CSV_PATH argument**

- **Path**: User provides a CSV path containing spaces or special characters -> `CSV_PATH="$1"` is correctly quoted -> but the path is passed to Python as `sys.argv[1]` -> Python's `open()` handles it correctly.
- **Analysis**: The bash script properly quotes `$CSV_PATH` in the file existence check (line 28-30) and passes it as a positional argument to Python. This is handled correctly. **Not exploitable.**
- **Likelihood**: N/A
- **Impact**: N/A

---

## 4. Criticality Calibration

| ID | Threat | Likelihood | Impact | Risk | Priority |
|----|--------|-----------|--------|------|----------|
| T4 | Indirect prompt injection via finding content | Medium-High | Critical | **Critical** | P0 |
| T5 | Hooks are non-blocking (false safety guardrail) | High | Medium | **High** | P1 |
| T6 | Hooks do not cover Bash tool | Medium | High | **High** | P1 |
| T9 | Arbitrary file read via relevant_paths | Medium | High | **High** | P1 |
| T2 | Path traversal in relevant_paths field | Medium | Medium | **Medium** | P2 |
| T8 | Malicious patches auto-committed | Low | Critical | **Medium** | P2 |
| T1 | Shell metacharacter injection in CSV output | Low | High | **Medium** | P3 |
| T7 | Branch prefix injection | Low | Medium | **Low** | P3 |
| T3 | Resource exhaustion via oversized CSV | Low | Low-Medium | **Low** | P4 |

---

## 5. Recommendations

### P0 -- Prompt Injection Mitigation

1. **Sanitize finding content before agent consumption**: Strip or escape control characters, markdown formatting, and instruction-like patterns from CSV field values before they enter the agent's context. At minimum, clearly delimit untrusted content with markers that the agent is trained to treat as data, not instructions.
2. **Separate data from instructions**: Instead of embedding raw finding text in the agent's prompt, extract structured fields (severity, file paths, vulnerability type) into a JSON schema and present only the schema to the agent. Free-text descriptions should be quarantined and only read when explicitly needed.
3. **Add a validation step**: Before acting on any finding, have the agent summarize what it intends to do and require explicit human confirmation. This is described in the workflow but not technically enforced.

### P1 -- Hook Enforcement

4. **Make hooks blocking**: Change the hook commands to require interactive confirmation (e.g., read from stdin or use a confirmation tool) rather than just echoing a warning. Alternatively, use hooks that return non-zero exit codes to block the operation until confirmed.
5. **Add Bash tool hook**: Add a PreToolUse hook on the Bash tool that warns when shell commands contain file-modifying operations (`sed -i`, `mv`, `cp`, `rm`, `>`, `>>`).
6. **Validate file paths against project root**: Before any Edit/Write/Read operation, verify that the target path is within the expected project directory. This could be implemented as a hook that checks the path argument.

### P2 -- Input Validation

7. **Validate relevant_paths**: In `parse-findings.sh` or in the workflow instructions, validate that `relevant_paths` values are relative paths that do not contain `..` sequences or begin with `/`. Reject or flag findings with suspicious paths.
8. **Add CSV size limits**: Before processing, check the file size against a reasonable maximum (e.g., 10 MB) and row count limit.
9. **Sanitize branch_prefix**: Validate that the `branch_prefix` config value contains only alphanumeric characters, hyphens, and forward slashes.

### P3 -- Operational Safety

10. **Default to dry-run mode**: Consider a mode where the agent produces patch files or diff output without directly modifying the codebase, requiring the user to apply patches manually.
11. **Add git stash before patching**: Before making any edits, automatically stash or checkpoint the working tree so there is always a clean revert path.
12. **Log all file operations**: Maintain an audit log of every file the agent reads and modifies during a patching session, so the operator can review the full scope of access.

---

## 6. Residual Risks

Even with all recommendations implemented:

- **AI agent judgment errors**: The agent may generate patches that introduce new vulnerabilities (e.g., incomplete input validation, race conditions in fixes). Code review of generated patches remains essential.
- **Stale findings**: If the finding CSV references code that has been significantly refactored, the agent may apply fixes to the wrong location or misunderstand the current code structure. The workflow addresses this in Phase 4 but relies on the agent's ability to correctly identify moved code.
- **Fix-pattern limitations**: The fix patterns in `fix-patterns.md` cover common vulnerability classes but may not address novel or complex vulnerabilities. The agent may apply an inappropriate pattern.
- **Supply chain trust**: The skill trusts that Codex CSV exports are legitimate security findings. If the Codex platform itself is compromised, the findings could direct the agent to introduce vulnerabilities rather than fix them.

---

## 7. Summary

The most critical risk in the `threat-patch` skill is **indirect prompt injection through untrusted finding content** (T4). Because the skill's core operation is to feed external data (CSV fields) into an AI agent's decision-making process, and then have that agent modify source code, the attack surface is fundamentally an instruction-data confusion problem. The existing safety mechanisms (hooks, workflow confirmation gates) are informational rather than enforcing, providing a false sense of security.

Secondary concerns center on the hooks being non-blocking echo commands (T5), the Bash tool being unguarded (T6), and the ability to direct the agent to read arbitrary files via the `relevant_paths` field (T9).

The skill's architecture is sound in its workflow design -- the phased approach with confirmation gates, minimal-diff principle, and revert paths show security awareness. The gap is between the documented intent (human reviews every edit) and the technical reality (nothing actually blocks an edit from proceeding without review).
