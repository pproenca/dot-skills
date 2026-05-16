---
title: {Problem-Named — what the recipe accomplishes, e.g. "Fail Builds When X" or "Generate Y From Z"}
impact: {CRITICAL|HIGH|MEDIUM-HIGH|MEDIUM|LOW-MEDIUM}
impactDescription: {what this prevents / saves — quantified where possible}
tags: {category-prefix}, {problem-domain}, {webpack-api}, {related-tool}
---

## {Same as title}

## Problem

{2-4 sentences naming the concrete pain. Specific is better than generic. Example for a good problem statement:

"Your team agreed initial JS should stay under 250kb gzipped — but no one notices when a PR adds a 60kb dependency. CI passes; bundle bloat creeps in; weeks later a perf review catches that bundle size jumped 40%. You need CI to FAIL the build when the budget is exceeded — not warn, not log, fail."

Bad problem statement: "You need to manage bundle size." (No pain, no concrete trigger, no failure mode.)}

## Pattern

{1-2 sentences describing the technical approach. Name the hook, the stage if applicable, and the key insight. Example:
"Tap `processAssets` at `PROCESS_ASSETS_STAGE_OPTIMIZE_HASH`, sum entry-chunk asset sizes from `compilation.getAsset(name).info.size`, compare against budgets, push a WebpackError on excess."}

**Incorrect (without a plugin — what people do without one):**

```js
// Brief example of the non-plugin approach (shell script, manual maintenance,
// off-the-shelf plugin that doesn't fit, etc.). 5-15 lines max.
// Show what goes wrong: silent failure, drift, missed cases.
```

**Correct (with this plugin — the recipe's working code):**

```js
// Complete, runnable plugin — 60-150 lines.
// Production-shaped:
//   - schema-utils validation in constructor
//   - WebpackError pushed to compilation.errors (not throw)
//   - compiler.webpack.* namespace (not direct webpack import)
//   - Correct hook + stage
//   - Source-map-preserving transformations
//   - Cache integration where applicable
// User should be able to copy this verbatim and have a working plugin.

const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: { /* ... */ },
  additionalProperties: false,
};

class MyRecipePlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'MyRecipePlugin', baseDataPath: 'options' });
    this.options = options;
  }

  apply(compiler) {
    /* ... */
  }
}

module.exports = MyRecipePlugin;
```

## Usage

```js
// Show how the plugin is wired into webpack.config.js,
// with realistic options (not placeholder values).

new MyRecipePlugin({
  // realistic config
})
```

## How it works

{Walk through 3-6 key decisions in the code. Cross-reference the authoring skill where applicable:
- "We use `processAssets` not `emit` because [`webpack-plugin-authoring/hook-prefer-process-assets-over-emit`]."
- "We push to `compilation.errors`, not throw, because [`webpack-plugin-authoring/diag-push-webpack-error-not-throw`]."
- "We use `compiler.webpack.sources` so persistent cache works across versions; see [`webpack-plugin-authoring/asset-source-from-compiler-webpack`]."

The cross-references make the recipe a teaching artifact, not just a copy-paste source.}

## Variations

- **Variation 1 name** (one-line description): brief code or config snippet
- **Variation 2 name** (one-line description): brief code or config snippet
- **Variation 3 name** (one-line description)

## When NOT to use this pattern

- {Specific scenario where this is the wrong tool — name the better alternative}
- {Another scenario — e.g., "you already use [off-the-shelf plugin] and it fits your needs"}
- {Edge case where the cost/benefit doesn't work}

Reference: [{Authoritative source 1}]({URL}) · [{Authoritative source 2}]({URL})

---

## Authoring checklist

Before adding a new recipe:

- [ ] Filename matches `{prefix}-{kebab-case-slug}.md` where `{prefix}` is one of: `guard`, `meta`, `virtual`, `transform`, `dx`, `assets`
- [ ] First tag in frontmatter is the category prefix
- [ ] Title is problem-named (what it accomplishes), not API-named
- [ ] `impactDescription` is quantified where possible — savings in kb, ms, prevention of a named failure
- [ ] **Problem** section names a concrete pain with specifics (numbers, scenarios), not generic "you might want to..."
- [ ] Both `**Incorrect (without a plugin)**` and `**Correct (with this plugin)**` sections present
- [ ] Plugin code is production-shaped: schema-utils validation, WebpackError, compiler.webpack namespace, correct hook+stage
- [ ] Code blocks have language specifiers (` ```js `, ` ```json `, ` ```text `, ` ```bash `, ` ```nginx `)
- [ ] Cross-references to webpack-plugin-authoring rules where applicable
- [ ] At least 2 "Variations" entries
- [ ] At least 2 "When NOT to use this pattern" entries
- [ ] Reference link to authoritative sources (webpack.js.org, github.com/webpack-contrib, vercel/next.js, etc.)
- [ ] After saving, run `node ${CLAUDE_PLUGIN_ROOT}/scripts/validate-skill.js /path/to/skill`
- [ ] After saving, run `node ${CLAUDE_PLUGIN_ROOT}/scripts/build-agents-md.js /path/to/skill`
