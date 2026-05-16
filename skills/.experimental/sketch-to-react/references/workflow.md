# Detailed Workflow

Read this when executing the full conversion or troubleshooting a step. Each step lists inputs, outputs, failure modes, and how to recover.

## Step 1 — Preflight

**Script:** `scripts/preflight.sh <sketch-file> [--dry-run] [--force]`

**Inputs:**
- Path to a `.sketch` file
- `config.json` with all six fields populated

**Outputs:**
- `work/.sketch-path` (records the source file)
- `work/.preflight-stamp` (UTC timestamp)

**Checks:**
- sketchtool binary is executable
- Node.js ≥ 18 is on PATH
- All `config.json` fields are non-empty
- Target output paths have no conflicts (or `--force` is passed)

**Failure modes:**
- `ERROR: Sketch file not found` → wrong path, fix the argument
- `ERROR: sketchtool not found` → install Sketch.app or fix `sketchtool_path` in `config.json`
- `Overwrite would occur at...` → pass `--force` or remove the conflicting files

**Rollback:** Nothing written outside `work/`. Delete `work/` to fully reset.

---

## Step 2 — Parse

**Script:** `scripts/parse.sh <sketch-file>`

**Inputs:** Source `.sketch` file. Requires preflight stamp.

**Outputs:**
- `work/document.json` — full sketchtool dump of every layer in every page
- `work/structure.json` — `{pages, artboards}` summary for navigation
- `work/.parse-hash` — SHA-256 of the input file (used for cache hits)

**Idempotency:** Re-running with the same `.sketch` file is a no-op (exit code 2). Touching the source file invalidates the cache automatically.

**Failure modes:**
- `sketchtool dump` exit ≠ 0 → typically a corrupt or unsupported-version `.sketch` file. Open the file in Sketch.app first; if it opens, re-save and retry.

**Rollback:** Delete `work/document.json`, `work/structure.json`, `work/.parse-hash`.

---

## Step 3 — Extract tokens

**Script:** `node scripts/extract-tokens.js [--dry-run]`

**Inputs:** `work/document.json`

**Outputs:**
- `<output_root>/<tokens_path>` — `:root { --color-…; --font-…; --radius-…; --shadow-…; --space-…; }`
- `work/tokens.json` — JSON map (hex → var name, etc.) consumed by Step 5

**Naming logic:**
- Colors with a name in `assets.colorAssets` → `--color-<slug>`
- Unnamed colors → `--color-<6-char-hash-of-hex>` (stable across runs)
- Fonts → `--font-<family-slug>-<rounded-size>-size` / `-family`
- Radii → `--radius-<px>`
- Shadows → `--shadow-<6-char-hash-of-css>`
- Spacings → `--space-<px>` (only includes round multiples of 4 ≤ 256)

See `references/token-mapping.md` for the full mapping rules and rationale.

**Failure modes:**
- `ERROR: required input missing` → run Step 2 first
- Empty output → Sketch document has no fills/strokes/text, or document is empty

**Rollback:** Delete `<output_root>/<tokens_path>` and `work/tokens.json`. Re-run.

---

## Step 4 — Export assets

**Script:** `scripts/export-assets.sh <sketch-file> [--dry-run]`

**Inputs:** Source `.sketch` file.

**Outputs:**
- `<output_root>/<assets_dir>/*.png` (1x + 2x scales)
- `<output_root>/<icons_dir>/*.tsx` (SVG → React via SVGR)
- `work/svgs/*.svg` (staging — kept for debugging)
- `work/assets-manifest.json` — `{raster: [...], icons: [...]}`

**How it picks what to export:** sketchtool only exports layers marked **Exportable** in the Sketch UI. Layers without the export flag are skipped entirely.

**Failure modes:**
- Exit code 2 → no slices marked exportable. Open the Sketch file and mark layers in the right-panel Make Exportable section. This is the most common surprise.
- SVGR failure → usually means a malformed SVG. Inspect `work/svgs/` to find the offending file.
- `npx @svgr/cli` first-run download fails → check network. Pin with `npm i -D @svgr/cli` if the project is offline-sensitive.

**Rollback:** Delete `<output_root>/<assets_dir>` and `<output_root>/<icons_dir>`. Re-run.

---

## Step 5 — Generate components

**Script:** `node scripts/generate-components.js [--artboard <name>] [--dry-run]`

**Inputs:**
- `work/document.json`
- `work/tokens.json`
- `work/assets-manifest.json`

**Outputs:** For each artboard `<Name>`:
- `<output_root>/<components_dir>/<Name>.tsx`
- `<output_root>/<components_dir>/<Name>.module.css`

**Generation rules:**
- Artboard → top-level `<div>` (the root has `position: relative` so absolute children anchor correctly)
- Each child layer → `<div>` with `position: absolute` and `left/top/width/height` from the Sketch frame
- Text layers → `<span>` with the literal text (special chars `{` and `}` escaped to JSX expressions)
- Bitmap layers → `<img src="/<ref>" alt={name} />` referencing the exported raster
- Style values pulled from `tokens.json` when an exact match exists, otherwise inlined as literals

**Why absolute positioning instead of flex/grid?** The Sketch document is positional, not semantic — there's no reliable way to infer flex direction or grid gaps from coordinates. The output is a *scaffold* that matches the design pixel-for-pixel; refactor to flex/grid manually once the structure is clear. This is intentional, not a bug.

**Selective generation:** `--artboard "Login Screen"` regenerates only that one component pair. Useful while iterating on a single screen.

**Failure modes:**
- `ERROR: artboard "X" not found` → run with no `--artboard` flag to see the available names, then retry.
- Prettier crash → continues without formatting; warning printed.

**Rollback:** Delete the generated `.tsx` / `.module.css` pairs. The skill never modifies sibling files, so a delete is sufficient.

---

## Step 6 — Verify

**Script:** `scripts/verify.sh`

**Inputs:** Everything Steps 3–5 wrote.

**Checks (PASS/FAIL each):**
- Tokens file exists and has ≥ 1 `--color-*` variable
- Every artboard in the document has a matching `.tsx` + `.module.css`
- `tsc --noEmit` passes (if `tsconfig.json` exists at the project root)
- No `styles['…']` reference in JSX is missing from the matching CSS module
- Asset manifest is present

**Exit codes:** 0 = all PASS, 1 = at least one FAIL.

**What to do on FAIL:** The failure message names the specific assertion. Most failures point to a Step 3/4/5 problem — re-run that step after fixing.

---

## Full pipeline (happy path)

```bash
SKETCH=./design.sketch

bash scripts/preflight.sh "$SKETCH" \
  && bash scripts/parse.sh "$SKETCH" \
  && node scripts/extract-tokens.js \
  && bash scripts/export-assets.sh "$SKETCH" \
  && node scripts/generate-components.js \
  && bash scripts/verify.sh
```

## Rollback the entire run

Because every write target is configured and the skill writes nothing outside those paths, rollback is:

```bash
rm -rf src/components src/components/icons src/assets src/styles/tokens.module.css work/
```

If the project is under git, `git clean -fdx <output_root>` followed by `git checkout -- <output_root>` is safer.
