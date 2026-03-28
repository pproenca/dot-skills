# Threat Model: build-agents-md.js and validate-skill.js

**Date:** 2026-03-28
**Scope:** Internal build/validation scripts for the dev-skill plugin
**Analyst:** Claude (automated threat model)
**Severity Scale:** CRITICAL / HIGH / MEDIUM / LOW / INFORMATIONAL

---

## 1. System Overview

### Components Under Analysis

| Script | Purpose | Lines | Dependencies |
|--------|---------|-------|-------------|
| `build-agents-md.js` | Reads a skill directory (metadata.json, references/*.md) and compiles them into a single AGENTS.md document | ~232 | `fs`, `path` (Node built-ins only) |
| `validate-skill.js` | Validates skill directory structure against quality rules; reports issues as human-readable or JSON output | ~412 | `fs`, `path`, `./validation/validator.js`, `./build-agents-md.js` |
| `validation/validator.js` | Core validation logic; reads and parses skill files | ~735 | `fs`, `path`, `./markdown-parser.js`, `./schemas.js`, `./types.js`, `./constants.js` |
| `validation/schemas.js` | Schema validation functions (frontmatter, metadata, rule content, code examples) | ~712 | `./constants.js`, `./types.js`, `./markdown-parser.js` |
| `validation/markdown-parser.js` | Markdown AST parser using unified/remark | ~96 | `unified`, `remark-parse`, `remark-frontmatter`, `unist-util-visit`, `yaml` |
| `validation/constants.js` | Static validation constants, regex patterns, messages | ~389 | None |
| `validation/types.js` | Type factory functions for validation issues/reports | ~57 | None |

### Data Flow

```
CLI args (process.argv)
    |
    v
skillDir path (user-provided string)
    |
    v
fs.readFileSync / fs.readdirSync / fs.existsSync (read-only)
    |
    v
Parse: JSON.parse (metadata.json), YAML parse (frontmatter), Regex (sections), Remark AST (markdown)
    |
    v
Validate: pattern matching, length checks, structure checks
    |
    v
Output: console.log (stdout) -- human-readable or JSON
    |
    v
[build-agents-md.js only]: fs.writeFileSync (AGENTS.md in skill directory)
```

---

## 2. Threat Analysis

### T-01: Path Traversal via CLI Argument

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Category** | Input Validation |
| **Vector** | `process.argv[2]` is used directly as a directory path |
| **Analysis** | Both scripts accept a directory path from `process.argv`. This path is passed to `fs.existsSync`, `fs.readFileSync`, `fs.readdirSync`, and `path.join`. A malicious actor could pass `../../../../etc` or similar. However, since these are CLI tools invoked manually by the developer, the user is already trusted. The scripts check `fs.existsSync(skillDir)` before proceeding but do not validate the path is within an expected directory boundary. |
| **Impact** | An attacker with shell access could read arbitrary directories. But if an attacker has shell access, they already have that capability directly. |
| **Mitigation** | No action needed for internal tooling. If exposed externally, add `path.resolve()` + allowlist check. |

### T-02: Write to Arbitrary Path (build-agents-md.js)

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Category** | File System Write |
| **Vector** | `fs.writeFileSync(path.join(skillDir, 'AGENTS.md'), output)` at line 228 |
| **Analysis** | `build-agents-md.js` writes an `AGENTS.md` file into the provided skill directory. The write destination is `path.join(skillDir, 'AGENTS.md')` -- the filename is hardcoded ("AGENTS.md"), so the user cannot control the filename, only the parent directory. The content written is entirely derived from files already within that directory (metadata.json, references/*.md). There is no injection of external content. |
| **Impact** | Overwrite of an existing AGENTS.md in a directory of the user's choosing. Content is deterministic from directory contents. |
| **Mitigation** | Acceptable for internal use. The write is intentional behavior. |

### T-03: JSON Parsing of Untrusted Input

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Category** | Deserialization |
| **Vector** | `JSON.parse(fs.readFileSync(metadataPath, 'utf-8'))` in build-agents-md.js line 106, and in validator.js lines 339, 202 |
| **Analysis** | `JSON.parse()` in JavaScript is safe -- it does not execute code, only produces data structures. The parsed object is used for property reads (e.g., `metadata.version`, `metadata.organization`). No `eval()`, `Function()`, or `require()` is called on parsed values. Parsed values are interpolated into strings for the output markdown document, but that document is not executed. |
| **Impact** | None. JSON.parse is not vulnerable to code injection. |
| **Mitigation** | None needed. |

### T-04: YAML Parsing via remark-frontmatter + yaml

| Field | Value |
|-------|-------|
| **Severity** | INFORMATIONAL |
| **Category** | Deserialization |
| **Vector** | `parseYaml(node.value)` in markdown-parser.js line 35 |
| **Analysis** | The `yaml` npm package (used here) is the modern successor to `js-yaml` and does NOT support dangerous YAML features like `!!js/function` or `!!python/object` by default. It parses to plain JavaScript objects. The frontmatter content is read from .md files within the skill directory. Even if a malicious .md file contained exotic YAML constructs, the `yaml` package in its default configuration would either ignore them or throw. |
| **Impact** | None under default configuration. |
| **Mitigation** | None needed. Verify that `yaml` package is reasonably up-to-date to avoid known CVEs. |

### T-05: Regular Expression Denial of Service (ReDoS)

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Category** | Availability |
| **Vector** | Multiple regex patterns in constants.js, schemas.js, and both main scripts |
| **Analysis** | The codebase contains ~50+ regex patterns. I reviewed each for catastrophic backtracking. Most are simple literal matches or have bounded quantifiers. The most complex patterns are in `QUANTIFIED_PATTERNS` and `VAGUE_PATTERNS`, which use word boundaries (`\b`) and simple alternation -- these are not susceptible to exponential backtracking. The `FRONTMATTER_REGEX = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/` uses lazy quantifier on a bounded pattern (anchored at both ends), which is safe. `stripComments` and `stripStrings` use `[\s\S]*?` (lazy) inside bounded patterns, also safe. No regex uses nested quantifiers (e.g., `(a+)+`) which would indicate ReDoS risk. |
| **Impact** | Negligible. Processing time is linear with input size. |
| **Mitigation** | None needed. Patterns are well-constructed. |

### T-06: Prototype Pollution via Parsed Objects

| Field | Value |
|-------|-------|
| **Severity** | INFORMATIONAL |
| **Category** | Object Injection |
| **Vector** | `parseFrontmatter()` in build-agents-md.js manually constructs an object from key-value pairs (lines 19-37) |
| **Analysis** | The `parseFrontmatter()` in build-agents-md.js uses a simple `frontmatter[key] = value` assignment. If a frontmatter line contained `__proto__: malicious`, this could pollute the prototype. However, (a) the frontmatter object is short-lived and used only for property reads, (b) the validator uses the `yaml` package which returns clean objects, and (c) no downstream code uses `hasOwnProperty`-less iteration on these objects in a security-sensitive way. The build script's manual parser only reads known keys (`title`, `impact`, `tags`, `impactDescription`). |
| **Impact** | Theoretical prototype pollution with no practical exploit path. |
| **Mitigation** | Could use `Object.create(null)` instead of `{}` in build-agents-md.js line 23 for defense-in-depth. Non-urgent. |

### T-07: Command Injection

| Field | Value |
|-------|-------|
| **Severity** | NONE (not present) |
| **Category** | Command Injection |
| **Analysis** | Neither script uses `child_process.exec`, `child_process.spawn`, `eval()`, `Function()`, `require()` with dynamic arguments, or any form of shell execution. All operations are synchronous file reads, regex matching, and string concatenation. |
| **Impact** | N/A |

### T-08: Network Access

| Field | Value |
|-------|-------|
| **Severity** | NONE (not present) |
| **Category** | Network |
| **Analysis** | Neither script imports `http`, `https`, `net`, `fetch`, or any networking module. No outbound connections are made. No data exfiltration vector exists. |
| **Impact** | N/A |

### T-09: Environment Variable Usage

| Field | Value |
|-------|-------|
| **Severity** | INFORMATIONAL |
| **Category** | Configuration |
| **Vector** | `process.env.SKILL_VALIDATOR_CONCURRENCY` in validate-skill.js line 31 |
| **Analysis** | The only environment variable read is `SKILL_VALIDATOR_CONCURRENCY`, parsed with `parseInt()` and validated (`if (n > 0)`). This controls the number of parallel validation tasks. An absurdly high value could cause high memory usage from parallel file reads, but this is bounded by the number of skill directories found. |
| **Impact** | Negligible. Controlled concurrency with sane defaults. |
| **Mitigation** | Could add an upper bound cap (e.g., `Math.min(n, 32)`). Non-urgent. |

### T-10: Dependency Supply Chain (Third-Party Packages)

| Field | Value |
|-------|-------|
| **Severity** | LOW |
| **Category** | Supply Chain |
| **Vector** | `unified`, `remark-parse`, `remark-frontmatter`, `unist-util-visit`, `yaml` |
| **Analysis** | The markdown-parser.js uses five npm packages. These are well-known, widely-used packages maintained by the unified collective and the yaml working group. They are standard choices for markdown AST parsing. The risk is typical npm supply chain risk (compromised package update), not specific to these scripts. |
| **Impact** | Standard npm supply chain risk. |
| **Mitigation** | Use a lockfile (package-lock.json or pnpm-lock.yaml). Pin dependency versions. Run `npm audit` periodically. |

---

## 3. Attack Surface Summary

| Surface | Present | Notes |
|---------|---------|-------|
| Network access | No | No imports of networking modules |
| Shell/command execution | No | No child_process, exec, eval |
| File writes | Yes (1 location) | `build-agents-md.js` writes AGENTS.md only, hardcoded filename |
| File reads | Yes | Reads files within user-specified directory only |
| User input | CLI args only | `process.argv[2]` -- directory path |
| Environment variables | 1 variable | `SKILL_VALIDATOR_CONCURRENCY` -- integer, validated |
| Dynamic code execution | No | No eval, Function, vm, or dynamic require |
| Deserialization | JSON + YAML | Both safe parsers with no code execution |
| External dependencies | 5 npm packages | Well-known markdown/YAML parsing ecosystem |

---

## 4. Findings Summary

| ID | Severity | Finding | Action |
|----|----------|---------|--------|
| T-01 | LOW | CLI path not boundary-checked | Accept for internal use |
| T-02 | LOW | Write to user-specified directory | Intentional behavior |
| T-03 | LOW | JSON.parse on file contents | Safe by design |
| T-04 | INFORMATIONAL | YAML parsing via `yaml` package | Safe defaults, keep updated |
| T-05 | LOW | Regex patterns reviewed for ReDoS | No vulnerable patterns found |
| T-06 | INFORMATIONAL | Prototype pollution in manual frontmatter parser | Consider `Object.create(null)` |
| T-07 | NONE | No command injection vectors | Clean |
| T-08 | NONE | No network access | Clean |
| T-09 | INFORMATIONAL | Env var for concurrency | Consider upper bound cap |
| T-10 | LOW | npm dependency supply chain | Standard risk, use lockfile |

---

## 5. Verdict

**These scripts are safe for internal use.** They are read-heavy tools that parse local files and produce validation reports or compiled markdown. There is no network access, no shell execution, no dynamic code evaluation, and no capability to affect anything outside the specified skill directory (aside from the single intentional AGENTS.md write). The attack surface is minimal and appropriate for developer tooling.

### Recommended Improvements (Non-Urgent, Defense-in-Depth)

1. **build-agents-md.js line 23**: Use `Object.create(null)` for the frontmatter object to eliminate theoretical prototype pollution.
2. **validate-skill.js line 31**: Cap `SKILL_VALIDATOR_CONCURRENCY` to a reasonable maximum (e.g., 32).
3. **General**: Ensure npm dependencies are pinned and `npm audit` is run periodically.

None of these are security vulnerabilities in the current internal-use context. They are hardening suggestions only.
