# Gotchas

Append failure modes as they're discovered. Each entry: what happened, what fixed it, date.

---

## The Mac App Store build of Sketch does NOT bundle sketchtool

The App Store distribution of Sketch is sandboxed and ships without the
`sketchtool` CLI. Symptom: preflight fails with "sketchtool not found" even
though `/Applications/Sketch.app` clearly exists.

Detection: the App Store build has a `Contents/_MASReceipt` directory.
Preflight checks for this and prints App Store-specific instructions.

Fix: replace with the direct-download build from sketch.com/downloads/mac/.
Added: 2026-05-16

## sketchtool 2026 removed the `dump` and `list pages/artboards` commands

Older versions of sketchtool (up through ~v97) had `sketchtool dump <file>` and
`sketchtool list pages|artboards` for reading document JSON. These were removed.
The 2026.x sketchtool only does `export ...`, `metadata`, `migrate`, `patch`,
and a few plugin-related commands.

Workaround: parse.sh extracts JSON directly from the .sketch archive (it's a
ZIP containing `document.json` + `pages/<UUID>.json`). This is also faster than
shelling out to sketchtool, and works cross-platform.

Sketchtool is still required for asset export (`sketchtool export slices`), so
the macOS dependency stands for that step.
Added: 2026-05-16

## Modern UI kits use `symbolMaster`, not `artboard`

A Sketch document can contain two kinds of "component roots":
- `artboard`: screen-like containers (typical of screen design files)
- `symbolMaster`: reusable component definitions (typical of design systems and UI kits)

The Apple iOS UI Kit, Material Design kits, and most published design systems
contain ~zero artboards and thousands of symbol masters. The generator picks
up BOTH classes as component roots.

Side effect: a large UI kit can produce thousands of `.tsx` files. Use
`--artboard <name>` to generate one symbol at a time during exploration.
Added: 2026-05-16

## Named colors live in `sharedSwatches.objects`, not `assets.colorAssets`

In modern Sketch (≥ v69), the canonical location for named document colors is
`document.sharedSwatches.objects[]`. Each swatch has `name` and `value`. The
older `document.assets.colorAssets` array is usually empty in current
documents — kept for back-compat only.

extract-tokens.js reads both, preferring the first source that names a given
hex. Without this fix, every color got a hash-only name regardless of how the
designer labeled it in Sketch.
Added: 2026-05-16

## Known caveats (watch for during first runs)

- Sketchtool path differs on Setapp-installed Sketch (`/Applications/Setapp/Sketch.app/...`). If preflight fails on the default path, update `config.json`.
- `npx @svgr/cli@latest` downloads on first run — slow on cold cache, ~5–15s. Subsequent runs hit the npm cache.
- Sketch's "Make Exportable" flag is per-layer. If `export-assets.sh` reports zero slices, the file probably has zero exportable layers, not zero shapes.
- Generated components use absolute positioning by design (see `references/layer-to-jsx.md`). This is a scaffold, not a finished component.

Add real gotchas below as they happen.
