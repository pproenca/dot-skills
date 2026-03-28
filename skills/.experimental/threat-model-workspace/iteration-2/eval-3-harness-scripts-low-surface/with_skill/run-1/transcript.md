# Threat Model Transcript: build-agents-md.js and validate-skill.js

**Date**: 2026-03-28
**Skill used**: threat-model (experimental)
**Target**: `build-agents-md.js`, `validate-skill.js` (and supporting `validation/*.js` modules)
**Target location**: `/Users/pedroproenca/.claude/plugins/marketplaces/dot-claude/plugins/dev-skill/scripts/`

---

## Understanding

The task is to run a threat model on two Node.js build/validation scripts used internally in the dot-skills ecosystem. The user expects a "quick check that they're not doing anything dangerous." The scripts are local CLI tools that read skill directories and check/generate files.

I was instructed to:
1. Read the threat-model skill's SKILL.md and all referenced technique files
2. Follow the 10-phase methodology exactly
3. Output THREAT-MODEL.md in the skill's 6-section format
4. Save outputs and this transcript to the specified paths

---

## Steps Taken (mapped to 10-phase methodology)

### Phase 0: Diff Analysis
**Skipped** -- no git range or diff requested. Full analysis mode.

### Phase 1: Codebase Survey
**Tools used**: Read tool on both target scripts, ls on the scripts directory.

**Findings**:
- `build-agents-md.js` (232 lines): Reads a skill directory's `metadata.json`, `references/*.md` (or `examples/` or `rules/`), and `_sections.md`. Compiles them into a single `AGENTS.md` file. Uses `fs`, `path` only. No network, no child_process, no eval.
- `validate-skill.js` (412 lines): Validates skill directory structure against quality guidelines. Supports single-skill and bulk (`--all`) validation modes. Imports `SkillValidator` from `./validation/validator.js` and `buildAgentsMD` from `./build-agents-md.js`.
- `validation/validator.js` (735 lines): Core validation logic. Reads files, parses frontmatter, checks content quality. Uses `unified`/`remark-parse`/`remark-frontmatter`/`yaml` for markdown/YAML parsing.
- `validation/types.js` (58 lines): Simple type factory functions (createError, createWarning, createReport).
- `validation/constants.js` (389 lines): Regex patterns, thresholds, validation messages. No code execution patterns.
- `validation/markdown-parser.js` (96 lines): Wraps unified/remark for AST extraction.

**Key observation**: Neither script uses `child_process`, `eval()`, `new Function()`, `vm.runInContext()`, or any code execution API. The entire codebase is file-read + regex-match + file-write (build only).

### Phase 2: Component Mapping
**Tools used**: Read tool on all validation/ modules.

**Components identified**:
- CLI entry point (process.argv parsing)
- File system reader (fs.readFileSync, fs.readdirSync, fs.existsSync)
- JSON parser (JSON.parse for metadata.json, config.json, hooks.json)
- Markdown/YAML parser (unified + remark + yaml package)
- Custom regex parsers (frontmatter, section headers, impact levels)
- File writer (fs.writeFileSync -- build-agents-md.js only)
- Report printer (console.log -- validate-skill.js only)

**No cross-language bridges found.** Pure JavaScript/Node.js.

### Phase 3: Asset Identification
**Assets identified**:
- Host filesystem integrity (the build script writes files)
- Developer workflow availability (crash resistance)
- Output correctness (generated AGENTS.md fidelity)
- Supply chain safety (npm dependencies)

### Phase 4: Trust Boundaries + Entry Point Mapping

**Entry points inventoried**:

| Variable | File:Line | Controller | Trust Tier |
|----------|-----------|------------|------------|
| `process.argv[2]` (skillDir) | build-agents-md.js:215, validate-skill.js:44-46 | CLI operator | Operator-controlled |
| `process.env.SKILL_VALIDATOR_CONCURRENCY` | validate-skill.js:31 | Environment | Operator-controlled |
| `fs.readFileSync(metadata.json)` content | build-agents-md.js:106, validator.js:339 | Skill directory files | Developer-controlled (operator-controlled if untrusted dir) |
| `fs.readFileSync(*.md)` content | validator.js throughout, build-agents-md.js:81 | Skill directory files | Developer-controlled |
| `fs.readdirSync(skillsDir)` entries | validate-skill.js:163 | Filesystem directory listing | Operator-controlled |

**No attacker-controlled inputs identified in typical usage.** All inputs are operator or developer controlled. The trust tier shifts if the tools are run against untrusted skill directories (e.g., CI pipeline processing submissions).

### Phase 5: Data Flow Tracing

**Traces performed** (manual, no trace script available for JS):

**Trace 1: CLI argument -> file write**
```
TRACE: skillDir (CLI argument)
Entry:  process.argv[2] (build-agents-md.js:215)
   |    pass-through: assigned to `skillDir` local variable
   |    validation: fs.existsSync(skillDir) check (line 222)
   |    pass-through: passed to buildAgentsMD(skillDir) (line 226)
   |    transform: path.join(skillDir, 'metadata.json') (line 101)
   |    transform: path.join(skillDir, 'references') (line 109)
   |    pass-through: used in path.join for all file reads
Sink:   fs.writeFileSync(path.join(skillDir, 'AGENTS.md'), output) (line 228)
        Operation: Write generated markdown to AGENTS.md
        Impact: Overwrites AGENTS.md in the specified directory
Validation: fs.existsSync check only (no path canonicalization, no symlink check)
FINDING: Symlink following on write -- if AGENTS.md is a symlink, target file is overwritten [LOW]
```

**Trace 2: File content -> JSON.parse -> string interpolation**
```
TRACE: metadata.json content
Entry:  fs.readFileSync(metadataPath, 'utf-8') (build-agents-md.js:106)
   |    transform: JSON.parse() -- safe, no code execution
   |    pass-through: metadata.technology, metadata.version, metadata.organization, metadata.abstract
   |    transform: string interpolation into markdown output (lines 135-140)
Sink:   Included in output string written to AGENTS.md
        Operation: String concatenation into markdown template
        Impact: None -- output is markdown, not executed
Validation: JSON.parse throws on invalid JSON (caught by caller)
FINDING: None -- data flows from file to markdown string with no code execution
```

**Trace 3: Markdown file content -> regex/remark parsing -> validation report**
```
TRACE: *.md file content
Entry:  fs.readFileSync(filepath, 'utf-8') (validator.js:445, 488, 629, etc.)
   |    transform: parseFrontmatter() via unified/remark-parse/yaml
   |    transform: regex matching against content patterns
   |    pass-through: matched values used in validation issue messages
Sink:   console.log() in printHumanReport/printJsonReport
        Operation: Output to stdout
        Impact: None -- file content excerpts may appear in validation messages
Validation: try/catch around all parse operations
FINDING: None -- read-only pipeline with error handling
```

**Trace 4: SKILL_VALIDATOR_CONCURRENCY env var -> Promise.all concurrency**
```
TRACE: SKILL_VALIDATOR_CONCURRENCY
Entry:  process.env.SKILL_VALIDATOR_CONCURRENCY (validate-skill.js:31)
   |    transform: parseInt(value, 10)
   |    validation: if (n > 0) guard (line 43)
   |    pass-through: options.concurrency
Sink:   chunk = skillDirs.slice(i, i + options.concurrency) (line 179)
        Operation: Controls number of parallel Promise.all validations
        Impact: Large value could run many parallel reads (bounded by directory count)
Validation: parseInt + positive-number check
FINDING: None significant -- operator self-inflicted at worst
```

### Phase 6: Attack Surface Enumeration

Six surfaces documented in the THREAT-MODEL.md output (3.1 through 3.6 plus Out-of-scope).

Key operation-to-risk mapping applied:
- Path concatenation (path.join with CLI arg): Checked for path traversal -- mitigated by fixed filename output
- File write (fs.writeFileSync): Checked for symlink attacks -- low risk identified
- JSON deserialization (JSON.parse): Checked for prototype pollution -- not applicable with standard JSON.parse
- Regex execution: Checked for ReDoS -- patterns are simple, no nested quantifiers
- Directory enumeration: Checked for DoS -- bounded by concurrency limit and SKILL.md filter

### Phase 7: Pattern Clustering

**No patterns to cluster.** Only 2 findings related to symlink following (read and write), which share a root cause but fall below the 3-instance threshold. The remaining findings are distinct (directory enumeration, env var parsing).

### Phase 8: Exploit Chain Construction

**No viable chains found.** Attempted to combine:
- Symlink plant + build script write -> file overwrite: Requires attacker to already have local fs access (no capability amplification)
- Directory traversal + bulk validation -> information disclosure: The validation output shows file paths and error messages but no file contents. Even if pointed at sensitive directories, the filter for `SKILL.md` presence limits scope.

No chain provides capability beyond what the attacker's prerequisite access already grants.

### Phase 9: Calibration

All findings rated LOW. Scope note: severity could increase to MEDIUM if tools are used in a CI pipeline processing untrusted submissions. In the current local-developer-tool context, all risks are effectively informational.

### Phase 10: Output

Wrote `THREAT-MODEL.md` to the specified outputs directory following the 6-section format from `references/output-format.md`.

---

## Tools Used

| Tool | Count | Purpose |
|------|-------|---------|
| Read | 9 | Read skill SKILL.md, methodology, output-format, data-flow-tracing, pattern-clustering, both target scripts, validator.js, types.js, constants.js, markdown-parser.js |
| Glob | 1 | Find validator.js location |
| Bash (ls) | 2 | List directory contents of scripts/ and validation/ |
| Write | 2 | Write THREAT-MODEL.md and this transcript |

---

## Issues Encountered

- **No trace script for JavaScript**: The skill references `scripts/trace-data-flows.sh` for automated entry-point/sink inventory. This script is designed for Swift/multi-language projects and was not applicable to the JavaScript targets. All data flow tracing was performed manually by reading code.
- **Very low attack surface**: The targets are minimal internal tools with no network exposure, no command execution, and no untrusted input in typical usage. The threat model methodology is designed for richer targets. The 10-phase process was followed faithfully, but several phases (7, 8) produced null results, which is the correct outcome for a low-surface target.

---

## Output Produced

| File | Path |
|------|------|
| THREAT-MODEL.md | `outputs/THREAT-MODEL.md` |
| Transcript | `transcript.md` (this file) |

---

## Summary Assessment

**Both scripts are safe for their intended purpose.** They are read-only (validator) or write-a-single-file (builder) tools with no code execution paths, no network access, no command injection surfaces, and proper error handling around all parsing operations. The only theoretical risks involve symlink following when processing an adversary-controlled skill directory, which requires the attacker to already have local filesystem access. No changes are recommended for current usage patterns.
