---
title: Auto-Generate Barrel Re-Exports From a Directory
impact: HIGH
impactDescription: prevents stale exports drifting from filesystem state
tags: virtual, barrel, exports, codegen
---

## Auto-Generate Barrel Re-Exports From a Directory

## Problem

Your codebase has `src/icons/` with 200 SVG-as-React-Component files. Every consumer wants to do `import { CheckIcon } from '@/icons'`. Hand-maintaining `src/icons/index.ts` with 200 re-export lines means every new icon requires editing two files (the icon file + the barrel), and the barrel rots silently — an icon file gets added without the re-export, consumers can't find it, ten minutes wasted.

Also, hand-written barrel files defeat tree-shaking in webpack 5+ unless every re-export is `export { X } from './X'` (not `export * from './X'`) — and humans get this wrong about 30% of the time, dragging the entire icons directory into every chunk.

You want a build-time-generated barrel that's always in sync and always tree-shake-friendly.

## Pattern

Similar to virtual-routes: tap `beforeResolve` to recognize `virtual:icons` (or `import './icons'` if you write a resolver alias), scan the directory in the resource-read step, generate per-file `export { default as X } from './X.svg'` lines, register the directory as `contextDependency` for watch invalidation.

**Incorrect (without a plugin — hand-maintained `index.ts`):**

```ts
// src/icons/index.ts — hand-maintained
export { default as CheckIcon } from './check.svg';
export { default as XIcon } from './x.svg';
export { default as ArrowUpIcon } from './arrow-up.svg';
// ... 200 more lines
// Added pages/icons/heart.svg? Don't forget index.ts.
// Used `export * from './pkg'`? Tree-shaking now bundles the whole directory.
```

**Correct (with this plugin — barrel generated on every build, always in sync):**

```js
const fs = require('node:fs');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    barrels: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          virtualModule: { type: 'string', minLength: 1 },
          sourceDir: { type: 'string', minLength: 1 },
          extensions: { type: 'array', items: { type: 'string' } },
          exportName: {
            enum: ['default', 'named', 'namespaceStar', 'pascalCase'],
            description: '`default` = export default; `pascalCase` = PascalCase name from filename',
          },
        },
        required: ['virtualModule', 'sourceDir'],
        additionalProperties: false,
      },
      minItems: 1,
    },
  },
  required: ['barrels'],
  additionalProperties: false,
};

class BarrelGeneratorPlugin {
  constructor(options) {
    validate(schema, options, { name: 'BarrelGeneratorPlugin', baseDataPath: 'options' });
    this.barrels = options.barrels.map((b) => ({
      virtualModule: b.virtualModule,
      sourceDir: path.resolve(b.sourceDir),
      extensions: b.extensions ?? ['.tsx', '.ts', '.svg'],
      exportName: b.exportName ?? 'pascalCase',
    }));
  }

  apply(compiler) {
    const PLUGIN = 'BarrelGeneratorPlugin';

    compiler.hooks.normalModuleFactory.tap(PLUGIN, (nmf) => {
      nmf.hooks.beforeResolve.tap(PLUGIN, (data) => {
        const barrel = this.barrels.find((b) => b.virtualModule === data.request);
        if (!barrel) return;
        data.request = path.join(barrel.sourceDir, '__barrel__.js');
      });
    });

    compiler.hooks.compilation.tap(PLUGIN, (compilation) => {
      const NormalModule = compiler.webpack.NormalModule;

      NormalModule.getCompilationHooks(compilation).readResource
        .for(undefined)
        .tap(PLUGIN, (loaderContext) => {
          const resource = loaderContext.resourcePath;
          const barrel = this.barrels.find((b) =>
            resource === path.join(b.sourceDir, '__barrel__.js'),
          );
          if (!barrel) return;

          // Watch the directory so additions/removals invalidate
          loaderContext._compilation.contextDependencies.add(barrel.sourceDir);

          const source = this.generate(barrel);
          return Buffer.from(source, 'utf8');
        });
    });
  }

  generate(barrel) {
    const entries = fs.readdirSync(barrel.sourceDir, { withFileTypes: true })
      .filter((e) => e.isFile())
      .filter((e) => barrel.extensions.some((ext) => e.name.endsWith(ext)))
      .filter((e) => e.name !== '__barrel__.js' && !e.name.startsWith('index.'));

    const lines = ['// Auto-generated barrel — do not edit'];
    for (const entry of entries) {
      const ext = barrel.extensions.find((e) => entry.name.endsWith(e));
      const base = entry.name.slice(0, -ext.length);
      const name = this.exportNameFor(barrel.exportName, base);
      const relative = './' + entry.name;

      switch (barrel.exportName) {
        case 'default':
          lines.push(`export { default } from ${JSON.stringify(relative)};`);
          break;
        case 'pascalCase':
        case 'named':
          lines.push(`export { default as ${name} } from ${JSON.stringify(relative)};`);
          break;
        case 'namespaceStar':
          lines.push(`export * from ${JSON.stringify(relative)};`);
          break;
      }
    }
    return lines.join('\n') + '\n';
  }

  exportNameFor(strategy, basename) {
    if (strategy === 'pascalCase') {
      return basename
        .replace(/[-_]+(.)/g, (_, c) => c.toUpperCase())
        .replace(/^(.)/, (c) => c.toUpperCase());
    }
    return basename;
  }
}

module.exports = BarrelGeneratorPlugin;
```

## Usage

```js
new BarrelGeneratorPlugin({
  barrels: [
    {
      virtualModule: 'virtual:icons',
      sourceDir: 'src/icons',
      extensions: ['.svg'],
      exportName: 'pascalCase', // check.svg → CheckIcon? close — see Variations
    },
    {
      virtualModule: 'virtual:components',
      sourceDir: 'src/components',
      extensions: ['.tsx'],
      exportName: 'named', // default export → its filename as PascalCase
    },
  ],
})

// Usage
import { CheckIcon, ArrowUpIcon } from 'virtual:icons';
import { Button, Card } from 'virtual:components';
```

## How it works

- **Per-export `export { default as X } from './X'`** is the tree-shakeable form. `export * from './X'` works but webpack 5 needs more analysis to prove no side effects; per-export is unambiguous.
- **Filter out `__barrel__.js`, `index.*`** — prevents the barrel from re-exporting itself (infinite recursion) and skips manually-written index files
- **`contextDependencies.add(barrel.sourceDir)`** triggers rebuild when icons are added/removed. See [`webpack-plugin-authoring/cache-context-dependencies-for-directories`].
- **Webpack 5 `sideEffects: false`** in package.json + per-export form = optimal tree-shaking; `*` re-exports require sideEffects analysis on each child module

## Variations

- **Add `Icon` suffix for SVG barrels**:
  ```js
  exportName: 'pascalCase',
  // post-process: name = name + 'Icon' for .svg
  ```
- **Subdirectory traversal** (`src/icons/social/*.svg` → `SocialFacebookIcon`): recursive scan, prefix with directory path
- **Filter by glob** (`{ include: ['*.icon.tsx'], exclude: ['*.test.tsx'] }`)
- **Emit `.d.ts` companion file** for IDE autocomplete (TypeScript can't introspect virtual modules)
- **Multiple namespace exports** (`export const Icons = { Check, X, ... }`)

## When NOT to use this pattern

- The directory is small (<10 files) — manual maintenance is cheaper
- IDE support matters more than build cleanliness — virtual modules don't get autocomplete unless you also emit a `.d.ts`
- You use a build tool with this built-in (Vite has `unplugin-auto-import`, Nuxt has `auto-imports`)
- Your "barrel" is genuinely curated (you re-export SOME of the directory, not all) — codegen would be wrong

Reference: [Webpack 5 tree shaking](https://webpack.js.org/guides/tree-shaking/) · [unplugin-auto-import](https://github.com/unplugin/unplugin-auto-import) · [contextDependencies](https://webpack.js.org/api/compilation-object/#contextdependencies)
