#!/usr/bin/env python3
"""Probe iOS SDK symbol docs together with local SDK declarations."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) == 1:
        print("usage: probe_symbol.py QUERY [search_symbols.py options...]", file=sys.stderr)
        return 2
    search_script = Path(__file__).with_name("search_symbols.py")
    cmd = [
        sys.executable,
        str(search_script),
        "--verify-interfaces",
        "--no-dedupe",
        "--doc-chars",
        "-1",
        *sys.argv[1:],
    ]
    return subprocess.call(cmd)


if __name__ == "__main__":
    raise SystemExit(main())
