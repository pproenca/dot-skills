---
title: Use compiler.webpack.* Instead of Importing webpack
impact: LOW-MEDIUM
impactDescription: prevents class-identity mismatches in monorepos
tags: compat, compiler-webpack, namespace, class-identity
---

## Use compiler.webpack.* Instead of Importing webpack

`require('webpack')` resolves to whatever webpack copy your plugin can find — which may not be the same one the user's compiler is from, especially in pnpm monorepos, yarn workspaces, or when the plugin is symlinked. `compiler.webpack` is the namespace exposing the EXACT webpack instance that created the compiler. Using it guarantees `instanceof` checks pass, persistent cache works, and `Compilation.PROCESS_ASSETS_STAGE_*` constants match what the user's webpack uses.

**Incorrect (direct import — different instance in monorepos):**

```js
const webpack = require('webpack');
const { sources, Compilation, WebpackError } = require('webpack');

class BannerPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('BannerPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'BannerPlugin',
          // Compilation.PROCESS_ASSETS_STAGE_ADDITIONS from "our" webpack
          // may differ from the host webpack's stage numbering
          stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS,
        },
        (assets) => {
          // sources.RawSource from "our" webpack — instanceof checks fail in user's webpack
          compilation.updateAsset(name, new sources.RawSource(/* ... */));
        },
      );
    });
  }
}
```

**Correct (compiler.webpack — guaranteed same instance as host):**

```js
class BannerPlugin {
  apply(compiler) {
    // Destructure once per compiler — the namespace is stable
    const { sources, Compilation, WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('BannerPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'BannerPlugin',
          stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS,
        },
        (assets) => {
          compilation.updateAsset(name, new sources.RawSource(/* ... */));
        },
      );
    });
  }
}
```

**Complete map of `compiler.webpack` exports:**

| Namespace | Contains | Replaces |
|---|---|---|
| `compiler.webpack.sources` | `RawSource`, `OriginalSource`, `SourceMapSource`, `ConcatSource`, `ReplaceSource`, `CachedSource`, `PrefixSource` | `require('webpack-sources')` |
| `compiler.webpack.Compilation` | `PROCESS_ASSETS_STAGE_*` stage constants, type reference | `require('webpack').Compilation` |
| `compiler.webpack.WebpackError` | Base error class | `require('webpack').WebpackError` |
| `compiler.webpack.ModuleFilenameHelpers` | URL/path helpers (`createFilename`) | `require('webpack').ModuleFilenameHelpers` |
| `compiler.webpack.util.createHash` | xxhash64-aware hash factory | `require('crypto').createHash` (doesn't know xxhash64) |
| `compiler.webpack.util.serialization` | Persistent-cache serializers | for custom serializable types |
| `compiler.webpack.optimize.SplitChunksPlugin` | Bundled plugins for re-use | `require('webpack').optimize.X` |
| `compiler.webpack.DefinePlugin`, etc. | Top-level bundled plugins | `require('webpack').DefinePlugin` |

**Single legitimate `require('webpack')` use case: TypeScript types only:**

```ts
// type-only import — erased at runtime, no runtime dependency
import type { Compiler, Compilation } from 'webpack';

class BannerPlugin {
  apply(compiler: Compiler) {
    const { sources, Compilation } = compiler.webpack; // runtime: use the namespace
  }
}
```

For published TypeScript plugins, types come from `webpack` itself (no `@types/webpack` needed for webpack 5).

**When does it matter in practice?**

- **pnpm strict mode** (default): each package gets its own dependency tree — direct require resolves to a different webpack copy
- **Yarn workspaces with `nohoist`**: same effect
- **Symlinked dev installs**: `npm link my-plugin` — your plugin resolves `webpack` against ITS node_modules, not the host's
- **Webpack used as a library**: tools like Next.js bundle their own webpack — `compiler.webpack` is the only way to get the right one

Reference: [Webpack 5 release — sources via compiler.webpack](https://webpack.js.org/blog/2020-10-10-webpack-5-release/) · [Webpack 5 release notes — compiler.webpack](https://webpack.js.org/blog/2020-10-10-webpack-5-release/#minimum-nodejs-version)
