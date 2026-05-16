# Token Mapping

How Sketch document values become CSS custom properties in `tokens.module.css`. Read this when a generated token has an unexpected name or when adjusting the extractor.

## Why extract tokens at all

The alternative — inlining literal hex/px values per component — produces visually correct output but duplicates the same color across N components. When the designer tweaks the primary blue, you have to find-and-replace 40 hex codes. Tokens make the design system the source of truth.

The extractor only deduplicates *exact* matches. `#1A73E8` and `#1a73e8` resolve to the same token; `#1A73E8` and `#1A74E8` are two different tokens. The agent should not try to be clever about "near matches" — that risks silently breaking the design.

## Naming priority

For each token kind, the extractor picks names in this order:

1. **Sketch-named asset** — if the designer named the color/style in the document's asset library, the slug of that name wins (`Primary Blue` → `--color-primary-blue`).
2. **Stable hash** — for unnamed values, a 6-character SHA-1 prefix of the canonical form (`#1A73E8` → `--color-1a73e8`-ish, but hashed not pretty-printed).

Why hashes instead of incremental numbers (`--color-1`, `--color-2`, …)? Because re-running the extractor against a slightly different `.sketch` file could otherwise reassign every number, producing huge meaningless diffs. Hashes are stable across runs and across documents.

## Per-kind rules

### Colors

| Source in Sketch | Token name |
|------------------|-----------|
| `assets.colorAssets[i]` with `name: "Primary Blue"` | `--color-primary-blue` |
| Layer fill, unnamed, `#1A73E8` | `--color-<hash6>` |
| Layer border, unnamed, `#FF0000` with alpha 0.5 | `--color-<hash6>` (the hex stored includes the alpha byte: `#ff000080`) |

Alpha is preserved as an 8-character hex (e.g., `#1a73e880` for 50% opacity). This is supported by every browser since 2017 and is shorter than `rgba()` in CSS.

### Typography

Each unique `(family, size)` pair produces two variables:

```css
--font-roboto-16-family: "Roboto", system-ui, sans-serif;
--font-roboto-16-size: 16px;
```

Weight and line-height are *not* tokenized currently. They appear inline in component CSS. Reason: Sketch stores them inconsistently across versions, and the agent should not silently lose typography fidelity by collapsing them.

### Radii

`fixedRadius` on rectangles only. Per-corner radii (top-left, bottom-right, etc.) are not tokenized — they appear inline because token reuse is rare for asymmetric radii.

### Shadows

Each unique shadow CSS string gets one token. The hash is of the full CSS (offset + blur + spread + color), so changing the spread by 1px creates a new token. This is intentional — shadows are a known source of design drift, and we want diffs to be visible.

### Spacing

Only spacings that satisfy **all** of these are extracted:
- Integer pixel value
- Multiple of 4
- ≤ 256px

The narrow filter avoids polluting the spacing scale with one-off measurements (e.g., a 137px-wide button). Round multiples of 4 are the canonical "design system" spacings.

## What is NOT tokenized

- **Gradients** — inlined in component CSS. Gradients are rarely reused exactly and the tokenization complexity isn't worth it.
- **Text alignment / decoration** — applied per-instance.
- **Opacity (layer-level)** — applied per-instance via `opacity: …` in component CSS.
- **Blend modes** — applied per-instance.

If a project standardizes on a fixed shadow scale or spacing scale, override the generated tokens file once and commit it; subsequent runs will skip overwriting it (via the `--force` gate in preflight).

## Adjusting the extractor

The token extractor lives in `scripts/extract-tokens.js`. Each kind has its own collection block. To add a new kind (e.g., easing curves):

1. Add a `Map` at the top.
2. In the `walk()` callback, identify the Sketch field and add to the map.
3. In the emit section, add a corresponding `/* Section */` block in the CSS output.
4. Add to `tokens.json` so `generate-components.js` can reference it via `var(--…)`.
