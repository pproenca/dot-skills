---
title: Add Looked-For-But-Absent Paths to missingDependencies
impact: HIGH
impactDescription: prevents stale builds when an optional file appears
tags: cache, missingDependencies, optional-files, monorepo
---

## Add Looked-For-But-Absent Paths to missingDependencies

When a plugin checks for an optional file (e.g., `tsconfig.json` in each candidate parent directory, a `.env.production` override) and the file doesn't exist, the absence is a real input to the build. If a developer later creates that file, the build must rebuild — but webpack has no way to know unless the path was registered in `compilation.missingDependencies`. Without it, the next rebuild produces stale output until something else forces a full rebuild.

**Incorrect (probes for `.env.local` but never declares it — adding the file is invisible):**

```js
compilation.hooks.processAssets.tap(/* ... */, () => {
  const envLocalPath = path.resolve(compiler.context, '.env.local');
  let extraEnv = {};
  if (fs.existsSync(envLocalPath)) {
    extraEnv = parseDotenv(fs.readFileSync(envLocalPath, 'utf8'));
    compilation.fileDependencies.add(envLocalPath);
  }
  // If .env.local DOESN'T exist now but is created later:
  // existsSync still returns false on the next rebuild (require.cache),
  // and webpack has no fileDependency on it. Build is permanently stale.
  emitEnvManifest(compilation, extraEnv);
});
```

**Correct (declare it as missing so its appearance triggers a rebuild):**

```js
compilation.hooks.processAssets.tap(/* ... */, () => {
  const envLocalPath = path.resolve(compiler.context, '.env.local');
  let extraEnv = {};
  if (fs.existsSync(envLocalPath)) {
    extraEnv = parseDotenv(fs.readFileSync(envLocalPath, 'utf8'));
    compilation.fileDependencies.add(envLocalPath);
  } else {
    // File didn't exist this build — re-run when it appears
    compilation.missingDependencies.add(envLocalPath);
  }
  emitEnvManifest(compilation, extraEnv);
});
```

**Use `missingDependencies` whenever the answer "no" is part of your output:**

- Module-resolution-like searches: walking up parent dirs looking for `package.json`, `tsconfig.json`, `.git`
- Optional config files: `.eslintrc.local`, `babel.config.dev.js`
- Conditional asset emission: "if `public/robots.txt` exists, copy it; otherwise emit a default"
- Resolver fallbacks: trying `./foo.ts`, then `./foo.tsx`, then `./foo.js`

**Don't pre-add every path that MIGHT exist.** `missingDependencies` is for paths the plugin actually probed and didn't find — webpack snapshots each one and rechecks on every rebuild. A `missingDependencies` Set with thousands of speculative entries makes rebuilds noticeably slower.

**Pair with proper resolution:** If your plugin uses webpack's resolver (`compiler.resolverFactory.get('normal')`), the resolver already adds appropriate `missingDependencies` for unsuccessful candidates. You only need to add manually when you do the lookup yourself.

Reference: [Compilation API — missingDependencies](https://webpack.js.org/api/compilation-object/#missingdependencies)
