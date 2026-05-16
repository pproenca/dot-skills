---
title: Register Compiler Hooks Once in apply, Not Inside Compilation Hooks
impact: CRITICAL
impactDescription: prevents O(n) duplicate tap registration
tags: hook, apply, registration, watch-mode, leak
---

## Register Compiler Hooks Once in apply, Not Inside Compilation Hooks

`apply(compiler)` runs exactly once. `compiler.hooks.compilation` (and `thisCompilation`) fires once per build — and in `--watch`, once per rebuild. Registering compiler-level hooks INSIDE a compilation tap creates a new tap on every rebuild, leaving previous tap functions still attached. After 50 rebuilds you have 50 copies of the same handler firing per event, leaking memory and making debugging impossible.

**Incorrect (re-registers `compiler.hooks.done` on every compilation — leaks across rebuilds):**

```js
class TimingPlugin {
  apply(compiler) {
    compiler.hooks.thisCompilation.tap('TimingPlugin', (compilation) => {
      const start = Date.now();
      // BUG: every rebuild adds another `done` tap. After 10 rebuilds,
      // this logs 10 times. After 100, the build is noticeably slow.
      compiler.hooks.done.tap('TimingPlugin', () => {
        console.log(`Build took ${Date.now() - start}ms`);
      });
    });
  }
}
```

**Correct (register all compiler hooks once in apply, share state via WeakMap):**

```js
class TimingPlugin {
  apply(compiler) {
    const startTimes = new WeakMap();

    compiler.hooks.thisCompilation.tap('TimingPlugin', (compilation) => {
      startTimes.set(compilation, Date.now());
    });

    // Registered once, fires once per build, no leak
    compiler.hooks.done.tap('TimingPlugin', (stats) => {
      const start = startTimes.get(stats.compilation);
      if (start !== undefined) {
        console.log(`Build took ${Date.now() - start}ms`);
      }
    });
  }
}
```

**Rule of thumb:**

- `compiler.hooks.*.tap(...)` belongs in `apply()` — runs once
- `compilation.hooks.*.tap(...)` belongs in the `thisCompilation` callback — runs once per compilation
- Use `WeakMap<Compilation, T>` to thread state from compilation to compiler-level hooks

**How this typically slips in:** Authors write a "complete" plugin inside one closure for readability, not realizing that nesting compiler-hook registration inside the compilation callback registers it again on every rebuild. The validate-skill linter cannot catch this; only watch-mode testing does.

Reference: [Writing a Plugin — apply method](https://webpack.js.org/contribute/writing-a-plugin/#basic-plugin-architecture)
