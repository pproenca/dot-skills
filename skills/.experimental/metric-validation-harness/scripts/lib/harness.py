#!/usr/bin/env python3
"""Shared helpers for the Python-based harness checks.

Config resolution, metric invocation, and pure-stdlib statistics (Spearman, AUC) — no
numpy/scipy required, so the harness runs anywhere Python 3.8+ is present.
Setting precedence everywhere: environment variable > config.json > built-in default.
"""
import csv
import json
import os
import shlex
import subprocess
import time

SKILL_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def _config():
    path = os.environ.get("HARNESS_CONFIG") or os.path.join(SKILL_ROOT, "config.json")
    if os.path.exists(path):
        try:
            return json.load(open(path, encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return {}
    return {}


def _resolve(value):
    return value.replace("{SKILL}", SKILL_ROOT) if isinstance(value, str) else value


def setting(name, env, default=""):
    if os.environ.get(env):
        return _resolve(os.environ[env])
    cfg = _config().get(name, "")
    return _resolve(cfg) if cfg else _resolve(default)


def metric_cmd():
    return setting("metric_cmd", "METRIC_CMD",
                   "python3 {SKILL}/scripts/examples/metric_ast_nodes.py")


def baseline_cmd():
    return setting("baseline_cmd", "BASELINE_CMD",
                   "python3 {SKILL}/scripts/examples/metric_loc.py")


def run_metric(cmd, path, timeout=120):
    """Invoke `cmd <path>`; return the single number printed. Raises on failure/non-numeric."""
    proc = subprocess.run(shlex.split(cmd) + [path],
                          capture_output=True, text=True, timeout=timeout)
    if proc.returncode != 0:
        raise RuntimeError(f"metric command failed on {path}: {proc.stderr.strip()}")
    out = proc.stdout.strip()
    try:
        return float(out)
    except ValueError:
        raise RuntimeError(
            f"metric did not print a number on {path} (got: {out!r}). "
            "The metric must print exactly ONE number to stdout."
        )


def timed_metric(cmd, path):
    start = time.perf_counter()
    run_metric(cmd, path)
    return time.perf_counter() - start


def read_corpus(labels_csv):
    base = os.path.dirname(os.path.abspath(labels_csv))
    with open(labels_csv, encoding="utf-8") as f:
        for row in csv.DictReader(f):
            row["_path"] = os.path.join(base, row["path"])
            yield row


def _rank(values):
    order = sorted(range(len(values)), key=lambda i: values[i])
    ranks = [0.0] * len(values)
    i = 0
    while i < len(values):
        j = i
        while j + 1 < len(values) and values[order[j + 1]] == values[order[i]]:
            j += 1
        avg = (i + j) / 2.0 + 1.0  # average (1-based) rank for ties
        for k in range(i, j + 1):
            ranks[order[k]] = avg
        i = j + 1
    return ranks


def spearman(x, y):
    """Spearman rank correlation. Returns None if undefined (n<2 or zero variance)."""
    if len(x) != len(y) or len(x) < 2:
        return None
    rx, ry = _rank(x), _rank(y)
    n = len(x)
    mx, my = sum(rx) / n, sum(ry) / n
    num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
    dx = sum((a - mx) ** 2 for a in rx) ** 0.5
    dy = sum((b - my) ** 2 for b in ry) ** 0.5
    if dx == 0 or dy == 0:
        return None
    return num / (dx * dy)


def auc(scores, labels):
    """Area under ROC (Mann–Whitney U). labels are 0/1. Returns None if a class is empty."""
    pos = [s for s, l in zip(scores, labels) if l == 1]
    neg = [s for s, l in zip(scores, labels) if l == 0]
    if not pos or not neg:
        return None
    wins = sum((1.0 if p > n else 0.5 if p == n else 0.0) for p in pos for n in neg)
    return wins / (len(pos) * len(neg))
