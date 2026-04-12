# Transcript: scaffold `shipit deploy` CLI (without skill, run 1)

## 1. Task understanding

Design the TypeScript interface for a `shipit deploy` subcommand using commander.js. Requirements:

- Deploy a service by name to a target environment using a specified image tag.
- Must work equally well for two audiences: humans at a terminal and Claude agents in CI pipelines.
- Deliverables in the single output file `shipit-deploy.ts`:
  - Complete commander.js setup
  - `--help` examples
  - Flag parsing and validation
  - Error handling with stable exit codes
  - At least one way to get structured output for agents
- Do NOT implement the real deploy logic — stub it with a TODO and a fake return value.
- Constraint: must NOT read anything under `skills/.experimental/cli-for-agents/`. Use only default knowledge of commander.js, TypeScript, and CLI design. The goal is a natural baseline for an unaided agent.

## 2. Major steps and reasoning

### Step 1: Verify the output directory
Ran `ls` on the run-1 directory to confirm `outputs/` exists before writing. Standard pre-flight to avoid `ENOENT` on Write.

### Step 2: Design the CLI shape mentally
I sketched the design in my head before writing, aiming for a single self-contained file that still reflects how I'd organize a real module:

1. **Types at the top** — `Environment`, `OutputFormat`, `DeployOptions`, `DeployResult`, `DeployError`. Splitting the raw commander options from a normalized `DeployOptions` interface gives the handler a typed contract.
2. **Exit codes as an enum** — stable, documented, with explicit reserved meanings (0 success, 1 generic, 2 usage, 3 validation, 4 deploy failed, 5 timeout, 6 aborted). Agents branching on exit codes need these to be stable, so I wrote a comment saying they can't be renumbered without a major version bump.
3. **Custom `ShipitError`** carrying `code` and optional `hint`, so the top-level handler can route any thrown error to the right exit code and format.
4. **Per-flag validators** using `InvalidArgumentError` — this is the commander-native way to reject bad values early and get a good error message automatically. Added regex-backed validators for service name (DNS-label-ish) and image tag (Docker tag rules), plus a positive-integer parser for `--timeout-seconds`.
5. **Agent-context detection** — check `CI`, `SHIPIT_AGENT`, `CLAUDE_AGENT`, and `process.stdout.isTTY`. Used to set sensible defaults (JSON output when in agent mode) without forcing users to remember flags.
6. **Two output paths** — `writeResult` and `writeError` both honor text vs JSON. JSON goes to stdout for results and stderr for errors, so a pipeline can `jq` the result while still seeing errors separately. Colors only applied when the respective stream is a TTY AND `--no-color` wasn't passed.
7. **Deploy stub** — a `runDeploy` function that returns a fake `DeployResult` with a generated `deploymentId`, ISO timestamps, and a clear `TODO(shipit):` comment pointing at where the real rollout driver should go.
8. **Commander builder** — `buildDeployCommand` returns a `Command` with:
   - `--service -s`, `--env -e`, `--tag -t` as required, all validated
   - `--env` uses `Option.choices` so commander itself gates the value
   - `--dry-run`, `--timeout-seconds`, `--output -o`, `--no-color`, `--verbose`, `-y/--yes`
   - `.addHelpText("after", ...)` with four worked examples (human, dry run, agent/CI, pipe to jq), plus exit codes and env vars documented inline. This is what you see when you run `shipit deploy --help`.
9. **Safety rail** — if the tool is running in agent context AND the target is `prod` AND `--yes` wasn't passed AND it isn't a dry run, throw a usage error with a hint. This is the "don't let the agent accidentally ship to prod without explicit confirmation" guardrail.
10. **Top-level `main()`** — wraps `parseAsync` in try/catch, translates commander errors (detected by `code` + `exitCode` fields) into `UsageError`, lets `ShipitError` pass through with its own code, and catches everything else as `GenericError`. Uses `.exitOverride()` on the program so commander throws instead of calling `process.exit` itself, which lets our handler own formatting. Also detects `commander.helpDisplayed` / `commander.version` so `--help` and `-V` still exit 0.
11. **`if (require.main === module)` guard** so the file can be imported by tests without running `main()` on import.

### Step 3: Write the file
Wrote the file in one pass with `Write`. Chose CommonJS-style `require.main === module` rather than `import.meta.url` because it's simpler and matches most commander.js project templates; can be swapped if the project is ESM.

## 3. Tools used

- `Bash` — one `ls` to confirm the output directory.
- `Write` — one call to create `shipit-deploy.ts`, one call to create this transcript.

No `Read` / `Grep` / `Glob` calls because the task constraint said to work only from default knowledge.

## 4. Issues encountered

None significant. A few small design decisions I resolved inline while writing:

- **`Option.choices` vs custom parser for `--env`.** I used both — `choices()` gives commander native validation and auto-completion, while `argParser(parseEnvironment)` also narrows the return type and keeps the error message consistent if someone calls `parseEnvironment` directly. Slight redundancy but no real downside.
- **Where to emit JSON errors.** I send result JSON to stdout (so `| jq` works) and error JSON to stderr (so it doesn't pollute a happy-path pipeline). This is the Unix convention and agents that parse both streams can tell them apart.
- **`--no-color` handling.** Commander implicitly exposes this as `opts.color = false` when `--no-color` is passed. I normalized it in the handler with `rawOpts.color !== false` so the downstream `DeployOptions.color` is always a boolean.
- **Prod guardrail.** I debated whether to require `--yes` for prod in all contexts or only in agent context. I went with "only in non-TTY / CI context" because a human typing at a terminal is assumed to have read the command they just typed; the risk is specifically the agent firing-and-forgetting. A real implementation would probably also have an interactive `prompts` confirmation for TTY humans.
- **Exit code numbering.** I deliberately kept `2 = usage error` to match commander's own default and POSIX convention, then layered our semantic codes (3–6) on top.

## 5. Output produced

- `outputs/shipit-deploy.ts` — complete TypeScript source (~350 lines) containing:
  - Type definitions: `Environment`, `OutputFormat`, `DeployOptions`, `DeployResult`, `DeployError`
  - `ExitCode` enum with documented meanings
  - `ShipitError` class carrying a code and optional hint
  - Argument validators using commander's `InvalidArgumentError`: `parseService`, `parseEnvironment`, `parseTag`, `parsePositiveInt`
  - `isAgentContext()` env/TTY detection
  - `writeResult` / `writeError` dual-format output helpers
  - `runDeploy` stub with a `TODO(shipit):` comment and a fake `DeployResult`
  - `buildDeployCommand()` with all flags, `.addHelpText("after", ...)` examples, and the prod-agent safety rail
  - `buildProgram()` wiring the top-level `shipit` program with `.exitOverride()`
  - `main()` entry point that translates commander errors, `ShipitError`, and unknown errors into the correct exit codes and output format
  - `require.main === module` guard so the file is test-importable
- `transcript.md` — this file.
