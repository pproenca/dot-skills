---
title: Fail Builds When Forbidden Imports Cross Architectural Boundaries
impact: CRITICAL
impactDescription: prevents architecture decay across long-lived codebases
tags: guard, architecture, imports, layering, eslint-no-restricted-imports
---

## Fail Builds When Forbidden Imports Cross Architectural Boundaries

## Problem

You've established an architectural rule: `src/ui/**` may never import from `src/server/**` (because server code drags `pg`, `bcrypt`, and Node `fs` into the client bundle and bloats it by 800kb). The team agreed in design review. Three months later, someone imports `getUserById` from `src/server/db.ts` into a React component because autocomplete suggested it — the bundle silently bloats and a `bcrypt` runtime call ends up in the browser. ESLint's `no-restricted-imports` catches some cases but only at the source-text level; it misses transitive imports (`import './helpers'` where `helpers.ts` re-exports forbidden code) and barrel-file laundering.

This plugin enforces the rule against webpack's RESOLVED module graph — if forbidden code reaches a forbidden chunk, the build fails with the import chain showing how.

## Pattern

Tap `compilation.hooks.afterOptimizeModules` (after the dependency graph is finalized), walk every module, check each module's `userRequest` against forbidden patterns based on which chunks the module ended up in, and push a `WebpackError` with the import chain on each violation.

**Incorrect (without a plugin — relying on ESLint `no-restricted-imports` only):**

```js
// .eslintrc.js
module.exports = {
  rules: {
    'no-restricted-imports': ['error', {
      patterns: ['**/server/**'],  // catches direct import in the SAME FILE
    }],
  },
};
// Misses: import './helpers' where helpers.ts itself imports from server/
// Misses: barrel-file laundering where ./index.ts re-exports server/db
// Misses: transitive imports through legitimate-looking utility libraries
```

**Correct (with this plugin — checks resolved chunk membership, not source text):**

```js
const path = require('node:path');
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    rules: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string', minLength: 1 },
          chunks: { type: 'string', minLength: 1, description: 'Glob/regex for chunk names this rule applies to' },
          forbidden: { type: 'string', minLength: 1, description: 'Glob/regex matched against module.userRequest' },
          message: { type: 'string' },
        },
        required: ['name', 'chunks', 'forbidden'],
        additionalProperties: false,
      },
      minItems: 1,
    },
  },
  required: ['rules'],
  additionalProperties: false,
};

class ForbiddenImportsPlugin {
  constructor(options) {
    validate(schema, options, { name: 'ForbiddenImportsPlugin', baseDataPath: 'options' });
    this.rules = options.rules.map((r) => ({
      ...r,
      chunksRegex: toRegex(r.chunks),
      forbiddenRegex: toRegex(r.forbidden),
    }));
  }

  apply(compiler) {
    const { WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('ForbiddenImportsPlugin', (compilation) => {
      compilation.hooks.afterOptimizeModules.tap('ForbiddenImportsPlugin', (modules) => {
        for (const rule of this.rules) {
          for (const mod of modules) {
            const request = mod.userRequest || mod.rawRequest;
            if (!request || !rule.forbiddenRegex.test(request)) continue;

            // Find which chunks this module landed in, filter to matching ones
            const matchingChunks = [...compilation.chunkGraph.getModuleChunks(mod)]
              .filter((c) => rule.chunksRegex.test(c.name ?? ''));
            if (matchingChunks.length === 0) continue;

            const chain = explainHowItGotHere(compilation, mod, rule);
            for (const chunk of matchingChunks) {
              const err = new WebpackError(
                `[${rule.name}] Forbidden import in chunk "${chunk.name}": ${request}\n` +
                (rule.message ? `  ${rule.message}\n` : '') +
                `  Import chain:\n${chain.map((c) => `    ${c}`).join('\n')}`,
              );
              err.hideStack = true;
              err.module = mod;
              compilation.errors.push(err);
            }
          }
        }
      });
    });
  }
}

function explainHowItGotHere(compilation, target, rule) {
  // Walk reverse dependencies until we find one that DOESN'T match `forbidden`
  // — that's where the architectural violation begins
  const chain = [target.userRequest];
  const seen = new Set([target]);

  let cursor = target;
  while (cursor) {
    const incoming = [...compilation.moduleGraph.getIncomingConnections(cursor)]
      .map((c) => c.originModule)
      .filter((m) => m && !seen.has(m));
    if (incoming.length === 0) break;
    const next = incoming[0];
    seen.add(next);
    chain.unshift(next.userRequest ?? '<entry>');
    if (!rule.forbiddenRegex.test(next.userRequest ?? '')) break;
    cursor = next;
  }
  return chain;
}

function toRegex(pattern) {
  if (pattern.startsWith('/') && pattern.endsWith('/')) {
    return new RegExp(pattern.slice(1, -1));
  }
  // Glob → regex: ** matches anything, * matches single segment
  const escaped = pattern
    .replace(/[.+?^${}()|[\]\\]/g, '\\$&')
    .replace(/\*\*/g, '.*')
    .replace(/\*/g, '[^/]*');
  return new RegExp(`^${escaped}$|${escaped}`);
}

module.exports = ForbiddenImportsPlugin;
```

## Usage

```js
new ForbiddenImportsPlugin({
  rules: [
    {
      name: 'no-server-in-ui',
      chunks: '*',                       // any client chunk
      forbidden: '**/src/server/**',
      message: 'UI code cannot import server code — use API client at src/api/ instead',
    },
    {
      name: 'no-test-utils-in-prod',
      chunks: '*',
      forbidden: '/(test-utils|__mocks__|jest\\.setup)/',
      message: 'Test utilities must not be bundled into production builds',
    },
  ],
})
```

## How it works

- **`afterOptimizeModules`** runs after webpack has finalized which modules go in which chunks (post-split-chunks). Earlier hooks miss this picture; later hooks (`afterEmit`) are too late to fail.
- **`compilation.chunkGraph.getModuleChunks(mod)`** is webpack 5's API — replaces the deprecated `module.chunksIterable`. See [`webpack-plugin-authoring/perf-traverse-chunks-not-modules`].
- **`compilation.moduleGraph.getIncomingConnections(mod)`** walks reverse dependencies — used to produce the "how did this end up here?" chain that makes errors actionable.
- **`err.hideStack = true`** suppresses webpack's auto-stack on the error — the import chain IS the explanation. See [`webpack-plugin-authoring/diag-attach-loc-to-errors`].

## Variations

- **Warn-only mode for new rules** (rollout): `failOn: 'warning'` per rule
- **Allowlist exceptions** (you must violate the rule for a specific file): add an `exceptions: string[]` array per rule
- **Apply only to production builds:** `if (compiler.options.mode !== 'production') return;` in `apply()`
- **Check loaders/resources too** (catch a CSS import that drags JS): extend the request check to include `mod.loaders` as well

## When NOT to use this pattern

- You already use [eslint-plugin-boundaries](https://github.com/javierbrea/eslint-plugin-boundaries) or [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) — those work at source-text level which is sufficient for most projects, and run in your editor too
- Your architectural rules are about WHICH FILES exist, not what imports what — `git pre-commit` checks are better

Reference: [eslint-no-restricted-imports](https://eslint.org/docs/latest/rules/no-restricted-imports) · [dependency-cruiser](https://github.com/sverweij/dependency-cruiser) · [webpack moduleGraph API](https://webpack.js.org/api/compilation-object/#modulegraph)
