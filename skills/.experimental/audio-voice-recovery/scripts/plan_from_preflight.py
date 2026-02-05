#!/usr/bin/env python3
"""Create a processing plan template from a preflight JSON report."""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Generate a workflow plan from a preflight report."
    )
    parser.add_argument("--preflight", required=True, help="Path to preflight JSON")
    parser.add_argument("--out", help="Output markdown file (default: stdout)")
    return parser


def format_value(value: object) -> str:
    return "unknown" if value is None else str(value)


def main() -> int:
    parser = build_arg_parser()
    args = parser.parse_args()

    try:
        preflight = json.loads(Path(args.preflight).read_text())
    except Exception as exc:
        sys.stderr.write(f"Error reading preflight JSON: {exc}\n")
        return 1

    derived = preflight.get("derived", {})
    input_info = preflight.get("input", {})
    roi = preflight.get("roi")
    audio_stream = preflight.get("audio_stream", {}) or {}

    lines = []
    lines.append("# Processing Plan (Template)")
    lines.append("")
    lines.append("## Evidence And Scope")
    lines.append(f"- File: {format_value(input_info.get('path'))}")
    lines.append(f"- SHA-256: {format_value(input_info.get('sha256'))}")
    lines.append(f"- ROI: {format_value(roi) if roi else 'full file'}")
    lines.append("")
    lines.append("## Baseline Summary")
    lines.append(f"- Codec: {format_value(audio_stream.get('codec_name'))}")
    lines.append(f"- Sample rate: {format_value(audio_stream.get('sample_rate'))}")
    lines.append(f"- Bit depth: {format_value(audio_stream.get('bits_per_sample') or audio_stream.get('bits_per_raw_sample'))}")
    lines.append(f"- Peak level (dB): {format_value(derived.get('peak_level_db'))}")
    lines.append(f"- RMS level (dB): {format_value(derived.get('rms_level_db'))}")
    lines.append(f"- Mean volume (dB): {format_value(derived.get('mean_volume_db'))}")
    lines.append(f"- Max volume (dB): {format_value(derived.get('max_volume_db'))}")
    lines.append(f"- Integrated loudness (LUFS): {format_value(derived.get('integrated_lufs'))}")
    lines.append(f"- Loudness range (LU): {format_value(derived.get('loudness_range_lu'))}")
    lines.append(f"- True peak (dBFS): {format_value(derived.get('true_peak_dbfs'))}")
    lines.append(f"- Dynamic range: {format_value(derived.get('dynamic_range'))}")
    lines.append(f"- DC offset: {format_value(derived.get('dc_offset'))}")
    lines.append(f"- Clipping detected: {format_value(derived.get('clipping_detected'))}")
    lines.append("")
    lines.append("## Risks And Constraints")
    lines.append("- Note any clipping indicators, noise type, or artifacts from listening checks.")
    lines.append("- Record any chain-of-custody constraints, tool limitations, or time constraints.")
    lines.append("")
    lines.append("## Proposed Workflow Order (Fill In)")
    lines.append("1. Preserve original and create working copy with hashes.")
    lines.append("2. If clipping is detected, declip before any denoise/EQ/compression.")
    lines.append("3. Address DC offset if present.")
    lines.append("4. Profile noise and choose a reduction strategy (stationary vs non-stationary).")
    lines.append("5. Apply targeted spectral or temporal repairs (clicks, dropouts, hum).")
    lines.append("6. Apply speech-focused enhancement (EQ/voice isolation) as needed.")
    lines.append("7. Re-check clipping and loudness; avoid over-processing.")
    lines.append("8. Run objective comparison and A/B listening review.")
    lines.append("")
    lines.append("## Success Criteria")
    lines.append("- Define objective metrics to improve (e.g., reduced clipping indicators, improved SNR).")
    lines.append("- Define subjective criteria (intelligibility, artifact tolerance).")
    lines.append("- Require A/B listening review before declaring completion.")
    lines.append("")

    output = "\n".join(lines)
    out_path = Path(args.out) if args.out else None
    if out_path:
        out_path.write_text(output)
    else:
        sys.stdout.write(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
