"""
flagctl - feature flag management CLI.

Agent-friendly refactor. Every input is a flag; there are no interactive
fallbacks. All destructive actions support --dry-run and --yes. Machine-
readable output is available via --json on every command.

Examples:
    flagctl list
    flagctl list --json --limit 100
    flagctl create --name checkout-v2 --description "..." --owner a@b.io
    flagctl toggle --name checkout-v2 --state on --yes
    flagctl delete --name checkout-v2 --confirm checkout-v2 --yes
"""
from __future__ import annotations

import json
import os
import sys
import traceback
import urllib.error
import urllib.request
from typing import Any

import click

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

API_BASE = os.environ.get("FLAGCTL_API_BASE", "https://flags.internal.example.com/v1")
API_TIMEOUT_SECONDS = 15

VALID_STATES = ("on", "off")
DEFAULT_LIMIT = 50

# sysexits.h-compatible exit codes.
# Code 2 = usage error (fix input, do not retry blindly).
# Code 1 = generic runtime failure.
# Code 69 = EX_UNAVAILABLE — upstream service cannot be reached.
# Code 75 = EX_TEMPFAIL — transient failure, retry with backoff.
EXIT_OK = 0
EXIT_FAILURE = 1
EXIT_USAGE = 2
EXIT_UNAVAILABLE = 69
EXIT_TEMPFAIL = 75


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------


def _no_color() -> bool:
    """Return True when color must be disabled.

    Honors the no-color.org spec (any non-empty NO_COLOR disables color) and
    also disables color whenever stdout is not a TTY so that regex-based
    agent parsers never see escape sequences.
    """
    if os.environ.get("NO_COLOR"):
        return True
    if not sys.stdout.isatty():
        return True
    return False


def echo_err(message: str) -> None:
    """Write a diagnostic line to stderr. Never touches stdout."""
    click.echo(message, err=True)


def echo_out(message: str) -> None:
    """Write a data line to stdout."""
    click.echo(message)


def print_error(
    message: str,
    *,
    examples: list[str] | None = None,
    debug_exc: BaseException | None = None,
) -> None:
    """Emit a standard, actionable error block on stderr.

    Every error follows the same shape: a one-line "Error:" message, then an
    indented example invocation or two. Stack traces are only shown when
    FLAGCTL_DEBUG=1 is set; the default output stays small and parseable.
    """
    echo_err(f"Error: {message}")
    if examples:
        for example in examples:
            echo_err(f"  {example}")
    if debug_exc is not None and os.environ.get("FLAGCTL_DEBUG"):
        echo_err("")
        echo_err("".join(traceback.format_exception(debug_exc)).rstrip())


# ---------------------------------------------------------------------------
# HTTP layer
# ---------------------------------------------------------------------------


class ApiError(click.ClickException):
    """CLI-level API failure with a precomputed exit code."""

    def __init__(self, message: str, exit_code: int = EXIT_FAILURE) -> None:
        super().__init__(message)
        self.exit_code = exit_code

    def show(self, file: Any = None) -> None:  # type: ignore[override]
        # click's default prints "Error: <msg>" to stderr, which is exactly
        # what we want — keep it consistent with print_error() formatting.
        echo_err(f"Error: {self.message}")


def api_request(
    method: str,
    path: str,
    data: dict[str, Any] | None = None,
) -> Any:
    """Make a JSON API request and return the parsed body.

    Raises ApiError with a classified exit code so the command layer can
    surface the right signal to the agent (69 = unavailable, 75 = transient,
    1 = generic failure, 2 = usage-style rejection from the server).
    """
    url = f"{API_BASE}{path}"
    body: bytes | None = None
    headers = {"Accept": "application/json"}
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        headers["Content-Type"] = "application/json"

    request = urllib.request.Request(url, data=body, method=method, headers=headers)

    try:
        with urllib.request.urlopen(request, timeout=API_TIMEOUT_SECONDS) as resp:
            raw = resp.read()
            if not raw:
                return None
            return json.loads(raw)
    except urllib.error.HTTPError as http_err:
        status = http_err.code
        # 404 is not always an error — callers handle it explicitly.
        if status == 404:
            raise ApiError(f"not found: {method} {path}", exit_code=EXIT_FAILURE) from http_err
        if status in (400, 409, 422):
            # Client errors — caller should fix inputs, don't retry.
            detail = _safe_detail(http_err)
            raise ApiError(
                f"{method} {path} rejected: {status} {detail}",
                exit_code=EXIT_USAGE,
            ) from http_err
        if status in (429, 502, 503, 504):
            # Transient upstream trouble — agents should retry with backoff.
            raise ApiError(
                f"{method} {path} transient failure: {status}",
                exit_code=EXIT_TEMPFAIL,
            ) from http_err
        raise ApiError(
            f"{method} {path} failed: {status} {_safe_detail(http_err)}",
            exit_code=EXIT_FAILURE,
        ) from http_err
    except urllib.error.URLError as url_err:
        raise ApiError(
            f"cannot reach API at {API_BASE}: {url_err.reason}",
            exit_code=EXIT_UNAVAILABLE,
        ) from url_err
    except TimeoutError as timeout_err:
        raise ApiError(
            f"timed out talking to {API_BASE} after {API_TIMEOUT_SECONDS}s",
            exit_code=EXIT_TEMPFAIL,
        ) from timeout_err
    except json.JSONDecodeError as json_err:
        raise ApiError(
            f"malformed JSON response from {method} {path}",
            exit_code=EXIT_FAILURE,
        ) from json_err


def _safe_detail(http_err: urllib.error.HTTPError) -> str:
    """Best-effort extract a short error message from an HTTPError body."""
    try:
        raw = http_err.read()
        if not raw:
            return ""
        try:
            payload = json.loads(raw)
            if isinstance(payload, dict):
                for key in ("error", "message", "detail"):
                    if key in payload and isinstance(payload[key], str):
                        return payload[key]
            return str(payload)
        except json.JSONDecodeError:
            return raw.decode("utf-8", errors="replace").strip()[:200]
    except Exception:
        return ""


# ---------------------------------------------------------------------------
# Presentation helpers
# ---------------------------------------------------------------------------


def emit_record(
    record: dict[str, Any],
    *,
    as_json: bool,
    human_lines: list[str] | None = None,
    next_steps: list[str] | None = None,
) -> None:
    """Print a single record.

    JSON mode: one object on stdout, nothing else.
    Human mode: the provided lines on stdout, optional "Next:" hints on stderr
    so they never contaminate a piped pipeline.
    """
    if as_json:
        echo_out(json.dumps(record))
        return

    if human_lines:
        for line in human_lines:
            echo_out(line)
    if next_steps:
        echo_err("")
        echo_err("Next:")
        for step in next_steps:
            echo_err(f"  {step}")


def emit_list(
    records: list[dict[str, Any]],
    *,
    as_json: bool,
    truncated: bool,
    limit: int,
) -> None:
    """Print a list of records.

    Human mode: one record per line, tab-separated, with a fixed header line
    on stdout. Grep/awk/cut all work against it.

    JSON mode: NDJSON — one object per line — so agents can stream huge
    lists without buffering the whole thing.
    """
    if as_json:
        for record in records:
            echo_out(json.dumps(record))
        if truncated:
            echo_err(
                f"(showing first {limit} records; pass --limit <n> or --all for more)"
            )
        return

    echo_out("NAME\tSTATE\tUPDATED\tOWNER")
    for record in records:
        name = str(record.get("name", ""))
        state = str(record.get("state", ""))
        updated = str(record.get("updated", ""))
        owner = str(record.get("owner", ""))
        # Guard against embedded newlines/tabs breaking the per-line contract.
        owner = owner.replace("\t", " ").replace("\n", " ")
        echo_out(f"{name}\t{state}\t{updated}\t{owner}")

    if truncated:
        echo_err(
            f"(showing first {limit} records; pass --limit <n> or --all for more)"
        )


# ---------------------------------------------------------------------------
# Root command group
# ---------------------------------------------------------------------------

HELP_EPILOG = """\

Environment:
  FLAGCTL_API_BASE   API base URL (default: https://flags.internal.example.com/v1)
  FLAGCTL_NO_INPUT   Set to 1 to force non-interactive mode (same as --no-input)
  FLAGCTL_DEBUG      Set to 1 to print stack traces on unexpected errors
  NO_COLOR           Set to any non-empty value to disable colored output

Examples:
  flagctl list
  flagctl create --name checkout-v2 --description "New checkout" --owner a@b.io
  flagctl toggle --name checkout-v2 --state on --yes
  flagctl delete --name checkout-v2 --confirm checkout-v2 --yes

Run "flagctl <command> --help" for per-command help and examples.
"""


class _OrderedGroup(click.Group):
    """Keep subcommand help listing in a stable, documented order."""

    def list_commands(self, ctx: click.Context) -> list[str]:
        return ["list", "get", "create", "toggle", "delete"]


@click.group(
    cls=_OrderedGroup,
    invoke_without_command=True,
    context_settings={
        "help_option_names": ["-h", "--help"],
        "max_content_width": 100,
    },
    epilog=HELP_EPILOG,
)
@click.version_option(version="2.0.0", prog_name="flagctl")
@click.option(
    "--no-input",
    "no_input",
    is_flag=True,
    envvar="FLAGCTL_NO_INPUT",
    help="Disable all interactive prompts; fail fast on missing values (env: FLAGCTL_NO_INPUT).",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit machine-readable JSON on stdout.",
)
@click.pass_context
def cli(ctx: click.Context, no_input: bool, json_out: bool) -> None:
    """Manage feature flags.

    flagctl is a headless-friendly CLI for listing, creating, toggling, and
    deleting feature flags. Every input is a flag — there are no interactive
    prompts by default — and every destructive command supports --dry-run
    and --yes. Use --json on any command for stable machine-readable output.

    \b
    Commands:
      list     List feature flags (bounded by --limit)
      get      Show a single flag
      create   Create a flag (idempotent: skips if already present)
      toggle   Set a flag's state to on or off
      delete   Delete a flag (requires --confirm and --yes)
    """
    ctx.ensure_object(dict)
    ctx.obj["no_input"] = no_input
    ctx.obj["json"] = json_out

    if ctx.invoked_subcommand is None:
        # Zero-arg invocation is safe: print help and exit 0.
        echo_out(ctx.get_help())
        ctx.exit(EXIT_OK)


# ---------------------------------------------------------------------------
# list
# ---------------------------------------------------------------------------


@cli.command("list")
@click.option(
    "-l",
    "--limit",
    type=click.IntRange(min=1),
    default=DEFAULT_LIMIT,
    show_default=True,
    help="Maximum records to return. Use --all to get every record.",
)
@click.option(
    "--all",
    "all_records",
    is_flag=True,
    help="Return every record (may be large). Overrides --limit.",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit NDJSON (one object per line) on stdout.",
)
@click.pass_context
def cmd_list(ctx: click.Context, limit: int, all_records: bool, json_out: bool) -> None:
    """List feature flags.

    \b
    Examples:
      flagctl list
      flagctl list --limit 10
      flagctl list --all --json
      flagctl list --json | jq '.[] | select(.state=="on") | .name'

    \b
    See also:
      flagctl get --name <name>        show a single flag
      flagctl toggle --name <name>     change a flag's state
    """
    json_out = json_out or bool(ctx.obj.get("json"))

    try:
        flags = api_request("GET", "/flags")
    except ApiError as err:
        err.show()
        ctx.exit(err.exit_code)

    if flags is None:
        flags = []
    if not isinstance(flags, list):
        print_error(
            f"unexpected list response shape from {API_BASE}/flags",
            examples=["flagctl list --json"],
        )
        ctx.exit(EXIT_FAILURE)

    truncated = False
    if not all_records and len(flags) > limit:
        flags = flags[:limit]
        truncated = True

    emit_list(flags, as_json=json_out, truncated=truncated, limit=limit)


# ---------------------------------------------------------------------------
# get
# ---------------------------------------------------------------------------


@cli.command("get")
@click.option(
    "-n",
    "--name",
    required=True,
    help="Flag name to fetch.",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit the flag as a single JSON object on stdout.",
)
@click.pass_context
def cmd_get(ctx: click.Context, name: str, json_out: bool) -> None:
    """Show a single feature flag.

    \b
    Examples:
      flagctl get --name checkout-v2
      flagctl get --name checkout-v2 --json

    \b
    See also:
      flagctl list                     list all flags
      flagctl toggle --name <name>     change a flag's state
    """
    json_out = json_out or bool(ctx.obj.get("json"))

    name = name.strip()
    if not name:
        print_error(
            "--name must not be empty.",
            examples=["flagctl get --name checkout-v2"],
        )
        ctx.exit(EXIT_USAGE)

    try:
        flag = api_request("GET", f"/flags/{name}")
    except ApiError as err:
        if "not found" in err.message:
            print_error(
                f"flag '{name}' does not exist.",
                examples=[
                    "flagctl list                           # see all flags",
                    f"flagctl create --name {name} --description '...' --owner you@example.com",
                ],
            )
            ctx.exit(EXIT_FAILURE)
        err.show()
        ctx.exit(err.exit_code)

    if not isinstance(flag, dict):
        print_error(f"unexpected response shape for flag '{name}'")
        ctx.exit(EXIT_FAILURE)

    emit_record(
        flag,
        as_json=json_out,
        human_lines=[
            f"name:        {flag.get('name', '')}",
            f"state:       {flag.get('state', '')}",
            f"description: {flag.get('description', '')}",
            f"owner:       {flag.get('owner', '')}",
            f"updated:     {flag.get('updated', '')}",
        ],
        next_steps=[
            f"flagctl toggle --name {flag.get('name', name)} --state on --yes",
            f"flagctl delete --name {flag.get('name', name)} --confirm {flag.get('name', name)} --yes",
        ],
    )


# ---------------------------------------------------------------------------
# create
# ---------------------------------------------------------------------------


@cli.command("create")
@click.option(
    "-n",
    "--name",
    required=True,
    help="Flag name (the stable identifier; must be unique).",
)
@click.option(
    "-d",
    "--description",
    required=True,
    help="Human-readable description.",
)
@click.option(
    "-o",
    "--owner",
    required=True,
    envvar="FLAGCTL_OWNER",
    help="Owner email (env: FLAGCTL_OWNER).",
)
@click.option(
    "--state",
    type=click.Choice(VALID_STATES, case_sensitive=False),
    default="off",
    show_default=True,
    help="Initial state.",
)
@click.option(
    "--dry-run",
    "dry_run",
    is_flag=True,
    help="Show what would be created without hitting the API.",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit the created (or existing) flag as a single JSON object.",
)
@click.pass_context
def cmd_create(
    ctx: click.Context,
    name: str,
    description: str,
    owner: str,
    state: str,
    dry_run: bool,
    json_out: bool,
) -> None:
    """Create a feature flag (idempotent).

    If a flag with the same name already exists with the same description
    and owner, the command is a successful no-op and the output shape is the
    same as on a fresh create — so downstream pipelines work on every run.

    \b
    Examples:
      flagctl create --name checkout-v2 --description "New checkout" --owner a@b.io
      flagctl create --name checkout-v2 --description "..." --owner a@b.io --state on
      flagctl create --name checkout-v2 --description "..." --owner a@b.io --dry-run
      flagctl create --name checkout-v2 --description "..." --owner a@b.io --json

    \b
    See also:
      flagctl list                     see existing flags
      flagctl toggle --name <name>     change state after creation
    """
    json_out = json_out or bool(ctx.obj.get("json"))
    state = state.lower()

    name = name.strip()
    if not name:
        print_error(
            "--name must not be empty.",
            examples=[
                "flagctl create --name checkout-v2 --description '...' --owner a@b.io",
            ],
        )
        ctx.exit(EXIT_USAGE)

    if "@" not in owner:
        print_error(
            f"--owner '{owner}' does not look like an email address.",
            examples=[
                f"flagctl create --name {name} --description '...' --owner you@example.com",
            ],
        )
        ctx.exit(EXIT_USAGE)

    payload = {
        "name": name,
        "description": description,
        "owner": owner,
        "state": state,
    }

    if dry_run:
        _emit_create_result(payload, created=True, dry_run=True, as_json=json_out)
        ctx.exit(EXIT_OK)

    # Idempotency check: GET before POST so a retry becomes a no-op instead
    # of a duplicate, and so a conflict is surfaced with an actionable fix.
    try:
        existing = api_request("GET", f"/flags/{name}")
    except ApiError as err:
        if "not found" in err.message:
            existing = None
        else:
            err.show()
            ctx.exit(err.exit_code)

    if existing is not None:
        if not isinstance(existing, dict):
            print_error(f"unexpected response shape for flag '{name}'")
            ctx.exit(EXIT_FAILURE)
        if _conflicting(existing, payload):
            diffs = _describe_diff(existing, payload)
            print_error(
                f"flag '{name}' already exists with different values: {diffs}.",
                examples=[
                    f"flagctl get --name {name}",
                    f"flagctl toggle --name {name} --state {state} --yes",
                ],
            )
            ctx.exit(EXIT_USAGE)
        _emit_create_result(existing, created=False, dry_run=False, as_json=json_out)
        ctx.exit(EXIT_OK)

    try:
        result = api_request("POST", "/flags", data=payload)
    except ApiError as err:
        err.show()
        ctx.exit(err.exit_code)

    if not isinstance(result, dict):
        result = payload
    _emit_create_result(result, created=True, dry_run=False, as_json=json_out)


def _conflicting(existing: dict[str, Any], desired: dict[str, Any]) -> bool:
    for key in ("description", "owner"):
        if existing.get(key) not in (None, "", desired.get(key)):
            return True
    return False


def _describe_diff(existing: dict[str, Any], desired: dict[str, Any]) -> str:
    parts = []
    for key in ("description", "owner"):
        if existing.get(key) not in (None, "", desired.get(key)):
            parts.append(f"{key}='{existing.get(key)}' (desired '{desired.get(key)}')")
    return ", ".join(parts)


def _emit_create_result(
    record: dict[str, Any],
    *,
    created: bool,
    dry_run: bool,
    as_json: bool,
) -> None:
    """Standard output shape for create. Same fields whether we acted or not.

    The `changed` field mirrors Ansible/Terraform semantics so downstream
    callers can still branch on "did work happen" without branching on the
    whole output shape.
    """
    enriched = dict(record)
    enriched.setdefault("name", record.get("name"))
    enriched.setdefault("state", record.get("state"))
    enriched["changed"] = created and not dry_run
    enriched["dry_run"] = dry_run

    name = record.get("name", "")
    state = record.get("state", "")
    verb = "would create" if dry_run else ("created" if created else "unchanged")

    next_steps = [
        f"flagctl toggle --name {name} --state on --yes",
        f"flagctl get --name {name}",
    ]

    emit_record(
        enriched,
        as_json=as_json,
        human_lines=[
            f"{verb} {name}",
            f"name:        {name}",
            f"state:       {state}",
            f"description: {record.get('description', '')}",
            f"owner:       {record.get('owner', '')}",
            f"changed:     {str(enriched['changed']).lower()}",
            f"dry_run:     {str(dry_run).lower()}",
        ],
        next_steps=next_steps,
    )


# ---------------------------------------------------------------------------
# toggle
# ---------------------------------------------------------------------------


@cli.command("toggle")
@click.option(
    "-n",
    "--name",
    required=True,
    help="Flag name to toggle.",
)
@click.option(
    "--state",
    type=click.Choice(VALID_STATES + ("flip",), case_sensitive=False),
    default="flip",
    show_default=True,
    help="Desired end state. Use 'flip' to invert the current value.",
)
@click.option(
    "-y",
    "--yes",
    is_flag=True,
    help="Skip confirmation. Required in non-interactive mode.",
)
@click.option(
    "--dry-run",
    "dry_run",
    is_flag=True,
    help="Show the state change without applying it.",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit the flag as a single JSON object.",
)
@click.pass_context
def cmd_toggle(
    ctx: click.Context,
    name: str,
    state: str,
    yes: bool,
    dry_run: bool,
    json_out: bool,
) -> None:
    """Set a feature flag's state.

    Toggle is idempotent: if the flag is already in the desired state, the
    command prints the current record and exits 0 without hitting the write
    endpoint.

    \b
    Examples:
      flagctl toggle --name checkout-v2 --state on --yes
      flagctl toggle --name checkout-v2 --state off --yes
      flagctl toggle --name checkout-v2 --state flip --yes        # invert
      flagctl toggle --name checkout-v2 --state on --dry-run
      flagctl toggle --name checkout-v2 --state on --yes --json

    \b
    See also:
      flagctl get --name <name>        inspect a flag
      flagctl list                     list all flags
    """
    json_out = json_out or bool(ctx.obj.get("json"))
    no_input = bool(ctx.obj.get("no_input"))
    state = state.lower()

    name = name.strip()
    if not name:
        print_error(
            "--name must not be empty.",
            examples=["flagctl toggle --name checkout-v2 --state on --yes"],
        )
        ctx.exit(EXIT_USAGE)

    try:
        current = api_request("GET", f"/flags/{name}")
    except ApiError as err:
        if "not found" in err.message:
            print_error(
                f"flag '{name}' does not exist.",
                examples=[
                    "flagctl list",
                    f"flagctl create --name {name} --description '...' --owner you@example.com",
                ],
            )
            ctx.exit(EXIT_FAILURE)
        err.show()
        ctx.exit(err.exit_code)

    if not isinstance(current, dict):
        print_error(f"unexpected response shape for flag '{name}'")
        ctx.exit(EXIT_FAILURE)

    current_state = str(current.get("state", "")).lower()
    if state == "flip":
        if current_state not in VALID_STATES:
            print_error(
                f"cannot flip flag '{name}': current state '{current_state}' is not on/off.",
                examples=[f"flagctl toggle --name {name} --state on --yes"],
            )
            ctx.exit(EXIT_FAILURE)
        target_state = "off" if current_state == "on" else "on"
    else:
        target_state = state

    # Idempotency: already in the desired state -> no-op with stable shape.
    if current_state == target_state:
        _emit_toggle_result(
            current,
            previous_state=current_state,
            target_state=target_state,
            changed=False,
            dry_run=dry_run,
            as_json=json_out,
        )
        return

    # Confirmation gate for the actual write.
    if not yes and not dry_run:
        if no_input or not sys.stdin.isatty():
            print_error(
                f"refusing to change '{name}' from {current_state} to {target_state} "
                "without --yes in non-interactive mode.",
                examples=[
                    f"flagctl toggle --name {name} --state {target_state} --yes",
                    f"flagctl toggle --name {name} --state {target_state} --dry-run",
                ],
            )
            ctx.exit(EXIT_USAGE)
        if not click.confirm(
            f"Toggle '{name}' from {current_state} to {target_state}?",
            default=False,
        ):
            echo_err("aborted")
            ctx.exit(EXIT_FAILURE)

    if dry_run:
        preview = dict(current)
        preview["state"] = target_state
        _emit_toggle_result(
            preview,
            previous_state=current_state,
            target_state=target_state,
            changed=True,
            dry_run=True,
            as_json=json_out,
        )
        return

    try:
        updated = api_request("PATCH", f"/flags/{name}", data={"state": target_state})
    except ApiError as err:
        err.show()
        ctx.exit(err.exit_code)

    if not isinstance(updated, dict):
        updated = dict(current)
        updated["state"] = target_state

    _emit_toggle_result(
        updated,
        previous_state=current_state,
        target_state=target_state,
        changed=True,
        dry_run=False,
        as_json=json_out,
    )


def _emit_toggle_result(
    record: dict[str, Any],
    *,
    previous_state: str,
    target_state: str,
    changed: bool,
    dry_run: bool,
    as_json: bool,
) -> None:
    enriched = dict(record)
    enriched["previous_state"] = previous_state
    enriched["state"] = target_state
    enriched["changed"] = changed
    enriched["dry_run"] = dry_run

    name = record.get("name", "")
    if dry_run and changed:
        verb = f"would toggle {name} from {previous_state} to {target_state}"
    elif changed:
        verb = f"toggled {name} from {previous_state} to {target_state}"
    else:
        verb = f"{name} already {target_state}"

    emit_record(
        enriched,
        as_json=as_json,
        human_lines=[
            verb,
            f"name:           {name}",
            f"previous_state: {previous_state}",
            f"state:          {target_state}",
            f"changed:        {str(changed).lower()}",
            f"dry_run:        {str(dry_run).lower()}",
        ],
        next_steps=[
            f"flagctl get --name {name}",
            f"flagctl list",
        ],
    )


# ---------------------------------------------------------------------------
# delete
# ---------------------------------------------------------------------------


@cli.command("delete")
@click.option(
    "-n",
    "--name",
    required=True,
    help="Flag name to delete.",
)
@click.option(
    "--confirm",
    "confirm",
    default=None,
    help="Must equal --name. Guards against accidental deletions.",
)
@click.option(
    "-y",
    "--yes",
    is_flag=True,
    help="Skip the interactive confirmation. Required in non-interactive mode.",
)
@click.option(
    "--dry-run",
    "dry_run",
    is_flag=True,
    help="Show what would be deleted without hitting the API.",
)
@click.option(
    "--json",
    "json_out",
    is_flag=True,
    help="Emit the result as a single JSON object.",
)
@click.pass_context
def cmd_delete(
    ctx: click.Context,
    name: str,
    confirm: str | None,
    yes: bool,
    dry_run: bool,
    json_out: bool,
) -> None:
    """Delete a feature flag.

    This command is idempotent: if the flag is already gone, it exits 0 with
    a "already absent" note on stderr. Because deletion is irreversible, the
    caller must pass --confirm=<name> AND --yes for the real delete to run.

    \b
    Examples:
      flagctl delete --name checkout-v2 --confirm checkout-v2 --yes
      flagctl delete --name checkout-v2 --confirm checkout-v2 --dry-run
      flagctl delete --name checkout-v2 --confirm checkout-v2 --yes --json

    \b
    See also:
      flagctl get --name <name>        inspect before deleting
      flagctl list                     list all flags
    """
    json_out = json_out or bool(ctx.obj.get("json"))
    no_input = bool(ctx.obj.get("no_input"))

    name = name.strip()
    if not name:
        print_error(
            "--name must not be empty.",
            examples=["flagctl delete --name checkout-v2 --confirm checkout-v2 --yes"],
        )
        ctx.exit(EXIT_USAGE)

    # Severe-action guardrail: name must be typed into --confirm.
    if confirm != name:
        print_error(
            f"--confirm must equal --name to delete '{name}' "
            f"(got --confirm={confirm!r}).",
            examples=[
                f"flagctl delete --name {name} --confirm {name} --yes",
                f"flagctl delete --name {name} --confirm {name} --dry-run",
            ],
        )
        ctx.exit(EXIT_USAGE)

    # --yes is mandatory in non-interactive mode (and implicit non-TTY).
    if not yes and not dry_run:
        if no_input or not sys.stdin.isatty():
            print_error(
                f"refusing to delete '{name}' without --yes in non-interactive mode.",
                examples=[f"flagctl delete --name {name} --confirm {name} --yes"],
            )
            ctx.exit(EXIT_USAGE)
        if not click.confirm(
            f"Delete '{name}'? This cannot be undone.",
            default=False,
        ):
            echo_err("aborted")
            ctx.exit(EXIT_FAILURE)

    if dry_run:
        _emit_delete_result(
            name=name,
            already_absent=False,
            dry_run=True,
            as_json=json_out,
        )
        return

    try:
        api_request("DELETE", f"/flags/{name}")
    except ApiError as err:
        if "not found" in err.message:
            # Idempotent cleanup: target already gone -> success.
            _emit_delete_result(
                name=name,
                already_absent=True,
                dry_run=False,
                as_json=json_out,
            )
            return
        err.show()
        ctx.exit(err.exit_code)

    _emit_delete_result(
        name=name,
        already_absent=False,
        dry_run=False,
        as_json=json_out,
    )


def _emit_delete_result(
    *,
    name: str,
    already_absent: bool,
    dry_run: bool,
    as_json: bool,
) -> None:
    record = {
        "name": name,
        "deleted": not already_absent,
        "already_absent": already_absent,
        "changed": not already_absent and not dry_run,
        "dry_run": dry_run,
    }

    if dry_run:
        verb = f"would delete {name}"
    elif already_absent:
        # Note: the informational line goes to stderr so that JSON/data on
        # stdout stays parseable for downstream tools.
        echo_err(f"{name} already absent")
        verb = f"{name} already absent"
    else:
        verb = f"deleted {name}"

    emit_record(
        record,
        as_json=as_json,
        human_lines=[
            verb,
            f"name:           {name}",
            f"deleted:        {str(record['deleted']).lower()}",
            f"already_absent: {str(already_absent).lower()}",
            f"changed:        {str(record['changed']).lower()}",
            f"dry_run:        {str(dry_run).lower()}",
        ],
        next_steps=[
            "flagctl list",
        ],
    )


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------


def main() -> int:
    try:
        result = cli(standalone_mode=False)
        # click returns the exit code from ctx.exit() in non-standalone mode.
        if isinstance(result, int):
            return result
        return EXIT_OK
    except click.exceptions.UsageError as usage_err:
        # Click raises UsageError for unknown flags, bad choices, missing
        # required values. Format it consistently with print_error().
        print_error(
            usage_err.format_message(),
            examples=[
                "flagctl --help",
                "flagctl list --help",
                "flagctl create --help",
            ],
        )
        return EXIT_USAGE
    except click.exceptions.NoSuchOption as opt_err:
        print_error(
            opt_err.format_message(),
            examples=["flagctl --help"],
        )
        return EXIT_USAGE
    except ApiError as api_err:
        api_err.show()
        return api_err.exit_code
    except click.exceptions.Abort:
        echo_err("aborted")
        return EXIT_FAILURE
    except click.exceptions.Exit as exit_err:
        return int(exit_err.exit_code)
    except KeyboardInterrupt:
        echo_err("interrupted")
        return EXIT_FAILURE
    except Exception as unexpected:  # pragma: no cover - safety net
        print_error(
            f"unexpected internal error: {unexpected}",
            examples=[
                "FLAGCTL_DEBUG=1 flagctl <command>  # re-run with a traceback",
            ],
            debug_exc=unexpected,
        )
        return EXIT_FAILURE


if __name__ == "__main__":
    sys.exit(main())
