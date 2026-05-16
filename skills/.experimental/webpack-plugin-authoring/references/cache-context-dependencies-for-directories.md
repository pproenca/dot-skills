---
title: Use contextDependencies for Directory Scans, Not Glob Expansion
impact: HIGH
impactDescription: prevents missing newly-added files in watch mode
tags: cache, contextDependencies, glob, watch-mode
---

## Use contextDependencies for Directory Scans, Not Glob Expansion

When a plugin scans `src/icons/*.svg` and adds each resolved file to `fileDependencies`, watch mode rebuilds when an existing icon changes — but does NOT rebuild when a NEW icon is added to the directory. To watch the existence of files (additions and deletions, not just modifications), add the directory itself to `compilation.contextDependencies`. Webpack snapshots the directory listing and triggers a rebuild when it changes.

**Incorrect (only watches files that existed at first scan):**

```js
const fg = require('fast-glob');

compilation.hooks.processAssets.tap(/* ... */, async () => {
  const icons = await fg('src/icons/*.svg', { cwd: compiler.context, absolute: true });
  for (const icon of icons) {
    const svg = await fs.promises.readFile(icon, 'utf8');
    emitSprite(compilation, icon, svg);
    compilation.fileDependencies.add(icon); // catches modifications only
  }
  // Adding a new src/icons/foo.svg does NOT trigger a rebuild
});
```

**Correct (declare the directory so additions/deletions invalidate the build):**

```js
const fg = require('fast-glob');

compilation.hooks.processAssets.tapPromise(/* ... */, async () => {
  const iconsDir = path.resolve(compiler.context, 'src/icons');
  const icons = await fg('*.svg', { cwd: iconsDir, absolute: true });

  for (const icon of icons) {
    const svg = await fs.promises.readFile(icon, 'utf8');
    emitSprite(compilation, icon, svg);
    compilation.fileDependencies.add(icon); // existing files: modifications
  }

  compilation.contextDependencies.add(iconsDir); // directory: additions + deletions
});
```

**Decision matrix:**

| What you depend on | Add to |
|---|---|
| A specific file's content | `fileDependencies` |
| The set of files in a directory (additions/deletions matter) | `contextDependencies` |
| A specific filename that DOESN'T exist yet but might appear | `missingDependencies` |
| Both directory contents AND each file's content | Both: directory to `contextDependencies`, each file to `fileDependencies` |

**Common contextDependencies use cases:**

- Icon-sprite plugins scanning `src/icons/`
- i18n plugins watching `locales/` for new language files
- Route plugins generating from a `pages/` filesystem (the Next.js pattern)
- Asset plugins watching `public/` for new static files

**Glob patterns are NOT valid dependencies.** Webpack 5 deprecated converting globs to context dependencies — pass an absolute directory path instead. If you need recursive watching of subdirectories, you must add each subdirectory you read.

**Performance note:** Context dependencies snapshot the directory listing on every build. Avoid declaring `node_modules` or your project root — it triggers expensive directory scans on every rebuild.

Reference: [Compilation API — contextDependencies](https://webpack.js.org/api/compilation-object/#contextdependencies) · [Plugin Patterns — Watch Graph](https://webpack.js.org/contribute/plugin-patterns/#monitoring-the-watch-graph)
