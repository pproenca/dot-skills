#!/usr/bin/env python3
"""Compare baseline and processed audio metrics."""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

sys.dont_write_bytecode = True

from preflight_lib import collect_preflight, parse_roi, require_tool, write_json, write_output


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Compare objective metrics between two audio files."
    )
    parser.add_argument("--before", required=True, help="Path to baseline/original audio")
    parser.add_argument("--after", required=True, help="Path to processed/enhanced audio")
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


def collect_metrics(report: dict) -> dict:
    metrics = {}
    derived = report.get("derived", {})
    for key, value in derived.items():
        if isinstance(value, (int, float)):
            metrics[f"derived.{key}"] = value
    astats = report.get("analysis", {}).get("astats", {}).get("overall_numeric", {})
    for key, value in astats.items():
        metrics[f"astats.{key}"] = value
    volumedetect = report.get("analysis", {}).get("volumedetect", {})
    for key in ["mean_volume_db", "max_volume_db"]:
        value = volumedetect.get(key)
        if isinstance(value, (int, float)):
            metrics[f"volumedetect.{key}"] = value
    return metrics


def format_markdown(diff: dict) -> str:
    lines = []
    lines.append("# Objective Comparison")
    lines.append("")
    lines.append("| Metric | Before | After | Delta |")
    lines.append("| --- | --- | --- | --- |")
    for key in sorted(diff.keys()):
        entry = diff[key]
        lines.append(
            f"| {key} | {entry['before']} | {entry['after']} | {entry['delta']} |"
        )
    lines.append("")
    lines.append("Note: Objective metrics must be combined with A/B listening review.")
    return "\n".join(lines)


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
        before_report = collect_preflight(Path(args.before), ffmpeg, ffprobe, roi)
        after_report = collect_preflight(Path(args.after), ffmpeg, ffprobe, roi)
    except Exception as exc:
        sys.stderr.write(f"Error: {exc}\n")
        return 1

    before_metrics = collect_metrics(before_report)
    after_metrics = collect_metrics(after_report)
    diff = {}
    for key, before_value in before_metrics.items():
        if key not in after_metrics:
            continue
        after_value = after_metrics[key]
        diff[key] = {
            "before": before_value,
            "after": after_value,
            "delta": after_value - before_value,
        }

    out_path = Path(args.out) if args.out else None
    if args.format == "md":
        content = format_markdown(diff)
        write_output(content, out_path)
    else:
        write_json(
            {
                "before": before_report,
                "after": after_report,
                "diff": diff,
            },
            out_path,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
