# Workflow: verifying an Expo iOS app against HIG

This document describes how `scripts/verify-hig.sh` works, how to read its output, and how to extend it.

## Running

```bash
bash scripts/verify-hig.sh [project-dir] [--strict] [--json]
```

- `project-dir` — root of the Expo project to scan. Defaults to the current directory.
- `--strict` — exit non-zero on advisories as well as errors (use in CI to enforce everything).
- `--json` — emit findings as a JSON array (for tooling) instead of the text report.

The script is **read-only**. It opens no network connections and writes nothing to the target project.

## How it works

1. **Resolve search roots.** From `config.json` (`search_roots`) or the default `app src components`. Roots that don't exist are skipped; if none exist, the whole project is scanned.
2. **Pick a search tool.** `rg` (ripgrep) if installed — faster and respects `.gitignore` — otherwise `grep -rEn`. Both restrict to `.ts/.tsx/.js/.jsx` and exclude `node_modules`.
3. **Run checks.** Each check is one call to `check <severity> <rule> "<message>" "<regex>"`, which records a finding per matching line. The list/`.map` heuristic is a special check (`check_scrollview_map`).
4. **Report.** Findings are grouped into ERRORS then ADVISORIES, each with `file:line` and a link to `expo-ios-hig/references/<rule>.md`.
5. **Exit.** `0` if clean; `1` if any ERROR; with `--strict`, `1` if any advisory too.

## Reading the output

```
ERRORS:
  [native-avoid-material-ui] Material Design component kit imported on iOS
    app/(trails)/new.tsx:3:import { FAB } from 'react-native-paper'
    -> ../expo-ios-hig/references/native-avoid-material-ui.md
```

- **ERRORS** are high-precision (import paths and literal flags). Treat them as must-fix before shipping.
- **ADVISORIES** are heuristics with possible false positives (a hex color in a theme file, a custom display font on a hero). Review each; some are intentional exceptions documented in the corresponding rule's "When NOT to use this pattern" section.

## Fixing a finding

Open the linked rule file. Each `expo-ios-hig` rule has an **Incorrect** (the pattern this verifier flags) and a **Correct** example that is a minimal diff. Apply the correct form.

## Extending the checks

Add a line inside `run_checks()` in `scripts/verify-hig.sh`:

```bash
check ERROR <rule-slug> "<human message>" "<extended-regex>"
```

- `<rule-slug>` must match a file under `expo-ios-hig/references/` so the report link resolves.
- Use `ERROR` only for high-precision patterns (imports, literal flags). Use `ADVISORY` for heuristics that may false-positive.
- The regex is extended (ERE) and is passed to both `rg -e` and `grep -E`, so keep it portable (avoid PCRE-only constructs like lookaround).

For a multi-condition check (a file matching pattern A *and* pattern B), follow the shape of `check_scrollview_map()`.

## Limitations

- These are **textual** checks, not a type-aware AST analysis. They catch the common, high-signal patterns but cannot verify, for example, that every icon-only `Pressable` has an `accessibilityLabel` (that needs an ESLint rule with JSX analysis).
- Advisory heuristics will flag legitimate exceptions; that is by design — they prompt a look, not a guaranteed defect.
