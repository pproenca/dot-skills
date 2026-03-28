## 1. Overview

`build-agents-md.js` and `validate-skill.js` are Node.js CLI build/validation tools in the `dev-skill` plugin within the `dot-claude` marketplace. `build-agents-md.js` reads a skill directory's `metadata.json`, `_sections.md`, and individual reference markdown files, then compiles them into a single `AGENTS.md` document. `validate-skill.js` validates skill directory structure against quality guidelines, checking required files, metadata, sections, rule content, and optionally verifying that `AGENTS.md` matches script-generated output. It imports a `SkillValidator` class from `./validation/validator.js` which performs the detailed checks, and also imports `buildAgentsMD` from `build-agents-md.js` for the `--verify-generated` comparison.

Both tools run locally on the developer's machine, invoked via `node <script> <skill-directory>` from the command line. They have no network endpoints, no HTTP listeners, and no database connections. They only use the Node.js `fs` and `path` built-in modules. The primary security goals are: (1) host filesystem integrity -- the scripts should not write outside the intended skill directory, (2) safe handling of untrusted content within skill files -- markdown content and frontmatter from skill files flows through parsing and output generation, and (3) reliable operation -- the tools should not crash or produce corrupt output from malformed input.

## 2. Threat model, Trust boundaries and assumptions

### Assets / security goals

- **Host filesystem integrity**: The scripts write to `AGENTS.md` within the skill directory (`build-agents-md.js` line 228) and read from the skill directory tree. Writes should stay within the target directory.
- **Generated artifact correctness**: `AGENTS.md` is consumed by AI agents/LLMs as authoritative guidance. Corrupted or manipulated output could mislead downstream automation.
- **Developer environment**: The scripts run with the invoking user's full filesystem permissions. Any exploitation would inherit those privileges.
- **Build reproducibility**: `validate-skill.js --verify-generated` compares generated output to existing `AGENTS.md` for integrity verification.

### Trust boundaries & input classes

**Attacker-controlled inputs**
- **Skill directory contents**: Markdown files (`_sections.md`, reference `*.md` files, `SKILL.md`, `README.md`) and `metadata.json` within the target skill directory. If a developer runs these tools on a cloned/contributed skill from an untrusted source, all file contents are attacker-influenced. Content enters via `fs.readFileSync` in `build-agents-md.js` (lines 81, 106, 131) and throughout `validator.js`.

**Operator-controlled inputs**
- **Command-line arguments**: The skill directory path (`process.argv[2]` in `build-agents-md.js` line 215; parsed in `validate-skill.js` `parseArgs`) and CLI flags (`--strict`, `--json`, `--all`, `--concurrency`, `--sections-only`, `--verify-generated`).
- **Environment variable `SKILL_VALIDATOR_CONCURRENCY`**: Parsed as integer in `validate-skill.js` line 31, controls parallel validation count.

**Developer-controlled inputs**
- **The scripts themselves**: `build-agents-md.js`, `validate-skill.js`, and `validation/validator.js` are packaged in the `dot-claude` plugin. Only a threat if the supply chain (the `dot-claude` marketplace) is compromised.
- **Node.js runtime and npm dependencies**: The project depends on `remark-parse`, `remark-frontmatter`, `yaml`, `unified`, and related markdown processing packages (visible in `node_modules`).

### Assumptions & scope

- The scripts are run locally by a developer who trusts the Node.js runtime and the `dot-claude` plugin source. Supply-chain compromise of the plugin itself is out of scope.
- The skill directories being processed may come from untrusted contributors (pull requests, community submissions), so file contents within skill directories are treated as potentially attacker-influenced.
- There are no network listeners, no authentication flows, and no multi-user access patterns.
- Web application threats (CSRF, SSRF, session management, rate limiting) do not apply since there are no network endpoints.

## 3. Attack surface, mitigations and attacker stories

### 3.1 Path construction from command-line arguments (`build-agents-md.js`, `validate-skill.js`)

**Surface:** Both scripts accept a directory path from the command line. `build-agents-md.js` uses `process.argv[2]` (line 215) and joins it with filenames like `metadata.json`, `AGENTS.md`, `references/`, `rules/`. `validate-skill.js` takes the path from `parseArgs` (line 46) and passes it into `SkillValidator` methods and `buildAgentsMD`. The output path for `AGENTS.md` is always `path.join(skillDir, 'AGENTS.md')` (line 228).

**Risks:**
- If the operator supplies a path like `../../sensitive-dir`, the script writes `AGENTS.md` relative to that location. However, `path.join` normalizes the path, and `fs.existsSync` checks (line 102, 224) verify the directory exists before proceeding. The write target is always `<skillDir>/AGENTS.md`, so the operator controls where the file is written.
- Symlink following: if `skillDir` or subdirectories are symlinks pointing elsewhere, `fs.readFileSync` and `fs.writeFileSync` follow them without verification.

**Mitigations/controls:**
- The script checks `fs.existsSync(skillDir)` before proceeding (line 224 in `build-agents-md.js`, line 385-387 in `validate-skill.js`).
- The output filename is hardcoded to `AGENTS.md` -- it is not derived from file content.
- The operator explicitly provides the path, so they control the write location.
- `path.join` normalizes `../` sequences, preventing path components from escaping the join base.

**Attacker story:** An attacker submits a skill directory containing a symlink named `references` pointing to `/etc` or `~/.ssh`. When the developer runs `build-agents-md.js` on this directory, the script reads files from the symlinked location (line 159 `fs.readdirSync(referencesDir)`). In practice, the script would likely fail (no `_sections.md` in `/etc`) rather than exfiltrate data. But if the symlink pointed to a directory containing markdown files with the right naming pattern, their content would be included in the generated `AGENTS.md`. In typical local usage by a developer inspecting a PR, severity is low because the developer chooses what directory to run the tool on.

### 3.2 JSON parsing of `metadata.json` (`build-agents-md.js` line 106, `validator.js` line 340)

**Surface:** Both scripts parse `metadata.json` via `JSON.parse(fs.readFileSync(...))`. The parsed object's fields (`technology`, `version`, `organization`, `abstract`, `references`, `discipline`) are interpolated into string output or used for control flow.

**Risks:**
- `metadata.json` from an untrusted skill could contain excessively large strings (e.g., a 100MB `abstract` field), causing memory exhaustion during string concatenation in `buildAgentsMD`.
- Prototype pollution: `JSON.parse` in Node.js does not create prototype-polluted objects (it uses `null`-prototype internally for parsed objects in modern Node), so `__proto__` keys in the JSON would become regular string keys, not prototype mutations. This is a non-risk.
- The `references` array (line 183-186) is iterated and each element is interpolated into markdown output. Malicious strings could inject misleading markdown links but cannot execute code since the output is a `.md` file.

**Mitigations/controls:**
- `JSON.parse` throws on malformed input, and both scripts handle this with try/catch (validator line 429, build-agents-md has no explicit catch but the error propagates to the CLI).
- The parsed fields are only interpolated into markdown text (string concatenation), never into shell commands or `eval`.
- No upper bound on field sizes, but this is a DoS concern, not an integrity or confidentiality concern.

**Attacker story:** A malicious contributor submits a skill with a `metadata.json` containing a `references` array with 10,000 entries, each a long URL-like string. Running `build-agents-md.js` produces a massive `AGENTS.md` file that could slow down downstream consumers. The developer would notice the anomaly during review. Severity is low -- this is a nuisance, not a compromise.

### 3.3 Markdown file content interpolation into output (`build-agents-md.js` lines 75-98, 134-206)

**Surface:** `build-agents-md.js` reads all `.md` files from the references directory, parses their frontmatter (`title`, `impact`, `impactDescription`, `tags`), and interpolates those values into the generated `AGENTS.md` output via string concatenation (lines 170-176). `_sections.md` content is also parsed and section names/impacts are interpolated (line 166).

**Risks:**
- Markdown injection: A malicious reference file could contain frontmatter with a `title` like `Legit Rule](evil-link) -- [Injected`, which when interpolated into the markdown link format `[${ref.title}](${refDirName}/${ref.filename})` could break the link structure and inject additional markdown. However, this only affects the generated `.md` file's formatting -- it cannot execute code.
- Content from the `body` of reference files is **not** included in the generated `AGENTS.md` (the body is trimmed but only stored in the reference object, never appended to the output array). This limits the impact of malicious content in reference file bodies.

**Mitigations/controls:**
- Output is a plain markdown file (`AGENTS.md`), not HTML or executable code. Markdown injection can only affect formatting, not achieve code execution.
- File body content is parsed but not included in the output.
- Reference filenames are validated to match the `prefix-*.md` pattern (line 79), limiting which files are processed.

**Attacker story:** A contributor submits a reference file with frontmatter `title: "Good rule](http://evil.com) - [Click me"`. The generated `AGENTS.md` contains a malformed link that, when rendered by a markdown viewer, could display a deceptive hyperlink. In practice, this requires the developer to not review the generated output and for a downstream consumer to click the link. Severity is low.

### 3.4 `fs.readdirSync` and unbounded file processing (`build-agents-md.js` line 159, `validator.js` lines 163, 572)

**Surface:** Both scripts use `fs.readdirSync` to list directory contents without limiting the number of entries. `validate-skill.js` in `--all` mode (line 163) lists all subdirectories and validates each one, with concurrency controlled by `--concurrency` (default 6) or `SKILL_VALIDATOR_CONCURRENCY`.

**Risks:**
- A skill directory containing thousands of `.md` files could cause high memory usage and slow processing as each file is read into memory (`fs.readFileSync`), parsed, and processed.
- In `--all` mode, a directory with thousands of subdirectories (each containing a `SKILL.md`) would spawn many validation tasks. The concurrency limit (line 178) constrains parallel execution, but total memory could still grow.

**Mitigations/controls:**
- Concurrency is bounded by the `--concurrency` flag (default 6, validated to be positive at line 43-44).
- `SKILL_VALIDATOR_CONCURRENCY` environment variable is parsed with `parseInt` and validated (`if (n > 0)` at line 43).
- Files are processed synchronously within each skill (no streaming), but the workload is bounded by the directory contents which are under operator control.

**Attacker story:** A contributor creates a skill directory with 50,000 empty `.md` files prefixed to match section patterns. Running `validate-skill.js` on this directory would read and parse all files, consuming significant time and memory. This is a local DoS against the developer's machine. The developer would need to run the tool on the adversarial directory. Severity is low.

### 3.5 `fs.writeFileSync` output target (`build-agents-md.js` line 228)

**Surface:** `build-agents-md.js` writes the generated output to `path.join(skillDir, 'AGENTS.md')` using `fs.writeFileSync`. `validate-skill.js` does not write any files (read-only validation).

**Risks:**
- The write path is deterministic and under the operator's control (the `skillDir` argument). There is no TOCTOU race condition concern since the write is a single atomic `writeFileSync` call.
- If `skillDir` is a world-writable location (e.g., `/tmp/some-skill`), another process could race to create a symlink at `AGENTS.md` before the write, redirecting the write to an arbitrary location. However, this requires local access by another malicious process.

**Mitigations/controls:**
- The write target path is always `<skillDir>/AGENTS.md` -- no user-controlled filename component.
- `writeFileSync` is atomic at the Node.js level (single syscall write).
- Typical usage is within a project checkout, not in shared/world-writable directories.

**Attacker story:** On a shared CI machine, an attacker creates a symlink at `<skillDir>/AGENTS.md` pointing to a sensitive file. When the build script runs, it overwrites the symlink target with generated markdown content. This could corrupt a file outside the skill directory. This requires the attacker to have write access to the skill directory on the CI runner. Severity is low in typical local-developer usage; medium on shared CI without container isolation.

### 3.6 `process.exit` and error handling (`build-agents-md.js`, `validate-skill.js`)

**Surface:** Both scripts use `process.exit(1)` for error conditions and `process.exit(0)` for success. Error messages include user-supplied paths and parsed content (e.g., `console.error(`Error: Directory not found: ${skillDir}`)` at `build-agents-md.js` line 223).

**Risks:**
- Path strings containing terminal escape sequences could be injected via the `skillDir` argument, manipulating terminal output. For example, a path containing ANSI escape codes could clear the screen or alter displayed text.
- Error messages from `JSON.parse` failures include the parse error message, which reflects input content.

**Mitigations/controls:**
- Terminal escape injection is a cosmetic issue, not a code execution vector.
- The scripts only write to stdout/stderr, not to log files or network endpoints.

**Attacker story:** An operator runs `validate-skill.js` on a directory path containing ANSI escape sequences (e.g., `\x1b[2J` to clear the terminal). The error output manipulates the terminal display. This is a cosmetic nuisance requiring the operator to type or paste the malicious path. Severity is low.

### Out-of-scope / not applicable

- **Network attacks (CSRF, SSRF, rate limiting, DDoS)** are not applicable because neither script opens any network connections or listens on any ports.
- **Authentication and authorization bypass** are not applicable because there are no auth flows; the scripts run with the invoking user's permissions.
- **SQL injection** is not applicable because there are no database operations.
- **XSS / HTML injection** is not applicable because the output is a `.md` file, not served as HTML. Markdown viewers that render untrusted content have their own XSS concerns, but that is a downstream consumer issue.
- **Multi-tenant isolation** is not a goal; these are single-user local tools.
- **Credential/secret management** is not applicable; the scripts handle no secrets, tokens, or credentials.
- **Native code / memory safety** is not applicable; the scripts are pure JavaScript with no native addons.

## 4. Criticality calibration (critical, high, medium, low)

**Critical**
- None identified. These scripts have no network exposure, execute no external commands, and perform no security-sensitive operations (auth, crypto, native code). The attack surface is narrow.

**High**
- None identified. There are no code execution paths from attacker-controlled input, no command injection vectors, and no uncontrolled file writes.

**Medium**
- **Symlink following in skill directory reads** (3.1): `fs.readFileSync` and `fs.readdirSync` follow symlinks without verification. A malicious skill directory containing symlinks could cause the scripts to read files outside the intended directory. Impact is information inclusion in `AGENTS.md`, not exfiltration. Medium if processing untrusted skill PRs in automated CI; low in manual local usage.
- **Symlink race on write target** (3.5): On shared CI machines without container isolation, a symlink at `<skillDir>/AGENTS.md` could redirect the write to an arbitrary file. Medium on shared CI; low in local development.

**Low**
- **Markdown injection via frontmatter fields** (3.3): Malicious `title` or `impactDescription` values could produce deceptive links in the generated `AGENTS.md`. Only affects formatting of a static markdown file.
- **Memory exhaustion from oversized input** (3.2, 3.4): Extremely large `metadata.json` fields or thousands of reference files could cause high memory usage. This is a local DoS requiring the operator to run the tool on adversarial input.
- **Terminal escape sequence injection** (3.6): Malicious directory paths or file content reflected in error messages could manipulate terminal display. Cosmetic only.
- **Unbounded concurrency resource usage** (3.4): In `--all` mode, large numbers of skill directories consume memory proportional to total file count. Mitigated by the `--concurrency` flag.

**Scope note**: All findings assume the scripts are run locally by a developer or in a CI pipeline. The medium-severity symlink concerns apply only when processing untrusted skill directories (e.g., community-contributed PRs) on shared infrastructure. In the typical case of a developer running the tools on their own skill directories, all identified risks are low.
