# dot-skills

## What this codebase does

A static collection of ~150 AI Agent Skills (markdown under `skills/.curated/`
and `skills/.experimental/`) plus a small toolbelt of local maintainer
scripts that validate skill structure, derive versions from git history,
and regenerate the README table. There is **no web server, no HTTP
endpoint, no database, no auth layer, and no user input from
network** — every script is invoked locally by the repo maintainer or
in CI against checked-in files.

## Auth shape

N/A — no runtime auth. The only "principal" is the local user running
`pnpm test`, `pnpm validate`, or `npx add-skill`. Treat anything that
reads under `skills/**/SKILL.md` or `tests/fixtures/**` as
trusted-author content (PR review is the gate), not as untrusted input.

## Threat model

Realistic risks, ranked:

1. **Malicious PR adds a SKILL.md or fixture that exploits a parser/
   validator** — e.g. YAML payload that triggers a js-yaml quirk,
   frontmatter that smuggles through `cmdToPrompt`'s CDATA escaping in
   `scripts/skills-ref-parse.js`, or a path that breaks out of
   `skills_root` in the bash validator.
2. **Command injection via paths/arguments in shell scripts** —
   `scripts/skills-ref` and `scripts/generate-readme-tables` build
   shell commands from `$1`/directory names; an attacker-controlled
   skill directory name could matter if these are ever invoked on
   untrusted checkouts.
3. **Supply chain via `add-skill` install path** — README documents
   `npx add-skill pproenca/dot-skills` as the install command; not
   code in this repo, but worth flagging if anything here is fetched
   and executed by installers.

No remote attack surface; out-of-scope: anything mounted as a web
service, RBAC, secrets handling, session management.

## Project-specific patterns to flag

- **Shell scripts using unquoted/interpolated path args** in
  `scripts/skills-ref`, `scripts/generate-readme-tables` — any new
  `eval`, backtick, or `$(...)` over a `$dir` / `$1` is worth a look.
- **`execFileSync('git', [...])` in `scripts/*.mjs`** — currently safe
  (argv form, no shell). Flag any switch to `execSync` or shell-string
  form, especially if it interpolates skill names or commit messages.
- **`yaml.load` (vs `safeLoad`) in `scripts/skills-ref-parse.js`** —
  js-yaml v4 defaults to safe schema, but flag any change to a
  permissive schema (`yaml.load(s, { schema: yaml.DEFAULT_FULL_SCHEMA })`)
  or use of `!!js/function` tags reaching parse.
- **CDATA escaping in `cmdToPrompt`** (`skills-ref-parse.js`) — splits
  `]]>` to prevent escape. Any rewrite of XML/CDATA emission for skill
  prompts should preserve that.
- **`urlopen()` in `app-sdlc/scripts/scrape-hig.py`** — fetches URLs
  from `urls-*.txt`. Fine for maintainer use; flag if URLs ever come
  from a SKILL.md, frontmatter, or web request.

## Known false-positives

- **`skills/**/SKILL.md`, `skills/**/references/*.md`, `skills/**/assets/**`,
  `app-sdlc/8090-docs/**`** — documentation that contains code samples
  (eval, child_process, SQL strings, `dangerouslySetInnerHTML`,
  hard-coded API keys in examples, etc.). None of this is executed by
  the repo. Treat all matches under these paths as documentation
  unless the file extension is `.sh`, `.mjs`, `.js`, `.ts`, or `.py`.
- **`tests/fixtures/**`** — intentionally malformed SKILL.md files
  (cdata-terminator, invalid names, long descriptions). They exist to
  exercise the validator and should never be flagged as real findings.
- **`plugins/threat-model/skills/**`** — distributed threat-modeling
  skills; same docs-not-code rule applies.
- **`node_modules/**`, `.deepsec/**`** — vendor / scanner workspace.
