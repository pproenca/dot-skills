---
title: Export the Plugin Class Directly as module.exports (CJS) or default (ESM)
impact: LOW-MEDIUM
impactDescription: prevents users seeing "X is not a constructor"
tags: compat, exports, esm, cjs, package-json
---

## Export the Plugin Class Directly as module.exports (CJS) or default (ESM)

Webpack config files run as CommonJS in most setups (`webpack.config.js`) and as ESM when the user opts in (`webpack.config.mjs` or `"type": "module"`). Mixing `module.exports = MyPlugin` with named exports (`module.exports.MyPlugin = MyPlugin`) confuses Babel's `__esModule` interop and produces `new MyPlugin()` → `TypeError: MyPlugin is not a constructor`. The convention `webpack-contrib` settled on: the class is THE default export, and a CommonJS file uses `module.exports = MyPlugin` with `module.exports.default = MyPlugin` for ESM-default interop.

**Incorrect (mixed export shape — breaks for half of users):**

```js
class MyPlugin { /* ... */ }
class MyHelper { /* ... */ }

module.exports = { MyPlugin, MyHelper };
// CommonJS user: const MyPlugin = require('my-plugin').MyPlugin   ← works
// ESM user:     import MyPlugin from 'my-plugin'                  ← MyPlugin is the whole object, `new MyPlugin()` fails
```

**Correct (default-class + named helpers, CJS form with ESM interop):**

```js
class MyPlugin { /* ... */ }
class MyHelper { /* ... */ }

module.exports = MyPlugin;
// Named exports as properties of the default
module.exports.MyHelper = MyHelper;
// ESM default-interop shim — `import X from 'my-plugin'` gives the class
module.exports.default = MyPlugin;
```

```js
// CommonJS user (webpack.config.js):
const MyPlugin = require('my-plugin');
const { MyHelper } = require('my-plugin');

// ESM user (webpack.config.mjs):
import MyPlugin, { MyHelper } from 'my-plugin';
```

**Correct (pure ESM source — for new packages):**

```js
// src/index.mjs
export default class MyPlugin { /* ... */ }
export class MyHelper { /* ... */ }
```

```json
{
  "type": "module",
  "exports": {
    ".": {
      "import": "./src/index.mjs",
      "require": "./dist/index.cjs"
    }
  }
}
```

Use a build step (esbuild, tsup) to produce the `.cjs` for CommonJS consumers.

**package.json `exports` field for dual-mode:**

```json
{
  "name": "my-plugin",
  "main": "./dist/index.cjs",
  "module": "./dist/index.mjs",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs"
    },
    "./package.json": "./package.json"
  }
}
```

**TypeScript users want types — provide them:**

```ts
// src/index.ts
import type { Compiler } from 'webpack';

interface MyPluginOptions { /* ... */ }

class MyPlugin {
  constructor(options?: MyPluginOptions);
  apply(compiler: Compiler): void;
}

export = MyPlugin;       // CJS-style export for tsc → emits module.exports = MyPlugin
```

The TypeScript `export =` syntax produces the right CJS shape. Combined with `esModuleInterop: true` in tsconfig, both `require()` and `import default` work.

**Don't export an instance — always export the class.** `module.exports = new MyPlugin()` makes the plugin instance global; users can't pass different options per build, and MultiCompiler corrupts state instantly.

**Verify the export shape with a smoke test:**

```js
// tests/exports.test.js
const Plugin = require('../');
test('default export is a constructor', () => {
  expect(typeof Plugin).toBe('function');
  expect(typeof new Plugin().apply).toBe('function');
});
test('ESM default interop', () => {
  expect(Plugin.default).toBe(Plugin);
});
```

Reference: [Node.js — Package exports field](https://nodejs.org/api/packages.html#exports) · [webpack-contrib package conventions](https://github.com/webpack-contrib/mini-css-extract-plugin/blob/master/package.json)
