---
title: Use thisCompilation to Skip Child Compilations
impact: CRITICAL
impactDescription: prevents firing for every child compilation
tags: hook, compilation, child-compiler, thisCompilation
---

## Use thisCompilation to Skip Child Compilations

`compiler.hooks.compilation` fires for the main compilation AND every child compilation (e.g., `html-webpack-plugin`'s template compilation, `mini-css-extract`'s style compilation). `compiler.hooks.thisCompilation` fires ONLY for the parent compilation that the child belongs to. Tapping `compilation` when you mean to mutate the top-level asset graph causes your hook to run dozens of times, often producing duplicate assets or polluting child compilations meant to produce intermediate output.

**Incorrect (fires for every child compilation — duplicates assets, breaks html-webpack-plugin):**

```js
class InjectGlobalCssPlugin {
  apply(compiler) {
    compiler.hooks.compilation.tap('InjectGlobalCssPlugin', (compilation) => {
      // Fires for the parent build AND for HtmlWebpackPlugin's child compilation
      // for the index.html template — your CSS gets injected into the template
      // compiler too, where it has no meaning.
      compilation.hooks.processAssets.tap(
        { name: 'InjectGlobalCssPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS },
        (assets) => { /* ... */ },
      );
    });
  }
}
```

**Correct (thisCompilation fires only for the top-level compilation):**

```js
class InjectGlobalCssPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('InjectGlobalCssPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        { name: 'InjectGlobalCssPlugin', stage: Compilation.PROCESS_ASSETS_STAGE_ADDITIONS },
        (assets) => { /* ... */ },
      );
    });
  }
}
```

**When `compilation` IS the right hook:**

- You explicitly want to also instrument child compilations (e.g., a logger plugin that reports build progress for ALL compilations)
- You're providing custom hooks via `getCompilationHooks` and want them available on every compilation

Reference: [Compiler Hooks — thisCompilation vs compilation](https://webpack.js.org/api/compiler-hooks/#thiscompilation)
