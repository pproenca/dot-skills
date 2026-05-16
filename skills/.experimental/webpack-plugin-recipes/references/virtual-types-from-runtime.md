---
title: Emit TypeScript Declarations From Runtime Data
impact: HIGH
impactDescription: prevents type drift between JSON config and source code
tags: virtual, codegen, typescript, dts, types
---

## Emit TypeScript Declarations From Runtime Data

## Problem

Your app's behavior is driven by a `feature-flags.json` (or a GraphQL schema, or an OpenAPI spec) — but TypeScript can't infer types from runtime JSON. Without typed flags, `features.newCheckutMode` (typo) compiles fine and silently uses an unset flag. You want a `.d.ts` file generated at build time so TypeScript knows `features.newCheckoutMode` is a `boolean` and `features.newCheckutMode` is an error.

The pattern: read the source JSON, transform to a TS type declaration, emit as both a virtual module (for runtime) AND a `.d.ts` file on disk (for the TypeScript compiler to pick up). Persistent disk emission is what makes IDEs see the types — virtual modules alone don't surface to `tsc`.

## Pattern

In `beforeRun` (and `watchRun`), read the source data, produce both a runtime ESM module (compiled into the bundle via the virtual-module recipe) and a `.d.ts` file written to disk via `compiler.outputFileSystem` (in a path TypeScript already includes).

**Incorrect (without a plugin — typing JSON by hand):**

```ts
// src/feature-flags-types.ts — hand-maintained
export type FeatureFlags = {
  newCheckout: boolean;
  experimentalSearch: boolean;
  // forgot to add darkMode — it's in the JSON but not in the type
};

// feature-flags.json
{ "newCheckout": true, "experimentalSearch": false, "darkMode": true }

// Result: `features.darkMode` is `any`, no autocomplete, no compile error on typo
```

**Correct (with this plugin — `.d.ts` generated from the JSON):**

```js
const fs = require('node:fs');
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    sourceFile: { type: 'string', minLength: 1 },
    runtimeModule: { type: 'string', minLength: 1 },
    declarationFile: { type: 'string', minLength: 1 },
    typeName: { type: 'string', minLength: 1 },
  },
  required: ['sourceFile', 'runtimeModule', 'declarationFile'],
  additionalProperties: false,
};

const DEFAULTS = { typeName: 'Config' };

class TypedConfigPlugin {
  constructor(options) {
    validate(schema, options, { name: 'TypedConfigPlugin', baseDataPath: 'options' });
    this.options = { ...DEFAULTS, ...options };
    this.sourceFile = path.resolve(this.options.sourceFile);
    this.declarationFile = path.resolve(this.options.declarationFile);
  }

  apply(compiler) {
    const PLUGIN = 'TypedConfigPlugin';

    // 1) Write the .d.ts file BEFORE compilation so tsc picks it up
    const writeDts = async () => {
      const data = JSON.parse(await readFile(compiler.inputFileSystem, this.sourceFile));
      const dts = this.generateDts(data);
      await writeFile(compiler.outputFileSystem, this.declarationFile, dts);
    };

    compiler.hooks.beforeRun.tapPromise(PLUGIN, writeDts);
    compiler.hooks.watchRun.tapPromise(PLUGIN, writeDts);

    // 2) Provide the runtime virtual module (data as ESM)
    compiler.hooks.normalModuleFactory.tap(PLUGIN, (nmf) => {
      nmf.hooks.beforeResolve.tap(PLUGIN, (data) => {
        if (data.request !== this.options.runtimeModule) return;
        data.request = path.join(compiler.context, '__typed_config__', 'index.js');
      });
    });

    compiler.hooks.compilation.tap(PLUGIN, (compilation) => {
      const NormalModule = compiler.webpack.NormalModule;

      NormalModule.getCompilationHooks(compilation).readResource
        .for(undefined)
        .tapPromise(PLUGIN, async (loaderContext) => {
          const marker = path.join(compiler.context, '__typed_config__', 'index.js');
          if (loaderContext.resourcePath !== marker) return;

          const raw = await readFile(compiler.inputFileSystem, this.sourceFile);
          loaderContext._compilation.fileDependencies.add(this.sourceFile);

          return Buffer.from(
            `const config = ${raw};\nexport default config;\n`,
            'utf8',
          );
        });
    });
  }

  generateDts(data) {
    const indent = '  ';
    const typeOf = (v) => {
      if (v === null) return 'null';
      if (Array.isArray(v)) {
        if (v.length === 0) return 'unknown[]';
        // Union of unique element types
        const types = [...new Set(v.map(typeOf))];
        return types.length === 1 ? `${types[0]}[]` : `Array<${types.join(' | ')}>`;
      }
      if (typeof v === 'object') {
        const keys = Object.keys(v);
        if (keys.length === 0) return 'Record<string, unknown>';
        return `{\n${keys.map((k) => `${indent}${k}: ${typeOf(v[k])};`).join('\n')}\n}`;
      }
      if (typeof v === 'string') return `string`;
      if (typeof v === 'number') return `number`;
      if (typeof v === 'boolean') return `boolean`;
      return 'unknown';
    };

    const indentBlock = (s) =>
      s.split('\n').map((l, i) => (i === 0 ? l : indent + l)).join('\n');

    return [
      `// Auto-generated by TypedConfigPlugin from ${path.basename(this.sourceFile)}`,
      `// Do not edit. Edit the source JSON instead.`,
      ``,
      `declare module ${JSON.stringify(this.options.runtimeModule)} {`,
      `${indent}export type ${this.options.typeName} = ${indentBlock(typeOf(data))};`,
      `${indent}const config: ${this.options.typeName};`,
      `${indent}export default config;`,
      `}`,
      ``,
    ].join('\n');
  }
}

function readFile(fs, p) {
  return new Promise((res, rej) =>
    fs.readFile(p, (err, buf) => err ? rej(err) : res(buf.toString('utf8'))),
  );
}

function writeFile(fs, p, content) {
  return new Promise((res, rej) => {
    fs.mkdir(path.dirname(p), { recursive: true }, (err) => {
      if (err && err.code !== 'EEXIST') return rej(err);
      fs.writeFile(p, content, (err2) => err2 ? rej(err2) : res());
    });
  });
}

module.exports = TypedConfigPlugin;
```

## Usage

```js
new TypedConfigPlugin({
  sourceFile: 'config/feature-flags.json',
  runtimeModule: 'virtual:flags',
  declarationFile: 'src/types/generated/flags.d.ts',
  typeName: 'FeatureFlags',
})

// tsconfig.json should include src/types/generated/**
// Then in source:
import flags, { FeatureFlags } from 'virtual:flags';

if (flags.newCheckout) { /* typed boolean */ }
flags.darkMode;       // typed boolean
flags.darkMod;        // TS error: Property 'darkMod' does not exist
```

## How it works

- **`beforeRun`/`watchRun` write the `.d.ts` BEFORE compilation** — typescript's `forkTsCheckerWebpackPlugin` runs early and needs the file in place by then. If you wrote it in `processAssets`, type checking would run against the previous build's types.
- **`compiler.outputFileSystem`** instead of Node `fs` — respects test setups using `MemoryFs`, and is the canonical write surface
- **`compiler.inputFileSystem` for reads** with `fileDependencies.add(sourceFile)` — watch invalidates when the JSON changes. See [`webpack-plugin-authoring/cache-use-input-file-system`].
- **TypeScript's "ambient declaration"** via `declare module 'virtual:flags'` is the mechanism that makes virtual modules typed — same pattern used by `*.svg` and `*.css` types in CRA/Next templates
- **Type inference** by walking JSON values produces accurate types; for stricter types use JSON Schema → TS converters (`json-schema-to-typescript`)

## Variations

- **From GraphQL/OpenAPI schemas** — swap `JSON.parse + typeOf` for a schema-to-TS generator (`@graphql-codegen`, `openapi-typescript`)
- **Multiple sources** (`{ ts: ['a.json', 'b.json'], runtime: 'virtual:config' }` — merge at runtime)
- **As `const` types** (literal types not just `string`):
  ```ts
  // typeOf for `"checkout"` returns `'checkout'` instead of `string`
  ```
- **Branded types** for IDs (`type UserId = string & { readonly __brand: 'UserId' }`)

## When NOT to use this pattern

- You can use `as const` imports of JSON with `resolveJsonModule: true` — TypeScript will infer narrow literal types automatically
- The source is genuinely under TS control (a `.ts` config file) — no codegen needed
- You're using tRPC, GraphQL Codegen, or another tool that handles type generation — they specialize in this

Reference: [TypeScript ambient modules](https://www.typescriptlang.org/docs/handbook/modules.html#ambient-modules) · [json-schema-to-typescript](https://github.com/bcherny/json-schema-to-typescript) · [outputFileSystem](https://webpack.js.org/api/node/#nodejs-api)
