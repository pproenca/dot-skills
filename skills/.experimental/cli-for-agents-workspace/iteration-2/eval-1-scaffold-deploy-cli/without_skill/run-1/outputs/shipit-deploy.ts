#!/usr/bin/env node
/**
 * shipit deploy
 *
 * Deploy a service by name to a target environment using a specified image tag.
 *
 * This CLI is designed to work equally well for two audiences:
 *   1. Humans typing at a terminal (pretty output, colored errors, helpful hints)
 *   2. Claude agents running in CI pipelines (structured JSON output,
 *      deterministic exit codes, no interactive prompts, no color codes
 *      polluting logs)
 *
 * The mode is auto-detected from the environment (TTY + CI env vars) but can
 * always be forced with `--output <format>` and `--no-color`.
 */

import { Command, Option, InvalidArgumentError } from "commander";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/**
 * Known target environments. Kept as a union so that commander can validate
 * the flag against it and TypeScript can narrow at the call site.
 */
export type Environment = "dev" | "staging" | "prod";

export const ENVIRONMENTS: readonly Environment[] = ["dev", "staging", "prod"];

/**
 * Output format. `text` is the human-friendly default; `json` is intended for
 * agents and CI pipelines that need to parse the result.
 */
export type OutputFormat = "text" | "json";

/**
 * Parsed, validated options as they reach the deploy handler.
 *
 * Note: these are POST-validation. Raw commander options are stringly-typed;
 * this interface reflects the normalized shape after `parseOptions` runs.
 */
export interface DeployOptions {
  service: string;
  env: Environment;
  tag: string;
  dryRun: boolean;
  timeoutSeconds: number;
  output: OutputFormat;
  color: boolean;
  verbose: boolean;
  yes: boolean;
}

/**
 * Result of a deploy run. This shape is what gets serialized when
 * `--output json` is used. Keep it stable: agents will depend on it.
 */
export interface DeployResult {
  ok: boolean;
  service: string;
  environment: Environment;
  tag: string;
  deploymentId: string;
  startedAt: string; // ISO 8601
  finishedAt: string; // ISO 8601
  durationMs: number;
  dryRun: boolean;
  url?: string;
  message?: string;
}

/**
 * Error envelope for structured output. Mirrors DeployResult's shape so that
 * agents can switch on `ok` without a second parse.
 */
export interface DeployError {
  ok: false;
  code: ExitCode;
  error: {
    type: string;
    message: string;
    hint?: string;
  };
}

// ---------------------------------------------------------------------------
// Exit codes
// ---------------------------------------------------------------------------

/**
 * Stable exit codes. Agents and CI pipelines branch on these, so they must
 * not be renumbered without a major version bump.
 *
 *   0  Success
 *   1  Generic/unknown error
 *   2  Invalid usage (bad flags, missing required args) — matches commander default
 *   3  Validation error (semantically valid flags but invalid values,
 *      e.g. service name not found in registry)
 *   4  Deploy failed (the rollout itself returned an error)
 *   5  Timeout (deploy exceeded --timeout-seconds)
 *   6  Aborted by user (e.g. declined confirmation prompt)
 */
export enum ExitCode {
  Success = 0,
  GenericError = 1,
  UsageError = 2,
  ValidationError = 3,
  DeployFailed = 4,
  Timeout = 5,
  Aborted = 6,
}

// ---------------------------------------------------------------------------
// Custom errors
// ---------------------------------------------------------------------------

export class ShipitError extends Error {
  constructor(
    message: string,
    public readonly code: ExitCode,
    public readonly hint?: string,
  ) {
    super(message);
    this.name = "ShipitError";
  }
}

// ---------------------------------------------------------------------------
// Flag parsers / validators
// ---------------------------------------------------------------------------

const SERVICE_NAME_RE = /^[a-z][a-z0-9-]{1,62}[a-z0-9]$/;
const TAG_RE = /^[\w][\w.-]{0,127}$/;

function parseService(value: string): string {
  if (!SERVICE_NAME_RE.test(value)) {
    throw new InvalidArgumentError(
      `Service name "${value}" is invalid. ` +
        `Must be lowercase alphanumeric with dashes, 3-64 chars, starting with a letter.`,
    );
  }
  return value;
}

function parseEnvironment(value: string): Environment {
  if (!ENVIRONMENTS.includes(value as Environment)) {
    throw new InvalidArgumentError(
      `Unknown environment "${value}". Expected one of: ${ENVIRONMENTS.join(", ")}.`,
    );
  }
  return value as Environment;
}

function parseTag(value: string): string {
  if (!TAG_RE.test(value)) {
    throw new InvalidArgumentError(
      `Image tag "${value}" is invalid. ` +
        `Must match Docker tag rules: [A-Za-z0-9_][A-Za-z0-9_.-]{0,127}.`,
    );
  }
  return value;
}

function parsePositiveInt(value: string): number {
  const n = Number.parseInt(value, 10);
  if (!Number.isFinite(n) || n <= 0) {
    throw new InvalidArgumentError(
      `Expected a positive integer, got "${value}".`,
    );
  }
  return n;
}

// ---------------------------------------------------------------------------
// Environment detection
// ---------------------------------------------------------------------------

/**
 * Detect whether we're running in an agent/CI context. We use this to pick
 * sensible defaults: JSON output, no color, no interactive prompts.
 */
function isAgentContext(): boolean {
  if (process.env.CI === "true" || process.env.CI === "1") return true;
  if (process.env.SHIPIT_AGENT === "1") return true;
  // Claude Code / Anthropic agent runtimes commonly set these.
  if (process.env.CLAUDE_AGENT === "1") return true;
  if (!process.stdout.isTTY) return true;
  return false;
}

// ---------------------------------------------------------------------------
// Output helpers
// ---------------------------------------------------------------------------

function writeResult(result: DeployResult, opts: DeployOptions): void {
  if (opts.output === "json") {
    process.stdout.write(JSON.stringify(result) + "\n");
    return;
  }

  // Human text output
  const status = result.ok ? "SUCCESS" : "FAILED";
  const lines = [
    `shipit deploy ${status}`,
    `  service:       ${result.service}`,
    `  environment:   ${result.environment}`,
    `  tag:           ${result.tag}`,
    `  deploymentId:  ${result.deploymentId}`,
    `  duration:      ${result.durationMs}ms`,
  ];
  if (result.url) lines.push(`  url:           ${result.url}`);
  if (result.dryRun) lines.push(`  (dry run — no changes applied)`);
  if (result.message) lines.push(`  message:       ${result.message}`);
  process.stdout.write(lines.join("\n") + "\n");
}

function writeError(err: ShipitError, opts: Partial<DeployOptions>): void {
  const format = opts.output ?? (isAgentContext() ? "json" : "text");

  if (format === "json") {
    const payload: DeployError = {
      ok: false,
      code: err.code,
      error: {
        type: err.name,
        message: err.message,
        hint: err.hint,
      },
    };
    process.stderr.write(JSON.stringify(payload) + "\n");
    return;
  }

  // Human text output. We deliberately avoid ANSI color codes unless stderr
  // is a TTY and color is enabled — piped stderr should stay plain.
  const useColor = (opts.color ?? true) && process.stderr.isTTY;
  const red = useColor ? "\x1b[31m" : "";
  const reset = useColor ? "\x1b[0m" : "";
  process.stderr.write(`${red}error:${reset} ${err.message}\n`);
  if (err.hint) process.stderr.write(`  hint: ${err.hint}\n`);
}

// ---------------------------------------------------------------------------
// Deploy stub
// ---------------------------------------------------------------------------

/**
 * Stub: actual deploy logic lives in src/deploy/rollout.ts (not yet wired up).
 * Replace this with the real rollout driver once it lands.
 *
 * TODO(shipit): call into the real deploy driver.
 *   - resolve the service in the registry
 *   - push the image to the env's registry mirror
 *   - trigger the rollout via Argo / k8s / whatever the ops team picks
 *   - stream status back until terminal state or --timeout-seconds elapses
 */
async function runDeploy(opts: DeployOptions): Promise<DeployResult> {
  const startedAt = new Date();

  // Fake return value so the CLI is runnable end-to-end.
  const fake: DeployResult = {
    ok: true,
    service: opts.service,
    environment: opts.env,
    tag: opts.tag,
    deploymentId: `dpl_${Math.random().toString(36).slice(2, 10)}`,
    startedAt: startedAt.toISOString(),
    finishedAt: startedAt.toISOString(),
    durationMs: 0,
    dryRun: opts.dryRun,
    url: `https://deploys.internal/${opts.env}/${opts.service}`,
    message: opts.dryRun
      ? "dry run: no rollout was triggered"
      : "stub deploy — TODO: wire up real rollout driver",
  };

  return fake;
}

// ---------------------------------------------------------------------------
// Command builder
// ---------------------------------------------------------------------------

export function buildDeployCommand(): Command {
  const cmd = new Command("deploy");

  cmd
    .description(
      "Deploy a service to a target environment using a specified image tag.",
    )
    .requiredOption(
      "-s, --service <name>",
      "Service name to deploy (e.g. billing-api)",
      parseService,
    )
    .addOption(
      new Option("-e, --env <environment>", "Target environment")
        .choices([...ENVIRONMENTS])
        .makeOptionMandatory(true)
        .argParser(parseEnvironment),
    )
    .requiredOption(
      "-t, --tag <imageTag>",
      "Container image tag to deploy (e.g. v1.4.2 or a git SHA)",
      parseTag,
    )
    .option(
      "--dry-run",
      "Validate inputs and print what would happen without making changes",
      false,
    )
    .option(
      "--timeout-seconds <seconds>",
      "Abort the deploy if it hasn't reached a terminal state within this many seconds",
      parsePositiveInt,
      600,
    )
    .addOption(
      new Option("-o, --output <format>", "Output format")
        .choices(["text", "json"])
        .default(isAgentContext() ? "json" : "text"),
    )
    .option("--no-color", "Disable ANSI color codes in text output")
    .option("-v, --verbose", "Print extra diagnostic information", false)
    .option(
      "-y, --yes",
      "Skip confirmation prompts (required for non-interactive use)",
      false,
    );

  // Custom help with examples for BOTH humans and agents.
  cmd.addHelpText(
    "after",
    `
Examples:
  # Human use — deploy billing-api to staging at tag v1.4.2
  $ shipit deploy --service billing-api --env staging --tag v1.4.2

  # Dry run to see what would happen (safe, makes no changes)
  $ shipit deploy -s billing-api -e prod -t v1.4.2 --dry-run

  # Agent / CI use — structured JSON output, no prompts, stable exit codes
  $ shipit deploy -s billing-api -e prod -t "$GIT_SHA" --output json --yes

  # Pipe JSON output to jq
  $ shipit deploy -s web -e dev -t latest -o json | jq '.deploymentId'

Exit codes:
  0  success
  1  generic error
  2  invalid usage (bad flags / missing required args)
  3  validation error (e.g. unknown service)
  4  deploy failed
  5  timeout exceeded
  6  aborted by user

Environment variables:
  CI=1 / SHIPIT_AGENT=1 / CLAUDE_AGENT=1
       Switches defaults to JSON output and non-interactive mode.
  SHIPIT_REGISTRY
       Override the container registry. Useful for local testing.
`,
  );

  cmd.action(async (rawOpts, command: Command) => {
    const opts: DeployOptions = {
      service: rawOpts.service,
      env: rawOpts.env,
      tag: rawOpts.tag,
      dryRun: Boolean(rawOpts.dryRun),
      timeoutSeconds: rawOpts.timeoutSeconds,
      output: rawOpts.output as OutputFormat,
      color: rawOpts.color !== false,
      verbose: Boolean(rawOpts.verbose),
      yes: Boolean(rawOpts.yes),
    };

    // Agent-context sanity check: refuse to hang on a prompt if nobody is
    // there to answer it.
    if (isAgentContext() && !opts.yes && opts.env === "prod" && !opts.dryRun) {
      throw new ShipitError(
        "Non-interactive context detected but --yes was not provided for a prod deploy.",
        ExitCode.UsageError,
        "Pass --yes to confirm, or --dry-run to validate without deploying.",
      );
    }

    const result = await runDeploy(opts);
    writeResult(result, opts);

    if (!result.ok) {
      process.exit(ExitCode.DeployFailed);
    }
  });

  return cmd;
}

// ---------------------------------------------------------------------------
// Top-level program + entry point
// ---------------------------------------------------------------------------

export function buildProgram(): Command {
  const program = new Command();

  program
    .name("shipit")
    .description("TrustedHousesitters internal deploy tool")
    .version("0.1.0", "-V, --version", "Print shipit version and exit")
    .showHelpAfterError("(run `shipit deploy --help` for usage)")
    .exitOverride(); // so we can route commander errors through our handler

  program.addCommand(buildDeployCommand());

  return program;
}

/**
 * Entry point. Wraps the whole program in a try/catch so that:
 *   - commander errors (bad flags) come out as ExitCode.UsageError
 *   - ShipitError instances use their own .code
 *   - anything else becomes ExitCode.GenericError
 * In all cases we honor the chosen output format.
 */
export async function main(argv: string[] = process.argv): Promise<void> {
  const program = buildProgram();

  try {
    await program.parseAsync(argv);
    process.exit(ExitCode.Success);
  } catch (err: unknown) {
    // Commander wraps its own errors; detect and translate them.
    if (err && typeof err === "object" && "code" in err && "exitCode" in err) {
      const ce = err as { code: string; exitCode: number; message: string };
      // commander help/version are not errors
      if (ce.code === "commander.helpDisplayed" || ce.code === "commander.version") {
        process.exit(ExitCode.Success);
      }
      writeError(
        new ShipitError(ce.message, ExitCode.UsageError),
        { output: isAgentContext() ? "json" : "text" },
      );
      process.exit(ExitCode.UsageError);
    }

    if (err instanceof ShipitError) {
      writeError(err, { output: isAgentContext() ? "json" : "text" });
      process.exit(err.code);
    }

    // Unknown error
    const message = err instanceof Error ? err.message : String(err);
    writeError(
      new ShipitError(message, ExitCode.GenericError),
      { output: isAgentContext() ? "json" : "text" },
    );
    process.exit(ExitCode.GenericError);
  }
}

// Only auto-run when executed directly, not when imported for tests.
if (require.main === module) {
  void main();
}
