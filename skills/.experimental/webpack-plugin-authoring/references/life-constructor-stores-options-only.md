---
title: Store Options in the Constructor, Do the Work in apply()
impact: HIGH
impactDescription: prevents side effects on plugin import
tags: life, constructor, apply, side-effects
---

## Store Options in the Constructor, Do the Work in apply()

`new MyPlugin(options)` may run at config-load time, before any compiler exists. Doing filesystem reads, spawning workers, or starting timers in the constructor means importing `webpack.config.js` has side effects — your plugin executes during `webpack --version`, during `--inspect-config`, and during test suites that just want to read the config object. Every effect belongs in `apply(compiler)`, which is webpack's signal that "a build is about to happen and this plugin is part of it."

**Incorrect (side effects on construction — runs even when no build happens):**

```js
class JsonValidatorPlugin {
  constructor({ schemaPath }) {
    this.schemaPath = schemaPath;
    // Runs at config load — even when user runs `webpack --inspect-config`
    this.schema = JSON.parse(fs.readFileSync(schemaPath, 'utf8'));
    this.ajv = new Ajv();
    this.validate = this.ajv.compile(this.schema);
    // Worker started before we know if there's a compiler
    this.worker = new Worker(require.resolve('./validator-worker'));
  }
  apply(compiler) { /* ... */ }
}
```

**Correct (constructor only validates and stores options):**

```js
const { validate } = require('schema-utils');
const optionsSchema = require('./options-schema.json');

class JsonValidatorPlugin {
  constructor(options = {}) {
    validate(optionsSchema, options, {
      name: 'JsonValidatorPlugin',
      baseDataPath: 'options',
    });
    this.options = options;
    // No file reads, no workers, no network — just store.
  }

  apply(compiler) {
    // Lazy-initialize state that depends on the compiler
    let validateFn = null;
    let worker = null;

    compiler.hooks.beforeRun.tapPromise('JsonValidatorPlugin', async () => {
      if (!validateFn) {
        const buf = await readFile(compiler.inputFileSystem, this.options.schemaPath);
        const schema = JSON.parse(buf.toString('utf8'));
        validateFn = new Ajv().compile(schema);
      }
      if (!worker) {
        worker = new Worker(require.resolve('./validator-worker'));
      }
    });

    // Clean up on shutdown
    compiler.hooks.shutdown.tapPromise('JsonValidatorPlugin', async () => {
      if (worker) {
        await worker.terminate();
        worker = null;
      }
    });
  }
}
```

**What belongs where:**

| Activity | Constructor | `apply()` |
|---|---|---|
| Validate options via `schema-utils` | ✓ | ✗ (too late — webpack already accepted the plugin) |
| Store options on `this` | ✓ | ✗ |
| Read files | ✗ | ✓ (via `compiler.inputFileSystem`) |
| Spawn workers | ✗ | ✓ (start in `beforeRun`, terminate in `shutdown`) |
| Start timers / intervals | ✗ | ✓ |
| Network calls | ✗ | ✓ |
| Register hooks on `compiler` | ✗ | ✓ |
| Mutate `process.env` | ✗ | Never (use `DefinePlugin` instead) |

**Always clean up in `compiler.hooks.shutdown`** (async-series). Workers, file watchers, and child processes that aren't terminated leak across test runs and prevent CI processes from exiting.

**The `--inspect-config` test:** A good sanity check — `npx webpack --inspect-config 2>&1 | head` should print the resolved config without your plugin doing any work.

Reference: [Writing a Plugin — Basic plugin architecture](https://webpack.js.org/contribute/writing-a-plugin/) · [Compiler shutdown hook](https://webpack.js.org/api/compiler-hooks/#shutdown)
