---
title: Read Files Via compiler.inputFileSystem, Not Node fs
impact: HIGH
impactDescription: prevents bypassing the in-memory dev-server filesystem
tags: cache, inputFileSystem, dev-server, virtual-filesystem
---

## Read Files Via compiler.inputFileSystem, Not Node fs

`compiler.inputFileSystem` is webpack's cached filesystem abstraction. In `webpack-dev-server` and many test setups (especially `webpack/lib/util/MemoryFs`), it's a virtual in-memory filesystem that contains generated files invisible to Node's `fs`. Reading via `fs.readFileSync` bypasses the cache (every read hits disk), misses virtual files entirely, and breaks plugins that compose on top of `dev-server`'s asset pipeline.

**Incorrect (Node fs — bypasses cache, misses virtual files in dev-server):**

```js
const fs = require('node:fs');

compilation.hooks.processAssets.tap(/* ... */, () => {
  // Disk read on every call. Misses dev-server's in-memory assets entirely.
  const template = fs.readFileSync(this.templatePath, 'utf8');
  emit(template);
  compilation.fileDependencies.add(this.templatePath);
});
```

**Correct (inputFileSystem — cached, virtualization-aware):**

```js
compilation.hooks.processAssets.tapPromise(/* ... */, async () => {
  const { inputFileSystem } = compiler;

  const template = await new Promise((resolve, reject) => {
    inputFileSystem.readFile(this.templatePath, (err, buffer) => {
      if (err) reject(err);
      else resolve(buffer.toString('utf8'));
    });
  });

  emit(template);
  compilation.fileDependencies.add(this.templatePath);
});
```

**inputFileSystem method shape:** All methods are CALLBACK-style (Node-fs-classic). Wrap with `util.promisify` or your own promise wrapper for `async/await`. Common methods:

| Method | Signature | Notes |
|---|---|---|
| `readFile(path, cb)` | `(Buffer) => void` | Returns Buffer, not string |
| `readJson(path, cb)` | `(parsed) => void` | webpack 5 — parses JSON |
| `readdir(path, cb)` | `(string[]) => void` | Directory contents |
| `stat(path, cb)` | `(Stats) => void` | File metadata |
| `purge(path?)` | sync | Invalidate cache for path (or all) |

**Why this matters even outside dev-server:**

- `inputFileSystem` caches stat and content during a single build — N reads of the same file = 1 disk hit
- `compiler.intermediateFileSystem` is the OUTPUT counterpart for `cache.type: 'filesystem'` writes
- Plugins that work with `webpack-dev-middleware` MUST use `inputFileSystem` — otherwise their reads don't see the dev-middleware's in-memory output

**For writes during the build, use `outputFileSystem`:**

```js
// Writing a generated config file alongside the output
await new Promise((resolve, reject) => {
  compiler.outputFileSystem.mkdir(
    path.dirname(targetPath),
    { recursive: true },
    (err) => err ? reject(err) : resolve(),
  );
});
```

This honors `output.path` redirection in tests and respects dev-middleware's in-memory write surface.

Reference: [Compiler API — inputFileSystem](https://webpack.js.org/api/compiler-hooks/) · [webpack/enhanced-resolve](https://github.com/webpack/enhanced-resolve)
