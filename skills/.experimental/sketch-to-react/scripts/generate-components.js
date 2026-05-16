#!/usr/bin/env node
// generate-components.js — Generate one .tsx + .module.css per artboard.
// Part of: sketch-to-react
//
// Usage: node generate-components.js [--artboard <name>] [--dry-run]
//
// Inputs:
//   work/document.json      (from parse.sh)
//   work/structure.json     (from parse.sh)
//   work/tokens.json        (from extract-tokens.js)
//   work/assets-manifest.json (from export-assets.sh)
//
// Outputs:
//   <output_root>/<components_dir>/<Name>.tsx
//   <output_root>/<components_dir>/<Name>.module.css
//
// The generated code is a *scaffold*: absolute-positioned divs that match the
// Sketch layout. Refactor to flex/grid as needed. CSS values reference tokens
// where the Sketch value matches a known token, otherwise inline the literal.

'use strict';

const fs = require('fs');
const path = require('path');

const SKILL_ROOT = path.resolve(__dirname, '..');
const WORK_DIR = path.join(SKILL_ROOT, 'work');
const CONFIG = require(path.join(SKILL_ROOT, 'config.json'));

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const artboardFilter = (() => {
  const i = args.indexOf('--artboard');
  return i >= 0 ? args[i + 1] : null;
})();

function required(p) {
  if (!fs.existsSync(p)) {
    console.error(`ERROR: required input missing: ${p}`);
    console.error('Run the previous workflow step first.');
    process.exit(1);
  }
  return JSON.parse(fs.readFileSync(p, 'utf8'));
}

const doc = required(path.join(WORK_DIR, 'document.json'));
const structure = required(path.join(WORK_DIR, 'structure.json'));
const tokens = required(path.join(WORK_DIR, 'tokens.json'));
const assets = fs.existsSync(path.join(WORK_DIR, 'assets-manifest.json'))
  ? JSON.parse(fs.readFileSync(path.join(WORK_DIR, 'assets-manifest.json'), 'utf8'))
  : { raster: [], icons: [] };

// --- Helpers ---

function pascalCase(s) {
  return String(s || '')
    .replace(/[^a-zA-Z0-9]+/g, ' ')
    .split(' ')
    .filter(Boolean)
    .map((w) => w[0].toUpperCase() + w.slice(1))
    .join('') || 'Component';
}

function kebabCase(s) {
  return String(s || '')
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .replace(/([a-z])([A-Z])/g, '$1-$2')
    .toLowerCase()
    .replace(/^-+|-+$/g, '') || 'el';
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

function colorRef(hex) {
  const name = tokens.colors && tokens.colors[hex];
  return name ? `var(${name})` : hex;
}

function spacingRef(px) {
  if (tokens.spacings && tokens.spacings.includes(px)) return `var(--space-${px})`;
  return `${px}px`;
}

function radiusRef(px) {
  const name = tokens.radii && tokens.radii[px];
  return name ? `var(${name})` : `${px}px`;
}

// --- Find component-producing layers in the document ---
// Two Sketch layer classes act as "components":
//   - artboard:     top-level screen-like containers (older or screen-design docs)
//   - symbolMaster: reusable component definitions (Sketch's Symbols feature)
// Modern UI kits ship almost entirely as symbolMasters; screen-design docs ship
// as artboards. We treat both as roots and generate one component per match.
const COMPONENT_CLASSES = new Set(['artboard', 'symbolMaster']);

function collectComponentRoots(node, found = []) {
  if (!node || typeof node !== 'object') return found;
  if (COMPONENT_CLASSES.has(node._class)) {
    found.push(node);
    return found; // don't recurse into a component root — its layers belong to it
  }
  for (const k of Object.keys(node)) {
    const v = node[k];
    if (Array.isArray(v)) v.forEach((c) => collectComponentRoots(c, found));
    else if (v && typeof v === 'object') collectComponentRoots(v, found);
  }
  return found;
}

const roots = collectComponentRoots(doc).filter((a) =>
  !artboardFilter || a.name === artboardFilter
);

if (roots.length === 0) {
  if (artboardFilter) {
    console.error(`ERROR: artboard/symbol "${artboardFilter}" not found in document.`);
    console.error('Sample of available names (first 20):');
    for (const ab of collectComponentRoots(doc).slice(0, 20)) {
      console.error(`  - ${ab.name}  (${ab._class})`);
    }
    process.exit(1);
  }
  console.error('ERROR: no artboards or symbols found in Sketch document.');
  process.exit(1);
}

// --- Build CSS rules and JSX from a layer subtree ---

function buildStyle(layer) {
  const rules = [];
  const frame = layer.frame || {};
  // Offsets are layer-specific coordinates, not design-system spacings — emit
  // literal px so we don't pollute output with var(--space-N) for arbitrary x/y.
  if (frame.x !== undefined && layer._class !== 'artboard') {
    rules.push(`position: absolute`);
    rules.push(`left: ${Math.round(frame.x)}px`);
    rules.push(`top: ${Math.round(frame.y)}px`);
  }
  // Width/height can be tokenized when they match the design-system scale.
  if (frame.width !== undefined) rules.push(`width: ${spacingRef(Math.round(frame.width))}`);
  if (frame.height !== undefined) rules.push(`height: ${spacingRef(Math.round(frame.height))}`);

  const fills = (layer.style && layer.style.fills) || [];
  const bg = fills.find((f) => f && f.isEnabled !== false && f.color);
  if (bg) rules.push(`background: ${colorRef(rgbaToHex(bg.color))}`);

  const borders = (layer.style && layer.style.borders) || [];
  const border = borders.find((b) => b && b.isEnabled !== false && b.color);
  if (border) {
    const w = border.thickness || 1;
    rules.push(`border: ${w}px solid ${colorRef(rgbaToHex(border.color))}`);
  }

  if (layer._class === 'rectangle' && layer.fixedRadius && layer.fixedRadius > 0) {
    rules.push(`border-radius: ${radiusRef(layer.fixedRadius)}`);
  }

  const shadows = (layer.style && layer.style.shadows) || [];
  const shadow = shadows.find((s) => s && s.isEnabled !== false && s.color);
  if (shadow) {
    const css = `${shadow.offsetX || 0}px ${shadow.offsetY || 0}px ${shadow.blurRadius || 0}px ${shadow.spread || 0}px ${rgbaToHex(shadow.color)}`;
    const name = tokens.shadows && tokens.shadows[css];
    rules.push(`box-shadow: ${name ? `var(${name})` : css}`);
  }

  return rules;
}

function textContent(layer) {
  if (layer._class !== 'text' || !layer.attributedString) return '';
  const s = layer.attributedString.string || '';
  // Escape for JSX text nodes
  return s.replace(/[{}]/g, (c) => `{'${c}'}`);
}

function generateLayer(layer, cssAcc, depth = 0) {
  if (!layer || layer.isVisible === false) return '';
  const className = kebabCase(layer.name || layer._class || 'el');
  const style = buildStyle(layer);
  if (style.length) cssAcc[className] = style;

  const indent = '  '.repeat(depth + 2);

  if (layer._class === 'text') {
    return `${indent}<span className={styles['${className}']}>${textContent(layer)}</span>\n`;
  }

  if (layer._class === 'bitmap') {
    const imgRef = (layer.image && layer.image._ref) || '';
    return `${indent}<img className={styles['${className}']} src="/${imgRef}" alt={${JSON.stringify(layer.name || '')}} />\n`;
  }

  // Group / artboard / shape — render as div with children
  const children = (layer.layers || [])
    .map((c) => generateLayer(c, cssAcc, depth + 1))
    .join('');

  if (!children) {
    return `${indent}<div className={styles['${className}']} />\n`;
  }
  return `${indent}<div className={styles['${className}']}>\n${children}${indent}</div>\n`;
}

// --- Generate file pair per artboard ---

const outDir = path.join(CONFIG.output_root, CONFIG.components_dir);
const written = [];
const seenNames = new Set();

for (const ab of roots) {
  // Disambiguate duplicate names — "Foo/Bar" and "Foo / Bar" both kebab to
  // "foo-bar", and several symbolMasters legitimately share short names across
  // categories. Suffix with a stable short hash on collision.
  let compName = pascalCase(ab.name);
  if (seenNames.has(compName)) {
    const suffix = (ab.do_objectID || '').slice(0, 6);
    compName = `${compName}_${suffix}`;
  }
  seenNames.add(compName);

  const cssAcc = {};
  const rootClass = kebabCase(ab.name) || 'root';

  // Root frame: ignore x/y for the root element (it's always its own coordinate space)
  const rootStyle = buildStyle({ ...ab, frame: { ...ab.frame, x: undefined, y: undefined } });
  if (rootStyle.length) cssAcc[rootClass] = ['position: relative', ...rootStyle];

  const childrenJsx = (ab.layers || [])
    .map((c) => generateLayer(c, cssAcc, 0))
    .join('');

  const tsx = `import styles from './${compName}.module.css';\n\nexport function ${compName}() {\n  return (\n    <div className={styles['${rootClass}']}>\n${childrenJsx}    </div>\n  );\n}\n`;

  const cssLines = [];
  cssLines.push('/* Generated by sketch-to-react — DO NOT EDIT MANUALLY. */');
  for (const [cls, rules] of Object.entries(cssAcc)) {
    cssLines.push(`.${cls} {`);
    for (const r of rules) cssLines.push(`  ${r};`);
    cssLines.push('}');
    cssLines.push('');
  }

  const tsxPath = path.join(outDir, `${compName}.tsx`);
  const cssPath = path.join(outDir, `${compName}.module.css`);

  if (dryRun) {
    console.log(`Would write: ${tsxPath}`);
    console.log(`Would write: ${cssPath}`);
  } else {
    fs.mkdirSync(path.dirname(tsxPath), { recursive: true });
    fs.writeFileSync(tsxPath, tsx);
    fs.writeFileSync(cssPath, cssLines.join('\n'));
    written.push({ tsx: tsxPath, css: cssPath, name: compName });
  }
}

if (dryRun) {
  console.log(`\nDry run — ${roots.length} component(s) would generate ${roots.length * 2} file(s).`);
  process.exit(0);
}

// --- Optional prettier formatting ---

const projectRoot = path.resolve(CONFIG.output_root, '..');
const hasPrettier = fs.existsSync(path.join(projectRoot, 'node_modules', '.bin', 'prettier'));
if (hasPrettier && written.length) {
  const { execSync } = require('child_process');
  const files = written.flatMap((w) => [w.tsx, w.css]).map((p) => JSON.stringify(p)).join(' ');
  try {
    execSync(`npx prettier --write ${files}`, { cwd: projectRoot, stdio: 'inherit' });
  } catch (e) {
    console.warn('WARN: prettier failed (continuing):', e.message);
  }
}

console.log(`\nGenerated ${written.length} component(s):`);
for (const w of written) console.log(`  ${w.name}: ${w.tsx}`);
console.log('\nNext: bash scripts/verify.sh');
