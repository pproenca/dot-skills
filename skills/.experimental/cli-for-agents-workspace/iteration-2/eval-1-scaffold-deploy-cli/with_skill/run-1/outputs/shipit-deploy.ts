#!/usr/bin/env node
/**
 * shipit deploy — agent-friendly deploy subcommand
 *
 * Designed to be invoked by humans at a prompt AND by Claude agents in CI
 * pipelines. Implements the cli-for-agents rules for exit codes, idempotency,
 * color gating, and chainable success output.
 */

import { Command, Option } from 'commander';
import { createHash } from 'crypto';

// ---------------------------------------------------------------------------
// Exit codes (sysexits.h taxonomy). Agents branch on these — do not renumber.
// ---------------------------------------------------------------------------
const EX_OK = 0;        // success
const EX_FAILURE = 1;   // generic runtime failure
const EX_USAGE = 2;     // usage / input error — do not retry, fix the command
const EX_TEMPFAIL = 75; // sysexits.h EX_TEMPFAIL — transient, retry with backoff

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------
interface DeployOptions {
  service: string;
  env: string;
  tag: string;
  idempotencyKey?: string;
  deploymentId?: string;
  dryRun?: boolean;
  yes?: boolean;
  json?: boolean;
  color?: boolean; // commander negates --no-color into `color: false`
  verbose?: boolean;
}

interface DeployResult {
  deploy_id: string;
  idempotency_key: string;
  service: string;
  env: string;
  tag: string;
  changed: boolean;
  status: 'succeeded' | 'skipped' | 'dry-run';
  url: string;
}

class TransientError extends Error {
  readonly transient = true;
}

// ---------------------------------------------------------------------------
// Color gating — honor NO_COLOR env var (non-empty), --no-color flag, and TTY
// ---------------------------------------------------------------------------
function useColor(colorFlag: boolean | undefined, stream: NodeJS.WriteStream): boolean {
  if (colorFlag === false) return false; // --no-color passed
  const noColor = process.env.NO_COLOR;
  if (noColor !== undefined && noColor !== '') return false; // no-color.org spec
  return Boolean(stream.isTTY);
}

function red(s: string, on: boolean): string {
  return on ? `\x1b[31m${s}\x1b[0m` : s;
}

function green(s: string, on: boolean): string {
  return on ? `\x1b[32m${s}\x1b[0m` : s;
}

// ---------------------------------------------------------------------------
// Idempotency key derivation — deterministic when caller omits it
// ---------------------------------------------------------------------------
function deriveIdempotencyKey(service: string, env: string, tag: string): string {
  // Short deterministic digest so retries with the same inputs hit the same deploy.
  const digest = createHash('sha256')
    .update(`${service}:${env}:${tag}`)
    .digest('hex')
    .slice(0, 16);
  return `${service}-${env}-${tag}-${digest}`;
}

// ---------------------------------------------------------------------------
// Stub deploy implementation
// ---------------------------------------------------------------------------
async function runDeploy(
  opts: Pick<DeployOptions, 'service' | 'env' | 'tag' | 'dryRun'> & { idempotencyKey: string }
): Promise<DeployResult> {
  // TODO: wire to real deploy API. Must send Idempotency-Key header so that a
  // retry with the same key returns the original deployment instead of minting
  // a new one (RFC draft-ietf-httpapi-idempotency-key-header).
  return {
    deploy_id: `dep_${opts.idempotencyKey.slice(-12)}`,
    idempotency_key: opts.idempotencyKey,
    service: opts.service,
    env: opts.env,
    tag: opts.tag,
    changed: !opts.dryRun,
    status: opts.dryRun ? 'dry-run' : 'succeeded',
    url: `https://shipit.example.com/deploys/dep_${opts.idempotencyKey.slice(-12)}`,
  };
}

// ---------------------------------------------------------------------------
// Output helpers
// ---------------------------------------------------------------------------
function emitSuccess(result: DeployResult, opts: DeployOptions): void {
  const colorize = useColor(opts.color, process.stdout);

  if (opts.json) {
    // Machine-readable — single JSON object on stdout, nothing else.
    process.stdout.write(JSON.stringify(result) + '\n');
    return;
  }

  // Human-readable — chainable values plus a next-step suggestion.
  const ok = green('OK', colorize);
  process.stdout.write(`${ok} deploy ${result.status}\n`);
  process.stdout.write(`  deploy_id       ${result.deploy_id}\n`);
  process.stdout.write(`  service         ${result.service}\n`);
  process.stdout.write(`  env             ${result.env}\n`);
  process.stdout.write(`  tag             ${result.tag}\n`);
  process.stdout.write(`  idempotency_key ${result.idempotency_key}\n`);
  process.stdout.write(`  url             ${result.url}\n`);
  process.stdout.write('\n');
  process.stdout.write(`Next: shipit deploy verify --id ${result.deploy_id}\n`);
}

function emitError(message: string, example: string, code: number, opts?: Partial<DeployOptions>): never {
  const colorize = useColor(opts?.color, process.stderr);
  const label = red('Error:', colorize);
  process.stderr.write(`${label} ${message}\n`);
  process.stderr.write(`  Try: ${example}\n`);
  process.exit(code);
}

// ---------------------------------------------------------------------------
// Command definition
// ---------------------------------------------------------------------------
const program = new Command();

program
  .name('shipit deploy')
  .description('Deploy a service tag to an environment. Idempotent on --idempotency-key.')
  .requiredOption('-s, --service <name>', 'service to deploy (e.g. api, web)')
  .requiredOption('-e, --env <env>', 'target environment (e.g. staging, prod)')
  .requiredOption('-t, --tag <tag>', 'image tag or git sha to deploy')
  .option(
    '-k, --idempotency-key <key>',
    'caller-supplied key; retries with the same key hit the same deploy'
  )
  .option(
    '--deployment-id <id>',
    'alias for --idempotency-key (for callers that think in deployment IDs)'
  )
  .option('-n, --dry-run', 'plan the deploy without applying it', false)
  .option('-y, --yes', 'skip confirmation prompts (required in non-TTY)', false)
  .option('--json', 'emit machine-readable JSON on stdout', false)
  .addOption(
    new Option('--no-color', 'disable ANSI color (also honors NO_COLOR env var)')
  )
  .option('-v, --verbose', 'verbose progress on stderr', false)
  .addHelpText(
    'after',
    `
Environment:
  NO_COLOR           When set to any non-empty value, disables ANSI color.

Exit codes:
  0   Deploy succeeded (or was a no-op retry).
  1   Runtime failure — inspect stderr, consider retry.
  2   Usage error — fix flags before retrying.
  75  Transient failure (EX_TEMPFAIL) — safe to retry with backoff.

Examples:
  # Minimal human invocation
  $ shipit deploy --service api --env staging --tag v1.4.2

  # CI / agent invocation with explicit idempotency key and JSON output
  $ shipit deploy \\
      --service api --env prod --tag v1.4.2 \\
      --idempotency-key "release-2026-04-12-api" \\
      --json --yes --no-color

  # Dry-run to preview a production deploy
  $ shipit deploy --service api --env prod --tag v1.4.2 --dry-run --json

  # Chain into verify using the deploy_id from --json output
  $ ID=$(shipit deploy -s api -e prod -t v1.4.2 --json | jq -r .deploy_id)
  $ shipit deploy verify --id "$ID"
`
  );

// ---------------------------------------------------------------------------
// Action handler
// ---------------------------------------------------------------------------
program.action(async (rawOpts: DeployOptions) => {
  const opts = rawOpts;

  // Cross-flag validation (commander handles missing required flags for us,
  // but we still want actionable errors for semantic mistakes).
  if (opts.idempotencyKey && opts.deploymentId && opts.idempotencyKey !== opts.deploymentId) {
    emitError(
      '--idempotency-key and --deployment-id were both set to different values.',
      'shipit deploy --service api --env prod --tag v1.4.2 --idempotency-key release-2026-04-12',
      EX_USAGE,
      opts
    );
  }

  // Derive a stable idempotency key when the caller omits one. Retries with
  // the same service/env/tag will map to the same deploy on the server side.
  const idempotencyKey =
    opts.idempotencyKey ??
    opts.deploymentId ??
    deriveIdempotencyKey(opts.service, opts.env, opts.tag);

  if (opts.verbose) {
    process.stderr.write(
      `[shipit] service=${opts.service} env=${opts.env} tag=${opts.tag} key=${idempotencyKey}\n`
    );
  }

  // Destructive-action guard: prod deploys require --yes in non-TTY contexts.
  if (opts.env === 'prod' && !opts.yes && !opts.dryRun && !process.stdin.isTTY) {
    emitError(
      'prod deploys require --yes when running non-interactively.',
      `shipit deploy --service ${opts.service} --env prod --tag ${opts.tag} --yes`,
      EX_USAGE,
      opts
    );
  }

  try {
    const result = await runDeploy({
      service: opts.service,
      env: opts.env,
      tag: opts.tag,
      dryRun: opts.dryRun,
      idempotencyKey,
    });
    emitSuccess(result, opts);
    process.exit(EX_OK);
  } catch (err) {
    if (err instanceof TransientError) {
      emitError(
        `transient failure: ${err.message}`,
        `shipit deploy --service ${opts.service} --env ${opts.env} --tag ${opts.tag} --idempotency-key ${idempotencyKey}`,
        EX_TEMPFAIL,
        opts
      );
    }
    const message = err instanceof Error ? err.message : String(err);
    emitError(
      `deploy failed: ${message}`,
      `shipit deploy --service ${opts.service} --env ${opts.env} --tag ${opts.tag} --idempotency-key ${idempotencyKey} --verbose`,
      EX_FAILURE,
      opts
    );
  }
});

// Commander's built-in error handler writes to stderr but exits 1; override
// so that usage errors (missing required flags, unknown flags) exit with
// EX_USAGE (2) instead.
program.exitOverride((err) => {
  if (
    err.code === 'commander.missingMandatoryOptionValue' ||
    err.code === 'commander.missingArgument' ||
    err.code === 'commander.unknownOption' ||
    err.code === 'commander.invalidOptionArgument' ||
    err.code === 'commander.unknownCommand'
  ) {
    process.stderr.write(
      `  Try: shipit deploy --service api --env staging --tag v1.4.2 --help\n`
    );
    process.exit(EX_USAGE);
  }
  if (err.code === 'commander.helpDisplayed' || err.code === 'commander.help') {
    process.exit(EX_OK);
  }
  process.exit(EX_FAILURE);
});

// Show help instead of hanging when invoked with zero arguments.
if (process.argv.length <= 2) {
  program.outputHelp();
  process.exit(EX_OK);
}

program.parseAsync(process.argv).catch((err) => {
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`Error: ${message}\n`);
  process.exit(EX_FAILURE);
});

export { deriveIdempotencyKey, runDeploy, useColor, EX_OK, EX_FAILURE, EX_USAGE, EX_TEMPFAIL };
