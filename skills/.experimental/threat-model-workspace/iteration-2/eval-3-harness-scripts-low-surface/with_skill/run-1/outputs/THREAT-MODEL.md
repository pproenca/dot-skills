# Threat Model: build-agents-md.js and validate-skill.js

## 1. Overview

`build-agents-md.js` and `validate-skill.js` are Node.js CLI build/validation tools for the dot-skills ecosystem. `build-agents-md.js` reads a skill directory structure (metadata.json, references/*.md, _sections.md) and compiles them into a single AGENTS.md document. `validate-skill.js` validates that a skill directory conforms to structural and quality guidelines, checking file presence, frontmatter correctness, content quality, and optionally verifying that AGENTS.md matches the generated output. It imports `SkillValidator` from `./validation/validator.js`, which contains the core validation logic, and `buildAgentsMD` from `./build-agents-md.js` for the `--verify-generated` feature.

Both tools run locally as CLI utilities invoked by the developer (e.g., `node build-agents-md.js <skill-directory>`), without network endpoints, without authentication, and without long-running services. They operate on local filesystem skill directories. The validator depends on `unified`, `remark-parse`, `remark-frontmatter`, `unist-util-visit`, and `yaml` npm packages for markdown/YAML parsing. Neither script uses `child_process`, `eval()`, `new Function()`, or any dynamic code execution APIs.

The primary security goals are: (1) host filesystem integrity -- the tools should not write to or delete files outside the intended skill directory, (2) availability -- the tools should not crash or hang when given malformed input, and (3) supply chain integrity -- the npm dependencies should not introduce vulnerabilities.

## 2. Threat model, Trust boundaries and assumptions

### Assets / security goals
- **Host filesystem integrity**: The build script writes a single output file (`AGENTS.md`) into the skill directory. No other files should be created, modified, or deleted.
- **Developer workflow availability**: The tools should handle malformed skill directories (missing files, invalid JSON, broken markdown) gracefully with error messages, not crashes or hangs.
- **Output correctness**: The generated AGENTS.md should faithfully reflect the source files. The validator should not report false positives or miss real issues.
- **Supply chain safety**: The npm dependencies used for markdown parsing should be trustworthy and not introduce code execution vectors.

### Trust boundaries & input classes

**Operator-controlled inputs**
- **CLI argument** (`process.argv[2]`): The skill directory path, provided by the developer at invocation time. This controls which directory is read from and (for build) written to.
- **Skill directory contents**: `metadata.json`, `SKILL.md`, `references/*.md`, `_sections.md`, `README.md`, `config.json`, `hooks/hooks.json`. All files are read from the developer's local filesystem.
- **Environment variable**: `SKILL_VALIDATOR_CONCURRENCY` controls parallelism in bulk validation mode. Parsed with `parseInt()`.

**Developer-controlled inputs**
- **Source code and dependencies**: The scripts themselves, plus `validation/*.js` modules and npm packages (`unified`, `remark-parse`, `yaml`, etc.).
- **Skill templates and structure conventions**: The expected file naming patterns and content formats.

### Assumptions & scope
- **Local-only execution**: Both tools are run locally by the developer. There is no network-facing entry point, so remote attacker scenarios do not apply.
- **Trusted operator**: The developer invoking the script controls the CLI argument and the contents of the skill directory. If the developer is hostile to themselves, the threat model is moot.
- **No untrusted skill directories**: In typical usage, the developer runs these tools against their own skill directories. If a developer downloads and validates an untrusted third-party skill directory, the file-reading operations become more relevant (see Section 3).
- **npm supply chain is separately managed**: Dependency auditing is out of scope for this analysis but noted as a consideration.

## 3. Attack surface, mitigations and attacker stories

### 3.1 Skill directory path from CLI argument (`build-agents-md.js:215-228`, `validate-skill.js:44-46`)

**Surface:** Both scripts take a directory path from `process.argv[2]`. `build-agents-md.js` reads files from this directory and writes `AGENTS.md` back into it. `validate-skill.js` reads files from this directory (and subdirectories) for validation.

**Risks:**
- Path traversal via the CLI argument: If an attacker could control the argument (e.g., in a CI pipeline reading from an untrusted source), they could point the build script at an arbitrary directory, causing it to overwrite an `AGENTS.md` file there. However, the write is always `path.join(skillDir, 'AGENTS.md')` -- it only writes a single file with a fixed name inside the target directory.
- Symlink following: If the skill directory or files within it are symlinks, `fs.readFileSync` and `fs.writeFileSync` follow symlinks by default. A malicious skill directory could contain a symlink `metadata.json -> /etc/passwd`, causing the script to read that file and attempt to parse it as JSON (which would fail harmlessly).

**Mitigations/controls:**
- `fs.existsSync()` checks are performed before reading (lines 102-103 of build-agents-md.js, lines 383-387 of validate-skill.js).
- The build script writes exactly one file (`AGENTS.md`) with a hardcoded name -- no user-controlled output paths.
- The validator is read-only -- it never writes files.
- JSON.parse on non-JSON content (e.g., from a symlink to a binary file) would throw, caught by the `try/catch` in the caller.

**Attacker story:** An attacker who controls a CI pipeline configuration could set the skill directory argument to a sensitive location, causing the build script to write an AGENTS.md file there. In typical local usage this is not a concern because the developer controls the CLI invocation. Severity is low because the written content is benign markdown derived from the directory's own files.

### 3.2 File content parsing -- JSON (`build-agents-md.js:106`, `validate-skill.js:339-343`, `validator.js:428`)

**Surface:** Both scripts parse `metadata.json` and potentially `config.json` and `hooks/hooks.json` using `JSON.parse()`.

**Risks:**
- Malformed JSON causing uncaught exceptions: Handled by try/catch in all three locations.
- Prototype pollution via `JSON.parse()`: Node.js `JSON.parse()` does not natively create `__proto__` properties from JSON keys. No `Object.assign` or deep-merge of parsed JSON into shared objects occurs.

**Mitigations/controls:**
- `JSON.parse()` is the standard, safe JSON parsing API in Node.js.
- Error handling wraps all parse calls (`try/catch` in `loadMetadata`, `validateMetadataFile`, `validateCompositionSkill`).
- Parsed metadata is used in string interpolation for output generation -- no code execution path.

**Attacker story:** A malicious `metadata.json` with deeply nested or very large content could cause increased memory usage during parsing, but this is bounded by the file size on disk. No code execution is reachable from parsed JSON values.

### 3.3 File content parsing -- Markdown/YAML (`validator.js` via `markdown-parser.js`)

**Surface:** The validator parses markdown files using `unified` + `remark-parse` + `remark-frontmatter`, and YAML frontmatter using the `yaml` package's `parse()` function.

**Risks:**
- ReDoS in markdown parsing: The `unified`/`remark-parse` stack uses a proper parser (not regex-based), making catastrophic backtracking unlikely.
- YAML parsing of untrusted content: The `yaml` package (v2) does not support unsafe YAML features like `!!js/function` by default. It parses to plain objects.
- Regex-based parsing in `build-agents-md.js` (`FRONTMATTER_REGEX`, `SECTION_HEADER_REGEX`): These regexes are simple and non-catastrophic. `FRONTMATTER_REGEX = /^---\n([\s\S]*?)\n---\n([\s\S]*)$/` uses a lazy quantifier `*?` which is safe.

**Mitigations/controls:**
- `yaml` v2 defaults to safe parsing (no code execution tags).
- The custom regex patterns are simple alternations or anchored patterns with no nested quantifiers.
- The `build-agents-md.js` frontmatter parser is a simple line-by-line key:value splitter (lines 24-36), not vulnerable to ReDoS.

**Attacker story:** A crafted markdown file in an untrusted skill directory could attempt to exploit a parsing vulnerability in `remark-parse` or `yaml`. In practice, these are mature, widely-used packages with no known ReDoS or code execution vulnerabilities. Severity is low.

### 3.4 File write operation (`build-agents-md.js:228`)

**Surface:** `fs.writeFileSync(outputPath, output)` where `outputPath = path.join(skillDir, 'AGENTS.md')`.

**Risks:**
- Writing to an unintended location: The output path is always `<skillDir>/AGENTS.md`. The skill directory path comes from the CLI argument (operator-controlled). No user-controlled data enters the filename.
- Overwriting existing files: The script overwrites any existing `AGENTS.md` without prompting. This is by design (regeneration).
- Symlink-based file overwrite: If `<skillDir>/AGENTS.md` is a symlink to another file, the write would follow the symlink and overwrite the target. However, the content written is benign markdown.

**Mitigations/controls:**
- The filename is hardcoded (`'AGENTS.md'`), not derived from file contents or external input.
- The write content is generated entirely from files within the same skill directory -- no external data injection.
- The validate script (`validate-skill.js`) is entirely read-only and never writes files.

**Attacker story:** If an attacker plants a symlink `AGENTS.md -> ~/.ssh/authorized_keys` inside a skill directory and tricks the developer into running the build script against it, the SSH authorized_keys file would be overwritten with markdown content (effectively destroying it, denying SSH access). This requires the attacker to have write access to the skill directory, which in practice means they already have local access. Severity is low.

### 3.5 Directory traversal during bulk validation (`validate-skill.js:163-164`)

**Surface:** In `--all` mode, `validate-skill.js` calls `fs.readdirSync(skillsDir, { withFileTypes: true })` and iterates over subdirectories.

**Risks:**
- If `skillsDir` points to a large directory (e.g., `/`), the script would attempt to enumerate and validate many directories, consuming CPU and memory. This is a self-inflicted DoS, not an external attack.
- Symlinked subdirectories would be followed, potentially validating directories outside the intended scope.

**Mitigations/controls:**
- The filter `.filter(e => e.isDirectory() && fs.existsSync(path.join(skillsDir, e.name, 'SKILL.md')))` limits processing to directories containing a `SKILL.md` file.
- Concurrency is bounded by `options.concurrency` (default 6, configurable via `--concurrency` flag or `SKILL_VALIDATOR_CONCURRENCY` env var).
- `parseInt()` on the concurrency value handles non-numeric input safely (returns NaN, which fails the `n > 0` check, keeping the default).

**Attacker story:** Not applicable in typical usage. The developer controls the `--all` target directory.

### 3.6 Environment variable parsing (`validate-skill.js:31`)

**Surface:** `parseInt(process.env.SKILL_VALIDATOR_CONCURRENCY || '6', 10)`.

**Risks:**
- Setting a very large concurrency value could cause many parallel Promise.all operations, consuming memory. However, each validation operation is lightweight (file reads and regex matching).
- Non-numeric values are handled safely by the `if (n > 0)` guard.

**Mitigations/controls:**
- `parseInt()` with radix 10 is safe for all string inputs.
- The `n > 0` check prevents zero, negative, or NaN values from being used.

**Attacker story:** An attacker who controls environment variables already has shell access, making this moot.

### Out-of-scope / not applicable
- **Network-based attacks (SSRF, XSS, CSRF, request smuggling)**: Neither script makes network requests or serves HTTP content. Not applicable.
- **Authentication/authorization bypass**: Neither script has auth mechanisms. Not applicable for local CLI tools.
- **SQL injection**: No database access. Not applicable.
- **Command injection**: Neither script uses `child_process.exec()`, `child_process.spawn()`, `eval()`, `new Function()`, or any shell/command execution APIs. Not applicable.
- **Deserialization RCE**: `JSON.parse()` and `yaml.parse()` (v2 defaults) do not support code execution. Not applicable.
- **Memory corruption**: Node.js is memory-safe. Not applicable (unless a native addon is involved, which is not the case here).
- **Cryptographic weaknesses**: Neither script performs cryptographic operations. Not applicable.
- **Multi-tenant isolation**: Single-user local CLI tool. Not applicable.

## 4. Systemic findings

No systemic findings identified. The scripts have a narrow, well-contained attack surface. The few risks identified are independent of each other (path handling, file parsing, file writing) and do not share a common root cause amenable to a single fix. No vulnerability class has 3 or more instances.

## 5. Exploit chains

No exploit chains identified. The individual findings are all low severity and do not combine into higher-impact attack paths. The primary reason is that the scripts operate in a trusted local context where the operator controls all inputs (CLI arguments, file contents, environment variables). There is no attacker-controlled entry point that could be chained through multiple stages.

The closest theoretical chain would be:
1. Attacker plants a malicious skill directory with a symlink (`AGENTS.md -> sensitive-file`)
2. Developer runs `build-agents-md.js` against it
3. Sensitive file is overwritten with markdown

This requires the attacker to already have write access to the developer's filesystem, which means they already have more access than this chain would provide. The chain does not amplify attacker capability.

## 6. Criticality calibration (critical, high, medium, low)

### Exploit chains
None identified.

### Systemic findings
None identified.

### Individual findings

**Critical**
None.

**High**
None.

**Medium**
None.

**Low**
- Symlink following in file write: `build-agents-md.js` writes `AGENTS.md` via `fs.writeFileSync` which follows symlinks. If a malicious skill directory contains a symlinked `AGENTS.md`, the target file would be overwritten with benign markdown content. Requires attacker to have local filesystem write access to plant the symlink. (Section 3.4)
- Symlink following in file reads: Both scripts follow symlinks when reading skill directory contents (`metadata.json`, `*.md` files). A symlinked file pointing outside the skill directory would be read and parsed. Parsing would fail for non-JSON/non-markdown content, producing an error message that might disclose the file path. Requires local filesystem write access. (Sections 3.1, 3.2, 3.3)
- Unbounded directory enumeration in bulk mode: `validate-skill.js --all /` would attempt to find and validate all directories on the filesystem containing a `SKILL.md` file. This is operator-controlled and self-inflicted. (Section 3.5)

**Scope note**: All findings require local filesystem access by the attacker or self-inflicted misuse by the operator. In the intended usage context (developer running tools against their own skill directories), all findings are effectively informational. If these scripts were integrated into a CI pipeline that processes untrusted skill directory submissions, the symlink-following findings would be upgraded to medium severity, and input validation of the skill directory path would become advisable.
