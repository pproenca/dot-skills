#!/usr/bin/env node
// extract-tokens.js — Scan Sketch document for design tokens, emit CSS variables.
// Part of: sketch-to-react
//
// Usage: node extract-tokens.js [--dry-run]
//
// Inputs:
//   work/document.json (from parse.sh)
//   config.json
//
// Outputs:
//   <output_root>/<tokens_path>  — CSS custom properties scoped to :root
//   work/tokens.json             — JSON map used by generate-components.js
//
// Token naming: derived from Sketch's document colors / text styles when named;
// falls back to deterministic short hashes (e.g. --color-1a2b3c) so re-runs are stable.

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const SKILL_ROOT = path.resolve(__dirname, '..');
const WORK_DIR = path.join(SKILL_ROOT, 'work');
const CONFIG = require(path.join(SKILL_ROOT, 'config.json'));

const dryRun = process.argv.includes('--dry-run');

const docPath = path.join(WORK_DIR, 'document.json');
if (!fs.existsSync(docPath)) {
  console.error(`ERROR: ${docPath} not found. Run scripts/parse.sh first.`);
  process.exit(1);
}

const doc = JSON.parse(fs.readFileSync(docPath, 'utf8'));

// --- Helpers ---

function slugify(name) {
  return String(name || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function shortHash(input) {
  return crypto.createHash('sha1').update(input).digest('hex').slice(0, 6);
}

function rgbaToHex({ red, green, blue, alpha }) {
  const r = Math.round(red * 255).toString(16).padStart(2, '0');
  const g = Math.round(green * 255).toString(16).padStart(2, '0');
  const b = Math.round(blue * 255).toString(16).padStart(2, '0');
  if (alpha !== undefined && alpha < 1) {
    const a = Math.round(alpha * 255).toString(16).padStart(2, '0');
    return `#${r}${g}${b}${a}`;
  }
  return `#${r}${g}${b}`;
}

function walk(node, fn) {
  if (!node || typeof node !== 'object') return;
  fn(node);
  for (const k of Object.keys(node)) {
    const v = node[k];
    if (Array.isArray(v)) v.forEach((c) => walk(c, fn));
    else if (v && typeof v === 'object') walk(v, fn);
  }
}

// --- Collect ---

const colors = new Map();   // hex -> {name, hex}
const fonts = new Map();    // signature -> {name, family, size, weight, lineHeight}
const radii = new Map();    // value -> {name, value}
const shadows = new Map();  // signature -> {name, css}
const spacings = new Set(); // distinct integer values from frames

// Document-defined colors (highest-priority names). Source-of-truth changed
// between Sketch versions:
//   - Modern (Sketch ≥ 69): document.sharedSwatches.objects[] — has semantic names
//     like "Accents/Light/8 Blue" and is referenced by layers via swatchID.
//   - Legacy: document.assets.colorAssets[] — kept for back-compat; usually
//     empty in modern documents.
// We merge both, preferring whichever names a given hex first.
const namedColorSources = [
  ...((doc.sharedSwatches && doc.sharedSwatches.objects) || []).map((s) => ({
    name: s.name,
    color: s.value,
  })),
  ...((doc.assets && doc.assets.colorAssets) || []),
];
namedColorSources.forEach((c, i) => {
  if (!c.color) return;
  const hex = rgbaToHex(c.color);
  if (colors.has(hex)) return; // first source wins
  const baseName = c.name ? slugify(c.name) : `c${i + 1}`;
  colors.set(hex, { name: `--color-${baseName}`, hex });
});

// Layer-derived
walk(doc, (n) => {
  // Fill colors
  const fills = (n.style && n.style.fills) || [];
  fills.forEach((f) => {
    if (f && f.color && f.isEnabled !== false) {
      const hex = rgbaToHex(f.color);
      if (!colors.has(hex)) {
        colors.set(hex, { name: `--color-${shortHash(hex)}`, hex });
      }
    }
  });

  // Border colors
  const borders = (n.style && n.style.borders) || [];
  borders.forEach((b) => {
    if (b && b.color && b.isEnabled !== false) {
      const hex = rgbaToHex(b.color);
      if (!colors.has(hex)) {
        colors.set(hex, { name: `--color-${shortHash(hex)}`, hex });
      }
    }
  });

  // Text attributes
  if (n._class === 'text' && n.attributedString) {
    const attrs = (n.attributedString.attributes || [])[0];
    const attributes = attrs && attrs.attributes;
    if (attributes && attributes.MSAttributedStringFontAttribute) {
      const font = attributes.MSAttributedStringFontAttribute.attributes || {};
      const family = font.name || 'system-ui';
      const size = font.size || 16;
      const sig = `${family}|${size}`;
      if (!fonts.has(sig)) {
        fonts.set(sig, {
          name: `--font-${slugify(family)}-${Math.round(size)}`,
          family,
          size,
        });
      }
    }
  }

  // Border radius
  if (
    n._class === 'rectangle' &&
    typeof n.fixedRadius === 'number' &&
    n.fixedRadius > 0 &&
    !radii.has(n.fixedRadius)
  ) {
    radii.set(n.fixedRadius, { name: `--radius-${n.fixedRadius}`, value: n.fixedRadius });
  }

  // Shadows
  const shadowList = (n.style && n.style.shadows) || [];
  shadowList.forEach((s) => {
    if (!s || s.isEnabled === false || !s.color) return;
    const hex = rgbaToHex(s.color);
    const css = `${s.offsetX || 0}px ${s.offsetY || 0}px ${s.blurRadius || 0}px ${s.spread || 0}px ${hex}`;
    if (!shadows.has(css)) {
      shadows.set(css, { name: `--shadow-${shortHash(css)}`, css });
    }
  });

  // Spacing from frame widths/heights — keep round numbers only
  if (n.frame && typeof n.frame === 'object') {
    [n.frame.width, n.frame.height].forEach((dim) => {
      if (Number.isFinite(dim) && dim > 0 && dim <= 256 && dim % 4 === 0) {
        spacings.add(dim);
      }
    });
  }
});

// --- Emit CSS ---

const lines = [];
lines.push('/* Generated by sketch-to-react — DO NOT EDIT MANUALLY.');
lines.push(' * Regenerate by re-running the workflow against the source .sketch file.');
lines.push(' */');
lines.push(':root {');

if (colors.size) {
  lines.push('  /* Colors */');
  for (const { name, hex } of colors.values()) lines.push(`  ${name}: ${hex};`);
}
if (fonts.size) {
  lines.push('');
  lines.push('  /* Typography */');
  for (const { name, family, size } of fonts.values()) {
    lines.push(`  ${name}-family: "${family}", system-ui, sans-serif;`);
    lines.push(`  ${name}-size: ${size}px;`);
  }
}
if (radii.size) {
  lines.push('');
  lines.push('  /* Radii */');
  for (const { name, value } of [...radii.values()].sort((a, b) => a.value - b.value)) {
    lines.push(`  ${name}: ${value}px;`);
  }
}
if (shadows.size) {
  lines.push('');
  lines.push('  /* Shadows */');
  for (const { name, css } of shadows.values()) lines.push(`  ${name}: ${css};`);
}
if (spacings.size) {
  lines.push('');
  lines.push('  /* Spacing (px) */');
  for (const v of [...spacings].sort((a, b) => a - b)) {
    lines.push(`  --space-${v}: ${v}px;`);
  }
}
lines.push('}');
lines.push('');

const cssOutPath = path.join(CONFIG.output_root, CONFIG.tokens_path);
const tokensJsonPath = path.join(WORK_DIR, 'tokens.json');

const summary = {
  colors: colors.size,
  fonts: fonts.size,
  radii: radii.size,
  shadows: shadows.size,
  spacings: spacings.size,
};

if (dryRun) {
  console.log('Dry run — would write:');
  console.log(`  ${cssOutPath}  (${lines.length} lines)`);
  console.log(`  ${tokensJsonPath}`);
  console.log('Summary:', summary);
  process.exit(0);
}

fs.mkdirSync(path.dirname(cssOutPath), { recursive: true });
fs.writeFileSync(cssOutPath, lines.join('\n'));

fs.writeFileSync(tokensJsonPath, JSON.stringify({
  colors: Object.fromEntries([...colors.entries()].map(([hex, v]) => [hex, v.name])),
  fonts: Object.fromEntries([...fonts.entries()].map(([sig, v]) => [sig, v.name])),
  radii: Object.fromEntries([...radii.entries()].map(([px, v]) => [px, v.name])),
  shadows: Object.fromEntries([...shadows.entries()].map(([css, v]) => [css, v.name])),
  spacings: [...spacings].sort((a, b) => a - b),
}, null, 2));

console.log(`Wrote tokens to: ${cssOutPath}`);
console.log(`Token map:      ${tokensJsonPath}`);
console.log('Summary:', summary);
console.log('');
console.log('Next: bash scripts/export-assets.sh <your.sketch>');
