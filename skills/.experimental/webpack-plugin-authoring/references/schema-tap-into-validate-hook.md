---
title: Use compiler.hooks.validate for Cross-Cutting Validation (5.106+)
impact: MEDIUM-HIGH
impactDescription: prevents expensive validation running on every config load
tags: schema, validate-hook, futureDefaults, webpack-5
---

## Use compiler.hooks.validate for Cross-Cutting Validation (5.106+)

Constructor-time validation runs every time `webpack.config.js` is loaded — even for `--inspect-config`, dry-run tooling, and IDE integrations. Webpack 5.106 added `compiler.hooks.validate` (SyncHook) for plugins to register validation work that should ONLY run when webpack is actually going to validate the build. Combined with `experiments.futureDefaults`, this lets users turn validation off in production for faster startup. The schema validation still happens — but only on opt-in, and integrated with webpack's own checks.

**Incorrect (validation runs every time the plugin is instantiated):**

```js
class CrossFieldValidatorPlugin {
  constructor(options = {}) {
    this.options = options;
    // Heavy cross-field check (e.g., verifying that referenced files exist)
    // runs even when user only loads the config to inspect it
    if (options.routes) {
      for (const route of options.routes) {
        if (!fs.existsSync(route.handler)) {
          throw new Error(`Handler ${route.handler} not found`);
        }
      }
    }
  }
  apply(compiler) { /* ... */ }
}
```

**Correct (defer cross-field validation to the validate hook):**

```js
class CrossFieldValidatorPlugin {
  constructor(options = {}) {
    // Schema validation still happens upfront — it's cheap and surfaces typos early
    validate(schema, options, { name: 'CrossFieldValidatorPlugin', baseDataPath: 'options' });
    this.options = options;
  }

  apply(compiler) {
    // Heavy filesystem checks deferred — only run if webpack is validating
    compiler.hooks.validate.tap('CrossFieldValidatorPlugin', () => {
      if (!this.options.routes) return;
      for (const route of this.options.routes) {
        if (!compiler.inputFileSystem.statSync?.(route.handler)) {
          compiler.validate(new WebpackError(
            `[CrossFieldValidatorPlugin] Handler not found: ${route.handler}`,
          ));
        }
      }
    });

    compiler.hooks.thisCompilation.tap('CrossFieldValidatorPlugin', (compilation) => {
      /* ... */
    });
  }
}
```

**When to use the `validate` hook vs constructor:**

| Validation type | Where |
|---|---|
| Shape/type checks (JSON Schema) | Constructor, via `schema-utils.validate()` |
| Cross-field consistency (option A requires option B) | `compiler.hooks.validate` |
| Filesystem existence checks | `compiler.hooks.validate` |
| Compatibility with other plugins | `compiler.hooks.initialize` (after all plugins applied) |
| Runtime correctness (depends on compilation state) | `compilation.hooks.afterSeal` |

**Compatibility note:** `compiler.hooks.validate` only exists in webpack 5.106+. If you support older versions:

```js
apply(compiler) {
  if (compiler.hooks.validate) {
    compiler.hooks.validate.tap('Plugin', () => this.validate(compiler));
  } else {
    // Fall back to running validation at beforeRun on older webpack
    compiler.hooks.beforeRun.tap('Plugin', () => this.validate(compiler));
  }
}
```

Reference: [Webpack 5.106 release notes](https://webpack.js.org/blog/2026-04-08-webpack-5-106/) · [experiments.futureDefaults](https://webpack.js.org/configuration/experiments/#experimentsfuturedefaults)
