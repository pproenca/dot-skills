#!/usr/bin/env python3
"""Build cached symbol graphs for the active macOS SDK."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path


DEFAULT_MODULES = ["SwiftUI", "SwiftUICore", "AppKit"]
DEFAULT_SDK = "macosx"
DEFAULT_TARGET = "arm64-apple-macos"


def run(args: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        check=True,
        text=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def sdk_path(sdk: str) -> Path:
    result = run(["xcrun", "--sdk", sdk, "--show-sdk-path"], capture=True)
    return Path(result.stdout.strip())


def default_cache_root() -> Path:
    override = os.environ.get("CODEX_MACOS26_DOCS_CACHE")
    if override:
        return Path(override).expanduser()
    return Path.home() / ".cache" / "codex" / "search-macos26-docs"


def cache_dir(root: Path, sdk: Path, target: str, module: str) -> Path:
    return root / sdk.name / target / module


def manifest_matches(manifest_path: Path, sdk: Path, target: str, module: str) -> bool:
    if not manifest_path.exists():
        return False
    try:
        manifest = json.loads(manifest_path.read_text())
    except json.JSONDecodeError:
        return False
    return (
        manifest.get("sdk_path") == str(sdk)
        and manifest.get("sdk_name") == sdk.name
        and manifest.get("target") == target
        and manifest.get("module") == module
    )


def has_symbol_graphs(out_dir: Path) -> bool:
    return any(out_dir.glob("*.symbols.json"))


def build_module(module: str, sdk: Path, target: str, root: Path, force: bool) -> Path:
    out_dir = cache_dir(root, sdk, target, module)
    manifest_path = out_dir / "manifest.json"
    if not force and has_symbol_graphs(out_dir) and manifest_matches(manifest_path, sdk, target, module):
        print(f"[cached] {module}: {out_dir}")
        return out_dir

    if force and out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"[build] {module}: {out_dir}")
    run(
        [
            "xcrun",
            "swift-symbolgraph-extract",
            "-module-name",
            module,
            "-target",
            target,
            "-sdk",
            str(sdk),
            "-output-dir",
            str(out_dir),
        ]
    )
    manifest_path.write_text(
        json.dumps(
            {
                "module": module,
                "sdk_path": str(sdk),
                "sdk_name": sdk.name,
                "target": target,
                "files": sorted(p.name for p in out_dir.glob("*.symbols.json")),
            },
            indent=2,
            sort_keys=True,
        )
        + "\n"
    )
    return out_dir


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk", default=DEFAULT_SDK, help=f"xcrun SDK name, default: {DEFAULT_SDK}")
    parser.add_argument("--target", default=DEFAULT_TARGET, help=f"Swift target triple, default: {DEFAULT_TARGET}")
    parser.add_argument(
        "--module",
        action="append",
        dest="modules",
        help="Module to extract. May be repeated. Defaults to SwiftUI, SwiftUICore, and AppKit.",
    )
    parser.add_argument("--cache-dir", default=None, help="Override cache root.")
    parser.add_argument("--force", action="store_true", help="Delete and rebuild selected module caches.")
    parser.add_argument("--list", action="store_true", help="Print resolved SDK/cache details without building.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    modules = args.modules or DEFAULT_MODULES
    sdk = sdk_path(args.sdk)
    root = Path(args.cache_dir).expanduser() if args.cache_dir else default_cache_root()

    print(f"sdk={sdk}")
    print(f"target={args.target}")
    print(f"cache_root={root}")
    print(f"modules={','.join(modules)}")

    if args.list:
        return 0

    for module in modules:
        build_module(module, sdk, args.target, root, args.force)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as exc:
        if exc.stdout:
            print(exc.stdout, file=sys.stderr)
        if exc.stderr:
            print(exc.stderr, file=sys.stderr)
        print(f"command failed: {' '.join(exc.cmd)}", file=sys.stderr)
        raise SystemExit(exc.returncode)
