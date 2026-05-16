# Scripts

| Script | Purpose | Risk |
|--------|---------|------|
| `analyze_complexity.py` | Heuristic complexity-hotspot scanner. AST-based for Python; regex-based pattern matching for JS/TS/JSX/TSX/Java/Go/Ruby/PHP/C#/C/C++/Swift/Vue/Svelte/Kotlin/Rust/Dart/Scala. Treat output as leads, not proof. | read-only |

## `analyze_complexity.py`

**Invocation:**

```bash
python3 scripts/analyze_complexity.py <repo-or-dir> [--format markdown|json] [--exclude DIR ...] [--max-findings N]
```

**Exit codes:**

| Code | Meaning |
|------|---------|
| 0    | Scan completed successfully (zero or more findings reported) |
| 2    | Bad input: path does not exist, or path is a file (must be a directory) |
| 3    | Scanned 0 files — check path / extensions / `--exclude` flags |
| 130  | Interrupted (Ctrl-C) |

**Output:** markdown (default) or JSON. Markdown ends with `_Scanned N files (M skipped)._` so the model can confirm work was performed. JSON output shape: `{ files_scanned, files_failed, findings: [...] }`.

**Heuristics intentionally lean on the side of false negatives over false positives.** The scanner is correct enough to surface true hotspots and conservative enough to avoid drowning the model in noise. Always inspect the surrounding code before recommending a fix.

**Limitations:**

- Only Python gets real AST analysis. All other languages use line-based regex matching: nesting tracked by indent + function-boundary heuristic.
- Templated languages (`.vue`, `.svelte`) are scanned across the full file, including non-script sections.
- `--exclude` matches bare directory names, not paths. For monorepo-scoped runs, point `root` at the package subdirectory instead.
