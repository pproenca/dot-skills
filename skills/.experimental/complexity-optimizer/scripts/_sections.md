# Scripts

| Script | Purpose | Risk |
|--------|---------|------|
| `analyze_complexity.py` | Heuristic complexity-hotspot scanner. AST-based for Python; regex-based pattern matching for JS/TS/JSX/TSX/Java/Go/Ruby/PHP/C#/C/C++/Swift/Vue/Svelte/Kotlin/Rust/Dart/Scala. | read-only |
| `test_analyze_complexity.py` | 13 regression tests pinning the scanner's false-positive fixes (nested-loop detection, cross-function isolation, SCREAMING_SNAKE handling, exit codes, `--changed-only`). | read-only |

## `analyze_complexity.py`

**Invocation:**

```bash
python3 scripts/analyze_complexity.py <repo-or-dir> [flags]
```

**Flags:**

| Flag | Default | Purpose |
|------|---------|---------|
| `--format markdown\|json` | markdown | Output format. JSON includes `files_scanned`, `files_failed`, `findings[]`. |
| `--exclude DIR` | (repeatable) | Skip directories with this name anywhere in the tree. |
| `--max-findings N` | 80 | Cap reported findings (sorted by severity then path). |
| `--changed-only` | off | Scan only files changed vs `--base`. Requires a git repo at root. |
| `--base REF` | `HEAD~1` | Git ref to diff against when `--changed-only` is set. Examples: `origin/main`, `HEAD`, `HEAD~5`. |

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0    | Scan completed (zero or more findings reported; `--changed-only` with no matching files also returns 0) |
| 2    | Bad input: path does not exist, path is a file (not directory), or `git diff` failed |
| 3    | Scanned 0 files — check path / extensions / `--exclude` flags |
| 130  | Interrupted (Ctrl-C) |

**Output:** markdown (default) or JSON. Markdown ends with `_Scanned N files (M skipped)._` JSON output shape:

```json
{
  "files_scanned": 42,
  "files_failed": 0,
  "findings": [{ "path": "...", "line": 5, "severity": "high", "kind": "nested-loop", "message": "...", "suggestion": "..." }]
}
```

**Heuristics intentionally lean on false negatives over false positives.** The scanner is correct enough to surface true hotspots and conservative enough to avoid drowning the model in noise. Always read the surrounding code before recommending a fix — consult `references/false-positives.md` for known noise patterns.

**Limitations:**

- Only Python gets real AST analysis. All other languages use line-based regex matching: nesting tracked by indent + function-boundary heuristic.
- Templated languages (`.vue`, `.svelte`) are scanned across the full file, including non-script sections — false positives possible inside `<template>` blocks.
- `--exclude` matches bare directory names, not paths. For monorepo-scoped runs, point `root` at the package subdirectory or use `--changed-only`.

## `test_analyze_complexity.py`

**Invocation:**

```bash
python3 scripts/test_analyze_complexity.py
```

Prints one `✓` or `✗` per case, returns exit 0 on success. Uses stdlib only (`subprocess`, `tempfile`, `pathlib`). The `--changed-only` test creates a throwaway git repo via `subprocess.run(["git", "init"])` — skipped if `git` is not on PATH.
