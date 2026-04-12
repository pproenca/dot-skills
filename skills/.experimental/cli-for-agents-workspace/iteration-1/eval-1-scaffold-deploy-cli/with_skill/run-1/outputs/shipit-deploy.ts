#!/usr/bin/env node
/**
 * shipit deploy — deploy a service to a target environment using an image tag.
 *
 * Designed to be usable by BOTH humans at a terminal AND AI agents / CI
 * pipelines running it headlessly. Follows the cli-for-agents skill rules
 * (flags-first, layered help with examples, actionable errors, dry-run,
 * stable JSON output, standard exit codes, env-var fallbacks, idempotent
 * semantics).
 *
 * This file implements only the `shipit deploy` subcommand. A top-level
 * `shipit` program is included so layered help (`shipit --help` vs
 * `shipit deploy --help`) works correctly. The real deploy logic is stubbed
 * with a TODO — it returns a fake result shaped like a real deploy record.
 */

import { Command, CommanderError, Option } from 'commander';

// ---------------------------------------------------------------------------
// Exit codes (sysexits.h + POSIX conventions)
// ---------------------------------------------------------------------------
// Distinct codes let agents branch on outcome without parsing error text.
// Rule: err-non-zero-exit-codes
const ExitCode = {
  OK: 0, //  success
  FAILURE: 1, //  generic runtime failure
  USAGE: 2, //  usage error — do not retry, fix the command
  UNAVAILABLE: 69, //  EX_UNAVAILABLE — service down, hard failure
  TEMPFAIL: 75, //  EX_TEMPFAIL — transient, retry with backoff
} as const;

type ExitCode = (typeof ExitCode)[keyof typeof ExitCode];

// ---------------------------------------------------------------------------
// Domain types
// ---------------------------------------------------------------------------

const VALID_ENVS = ['staging', 'production', 'canary'] as const;
type Environment = (typeof VALID_ENVS)[number];

interface DeployOptions {
  service: string;
  env: Environment;
  tag: string;
  dryRun: boolean;
  yes: boolean;
  json: boolean;
  noInput: boolean;
  noColor: boolean;
  verbose: boolean;
  quiet: boolean;
  debug: boolean;
}

/**
 * Stable success record. Same shape whether a new deploy was created or
 * the target state was already present (`changed: false`).
 *
 * Rule: output-machine-ids-on-success, idem-stable-output-on-skip
 */
interface DeployResult {
  deploy_id: string;
  service: string;
  env: Environment;
  tag: string;
  url: string;
  duration_ms: number;
  changed: boolean;
  dry_run: boolean;
}

// ---------------------------------------------------------------------------
// Color helpers — respect NO_COLOR and non-TTY stderr.
// Rule: output-respect-no-color
// ---------------------------------------------------------------------------

function useColor(noColorFlag: boolean): boolean {
  if (noColorFlag) return false;
  // no-color.org spec: any non-empty value disables color.
  const envNoColor = process.env.NO_COLOR;
  if (envNoColor !== undefined && envNoColor !== '') return false;
  // We colorize errors → check the stream we write to (stderr).
  return Boolean(process.stderr.isTTY);
}

function red(s: string, on: boolean): string {
  return on ? `\x1b[31m${s}\x1b[0m` : s;
}

// ---------------------------------------------------------------------------
// Error emission — stderr only, with actionable fix + example invocation.
// Rule: err-stderr-not-stdout, err-actionable-fix, err-include-example-invocation
// ---------------------------------------------------------------------------

interface CliError {
  message: string;
  fix?: string[]; //  concrete next action(s) the caller can take
  examples?: string[]; //  copy-pasteable invocations that would succeed
  code: ExitCode;
}

function emitError(err: CliError, colorize: boolean): void {
  const prefix = red('Error:', colorize);
  process.stderr.write(`${prefix} ${err.message}\n`);
  if (err.fix && err.fix.length > 0) {
    for (const line of err.fix) {
      process.stderr.write(`  ${line}\n`);
    }
  }
  if (err.examples && err.examples.length > 0) {
    process.stderr.write('\nExample:\n');
    for (const ex of err.examples) {
      process.stderr.write(`  ${ex}\n`);
    }
  }
}

// ---------------------------------------------------------------------------
// Input validation — runs AFTER commander's required-option parse. Keeps
// validation at parse time, not mid-deploy.
// Rule: err-exit-fast-on-missing-required
// ---------------------------------------------------------------------------

function validateTag(value: string): string {
  if (value.length === 0) {
    throw new CommanderError(2, 'shipit.invalidTag', 'invalid --tag: empty string');
  }
  // Basic sanity: no whitespace, no shell metachars. Agents sometimes pass
  // unescaped `$(...)` substitutions — reject with a clear message.
  if (/[\s"'`$]/.test(value)) {
    throw new CommanderError(
      2,
      'shipit.invalidTag',
      `invalid --tag '${value}': contains whitespace or shell metacharacters`,
    );
  }
  return value;
}

function validateService(value: string): string {
  if (value.length === 0) {
    throw new CommanderError(2, 'shipit.invalidService', 'invalid --service: empty string');
  }
  if (!/^[a-z0-9][a-z0-9-]*$/.test(value)) {
    throw new CommanderError(
      2,
      'shipit.invalidService',
      `invalid --service '${value}': must match [a-z0-9][a-z0-9-]*`,
    );
  }
  return value;
}

// ---------------------------------------------------------------------------
// Deploy logic (stubbed).
// ---------------------------------------------------------------------------

/**
 * TODO: replace with real deploy implementation.
 *
 * Must be idempotent: if `service` is already running `tag` in `env`, return
 * the existing deploy record with `changed: false`. Otherwise trigger a
 * rollout and return the new record with `changed: true`. Network/runtime
 * failures should be surfaced as typed errors so the caller can map them to
 * the right exit code (TEMPFAIL vs FAILURE vs UNAVAILABLE).
 *
 * Rules: idem-retry-safe, idem-state-reconciliation, idem-stable-output-on-skip
 */
async function runDeploy(opts: DeployOptions): Promise<DeployResult> {
  const start = Date.now();
  // --- TODO: real work goes here ---
  //   1. look up current deploy for {service, env}
  //   2. if current.tag === opts.tag → return existing record (changed: false)
  //   3. else trigger rollout via deploy API, wait for health check
  //   4. map transport errors → TEMPFAIL, 5xx → UNAVAILABLE, 4xx → FAILURE
  // ----------------------------------

  // Fake return value, shaped like a real result.
  const fakeDeployId = `dep_${opts.service}_${opts.env}_${opts.tag}`.replace(/[^a-zA-Z0-9_]/g, '_');
  return {
    deploy_id: fakeDeployId,
    service: opts.service,
    env: opts.env,
    tag: opts.tag,
    url: `https://${opts.env}.${opts.service}.internal.example.com`,
    duration_ms: Date.now() - start,
    changed: true, //  stub always claims "changed"; real impl must set this
    dry_run: opts.dryRun,
  };
}

// ---------------------------------------------------------------------------
// Output formatting — human vs JSON. Plain text is the primary channel;
// decoration is sugar on top. Rule: output-no-decorative-only
// ---------------------------------------------------------------------------

function printHumanResult(r: DeployResult, opts: DeployOptions): void {
  if (opts.quiet) {
    // Quiet mode: just the deploy_id on stdout, so `$(shipit deploy ...)` works.
    process.stdout.write(`${r.deploy_id}\n`);
    return;
  }

  const verb = r.dry_run
    ? 'would deploy'
    : r.changed
      ? 'deployed'
      : 'already deployed';

  process.stdout.write(`${verb} ${r.tag} to ${r.env} (${r.service})\n`);
  process.stdout.write(`deploy_id: ${r.deploy_id}\n`);
  process.stdout.write(`url:       ${r.url}\n`);
  process.stdout.write(`duration:  ${(r.duration_ms / 1000).toFixed(1)}s\n`);
  process.stdout.write(`changed:   ${r.changed}\n`);
  if (r.dry_run) {
    process.stdout.write('dry_run:   true (no changes applied)\n');
  }
  // Rule: help-suggest-next-steps
  process.stdout.write('\nNext:\n');
  if (r.dry_run) {
    process.stdout.write(
      `  shipit deploy --service ${r.service} --env ${r.env} --tag ${r.tag} --yes\n`,
    );
  } else {
    process.stdout.write(`  shipit deploy status --id ${r.deploy_id}\n`);
    process.stdout.write(`  shipit logs --service ${r.service} --env ${r.env} --tail 100\n`);
    process.stdout.write(`  shipit deploy rollback --id ${r.deploy_id}\n`);
  }
}

function printJsonResult(r: DeployResult): void {
  // One top-level object, stable keys. Rule: output-json-flag
  process.stdout.write(`${JSON.stringify(r)}\n`);
}

// ---------------------------------------------------------------------------
// Main action — the body run when `shipit deploy ...` is invoked.
// ---------------------------------------------------------------------------

async function deployAction(
  raw: Record<string, unknown>,
  cmd: Command,
): Promise<void> {
  // Commander puts global flags on the parent program's opts, not on the
  // subcommand. Merge so the action sees both. Rule: struct-flag-order-independent
  const globalOpts = cmd.parent?.opts() ?? {};

  // --no-input is stored by commander as `input: false` (negation of an
  // implicit `--input` boolean). We invert here so our internal field name
  // matches the flag the user typed.
  const inputAllowed = raw.input !== false;
  // --no-color → commander stores as `color: false`.
  const colorAllowed = globalOpts.color !== false;

  // Normalize commander's output into a typed DeployOptions.
  const opts: DeployOptions = {
    service: raw.service as string,
    env: raw.env as Environment,
    tag: raw.tag as string,
    dryRun: Boolean(raw.dryRun),
    yes: Boolean(raw.yes),
    json: Boolean(raw.json),
    noInput: !inputAllowed,
    noColor: !colorAllowed,
    verbose: Boolean(globalOpts.verbose),
    quiet: Boolean(globalOpts.quiet),
    debug: Boolean(globalOpts.debug) || process.env.SHIPIT_DEBUG === '1',
  };

  const colorize = useColor(opts.noColor);

  // ---- Confirmation gate for destructive runs ------------------------------
  // Production deploys require --yes in non-interactive mode. We never fall
  // through to a prompt — agents inside tmux/VS Code/CI present as TTY but
  // have no one to answer. Rules: safe-force-bypass-flag,
  // safe-no-prompts-with-no-input, input-no-prompt-fallback
  //
  // For staging/canary we only gate on --no-input + no-tty to reduce friction;
  // production ALWAYS needs --yes.
  const isProduction = opts.env === 'production';
  const isTty = Boolean(process.stdin.isTTY) && Boolean(process.stdout.isTTY);
  const requireYes = !opts.dryRun && (isProduction || opts.noInput || !isTty);

  if (requireYes && !opts.yes) {
    emitError(
      {
        message: `refusing to deploy to '${opts.env}' without --yes in non-interactive mode.`,
        fix: [
          'Add --yes to confirm, or --dry-run to preview without applying.',
        ],
        examples: [
          `shipit deploy --service ${opts.service} --env ${opts.env} --tag ${opts.tag} --yes`,
          `shipit deploy --service ${opts.service} --env ${opts.env} --tag ${opts.tag} --dry-run`,
        ],
        code: ExitCode.USAGE,
      },
      colorize,
    );
    process.exit(ExitCode.USAGE);
  }

  // ---- Execute -------------------------------------------------------------
  try {
    if (opts.verbose && !opts.json && !opts.quiet) {
      process.stderr.write(
        `shipit: deploying ${opts.service}@${opts.tag} to ${opts.env}` +
          `${opts.dryRun ? ' (dry-run)' : ''}\n`,
      );
    }

    const result = await runDeploy(opts);

    if (opts.json) {
      printJsonResult(result);
    } else {
      printHumanResult(result, opts);
    }
    process.exit(ExitCode.OK);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    // Map known transient errors to EX_TEMPFAIL; everything else FAILURE.
    // Rule: err-non-zero-exit-codes
    const code = classifyError(err);

    emitError(
      {
        message: `deploy failed: ${message}`,
        fix:
          code === ExitCode.TEMPFAIL
            ? ['Transient failure — safe to retry.']
            : code === ExitCode.UNAVAILABLE
              ? ['Upstream deploy service is unavailable. Check status page before retrying.']
              : [
                  'Re-run with --debug to see the stack trace.',
                  `  SHIPIT_DEBUG=1 shipit deploy --service ${opts.service} --env ${opts.env} --tag ${opts.tag}`,
                ],
        code,
      },
      colorize,
    );

    // Stack trace only under --debug. Rule: err-no-stack-traces-by-default
    if (opts.debug || process.env.SHIPIT_DEBUG === '1') {
      if (err instanceof Error && err.stack) {
        process.stderr.write(`\n${err.stack}\n`);
      }
    }
    process.exit(code);
  }
}

/**
 * Classify a thrown error into an exit code. Placeholder mapping — the real
 * implementation should inspect typed error classes from the deploy client.
 */
function classifyError(err: unknown): ExitCode {
  if (!(err instanceof Error)) return ExitCode.FAILURE;
  const name = err.name.toLowerCase();
  if (name.includes('timeout') || name.includes('network')) return ExitCode.TEMPFAIL;
  if (name.includes('unavailable') || name.includes('503')) return ExitCode.UNAVAILABLE;
  return ExitCode.FAILURE;
}

// ---------------------------------------------------------------------------
// Program construction — commander.js setup.
// ---------------------------------------------------------------------------

/**
 * Build the top-level `shipit` program with `deploy` as a subcommand.
 * Exposed as a function so tests can build a fresh program per assertion.
 */
export function buildProgram(): Command {
  const program = new Command('shipit')
    .description('Internal deploy tool for the ops team.')
    .version('0.1.0', '-V, --version', 'show version and exit')
    // Global flags propagate to subcommands. Rule: struct-flag-order-independent
    .option('-v, --verbose', 'verbose output to stderr')
    .option('-q, --quiet', 'suppress non-essential output')
    .option('--no-color', 'disable ANSI color (also honors NO_COLOR env var)')
    .option('--debug', 'print stack traces on error (also: SHIPIT_DEBUG=1)')
    .enablePositionalOptions(false)
    .allowExcessArguments(false)
    // Rule: help-no-flag-required — `shipit` with no args prints help.
    .action(() => {
      program.outputHelp();
      process.exit(ExitCode.OK);
    });

  // Rule: help-layered-discovery — top-level help is a TOC. Commander
  // auto-generates the Commands section from the registered subcommands, so
  // we only need to append discovery hints and env-var docs afterward.
  program.addHelpText(
    'after',
    [
      '',
      'Run "shipit <command> --help" for details on a specific command.',
      '  shipit deploy --help',
      '',
      'Environment variables:',
      '  SHIPIT_ENV       default target environment (overridden by --env)',
      '  SHIPIT_SERVICE   default service name (overridden by --service)',
      '  SHIPIT_NO_INPUT  when set to "1", disables all prompts',
      '  SHIPIT_DEBUG     when set to "1", prints stack traces on error',
      '  NO_COLOR         when set (any non-empty value), disables ANSI color',
      '',
    ].join('\n'),
  );

  // ---- deploy subcommand --------------------------------------------------
  const deploy = program
    .command('deploy')
    .description('Deploy a service to a target environment using an image tag.')
    .summary('Deploy a service to an environment')
    // Rules: input-flags-over-positional, interact-flags-first,
    // err-exit-fast-on-missing-required, input-env-var-fallback
    .addOption(
      new Option('-s, --service <name>', 'service name to deploy')
        .env('SHIPIT_SERVICE')
        .argParser(validateService)
        .makeOptionMandatory(true),
    )
    .addOption(
      // Using .choices() + .makeOptionMandatory() gives fail-fast validation
      // at parse time with both "missing" and "invalid value" signalled via
      // distinct CommanderError codes that we rewrite in main().
      new Option('-e, --env <env>', `target environment (${VALID_ENVS.join('|')})`)
        .env('SHIPIT_ENV')
        .choices(VALID_ENVS as unknown as string[])
        .makeOptionMandatory(true),
    )
    .addOption(
      new Option('-t, --tag <tag>', 'image tag to deploy, e.g. v1.2.3')
        .argParser(validateTag)
        .makeOptionMandatory(true),
    )
    // Rule: safe-dry-run-flag
    .option('-n, --dry-run', 'show the plan without applying changes', false)
    // Rule: safe-force-bypass-flag
    .option('-y, --yes', 'skip confirmation; required for production in non-TTY mode', false)
    // Rule: output-json-flag
    .option('--json', 'emit a single JSON record on stdout (stable contract)', false)
    // Rule: interact-no-input-flag. Commander parses `--no-input` as negation
    // of an implicit `--input` flag — the parsed option key is `input` and
    // `--no-input` sets it to false. Default is `true` (input allowed), so
    // when `--no-input` is passed (or SHIPIT_NO_INPUT=1), `opts.input` is
    // false and we treat that as non-interactive mode.
    .addOption(
      new Option('--no-input', 'disable all prompts; fail on missing values')
        .env('SHIPIT_NO_INPUT')
        .default(true),
    )
    .action(deployAction);

  // Rule: help-examples-in-help + help-suggest-next-steps + help-flag-summary.
  // Examples section is copy-pasteable and covers the common cases.
  deploy.addHelpText(
    'after',
    [
      '',
      'Examples:',
      '  # Preview a staging deploy (safe, no changes applied)',
      '  shipit deploy --service api --env staging --tag v1.2.3 --dry-run',
      '',
      '  # Deploy to staging',
      '  shipit deploy --service api --env staging --tag v1.2.3',
      '',
      '  # Deploy to production (confirmation required via --yes)',
      '  shipit deploy --service api --env production --tag v1.2.3 --yes',
      '',
      '  # Emit a JSON record for chaining into another command',
      '  shipit deploy --service api --env staging --tag v1.2.3 --yes --json',
      '',
      '  # Set env/service once via environment variables',
      '  SHIPIT_ENV=staging SHIPIT_SERVICE=api shipit deploy --tag v1.2.3 --yes',
      '',
      'Exit codes:',
      '  0   deploy succeeded (or --dry-run preview printed)',
      '  1   deploy failed (generic runtime failure)',
      '  2   usage error — fix the command and retry',
      '  69  deploy service unavailable — do not retry immediately',
      '  75  transient failure — safe to retry with backoff',
      '',
      'See also:',
      '  shipit deploy status --id <deploy_id>   check a running deploy',
      '  shipit deploy rollback --id <deploy_id> roll back to the previous tag',
      '  shipit logs --service <name> --env <env> --tail 100',
      '',
    ].join('\n'),
  );

  return program;
}

// ---------------------------------------------------------------------------
// Entry point — wire exitOverride to produce actionable errors on parse
// failures, and parse argv. Rule: err-actionable-fix, err-include-example-invocation
// ---------------------------------------------------------------------------

export async function main(argv: string[] = process.argv): Promise<void> {
  const program = buildProgram();

  // Commander throws CommanderError for parse failures; we intercept to
  // rewrite the message with a concrete fix + example invocation. Configure
  // output so commander does not print its own red "error:" line before we
  // take over — we want a single, clean error block, not a duplicate.
  const swallow = () => {}; //  discard commander's built-in error writes
  program.exitOverride().configureOutput({ writeErr: swallow });
  for (const sub of program.commands) {
    sub.exitOverride().configureOutput({ writeErr: swallow });
  }

  // Detect --no-color early so error formatting honors it even on parse errors.
  const earlyNoColor = argv.includes('--no-color');
  const colorize = useColor(earlyNoColor);

  try {
    await program.parseAsync(argv);
  } catch (err) {
    if (!(err instanceof CommanderError)) {
      emitError(
        {
          message: err instanceof Error ? err.message : String(err),
          fix: ['Re-run with --debug (or SHIPIT_DEBUG=1) to see the stack trace.'],
          code: ExitCode.FAILURE,
        },
        colorize,
      );
      if (process.env.SHIPIT_DEBUG === '1' && err instanceof Error && err.stack) {
        process.stderr.write(`\n${err.stack}\n`);
      }
      process.exit(ExitCode.FAILURE);
    }

    // CommanderError: map well-known codes to actionable messages.
    const code = err.code;

    // --help / --version exit cleanly with 0.
    if (code === 'commander.helpDisplayed' || code === 'commander.help' ||
        code === 'commander.version') {
      process.exit(ExitCode.OK);
    }

    // Zero-arg top-level invocation → commander prints help via our .action(),
    // but it can also reach here via `commander.help`. Treat as success.
    if (code === 'commander.helpDisplayed') {
      process.exit(ExitCode.OK);
    }

    if (code === 'commander.missingMandatoryOptionValue') {
      emitError(
        {
          message: err.message,
          fix: [
            '--service, --env, and --tag are all required.',
            'You can also set SHIPIT_SERVICE and SHIPIT_ENV once via environment variables.',
          ],
          examples: [
            'shipit deploy --service api --env staging --tag v1.2.3',
            'shipit deploy --service api --env production --tag v1.2.3 --yes',
            'SHIPIT_ENV=staging SHIPIT_SERVICE=api shipit deploy --tag v1.2.3',
          ],
          code: ExitCode.USAGE,
        },
        colorize,
      );
      process.exit(ExitCode.USAGE);
    }

    if (
      code === 'shipit.invalidTag' ||
      code === 'shipit.invalidService' ||
      code === 'commander.invalidArgument' ||
      code === 'commander.invalidOptionArgument'
    ) {
      emitError(
        {
          message: err.message,
          fix: [
            `Valid environments: ${VALID_ENVS.join(', ')}.`,
            'Service names must match [a-z0-9][a-z0-9-]*.',
            'Tags must contain no whitespace or shell metacharacters.',
          ],
          examples: [
            'shipit deploy --service api --env staging --tag v1.2.3',
            'shipit deploy --service billing-api --env canary --tag v2.0.0-rc1',
          ],
          code: ExitCode.USAGE,
        },
        colorize,
      );
      process.exit(ExitCode.USAGE);
    }

    if (code === 'commander.unknownCommand' || code === 'commander.unknownOption') {
      emitError(
        {
          message: err.message,
          fix: ['Run "shipit --help" to see available commands and flags.'],
          examples: ['shipit --help', 'shipit deploy --help'],
          code: ExitCode.USAGE,
        },
        colorize,
      );
      process.exit(ExitCode.USAGE);
    }

    // Fallback: any other CommanderError is a usage problem by definition.
    emitError(
      {
        message: err.message || 'usage error',
        fix: ['Run "shipit deploy --help" for usage.'],
        code: ExitCode.USAGE,
      },
      colorize,
    );
    process.exit(ExitCode.USAGE);
  }
}

// Only run main() when invoked as a script, not when imported for testing.
// `require.main === module` check adapted for both CJS and ESM builds.
const isDirectRun =
  typeof require !== 'undefined' && typeof module !== 'undefined' && require.main === module;

if (isDirectRun) {
  main().catch((err) => {
    process.stderr.write(`fatal: ${err instanceof Error ? err.message : String(err)}\n`);
    process.exit(ExitCode.FAILURE);
  });
}
