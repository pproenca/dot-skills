#!/usr/bin/env python3
"""Generate a forensic preflight report for an audio file."""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

sys.dont_write_bytecode = True

from preflight_lib import (
    collect_preflight,
    format_markdown,
    parse_roi,
    require_tool,
    write_json,
    write_output,
)


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a forensic preflight report (JSON or Markdown)."
    )
    parser.add_argument("input", help="Path to input audio file")
    parser.add_argument(
        "--roi",
        help="Region of interest as start,end in seconds (e.g. 12.5,42.0)",
    )
    parser.add_argument(
        "--format",
        choices=["json", "md"],
        default="json",
        help="Output format (default: json)",
    )
    parser.add_argument("--out", help="Output file path (default: stdout)")
    parser.add_argument("--ffmpeg", help="Path to ffmpeg binary")
    parser.add_argument("--ffprobe", help="Path to ffprobe binary")
    return parser


def main() -> int:
    parser = build_arg_parser()
    args = parser.parse_args()

    try:
        roi = parse_roi(args.roi)
    except ValueError as exc:
        parser.error(str(exc))

    try:
        ffmpeg = require_tool(args.ffmpeg, "ffmpeg")
        ffprobe = require_tool(args.ffprobe, "ffprobe")
        report = collect_preflight(Path(args.input), ffmpeg, ffprobe, roi)
    except Exception as exc:
        sys.stderr.write(f"Error: {exc}\n")
        return 1

    out_path = Path(args.out) if args.out else None
    if args.format == "md":
        content = format_markdown(report)
        write_output(content, out_path)
    else:
        write_json(report, out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
