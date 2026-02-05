#!/usr/bin/env python3
"""Shared helpers for audio preflight scripts."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple


FLOAT_RE = re.compile(r"-?\d+(?:\.\d+)?")
EBUR128_I_RE = re.compile(r"\bI:\s*(-?\d+(?:\.\d+)?)\s*LUFS")
EBUR128_LRA_RE = re.compile(r"\bLRA:\s*(-?\d+(?:\.\d+)?)\s*LU\b")
EBUR128_TP_RE = re.compile(r"\bPeak:\s*(-?\d+(?:\.\d+)?)\s*dBFS")


def parse_float(value: str) -> Optional[float]:
    match = FLOAT_RE.search(value)
    if not match:
        return None
    try:
        return float(match.group(0))
    except ValueError:
        return None


def run_cmd(cmd: List[str]) -> Tuple[str, str]:
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(
            f"Command failed ({proc.returncode}): {' '.join(cmd)}\n{proc.stderr.strip()}"
        )
    return proc.stdout, proc.stderr


def require_tool(path: Optional[str], name: str) -> str:
    if path:
        return path
    resolved = shutil_which(name)
    if not resolved:
        raise RuntimeError(f"Required tool not found: {name}")
    return resolved


def shutil_which(name: str) -> Optional[str]:
    for base in os.environ.get("PATH", "").split(os.pathsep):
        candidate = Path(base) / name
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return str(candidate)
    return None


def sha256_file(path: Path) -> str:
    hasher = hashlib.sha256()
    with path.open("rb") as handle:
        while True:
            chunk = handle.read(1024 * 1024)
            if not chunk:
                break
            hasher.update(chunk)
    return hasher.hexdigest()


def tool_version(cmd: str) -> str:
    stdout, _ = run_cmd([cmd, "-version"])
    return stdout.splitlines()[0].strip() if stdout else "unknown"


def run_ffprobe(ffprobe: str, input_path: Path) -> Dict[str, Any]:
    stdout, _ = run_cmd(
        [
            ffprobe,
            "-v",
            "error",
            "-show_format",
            "-show_streams",
            "-print_format",
            "json",
            str(input_path),
        ]
    )
    return json.loads(stdout)


def run_ffmpeg_astats(
    ffmpeg: str, input_path: Path, roi: Optional[Dict[str, float]]
) -> Dict[str, Any]:
    cmd = [ffmpeg, "-hide_banner", "-nostats", "-v", "info", "-i", str(input_path)]
    if roi:
        cmd += ["-ss", str(roi["start"]), "-t", str(roi["duration"])]
    cmd += ["-af", "astats=metadata=1:reset=1", "-f", "null", "-"]
    _, stderr = run_cmd(cmd)
    return parse_astats(stderr)


def run_ffmpeg_volumedetect(
    ffmpeg: str, input_path: Path, roi: Optional[Dict[str, float]]
) -> Dict[str, Any]:
    cmd = [ffmpeg, "-hide_banner", "-nostats", "-v", "info", "-i", str(input_path)]
    if roi:
        cmd += ["-ss", str(roi["start"]), "-t", str(roi["duration"])]
    cmd += ["-af", "volumedetect", "-f", "null", "-"]
    _, stderr = run_cmd(cmd)
    return parse_volumedetect(stderr)


def run_ffmpeg_ebur128(
    ffmpeg: str, input_path: Path, roi: Optional[Dict[str, float]]
) -> Dict[str, Any]:
    cmd = [ffmpeg, "-hide_banner", "-nostats", "-v", "info", "-i", str(input_path)]
    if roi:
        cmd += ["-ss", str(roi["start"]), "-t", str(roi["duration"])]
    cmd += ["-af", "ebur128=peak=true", "-f", "null", "-"]
    _, stderr = run_cmd(cmd)
    return parse_ebur128(stderr)


def parse_astats(stderr: str) -> Dict[str, Any]:
    lines = [line for line in stderr.splitlines() if "astats" in line.lower()]
    overall_raw: Dict[str, str] = {}
    overall_numeric: Dict[str, float] = {}
    in_overall = False

    for line in lines:
        if "Overall" in line:
            in_overall = True
            continue
        if "Channel" in line:
            in_overall = False
        if not in_overall:
            continue
        match = re.search(r"\]\s*(.+?):\s*(.+)$", line)
        if not match:
            continue
        key = match.group(1).strip()
        value = match.group(2).strip()
        overall_raw[key] = value
        numeric = parse_float(value)
        if numeric is not None:
            overall_numeric[key] = numeric

    return {"overall": overall_raw, "overall_numeric": overall_numeric, "raw": lines}


def parse_volumedetect(stderr: str) -> Dict[str, Any]:
    lines = [line for line in stderr.splitlines() if "volumedetect" in line.lower()]
    mean_volume_db = None
    max_volume_db = None

    for line in lines:
        match = re.search(r"(mean_volume|max_volume):\s*([-\d.]+)\s*dB", line)
        if not match:
            continue
        label = match.group(1)
        value = float(match.group(2))
        if label == "mean_volume":
            mean_volume_db = value
        elif label == "max_volume":
            max_volume_db = value

    return {
        "mean_volume_db": mean_volume_db,
        "max_volume_db": max_volume_db,
        "raw": lines,
    }


def parse_ebur128(stderr: str) -> Dict[str, Any]:
    lines = stderr.splitlines()
    integrated_lufs = None
    loudness_range_lu = None
    true_peak_dbfs = None

    for line in lines:
        match = EBUR128_I_RE.search(line)
        if match:
            integrated_lufs = float(match.group(1))
        match = EBUR128_LRA_RE.search(line)
        if match:
            loudness_range_lu = float(match.group(1))
        match = EBUR128_TP_RE.search(line)
        if match:
            true_peak_dbfs = float(match.group(1))

    raw = [line for line in lines if "ebur128" in line.lower()]
    return {
        "integrated_lufs": integrated_lufs,
        "loudness_range_lu": loudness_range_lu,
        "true_peak_dbfs": true_peak_dbfs,
        "raw": raw,
    }


def extract_audio_stream(ffprobe_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    streams = ffprobe_data.get("streams", [])
    for stream in streams:
        if stream.get("codec_type") == "audio":
            return stream
    return None


def derive_metrics(
    astats: Dict[str, Any], volumedetect: Dict[str, Any], ebur128: Dict[str, Any]
) -> Dict[str, Any]:
    derived: Dict[str, Any] = {}
    overall = astats.get("overall_numeric", {})
    derived["peak_level_db"] = overall.get("Peak level dB")
    derived["rms_level_db"] = overall.get("RMS level dB")
    derived["dc_offset"] = overall.get("DC offset")
    derived["dynamic_range"] = overall.get("Dynamic range")
    derived["max_level"] = overall.get("Max level")
    derived["clipping"] = overall.get("Clipping")

    clipping_detected = None
    if derived.get("clipping") is not None:
        clipping_detected = derived["clipping"] > 0
    elif derived.get("max_level") is not None:
        clipping_detected = derived["max_level"] >= 1.0
    elif derived.get("peak_level_db") is not None:
        clipping_detected = derived["peak_level_db"] >= 0.0

    derived["clipping_detected"] = clipping_detected

    if volumedetect:
        derived["mean_volume_db"] = volumedetect.get("mean_volume_db")
        derived["max_volume_db"] = volumedetect.get("max_volume_db")

    if ebur128:
        derived["integrated_lufs"] = ebur128.get("integrated_lufs")
        derived["loudness_range_lu"] = ebur128.get("loudness_range_lu")
        derived["true_peak_dbfs"] = ebur128.get("true_peak_dbfs")

    return derived


def parse_roi(roi: Optional[str]) -> Optional[Dict[str, float]]:
    if not roi:
        return None
    parts = [part.strip() for part in roi.split(",") if part.strip()]
    if len(parts) != 2:
        raise ValueError("ROI must be formatted as start,end (seconds)")
    start = float(parts[0])
    end = float(parts[1])
    if start < 0 or end < 0:
        raise ValueError("ROI values must be non-negative")
    if end <= start:
        raise ValueError("ROI end must be greater than start")
    return {"start": start, "end": end, "duration": end - start}


def collect_preflight(
    input_path: Path,
    ffmpeg: str,
    ffprobe: str,
    roi: Optional[Dict[str, float]],
) -> Dict[str, Any]:
    if not input_path.exists():
        raise FileNotFoundError(f"Input not found: {input_path}")

    ffprobe_data = run_ffprobe(ffprobe, input_path)
    audio_stream = extract_audio_stream(ffprobe_data)
    astats = run_ffmpeg_astats(ffmpeg, input_path, roi)
    volumedetect = run_ffmpeg_volumedetect(ffmpeg, input_path, roi)
    ebur128 = run_ffmpeg_ebur128(ffmpeg, input_path, roi)

    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "input": {
            "path": str(input_path),
            "sha256": sha256_file(input_path),
            "file_size_bytes": input_path.stat().st_size,
        },
        "roi": roi,
        "ffprobe": ffprobe_data,
        "audio_stream": audio_stream,
        "analysis": {
            "astats": astats,
            "volumedetect": volumedetect,
            "ebur128": ebur128,
        },
        "derived": derive_metrics(astats, volumedetect, ebur128),
        "tool_versions": {
            "ffmpeg": tool_version(ffmpeg),
            "ffprobe": tool_version(ffprobe),
        },
    }
    return report


def format_markdown(report: Dict[str, Any]) -> str:
    input_info = report.get("input", {})
    derived = report.get("derived", {})
    audio_stream = report.get("audio_stream", {}) or {}
    lines = []
    lines.append("# Audio Preflight Report")
    lines.append("")
    lines.append("## Evidence Identity")
    lines.append(f"- Path: {input_info.get('path', 'unknown')}")
    lines.append(f"- SHA-256: {input_info.get('sha256', 'unknown')}")
    lines.append(f"- File size (bytes): {input_info.get('file_size_bytes', 'unknown')}")
    lines.append("")
    lines.append("## Signal Integrity")
    lines.append(f"- Codec: {audio_stream.get('codec_name', 'unknown')}")
    lines.append(f"- Sample rate: {audio_stream.get('sample_rate', 'unknown')}")
    lines.append(f"- Bit depth: {audio_stream.get('bits_per_sample') or audio_stream.get('bits_per_raw_sample') or 'unknown'}")
    lines.append(f"- Channels: {audio_stream.get('channels', 'unknown')}")
    lines.append("")
    lines.append("## Baseline Metrics")
    lines.append(f"- Peak level (dB): {derived.get('peak_level_db', 'unknown')}")
    lines.append(f"- RMS level (dB): {derived.get('rms_level_db', 'unknown')}")
    lines.append(f"- Mean volume (dB): {derived.get('mean_volume_db', 'unknown')}")
    lines.append(f"- Max volume (dB): {derived.get('max_volume_db', 'unknown')}")
    lines.append(f"- Integrated loudness (LUFS): {derived.get('integrated_lufs', 'unknown')}")
    lines.append(f"- Loudness range (LU): {derived.get('loudness_range_lu', 'unknown')}")
    lines.append(f"- True peak (dBFS): {derived.get('true_peak_dbfs', 'unknown')}")
    lines.append(f"- Dynamic range: {derived.get('dynamic_range', 'unknown')}")
    lines.append(f"- DC offset: {derived.get('dc_offset', 'unknown')}")
    lines.append("")
    lines.append("## Clipping Indicators")
    lines.append(f"- Clipping detected: {derived.get('clipping_detected', 'unknown')}")
    lines.append(f"- Clipping metric: {derived.get('clipping', 'unknown')}")
    lines.append(f"- Max level: {derived.get('max_level', 'unknown')}")
    lines.append("")
    roi = report.get("roi")
    lines.append("## ROI")
    lines.append(f"- ROI: {roi if roi else 'full file'}")
    lines.append("")
    lines.append("## Tool Versions")
    tool_versions = report.get("tool_versions", {})
    lines.append(f"- FFmpeg: {tool_versions.get('ffmpeg', 'unknown')}")
    lines.append(f"- FFprobe: {tool_versions.get('ffprobe', 'unknown')}")
    lines.append("")
    return "\n".join(lines)


def write_output(content: str, out_path: Optional[Path]) -> None:
    if out_path:
        out_path.write_text(content)
        return
    sys.stdout.write(content)


def write_json(report: Dict[str, Any], out_path: Optional[Path]) -> None:
    content = json.dumps(report, indent=2)
    if out_path:
        out_path.write_text(content)
        return
    sys.stdout.write(content)
