# Transcript: Threat Model of threat-patch Skill

**Date**: 2026-03-28
**Subject**: `skills/.experimental/threat-patch/`
**Approach**: Manual threat model using default knowledge (no threat-model skill)

---

## Understanding

The user asked for a threat model of the threat-patch skill, which parses Codex security finding CSVs and generates code patches. Two specific concerns were raised:

1. What happens if someone feeds it a malicious CSV
2. Whether the patch workflow has unintended side effects

The task required saving output to a specific path and producing a transcript of the analysis process. The threat-model skill was explicitly off-limits.

---

## Steps Taken

### Step 1: Enumerate skill files

**Tool**: Bash (ls -la, ls -laR)
**Files discovered**:
- `SKILL.md` -- Main skill instructions (75 lines)
- `config.json` -- Configuration with CSV path, threat model path, commit flag, branch prefix
- `metadata.json` -- Skill metadata (version 0.1.0, type: automation)
- `gotchas.md` -- Known issues (3 entries)
- `hooks/hooks.json` -- PreToolUse hooks for Edit and Write tools
- `references/workflow.md` -- 9-phase patching methodology (186 lines)
- `references/fix-patterns.md` -- Fix patterns for 9 vulnerability classes (315 lines)
- `references/output-format.md` -- Output templates for code patches and analysis-only reports (164 lines)
- `scripts/parse-findings.sh` -- Bash+Python CSV parser (123 lines)

### Step 2: Read all skill files

**Tool**: Read (8 file reads)
**Purpose**: Understand the full attack surface before modeling threats

Key observations during reading:
- `parse-findings.sh` uses an inline Python heredoc to parse CSV, outputs structured markdown
- CSV field values (title, description, severity, relevant_paths, commit_hash) are rendered directly into markdown output without sanitization
- The workflow instructs the agent to "Open each file listed in relevant_paths" -- no path validation
- PreToolUse hooks only run `echo` commands -- they are informational, not blocking
- `config.json` allows specifying arbitrary file paths for CSV and threat model inputs
- The skill explicitly modifies source code as its core function
- Phase 5 (Design Fix) has a confirmation gate, but it is instruction-based (tells the agent to ask), not mechanically enforced

### Step 3: Identify trust boundaries

Mapped 6 trust boundaries:
1. CSV input -> Python parser + agent context
2. Parsed findings -> agent reasoning and tool invocations
3. Agent tool calls -> user filesystem
4. Script execution -> shell process
5. Git operations -> repository history
6. Config file -> path resolution

### Step 4: Enumerate threats

Identified 8 threats by walking each trust boundary and considering how attacker-controlled data flows across it:

| ID | Threat | Severity |
|----|--------|----------|
| T1 | Prompt injection via malicious CSV content | HIGH |
| T2 | Path traversal via relevant_paths field | HIGH |
| T3 | Shell injection via CSV path argument | MEDIUM |
| T4 | Arbitrary code modification via crafted findings | HIGH |
| T5 | DoS via oversized CSV | LOW |
| T6 | Unsafe git operations with commit_patches | MEDIUM |
| T7 | Non-blocking hooks providing false security | MEDIUM |
| T8 | Config path manipulation for arbitrary reads | MEDIUM |

### Step 5: Analyze each threat

For each threat, documented:
- Description and mechanism
- Step-by-step attack path
- Likelihood and impact assessment
- Existing controls in the skill
- Specific recommendations

### Step 6: Produce risk matrix and prioritized mitigations

Organized threats by risk level (likelihood x impact) and produced 9 prioritized mitigations in three tiers: immediate, short-term, medium-term.

### Step 7: Write output

**Tool**: Write
**Output file**: `outputs/THREAT-MODEL.md`

---

## Issues Encountered

None. All files were readable and the skill structure was straightforward to analyze.

---

## Key Findings

1. **The most significant risk is prompt injection via CSV fields** (T1). The `parse-findings.sh` script faithfully renders CSV field values into markdown without any sanitization. Since these values enter the agent's context window, a malicious CSV can embed adversarial instructions.

2. **The hooks provide weaker protection than documented**. The skill's "Guardrails" section describes PreToolUse hooks as a safety measure, but the hooks only echo warning text -- they do not block tool execution or require user confirmation. This is a documentation accuracy issue as much as a security issue.

3. **The `relevant_paths` field is a file-read oracle**. The workflow explicitly instructs the agent to open every file listed in this field. No path validation, scoping, or sanitization is applied. A malicious CSV can direct the agent to read any file accessible to the user.

4. **The skill modifies security-critical code by design**, making T4 (malicious "fix" via crafted finding) inherently high-impact. The Phase 5 confirmation gate is the primary defense but is instruction-based, not mechanical.

---

## Output Produced

- `/Users/pedroproenca/Documents/Projects/dot-skills/skills/.experimental/threat-model-workspace/iteration-2/eval-2-threat-patch-self-analysis/without_skill/run-1/outputs/THREAT-MODEL.md` -- Full threat model with 8 threats, risk matrix, and prioritized mitigations
