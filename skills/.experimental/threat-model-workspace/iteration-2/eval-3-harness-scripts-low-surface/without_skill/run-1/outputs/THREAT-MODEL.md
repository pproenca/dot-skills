# Threat Model: build-agents-md.js & validate-skill.js

**Date:** 2026-03-28
**Scope:** Internal build/validation tooling for dot-skills project
**Risk Profile:** Low attack surface (internal developer tools, not internet-facing)

---

## 1. Asset Inventory

### Scripts Analyzed

| File | Purpose | LOC |
|------|---------|-----|
| `scripts/build-agents-md.js` | Reads skill directories, parses markdown/JSON, compiles an AGENTS.md file | ~232 |
| `scripts/validate-skill.js` | CLI that validates skill directory structure and content quality | ~412 |
| `scripts/validation/validator.js` | Core validation class with discipline-specific checks | ~735 |
| `scripts/validation/schemas.js` | Schema validation functions (frontmatter, metadata, rules, etc.) | ~712 |
| `scripts/validation/constants.js` | Centralized thresholds, regex patterns, validation messages | ~389 |
| `scripts/validation/types.js` | Type definitions and report builders | ~58 |
| `scripts/validation/markdown-parser.js` | Remark/unified-based markdown AST parser | ~96 |

### Dependencies (External)

| Package | Used In | Purpose |
|---------|---------|---------|
| `unified` | markdown-parser.js | Markdown processing pipeline |
| `remark-parse` | markdown-parser.js | Markdown parser |
| `remark-frontmatter` | markdown-parser.js | YAML frontmatter support |
| `unist-util-visit` | markdown-parser.js | AST traversal |
| `yaml` | markdown-parser.js | YAML parsing |

### Node.js Built-ins Used

| Module | Used In | Operations |
|--------|---------|------------|
| `fs` | All scripts | `readFileSync`, `writeFileSync`, `existsSync`, `readdirSync` |
| `path` | All scripts | `join`, `basename` |

---

## 2. Threat Analysis

### T1: Path Traversal via CLI Arguments

**Severity:** LOW
**Vector:** `build-agents-md.js` and `validate-skill.js` accept a directory path from `process.argv[2]`.

**Analysis:** Both scripts use the user-supplied path directly with `fs` operations:
- `build-agents-md.js` line 215: `const skillDir = process.argv[2]`
- `validate-skill.js` line 377: `const { skillDir, options } = parseArgs(args)`

However, these are internal CLI tools invoked by the developer themselves. There is no network input, no HTTP endpoint, and no untrusted user input. The path is used to read/scan a directory tree that the operator explicitly points to.

File writes are limited to a single location:
- `build-agents-md.js` line 228: `fs.writeFileSync(outputPath, output)` where `outputPath = path.join(skillDir, 'AGENTS.md')`

This writes only to `AGENTS.md` inside the skill directory the user provided. No arbitrary write location.

**Verdict:** No actionable risk. The tool is invoked locally by the developer.

---

### T2: Arbitrary File Write

**Severity:** LOW
**Vector:** `build-agents-md.js` writes `AGENTS.md` to the skill directory.

**Analysis:** The write target is deterministic: `path.join(skillDir, 'AGENTS.md')`. It cannot be redirected to an arbitrary path because:
1. The filename `AGENTS.md` is hardcoded.
2. The base directory is whatever the user passes as a CLI argument.
3. `validate-skill.js` performs zero file writes -- it is purely read-only.

**Verdict:** No risk. Write is scoped and predictable.

---

### T3: Code Injection via Parsed Content

**Severity:** NONE
**Vector:** Scripts parse markdown files and JSON files from disk.

**Analysis:** The scripts read `.md` and `.json` files and perform:
- Regex matching on markdown content
- `JSON.parse()` on metadata.json and hooks.json
- YAML parsing via the `yaml` package on frontmatter

None of these parsing operations lead to code execution. There is:
- No `eval()` anywhere in the codebase.
- No `Function()` constructor usage.
- No `child_process` / `exec` / `spawn` calls.
- No dynamic `import()` based on file content.
- No `vm` module usage.

The parsed data is used only for string comparisons, regex matching, and report generation.

**Verdict:** No risk. Data is parsed but never executed.

---

### T4: Denial of Service via Regex (ReDoS)

**Severity:** LOW
**Vector:** Several regex patterns are applied against file contents.

**Analysis:** The scripts define many regex patterns in `constants.js` and `schemas.js`. I reviewed all patterns for catastrophic backtracking potential:

- Most patterns are simple alternations or literal matches (e.g., `\bfoo\b`, `\bmaybe\b`).
- `FRONTMATTER_REGEX` in build-agents-md.js: `/^---\n([\s\S]*?)\n---\n([\s\S]*)$/` -- uses non-greedy `[\s\S]*?` which is bounded by the `---` delimiters. This is a standard frontmatter pattern and is safe.
- `SECTION_HEADER_REGEX`: `/^## (\d+)\. (.+) \(([a-z]+)\)/` -- the `.+` is bounded by ` \(` which anchors it. No backtracking risk.
- `CODE_FENCE_REGEX`, `INCORRECT_ANNOTATION_REGEX`, etc. are all bounded patterns.

The `VAGUE_PATTERNS` and `MARKETING_PATTERNS` arrays use word-boundary anchors (`\b`) which prevent runaway matching.

One pattern to note: `VAGUE_ANNOTATION_PATTERNS` uses nested parentheses `\([^)]*(?:\([^)]*\)[^)]*)*\)` which has a theoretical backtracking surface, but the inner `[^)]` character class is very restrictive (no nesting beyond one level). In practice, this runs against short annotation strings, not large inputs.

**Verdict:** No practical risk. All patterns are well-bounded. Input size is constrained to individual markdown files (typically < 200 lines).

---

### T5: Supply Chain Risk (npm Dependencies)

**Severity:** LOW-MEDIUM (general npm ecosystem risk, not specific to these scripts)
**Vector:** `markdown-parser.js` imports five npm packages.

**Analysis:** The dependencies are:
- `unified` / `remark-parse` / `remark-frontmatter` / `unist-util-visit` -- widely used, maintained by the unified collective. These are among the most battle-tested markdown processing libraries in the Node.js ecosystem.
- `yaml` -- the official YAML parser for JS, maintained by Eemeli Aro.

These are all read-only operations (parsing markdown/YAML). None of these packages perform network I/O, file writes, or code execution from parsed content.

**Verdict:** Standard npm supply chain risk applies (as with any Node.js project). No elevated concern specific to these scripts. Lock files and dependency auditing are the standard mitigations.

---

### T6: Environment Variable Injection

**Severity:** NONE
**Vector:** `validate-skill.js` reads `process.env.SKILL_VALIDATOR_CONCURRENCY`.

**Analysis:** Line 31 of `validate-skill.js`:
```javascript
concurrency: parseInt(process.env.SKILL_VALIDATOR_CONCURRENCY || '6', 10),
```

This value is parsed as an integer and used only to control the batch size of `Promise.all()` parallelism. There is no way to inject code or cause harm through this variable. A malicious value would simply parse to `NaN`, and the fallback logic (`if (n > 0)`) would prevent it from being used.

**Verdict:** No risk.

---

### T7: Prototype Pollution via JSON.parse

**Severity:** NONE
**Vector:** `JSON.parse()` is used on `metadata.json`, `hooks.json`, and `config.json`.

**Analysis:** `JSON.parse()` in Node.js does not suffer from prototype pollution. The parsed objects are plain objects. The scripts do not use deep-merge utilities or recursive object assignment that could introduce prototype pollution.

**Verdict:** No risk.

---

### T8: Symlink Following

**Severity:** LOW
**Vector:** `fs.readdirSync` and `fs.readFileSync` could follow symlinks.

**Analysis:** If a skill directory contains a symlink pointing outside the expected tree, the scripts would follow it and read the target. However:
1. These are internal developer tools operating on a local repo.
2. The developer controls the skill directory contents.
3. No write operation is performed on symlink targets (only `AGENTS.md` in the explicit skill directory).

**Verdict:** No practical risk in the intended usage context.

---

## 3. Summary

| ID | Threat | Severity | Actionable |
|----|--------|----------|------------|
| T1 | Path traversal via CLI args | LOW | No |
| T2 | Arbitrary file write | LOW | No |
| T3 | Code injection via parsed content | NONE | No |
| T4 | ReDoS | LOW | No |
| T5 | Supply chain (npm deps) | LOW-MEDIUM | Standard mitigations |
| T6 | Environment variable injection | NONE | No |
| T7 | Prototype pollution | NONE | No |
| T8 | Symlink following | LOW | No |

---

## 4. Conclusion

These scripts are safe for their intended purpose as internal developer tooling. Key observations:

1. **No code execution from input:** There are no `eval`, `Function`, `child_process`, `vm`, or dynamic `import()` calls anywhere. All parsed data is used for string comparison and report generation only.

2. **Minimal write surface:** Only `build-agents-md.js` writes a file, and the target is hardcoded to `AGENTS.md` inside the user-specified directory. `validate-skill.js` is entirely read-only.

3. **No network I/O:** Neither script makes HTTP requests, opens sockets, or performs any network communication.

4. **No sensitive data handling:** The scripts process markdown documentation and JSON metadata. They do not touch credentials, tokens, or secrets.

5. **Well-scoped dependencies:** External npm packages are limited to markdown/YAML parsing (unified ecosystem + yaml package) -- all well-maintained, read-only libraries.

**Overall risk assessment: LOW.** No dangerous patterns found. No changes recommended.
