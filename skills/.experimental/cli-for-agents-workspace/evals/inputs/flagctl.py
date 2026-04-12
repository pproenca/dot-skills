"""
flagctl — feature flag management CLI (legacy, inherited from a previous team).

Known issues:
- Agents running this in CI sometimes hang
- Error messages are vague
- No structured output
- No way to skip confirmation prompts

Usage:
    python flagctl.py create
    python flagctl.py delete my-flag
    python flagctl.py list
    python flagctl.py toggle my-flag
"""
import sys
import click
import json
import urllib.request


API_BASE = "https://flags.internal.example.com/v1"


def api_request(method, path, data=None):
    url = f"{API_BASE}{path}"
    req = urllib.request.Request(url, method=method)
    if data:
        req.data = json.dumps(data).encode()
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read())
    except Exception as e:
        print(f"error: {e}")
        sys.exit(1)


@click.group()
def cli():
    """A CLI for managing feature flags."""
    pass


@cli.command()
@click.argument("name", required=False)
def create(name):
    if not name:
        name = input("Flag name: ")
    description = input("Description: ")
    owner = input("Owner email: ")
    result = api_request("POST", "/flags", {
        "name": name,
        "description": description,
        "owner": owner,
    })
    print(f"Created {name}")


@cli.command()
@click.argument("name")
def delete(name):
    confirm = input(f"Delete {name}? This cannot be undone. (y/N): ")
    if confirm.lower() != "y":
        print("Aborted.")
        return
    api_request("DELETE", f"/flags/{name}")
    print(f"Deleted {name}")


@cli.command()
def list():
    flags = api_request("GET", "/flags")
    print("+----------------------+--------+------------+------------------+")
    print("| Name                 | State  | Updated    | Owner            |")
    print("+----------------------+--------+------------+------------------+")
    for f in flags:
        print(f"| {f['name']:20s} | {f['state']:6s} | {f['updated']:10s} | {f['owner']:16s} |")
    print("+----------------------+--------+------------+------------------+")


@cli.command()
@click.argument("name")
def toggle(name):
    flag = api_request("GET", f"/flags/{name}")
    new_state = "off" if flag["state"] == "on" else "on"
    confirm = input(f"Toggle {name} from {flag['state']} to {new_state}? (y/N): ")
    if confirm.lower() != "y":
        return
    api_request("PATCH", f"/flags/{name}", {"state": new_state})
    print(f"Toggled {name} to {new_state}")


if __name__ == "__main__":
    cli()
