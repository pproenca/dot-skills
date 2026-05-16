---
title: Strip Debug-Only Code From Production Bundles
impact: MEDIUM-HIGH
impactDescription: 5-30kb savings depending on how much dev instrumentation exists
tags: transform, dead-code-elimination, define-plugin, terser, dev
---

## Strip Debug-Only Code From Production Bundles

## Problem

Your dev builds have rich assertion code (`assert(user != null, 'expected user')`), debug logging (`if (__DEV__) console.log(...)`), and a 12kb dev-tools panel that nobody should ship to users. The standard answer is `process.env.NODE_ENV === 'production'` + terser dead-code-elimination, and it works for simple cases — but it misses:

- `assert()` calls (the call itself remains; only `if (__DEV__) assert(...)` is stripped)
- Imports that exist only for debug (`import { devtools } from 'react-devtools'` — the import survives even if no use)
- Multi-line assertion blocks that terser doesn't realize are dead

You want a plugin that ALSO replaces calls to a configured set of debug helpers with empty expressions BEFORE terser runs, so the entire call chain (including arguments — which may be expensive to compute) is dropped.

## Pattern

Run as a webpack 5 loader OR a plugin that adds a loader; the plugin form is more ergonomic — it wires up the loader via `module.rules` injection in `apply()`. The loader uses `babel`/`swc`/`acorn` to find calls to configured debug functions and replace them with `void 0`. In dev mode, the plugin is a no-op.

**Incorrect (without a plugin — DefinePlugin + terser alone):**

```js
new webpack.DefinePlugin({
  __DEV__: JSON.stringify(process.env.NODE_ENV !== 'production'),
});

// Source:
import { devAssert } from '@/debug';
devAssert(user != null, computeExpensiveDebugInfo());  // <- call still happens
if (__DEV__) devAssert(item.valid, item.errors());     // <- this one is stripped

// In prod: the first devAssert call ships including computeExpensiveDebugInfo()
// because terser sees a side-effectful function call and can't eliminate it.
```

**Correct (with this plugin — calls to debug helpers replaced before terser):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    helpers: {
      type: 'array',
      items: { type: 'string', minLength: 1 },
      description: 'Function names to strip (matches identifier calls)',
      minItems: 1,
    },
    importsFrom: {
      type: 'array',
      items: { type: 'string' },
      description: 'Strip imports from these packages entirely (e.g. ["@/debug"])',
    },
    mode: { enum: ['production', 'always', 'never'] },
  },
  required: ['helpers'],
  additionalProperties: false,
};

const DEFAULTS = { mode: 'production' };

class StripDebugHelpersPlugin {
  constructor(options) {
    validate(schema, options, { name: 'StripDebugHelpersPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
  }

  apply(compiler) {
    const shouldStrip =
      this.options.mode === 'always' ||
      (this.options.mode === 'production' && compiler.options.mode === 'production');
    if (!shouldStrip) return;

    // Register a loader against JS/TS files
    compiler.options.module.rules.push({
      test: /\.(jsx?|tsx?|mjs)$/,
      exclude: /node_modules/,
      enforce: 'pre',  // run before babel/swc so they see stripped code
      use: {
        loader: require.resolve('./strip-debug-loader'),
        options: this.options,
      },
    });
  }
}

module.exports = StripDebugHelpersPlugin;
```

```js
// strip-debug-loader.js
const { parse } = require('acorn');
const { simple: walk } = require('acorn-walk');
const MagicString = require('magic-string');

module.exports = function stripDebugLoader(source) {
  const opts = this.getOptions();
  const helpers = new Set(opts.helpers);
  const importsFrom = new Set(opts.importsFrom ?? []);

  let ast;
  try {
    ast = parse(source, { ecmaVersion: 'latest', sourceType: 'module' });
  } catch {
    return source;  // not parseable JS — pass through (e.g. JSX without TS plugin)
  }

  const magic = new MagicString(source);
  let changed = false;

  walk(ast, {
    CallExpression(node) {
      if (node.callee.type === 'Identifier' && helpers.has(node.callee.name)) {
        // Replace the entire call (including arguments) with void 0
        magic.overwrite(node.start, node.end, 'void 0');
        changed = true;
      }
    },
    ImportDeclaration(node) {
      if (typeof node.source.value === 'string' && importsFrom.has(node.source.value)) {
        // Delete the whole import line
        magic.remove(node.start, node.end);
        changed = true;
      }
    },
  });

  if (!changed) return source;

  const map = magic.generateMap({
    source: this.resourcePath,
    includeContent: true,
    hires: true,
  });
  this.callback(null, magic.toString(), map);
};
```

## Usage

```js
// webpack.config.js
new StripDebugHelpersPlugin({
  helpers: ['devAssert', 'devLog', 'invariant'],
  importsFrom: ['@/debug', '@/dev-utils'],  // entire module's imports removed
  mode: 'production',
})

// Source:
import { devAssert, devLog } from '@/debug';
import { compute } from './math';

export function checkout(cart) {
  devAssert(cart.items.length > 0, 'empty cart');  // → void 0
  devLog('checkout starting', cart);                // → void 0
  return compute(cart);
}

// Production output (after this plugin + terser):
import { compute } from './math';
export function checkout(cart) {
  return compute(cart);  // void 0 stripped, dead imports gone
}
```

## How it works

- **`enforce: 'pre'`** runs this loader before babel/swc/TypeScript. The downstream loaders see already-stripped code, so they don't waste work transforming code that's about to be removed.
- **AST-based, not regex-based** — `devAssert` inside a string literal or comment isn't replaced; `obj.devAssert(...)` isn't replaced (only top-level identifier calls)
- **`void 0`** is the smallest expression that's syntactically valid in every CallExpression position (statement, argument, ternary branch). Terser then collapses `void 0;` statements entirely.
- **MagicString preserves a source map** for the loader output, so debugging in prod still works (you see "this code was stripped" rather than mismapped lines)
- **Loader option flowing from plugin** — clean way to make a plugin configurable while keeping the loader as the unit of transformation

## Variations

- **`if (__DEV__) { ... }` blocks** (separate from helper calls): add an `IfStatement` walker that checks for `__DEV__` test, removes the whole block
- **SWC-based** for speed (1000x faster on large codebases): swap acorn for `@swc/core`'s `transformSync`
- **Per-environment defines** (`__INSPECT__`, `__VERBOSE__`): take the helpers list per-mode
- **Mark module as side-effect-free** for tree-shaking: set `module.sideEffects = false` in `additionalAssets`

## When NOT to use this pattern

- Your debug helpers are wrapped in `if (process.env.NODE_ENV !== 'production') {...}` and you trust terser to handle it — for simple cases, terser does
- You use [babel-plugin-transform-remove-debugger](https://babeljs.io/docs/babel-plugin-transform-remove-debugger) or [unplugin-strip](https://github.com/unplugin/unplugin-strip) — overlapping functionality
- Your debug helpers have side effects that matter even in production (auditing, telemetry) — stripping would break behavior

Reference: [acorn](https://github.com/acornjs/acorn) · [MagicString](https://github.com/Rich-Harris/magic-string) · [unplugin-strip](https://github.com/unplugin/unplugin-strip) · [DefinePlugin](https://webpack.js.org/plugins/define-plugin/)
