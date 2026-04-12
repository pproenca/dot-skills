"""
flagctl - feature flag management CLI.

Agent-friendly rewrite:
- All prompts can be bypassed with flags (fully non-interactive capable).
- `--yes / -y` skips confirmations.
- `--json` emits structured output on stdout; human output is the default.
- Errors go to stderr; stdout stays clean so `--json` is always pipeable.
- Network calls have a timeout so CI never hangs.
- Distinct exit codes make failures classifiable by agents.
- When stdin is not a TTY, the CLI never prompts; it fails fast with a
  clear error telling the agent which flag was missing.

Exit codes:
    0  success
    1  generic / unexpected error
    2  usage error (missing flag, non-interactive without required input)
    3  confirmation required but not granted (missing --yes in non-TTY)
    4  not found (HTTP 404)
    5  API / network error (HTTP >= 400, timeout, connection error)

Usage (human):
    python flagctl.py create my-flag --description "..." --owner you@ex.com
    python flagctl.py list
    python flagctl.py toggle my-flag
    python flagctl.py delete my-flag

Usage (agent / CI):
    python flagctl.py --json list
    python flagctl.py --json create my-flag -d "..." -o you@ex.com
    python flagctl.py --json toggle my-flag --yes
    python flagctl.py --json delete my-flag --yes
"""
from __future__ import annotations

import json
import sys
from typing import Any, Optional
from urllib import error as urllib_error
from urllib import request as urllib_request

import click

API_BASE = "https://flags.internal.example.com/v1"
DEFAULT_TIMEOUT_SECONDS = 15

# Exit codes - kept as module constants so tests / agents can import them.
EXIT_OK = 0
EXIT_GENERIC_ERROR = 1
EXIT_USAGE_ERROR = 2
EXIT_CONFIRMATION_REQUIRED = 3
EXIT_NOT_FOUND = 4
EXIT_API_ERROR = 5


# ---------------------------------------------------------------------------
# Output helpers
# ---------------------------------------------------------------------------


def _is_json_mode(ctx: click.Context) -> bool:
    """Return True if the top-level --json flag was set."""
    root = ctx.find_root()
    return bool(root.obj and root.obj.get("json"))


def emit_success(ctx: click.Context, payload: dict[str, Any], human_message: str) -> None:
    """Emit a success result.

    In JSON mode: prints a structured object to stdout.
    In human mode: prints `human_message` to stdout.
    """
    if _is_json_mode(ctx):
        out = {"ok": True, **payload}
        click.echo(json.dumps(out), nl=True)
    else:
        click.echo(human_message)


def emit_error(
    ctx: click.Context,
    message: str,
    *,
    code: str,
    exit_code: int,
    details: Optional[dict[str, Any]] = None,
) -> None:
    """Emit an error and exit with `exit_code`.

    Errors ALWAYS go to stderr (even in human mode) so stdout stays clean
    for piping. In JSON mode we additionally emit a structured error object
    to stderr so callers can parse it.
    """
    if _is_json_mode(ctx):
        payload: dict[str, Any] = {
            "ok": False,
            "error": {"code": code, "message": message},
        }
        if details:
            payload["error"]["details"] = details
        click.echo(json.dumps(payload), err=True)
    else:
        click.echo(f"error: {message}", err=True)
    ctx.exit(exit_code)


# ---------------------------------------------------------------------------
# HTTP layer
# ---------------------------------------------------------------------------


class ApiError(Exception):
    def __init__(self, message: str, *, status: Optional[int] = None) -> None:
        super().__init__(message)
        self.message = message
        self.status = status


def api_request(
    method: str,
    path: str,
    data: Optional[dict[str, Any]] = None,
    *,
    timeout: float = DEFAULT_TIMEOUT_SECONDS,
) -> Any:
    """Make an HTTP request. Raises ApiError on any failure - never exits.

    The caller is responsible for turning ApiError into a user-facing
    error via emit_error. This keeps HTTP concerns separate from CLI
    presentation concerns.
    """
    url = f"{API_BASE}{path}"
    req = urllib_request.Request(url, method=method)
    body: Optional[bytes] = None
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        req.add_header("Content-Type", "application/json")

    try:
        with urllib_request.urlopen(req, data=body, timeout=timeout) as resp:
            raw = resp.read()
            if not raw:
                return None
            try:
                return json.loads(raw)
            except json.JSONDecodeError as exc:
                raise ApiError(
                    f"invalid JSON response from API: {exc}",
                    status=resp.status,
                ) from exc
    except urllib_error.HTTPError as exc:
        # Try to extract a useful message from the response body.
        detail = ""
        try:
            raw = exc.read().decode("utf-8", errors="replace")
            try:
                parsed = json.loads(raw)
                detail = parsed.get("message") or parsed.get("error") or raw
            except json.JSONDecodeError:
                detail = raw
        except Exception:
            pass
        msg = f"HTTP {exc.code} from {method} {path}"
        if detail:
            msg += f": {detail}"
        raise ApiError(msg, status=exc.code) from exc
    except urllib_error.URLError as exc:
        raise ApiError(f"network error calling {method} {path}: {exc.reason}") from exc
    except TimeoutError as exc:
        raise ApiError(
            f"timeout after {timeout}s calling {method} {path}"
        ) from exc


def handle_api_error(ctx: click.Context, exc: ApiError) -> None:
    """Translate an ApiError into the right exit code + structured error."""
    if exc.status == 404:
        emit_error(
            ctx,
            str(exc.message),
            code="not_found",
            exit_code=EXIT_NOT_FOUND,
            details={"status": exc.status},
        )
    else:
        emit_error(
            ctx,
            str(exc.message),
            code="api_error",
            exit_code=EXIT_API_ERROR,
            details={"status": exc.status} if exc.status is not None else None,
        )


# ---------------------------------------------------------------------------
# Interaction helpers
# ---------------------------------------------------------------------------


def require_value(
    ctx: click.Context,
    value: Optional[str],
    *,
    flag_name: str,
    prompt_text: str,
) -> str:
    """Return `value` if set, otherwise prompt the user - but only if stdin
    is a TTY. If not a TTY, fail fast with a usage error naming the flag.
    This is the critical fix: agents in CI never hang on a silent prompt.
    """
    if value:
        return value
    if not sys.stdin.isatty():
        emit_error(
            ctx,
            f"missing required value for {flag_name}; stdin is not a TTY so no prompt is possible",
            code="missing_input",
            exit_code=EXIT_USAGE_ERROR,
            details={"flag": flag_name},
        )
    # Interactive path: click.prompt respects Ctrl-C, shows the label, etc.
    return click.prompt(prompt_text, type=str)


def confirm_or_exit(
    ctx: click.Context,
    prompt_text: str,
    *,
    assume_yes: bool,
) -> None:
    """Confirm a destructive action.

    - If `assume_yes` (i.e. --yes was passed), return immediately.
    - If stdin is a TTY, show an interactive y/N prompt.
    - If stdin is NOT a TTY and --yes was not passed, exit with
      EXIT_CONFIRMATION_REQUIRED so agents can detect the condition
      and retry with --yes.
    """
    if assume_yes:
        return
    if not sys.stdin.isatty():
        emit_error(
            ctx,
            "confirmation required but stdin is not a TTY; pass --yes to proceed",
            code="confirmation_required",
            exit_code=EXIT_CONFIRMATION_REQUIRED,
        )
    if not click.confirm(prompt_text, default=False):
        emit_error(
            ctx,
            "aborted by user",
            code="aborted",
            exit_code=EXIT_CONFIRMATION_REQUIRED,
        )


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


@click.group(context_settings={"help_option_names": ["-h", "--help"]})
@click.option(
    "--json",
    "json_output",
    is_flag=True,
    default=False,
    help="Emit machine-readable JSON on stdout (and structured errors on stderr).",
)
@click.option(
    "--api-base",
    default=API_BASE,
    show_default=True,
    envvar="FLAGCTL_API_BASE",
    help="Override the API base URL (also via FLAGCTL_API_BASE).",
)
@click.option(
    "--timeout",
    default=DEFAULT_TIMEOUT_SECONDS,
    show_default=True,
    type=float,
    envvar="FLAGCTL_TIMEOUT",
    help="HTTP timeout in seconds (also via FLAGCTL_TIMEOUT).",
)
@click.version_option("1.0.0", prog_name="flagctl")
@click.pass_context
def cli(ctx: click.Context, json_output: bool, api_base: str, timeout: float) -> None:
    """Manage feature flags.

    All commands support --json for structured output and --yes to skip
    confirmation prompts. The CLI never blocks on stdin when run
    non-interactively: missing values produce a usage error with exit
    code 2 instead of a silent hang.
    """
    ctx.ensure_object(dict)
    ctx.obj["json"] = json_output
    ctx.obj["api_base"] = api_base
    ctx.obj["timeout"] = timeout
    # Patch module-level API_BASE for this invocation so api_request picks it up.
    global API_BASE
    API_BASE = api_base


@cli.command()
@click.argument("name", required=False)
@click.option("-d", "--description", default=None, help="Flag description.")
@click.option("-o", "--owner", default=None, help="Owner email.")
@click.option(
    "--state",
    type=click.Choice(["on", "off"], case_sensitive=False),
    default="off",
    show_default=True,
    help="Initial flag state.",
)
@click.pass_context
def create(
    ctx: click.Context,
    name: Optional[str],
    description: Optional[str],
    owner: Optional[str],
    state: str,
) -> None:
    """Create a new feature flag.

    All inputs can be supplied via flags so the command is usable in CI
    without any interactive prompts. In a TTY, missing values are
    prompted for. In non-TTY environments, missing values fail fast.
    """
    name = require_value(ctx, name, flag_name="NAME argument", prompt_text="Flag name")
    description = require_value(
        ctx, description, flag_name="--description", prompt_text="Description"
    )
    owner = require_value(ctx, owner, flag_name="--owner", prompt_text="Owner email")

    payload = {
        "name": name,
        "description": description,
        "owner": owner,
        "state": state.lower(),
    }
    try:
        result = api_request("POST", "/flags", payload, timeout=ctx.obj["timeout"])
    except ApiError as exc:
        handle_api_error(ctx, exc)
        return  # pragma: no cover - emit_error exits

    emit_success(
        ctx,
        {"action": "created", "flag": result or payload},
        human_message=f"Created flag '{name}'.",
    )


@cli.command()
@click.argument("name")
@click.option(
    "-y",
    "--yes",
    "assume_yes",
    is_flag=True,
    default=False,
    help="Skip the confirmation prompt (required in non-interactive environments).",
)
@click.pass_context
def delete(ctx: click.Context, name: str, assume_yes: bool) -> None:
    """Delete a feature flag.

    Destructive. Use --yes to skip the confirmation prompt, which is
    required when running non-interactively (e.g. in CI).
    """
    confirm_or_exit(
        ctx,
        f"Delete flag '{name}'? This cannot be undone.",
        assume_yes=assume_yes,
    )
    try:
        api_request("DELETE", f"/flags/{name}", timeout=ctx.obj["timeout"])
    except ApiError as exc:
        handle_api_error(ctx, exc)
        return  # pragma: no cover

    emit_success(
        ctx,
        {"action": "deleted", "name": name},
        human_message=f"Deleted flag '{name}'.",
    )


@cli.command("list")
@click.option(
    "--state",
    type=click.Choice(["on", "off", "all"], case_sensitive=False),
    default="all",
    show_default=True,
    help="Filter flags by state.",
)
@click.pass_context
def list_flags(ctx: click.Context, state: str) -> None:
    """List feature flags.

    Human output is a compact table. Agents should use --json to get
    a stable array of flag objects on stdout.
    """
    try:
        flags = api_request("GET", "/flags", timeout=ctx.obj["timeout"])
    except ApiError as exc:
        handle_api_error(ctx, exc)
        return  # pragma: no cover

    if not isinstance(flags, list):
        emit_error(
            ctx,
            "unexpected API response: expected a list of flags",
            code="api_error",
            exit_code=EXIT_API_ERROR,
        )
        return  # pragma: no cover

    state_filter = state.lower()
    if state_filter != "all":
        flags = [f for f in flags if f.get("state") == state_filter]

    if _is_json_mode(ctx):
        click.echo(json.dumps({"ok": True, "flags": flags}))
        return

    if not flags:
        click.echo("No flags found.")
        return

    # Human-readable table. Widths adapt to content so long names don't break.
    headers = ("Name", "State", "Updated", "Owner")
    rows = [
        (
            str(f.get("name", "")),
            str(f.get("state", "")),
            str(f.get("updated", "")),
            str(f.get("owner", "")),
        )
        for f in flags
    ]
    widths = [
        max(len(headers[i]), max((len(r[i]) for r in rows), default=0))
        for i in range(len(headers))
    ]
    fmt = "  ".join(f"{{:<{w}}}" for w in widths)
    click.echo(fmt.format(*headers))
    click.echo(fmt.format(*("-" * w for w in widths)))
    for r in rows:
        click.echo(fmt.format(*r))


@cli.command()
@click.argument("name")
@click.option(
    "--to",
    "target_state",
    type=click.Choice(["on", "off"], case_sensitive=False),
    default=None,
    help="Set flag to this state explicitly (idempotent). If omitted, flip the current state.",
)
@click.option(
    "-y",
    "--yes",
    "assume_yes",
    is_flag=True,
    default=False,
    help="Skip the confirmation prompt (required in non-interactive environments).",
)
@click.pass_context
def toggle(
    ctx: click.Context,
    name: str,
    target_state: Optional[str],
    assume_yes: bool,
) -> None:
    """Toggle or set a feature flag's state.

    Without --to this flips the flag. With --to on|off the command is
    idempotent, which is what most agent workflows want.
    """
    try:
        flag = api_request("GET", f"/flags/{name}", timeout=ctx.obj["timeout"])
    except ApiError as exc:
        handle_api_error(ctx, exc)
        return  # pragma: no cover

    current_state = (flag or {}).get("state")
    if target_state is not None:
        new_state = target_state.lower()
    else:
        if current_state not in {"on", "off"}:
            emit_error(
                ctx,
                f"cannot toggle flag '{name}': unknown current state {current_state!r}",
                code="invalid_state",
                exit_code=EXIT_GENERIC_ERROR,
            )
            return  # pragma: no cover
        new_state = "off" if current_state == "on" else "on"

    if current_state == new_state:
        emit_success(
            ctx,
            {
                "action": "noop",
                "name": name,
                "state": new_state,
            },
            human_message=f"Flag '{name}' already {new_state}; nothing to do.",
        )
        return

    confirm_or_exit(
        ctx,
        f"Toggle flag '{name}' from {current_state} to {new_state}?",
        assume_yes=assume_yes,
    )

    try:
        api_request(
            "PATCH",
            f"/flags/{name}",
            {"state": new_state},
            timeout=ctx.obj["timeout"],
        )
    except ApiError as exc:
        handle_api_error(ctx, exc)
        return  # pragma: no cover

    emit_success(
        ctx,
        {
            "action": "toggled",
            "name": name,
            "from": current_state,
            "to": new_state,
        },
        human_message=f"Toggled flag '{name}' from {current_state} to {new_state}.",
    )


if __name__ == "__main__":
    cli()
