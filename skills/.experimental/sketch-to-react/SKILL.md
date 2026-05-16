---
name: sketch-to-react
description: Use this skill whenever the user wants to convert a Sketch file (.sketch) into React components with CSS Modules — generating design tokens, exporting assets (PNG/JPG + inline SVG icons), and scaffolding one .tsx + .module.css pair per artboard. Trigger on phrases like "convert this Sketch to React", "scaffold components from .sketch", "extract design tokens from Sketch", or any task pointing at a .sketch file alongside a React/TypeScript project. Also trigger when the user hands over a .sketch file with no explicit framing — Sketch → React is the assumed intent in a React workspace.
---

# Sketch → React Components

Automates conversion of a `.sketch` binary file into a React + CSS Modules component set, with extracted design tokens and exported assets. The workflow is **idempotent** (rerun = same result), supports **dry-run** mode, and **never overwrites** files without explicit confirmation.

## When to Apply

- User has a `.sketch` file and a React/TypeScript project, and asks to "convert" or "scaffold" components.
- User wants to extract design tokens (colors, typography, spacing) from a Sketch document into CSS variables.
- User wants to bulk-export icons/images from Sketch as React-ready assets.
- Designer hands off a Sketch file mid-project and engineering needs the styles + structure as a starting point — not pixel-perfect, but real CSS + JSX to refactor.

**Do NOT use** for: Figma files (different format), reverse-engineering production sites, or pixel-perfect screenshot replication. The output is a *scaffold*, not a finished component — expect to refine.

## Workflow Overview

```
.sketch ─▶ [1] preflight ─▶ [2] parse ─▶ [3] tokens ─▶ [4] assets ─▶ [5] components ─▶ [6] verify
```

| # | Step | Script | Output |
|---|------|--------|--------|
| 1 | Preflight | `scripts/preflight.sh` | Validates env (incl. App-Store-vs-direct Sketch), paths, overwrite plan |
| 2 | Parse | `scripts/parse.sh` | Unzips JSON from .sketch → `work/document.json`, `work/structure.json` |
| 3 | Tokens | `scripts/extract-tokens.js` | `<tokens_path>` + `work/tokens.json` (reads `sharedSwatches` for names) |
| 4 | Assets | `scripts/export-assets.sh` | PNG/JPG in `<assets_dir>`, SVG-as-TSX in `<icons_dir>` (sketchtool needed here) |
| 5 | Components | `scripts/generate-components.js` | One `.tsx` + `.module.css` per artboard / symbol in `<components_dir>` |
| 6 | Verify | `scripts/verify.sh` | Pass/fail summary + counts |

Full step details with rollback notes: [`references/workflow.md`](references/workflow.md).

## Tool Requirements

| Tool | Required | Why | How to get it |
|------|----------|-----|--------------|
| `unzip` | Yes | Extracts the .sketch archive (it's a ZIP) | Ships with macOS |
| `node` ≥ 18 | Yes | Runs parser/generator scripts | `brew install node` |
| `sketchtool` | For asset export only | `export slices` to PNG/SVG | Bundled with the direct-download Sketch.app on macOS (not the Mac App Store build — see `gotchas.md`) |
| `npx @svgr/cli` | If exporting icons | Converts exported SVGs → React components | Used via `npx` (no install needed) |
| `prettier` | Optional | Formats generated files | `npm i -D prettier` — auto-detected |
| `tsc` | Optional | Type-checks generated TSX | `npm i -D typescript` — auto-detected |

The parse step reads `.sketch` JSON directly (the file is a ZIP archive containing `document.json` + `pages/*.json`), so steps 1–3 and 5–6 work cross-platform. Only asset export needs sketchtool (macOS only).

## Risk & Guardrails

- **Risk level: Write.** Creates files inside the user's project. Does not delete or modify existing source files outside the configured output paths.
- **Overwrite protection:** Preflight scans target paths for existing files. If any conflict, the workflow stops and prints the list — the user must pass `--force` to proceed.
- **Dry-run:** Every script accepts `--dry-run` to print intended operations without writing.
- **Hook:** A PreToolUse hook ([`hooks/hooks.json`](hooks/hooks.json)) warns before any `rm -rf` inside the configured output paths.

## Setup

On first run, if `config.json` has empty fields, ask the user via `AskUserQuestion`:

- `output_root` (e.g., `src/`)
- `components_dir` (relative to output_root, e.g., `components/`)
- `icons_dir` (e.g., `components/icons/`)
- `assets_dir` (e.g., `assets/`)
- `tokens_path` (e.g., `styles/tokens.module.css`)
- `sketchtool_path` (default `/Applications/Sketch.app/Contents/Resources/sketchtool/bin/sketchtool`)

Save responses to `config.json` then proceed.

## How to Use

Typical invocation:

```bash
# 1. Run preflight + dry-run to see the plan
bash scripts/preflight.sh path/to/design.sketch --dry-run

# 2. Execute the pipeline
bash scripts/preflight.sh path/to/design.sketch \
  && bash scripts/parse.sh path/to/design.sketch \
  && node scripts/extract-tokens.js \
  && bash scripts/export-assets.sh path/to/design.sketch \
  && node scripts/generate-components.js \
  && bash scripts/verify.sh
```

For one-artboard-at-a-time generation, pass `--artboard "ArtboardName"` to `generate-components.js`.

## How Sketch Maps to Code

- **`sharedSwatches` (named colors) + document colors / text styles** → CSS custom properties in `tokens.module.css` (see [`references/token-mapping.md`](references/token-mapping.md))
- **Artboards AND `symbolMaster`s** → top-level components (`<Name>.tsx`). Modern UI kits ship almost entirely as symbol masters; screen-design docs ship as artboards. Both are treated as component roots.
- **Groups** → wrapping `<div>` with a class derived from the group name
- **Text layers** → `<span>` / `<h*>` / `<p>` based on type ramp (see [`references/layer-to-jsx.md`](references/layer-to-jsx.md))
- **Bitmap layers** → `<img src={...} />` referencing exported PNG/JPG
- **Symbols with vector content** → rendered as SVG React components from `icons/`
- **Shadows / borders / radii** → translated to CSS, deduplicated via tokens where possible

## Gotchas

See [`gotchas.md`](gotchas.md). Append new failure modes as they surface during use.

## Related Skills

- Consider creating a **Product Verification** skill (`/dev-skill:new`, type 2) to assert the generated components render and match a baseline screenshot.
- Consider creating a **Code Quality** skill (type 5) to enforce conventions on the generated component structure (props shape, file naming).
