# Layer → JSX Mapping

Read this to understand what each Sketch layer type becomes in the generated component, or when extending `generate-components.js` to handle a new layer class.

## Mapping table

| Sketch layer (`_class`) | JSX output | Notes |
|--------------------------|-----------|-------|
| `artboard` | `<div className={styles.root}>` | Top-level, `position: relative`. `x`/`y` from the frame are dropped. |
| `group` | `<div>` with children | Class name = kebab-case of group name. |
| `text` | `<span>` | Class name = kebab-case of layer name. Literal text content. JSX-special chars (`{`, `}`) escaped. |
| `rectangle` | `<div />` | Borders + fills + radius from style block. |
| `oval` | `<div />` | Same as rectangle, with `border-radius: 50%`. Currently rendered as a square div with corner radius half the smaller dimension — refactor manually for true circles. |
| `bitmap` | `<img src="/<ref>" alt={name} />` | `<ref>` resolves to an exported PNG/JPG in the assets dir. Alt text is the Sketch layer name — designer should write meaningful names. |
| `symbolInstance` | `<div />` (placeholder) | Symbols are not resolved. Replace manually with the corresponding React component. |
| `shapeGroup` | `<div />` | Pure-vector shapes become divs; if they were marked exportable, they're also available as SVG components in the icons dir. |
| `slice` | (nothing) | Slices are export hints, not rendered geometry. |

## Why so positional

Every non-artboard layer gets `position: absolute` with `left/top` from the Sketch frame. This is a deliberate choice:

- **Pixel-perfect on first render.** The generated component looks identical to the Sketch artboard.
- **No semantic guessing.** Inferring flex direction from coordinates is unreliable — two boxes at `y=100` and `y=200` could be a column, or could be unrelated overlapping cards.
- **Easy to refactor.** Once the developer sees the structure rendered, they can replace `position: absolute` with flex/grid intentionally.

This is opposite of what a hand-written component looks like, but matches the Sketch mental model exactly. The agent should suggest refactoring positional layout to flow layout once the user has reviewed the scaffold.

## Naming

| What | Convention | Example |
|------|------------|---------|
| Component name | PascalCase of artboard name | `Login Screen` → `LoginScreen` |
| CSS class name | kebab-case of layer name | `Email Input` → `email-input` |
| Icon component name | PascalCase from SVG filename | `arrow-right.svg` → `ArrowRight` |

If two layers share the same name, both end up writing to the same class. CSS Modules' last-rule-wins behavior means the second one shadows the first. **Fix in Sketch: rename layers to be unique within an artboard.** The extractor does not auto-rename because that would create silent class-name churn between runs.

## Text content edge cases

| Sketch text contains | JSX output |
|----------------------|-----------|
| Plain ASCII | Rendered literally inside `<span>` |
| `{` or `}` | Escaped as `{'{'}` / `{'}'}` |
| Multiline | Newlines preserved; render with `white-space: pre-wrap` in CSS if needed |
| Emoji / unicode | Rendered literally — the file is UTF-8 |
| Empty string | Empty `<span>` (intentional — keeps the slot for later content) |

The extractor does not strip leading/trailing whitespace because designers sometimes use leading spaces to align labels. If unwanted spaces appear, fix them in Sketch.

## Extending

To handle a new `_class` in `generate-components.js`:

1. Add a branch in `generateLayer()` before the generic group/div fallback.
2. Decide: leaf (no recursion into children) or container (recurse).
3. Use existing helpers — `kebabCase()`, `pascalCase()`, `colorRef()`, `spacingRef()`, `radiusRef()` — for consistency with the rest of the output.
4. Add an entry to the mapping table above.

If the new layer class has assets (icons, images), wire it through the manifest:
- Add the export logic to `scripts/export-assets.sh`.
- Update the manifest in the same place the existing raster/icon arrays are built.
- Reference manifest entries by `assets.icons.find(...)` in the generator.
