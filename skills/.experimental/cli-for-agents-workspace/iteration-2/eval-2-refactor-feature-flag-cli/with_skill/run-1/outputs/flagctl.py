"""
flagctl — feature flag management CLI (agent-friendly refactor).

Designed for both humans at a terminal and AI agents / CI pipelines.
Every input is available as a flag; prompts are opt-in and TTY-only.

Exit codes:
  0   success
  1   runtime failure (API error, not-found on non-idempotent path, etc.)
  2   usage error (bad/missing flags, non-TTY prompt attempt)
  69  service unavailable (EX_UNAVAILABLE — upstream API down)
  75  transient failure (EX_TEMPFAIL — retryable, e.g. 429/503/timeout)

\b
Examples:
  python flagctl.py list --limit 20
  python flagctl.py create --name checkout-v2 --description "new checkout" --owner team@example.com
  python flagctl.py toggle checkout-v2 --yes
  python flagctl.py delete checkout-v2 --yes --json
"""
import json
import os
import sys
import urllib.error
import urllib.request

import click


API_BASE = os.environ.get("FLAGCTL_API_BASE", "https://flags.internal.example.com/v1")

# Exit codes (BSD sysexits-inspired)
EXIT_OK = 0
EXIT_RUNTIME = 1
EXIT_USAGE = 2
EXIT_UNAVAILABLE = 69
EXIT_TEMPFAIL = 75


def _eprint(msg: str) -> None:
    """Write a line to stderr."""
    click.echo(msg, err=True)


def _die(msg: str, code: int, example: str | None = None) -> None:
    """Emit an actionable error to stderr and exit with a distinct code."""
    _eprint(f"error: {msg}")
    if example:
        _eprint(f"try:   {example}")
    sys.exit(code)


def api_request(method: str, path: str, data: dict | None = None) -> dict | list:
    """Call the flags API and classify failures into distinct exit codes."""
    url = f"{API_BASE}{path}"
    body = None
    headers = {}
    if data is not None:
        body = json.dumps(data).encode()
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=body, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            raw = resp.read()
            if not raw:
                return {}
            return json.loads(raw)
    except urllib.error.HTTPError as e:
        status = e.code
        if status in (429, 503, 504):
            _die(
                f"API {method} {path} returned {status} (transient)",
                EXIT_TEMPFAIL,
                example=f"retry in a few seconds: python flagctl.py {method.lower()} ...",
            )
        if status in (500, 502):
            _die(
                f"API {method} {path} returned {status} (upstream unavailable)",
                EXIT_UNAVAILABLE,
                example="check service status, then retry",
            )
        if status == 404:
            _die(
                f"API {method} {path} returned 404 (not found)",
                EXIT_RUNTIME,
                example="python flagctl.py list --limit 20",
            )
        _die(f"API {method} {path} returned HTTP {status}", EXIT_RUNTIME)
    except urllib.error.URLError as e:
        _die(
            f"cannot reach {API_BASE}: {e.reason}",
            EXIT_UNAVAILABLE,
            example="verify FLAGCTL_API_BASE or network, then retry",
        )
    except TimeoutError:
        _die(
            f"API {method} {path} timed out",
            EXIT_TEMPFAIL,
            example="retry the command; consider reducing --limit",
        )
    except json.JSONDecodeError as e:
        _die(f"API returned invalid JSON: {e}", EXIT_RUNTIME)
    # Unreachable, silences type checker.
    return {}


def _emit_record(record: dict, json_output: bool) -> None:
    """Emit a single record — JSON on one line, or tab-separated human text."""
    if json_output:
        click.echo(json.dumps(record, separators=(",", ":"), sort_keys=True))
    else:
        name = record.get("name", "")
        state = record.get("state", "")
        updated = record.get("updated", "")
        owner = record.get("owner", "")
        click.echo(f"{name}\t{state}\t{updated}\t{owner}")


def _require_non_interactive_input(
    value: str | None,
    flag_name: str,
    subcommand: str,
    example: str,
) -> str:
    """Return value if provided; otherwise fail fast with a usage error.

    Non-interactive mode: if the flag is missing and we cannot prompt
    (no TTY, --no-input set, etc.), emit an actionable error to stderr
    and exit with the usage exit code. Never hang on stdin.
    """
    if value is not None and value != "":
        return value
    _die(
        f"{subcommand}: missing required flag {flag_name}",
        EXIT_USAGE,
        example=example,
    )
    return ""  # unreachable


def _can_prompt(no_input: bool) -> bool:
    """True only when it is safe to prompt the user interactively."""
    if no_input:
        return False
    return sys.stdin.isatty() and sys.stderr.isatty()


# --- CLI ---------------------------------------------------------------------


@click.group(
    context_settings={"help_option_names": ["-h", "--help"]},
    invoke_without_command=True,
)
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit machine-readable JSON (NDJSON for list; single object otherwise).",
)
@click.option(
    "--no-input",
    is_flag=True,
    default=False,
    help="Never prompt; fail fast if a required flag is missing.",
)
@click.pass_context
def cli(ctx: click.Context, json_output: bool, no_input: bool) -> None:
    """Manage feature flags from humans and agents alike.

    Global flags (--json, --no-input) work with every subcommand.

    \b
    Examples:
      python flagctl.py list --limit 20
      python flagctl.py --json list --all
      python flagctl.py create --name checkout-v2 --description "new checkout" --owner team@example.com
    """
    ctx.ensure_object(dict)
    ctx.obj["json"] = json_output
    ctx.obj["no_input"] = no_input
    if ctx.invoked_subcommand is None:
        click.echo(ctx.get_help())
        ctx.exit(EXIT_OK)


@cli.command("list")
@click.option(
    "--limit",
    type=int,
    default=50,
    show_default=True,
    help="Maximum records to return. Ignored when --all is set.",
)
@click.option(
    "--all",
    "return_all",
    is_flag=True,
    default=False,
    help="Return every record (may be large). Opts out of --limit.",
)
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit NDJSON, one flag per line.",
)
@click.pass_context
def list_flags(ctx: click.Context, limit: int, return_all: bool, json_output: bool) -> None:
    """List feature flags, one record per line.

    Default is bounded to --limit 50 to protect agent context windows.
    Pass --all for everything, or --limit <n> for a specific cap.

    \b
    Examples:
      python flagctl.py list
      python flagctl.py list --limit 200
      python flagctl.py list --all --json
    """
    use_json = json_output or ctx.obj.get("json", False)

    flags = api_request("GET", "/flags")
    if not isinstance(flags, list):
        _die("API returned unexpected payload for /flags (expected list)", EXIT_RUNTIME)

    total = len(flags)
    if return_all:
        visible = flags
    else:
        visible = flags[:limit]

    if not use_json:
        # One record per line, tab-separated. No separator rows, no borders.
        click.echo("NAME\tSTATE\tUPDATED\tOWNER")
    for f in visible:
        _emit_record(f, use_json)

    if not return_all and total > len(visible):
        _eprint(
            f"(showing first {len(visible)} of {total}; pass --all or --limit <n> for more)"
        )


@cli.command()
@click.option("--name", help="Flag name (required). Must be kebab-case.")
@click.option("--description", help="Human-readable description (required).")
@click.option("--owner", help="Owner email (required).")
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit the created flag as a JSON object on stdout.",
)
@click.pass_context
def create(
    ctx: click.Context,
    name: str | None,
    description: str | None,
    owner: str | None,
    json_output: bool,
) -> None:
    """Create a new feature flag.

    All inputs are flags — no interactive prompts by default. In a TTY
    you may omit flags and flagctl will prompt, but only if --no-input
    is not set. CI and agents should pass every flag explicitly.

    \b
    Examples:
      python flagctl.py create --name checkout-v2 --description "Roll out new checkout" --owner team@example.com
      python flagctl.py create --name kill-switch --description "Emergency off" --owner oncall@example.com --json
    """
    use_json = json_output or ctx.obj.get("json", False)
    no_input = ctx.obj.get("no_input", False)
    example = (
        'python flagctl.py create --name my-flag '
        '--description "what it does" --owner team@example.com'
    )

    def _get(value: str | None, flag: str, prompt_label: str) -> str:
        if value:
            return value
        if _can_prompt(no_input):
            try:
                got = click.prompt(prompt_label, type=str, err=True)
            except click.Abort:
                _die("create: aborted", EXIT_USAGE, example=example)
            if got:
                return got
        _die(
            f"create: missing required flag {flag}",
            EXIT_USAGE,
            example=example,
        )
        return ""  # unreachable

    name_val = _get(name, "--name", "Flag name")
    description_val = _get(description, "--description", "Description")
    owner_val = _get(owner, "--owner", "Owner email")

    result = api_request(
        "POST",
        "/flags",
        {"name": name_val, "description": description_val, "owner": owner_val},
    )

    if use_json:
        payload = result if isinstance(result, dict) and result else {
            "name": name_val,
            "description": description_val,
            "owner": owner_val,
            "state": "off",
        }
        _emit_record(payload, json_output=True)
    else:
        # Chainable: print the created name on stdout so callers can pipe it.
        click.echo(name_val)
        _eprint(f"created flag {name_val}")


@cli.command()
@click.argument("name")
@click.option(
    "--yes",
    "assume_yes",
    is_flag=True,
    default=False,
    help="Skip the confirmation prompt. Required in non-TTY contexts.",
)
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit the deletion result as a JSON object on stdout.",
)
@click.pass_context
def delete(ctx: click.Context, name: str, assume_yes: bool, json_output: bool) -> None:
    """Delete a feature flag. This cannot be undone.

    By default, delete asks for confirmation — but only when attached to
    a TTY. In CI or agent contexts, pass --yes or the command fails fast
    with a usage error instead of hanging.

    \b
    Examples:
      python flagctl.py delete checkout-v2 --yes
      python flagctl.py delete legacy-banner --yes --json
      python flagctl.py delete kill-switch         # interactive confirm (TTY only)
    """
    use_json = json_output or ctx.obj.get("json", False)
    no_input = ctx.obj.get("no_input", False)

    if not assume_yes:
        if not _can_prompt(no_input):
            _die(
                f"delete: refusing to prompt for confirmation in non-interactive mode",
                EXIT_USAGE,
                example=f"python flagctl.py delete {name} --yes",
            )
        confirm = click.prompt(
            f"Delete {name}? This cannot be undone. Type 'y' to confirm",
            default="N",
            show_default=False,
            err=True,
        )
        if confirm.strip().lower() != "y":
            _eprint("delete: aborted")
            sys.exit(EXIT_OK)

    api_request("DELETE", f"/flags/{name}")

    if use_json:
        _emit_record({"name": name, "deleted": True}, json_output=True)
    else:
        click.echo(name)
        _eprint(f"deleted flag {name}")


@cli.command()
@click.argument("name")
@click.option(
    "--state",
    type=click.Choice(["on", "off"], case_sensitive=False),
    default=None,
    help="Explicit target state. If omitted, flips current state.",
)
@click.option(
    "--yes",
    "assume_yes",
    is_flag=True,
    default=False,
    help="Skip the confirmation prompt. Required in non-TTY contexts.",
)
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit the updated flag as a JSON object on stdout.",
)
@click.pass_context
def toggle(
    ctx: click.Context,
    name: str,
    state: str | None,
    assume_yes: bool,
    json_output: bool,
) -> None:
    """Toggle a feature flag on or off.

    Idempotent: setting --state to the current value is a no-op success.
    Prompts for confirmation only in a TTY when --yes is not set.

    \b
    Examples:
      python flagctl.py toggle checkout-v2 --yes
      python flagctl.py toggle checkout-v2 --state off --yes
      python flagctl.py toggle kill-switch --state on --yes --json
    """
    use_json = json_output or ctx.obj.get("json", False)
    no_input = ctx.obj.get("no_input", False)

    flag = api_request("GET", f"/flags/{name}")
    if not isinstance(flag, dict):
        _die(
            f"toggle: API returned unexpected payload for /flags/{name}",
            EXIT_RUNTIME,
        )

    current = str(flag.get("state", "off")).lower()
    if state is not None:
        new_state = state.lower()
    else:
        new_state = "off" if current == "on" else "on"

    # Idempotent no-op: already in desired state.
    if new_state == current:
        if use_json:
            _emit_record(
                {"name": name, "state": current, "changed": False},
                json_output=True,
            )
        else:
            click.echo(name)
            _eprint(f"toggle: {name} already {current} (no change)")
        sys.exit(EXIT_OK)

    if not assume_yes:
        if not _can_prompt(no_input):
            _die(
                f"toggle: refusing to prompt for confirmation in non-interactive mode",
                EXIT_USAGE,
                example=f"python flagctl.py toggle {name} --state {new_state} --yes",
            )
        confirm = click.prompt(
            f"Toggle {name} from {current} to {new_state}? Type 'y' to confirm",
            default="N",
            show_default=False,
            err=True,
        )
        if confirm.strip().lower() != "y":
            _eprint("toggle: aborted")
            sys.exit(EXIT_OK)

    api_request("PATCH", f"/flags/{name}", {"state": new_state})

    if use_json:
        _emit_record(
            {"name": name, "state": new_state, "changed": True},
            json_output=True,
        )
    else:
        click.echo(name)
        _eprint(f"toggled {name} to {new_state}")


if __name__ == "__main__":
    cli(obj={})
