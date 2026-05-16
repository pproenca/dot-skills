---
title: Fail Builds When Secret-Shaped Strings Leak Into Client Bundles
impact: CRITICAL
impactDescription: prevents shipping API keys / private tokens to the browser
tags: guard, secrets, leak-detection, security
---

## Fail Builds When Secret-Shaped Strings Leak Into Client Bundles

## Problem

A developer writes `const key = process.env.STRIPE_SECRET_KEY` inside a React component, intending it for an isomorphic helper that should only run on the server. `DefinePlugin` happily substitutes the literal `sk_live_4eC39HqL...` into the client bundle. The build succeeds, deploys to the CDN, and the secret is now public — Stripe will detect this within 24 hours and rotate the key, but by then your bot scrapers have logged it. The pain doesn't show up until the abuse alert. You want CI to fail when the emitted JS/CSS contains anything matching known secret patterns.

This isn't a substitute for proper code review or `git-secrets` pre-commit hooks — it's the last line of defense, catching the case where everyone agreed `STRIPE_SECRET_KEY` shouldn't be exposed but `DefinePlugin` substituted it anyway because someone wrote `process.env.STRIPE_SECRET_KEY` in client code.

## Pattern

Tap `processAssets` at `PROCESS_ASSETS_STAGE_ANALYSE` (after all transformations are done, all hashes settled, just before reporting), scan each text asset's content against an extensible list of secret-shape regexes, and push a `WebpackError` per match with the asset name and a redacted preview.

**Incorrect (without a plugin — pre-commit `git-secrets` only):**

```bash
# .git/hooks/pre-commit
git secrets --scan
# Catches secrets in NEW commits. Misses:
#   - DefinePlugin substituting secrets at build time (no source-text trace)
#   - Secrets embedded in vendored bundles (e.g., committed third-party builds)
#   - Secrets injected by other plugins (logging, debug helpers)
# Pre-commit catches the developer mistake; build-time catches the FINAL bundle.
```

**Correct (with this plugin — scans the emitted bundle, last line of defense):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    patterns: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          name: { type: 'string', minLength: 1 },
          regex: { type: 'string', minLength: 1 },
          flags: { type: 'string' },
        },
        required: ['name', 'regex'],
        additionalProperties: false,
      },
    },
    extensions: {
      type: 'array',
      items: { type: 'string', pattern: '^\\.' },
      description: 'File extensions to scan (default: .js .mjs .css .html .json)',
    },
    allowlist: {
      type: 'array',
      items: { type: 'string' },
      description: 'Specific matches to allow (e.g. "pk_test_TYooMQauvdEDq54NiTphI7jx")',
    },
  },
  additionalProperties: false,
};

// Default patterns — drawn from gitleaks/truffleHog plus webpack-specific cases
const DEFAULT_PATTERNS = [
  { name: 'AWS access key',        regex: 'AKIA[0-9A-Z]{16}' },
  { name: 'AWS secret key',        regex: '(?<![A-Za-z0-9/+=])[A-Za-z0-9/+=]{40}(?![A-Za-z0-9/+=])' },
  { name: 'Stripe secret key',     regex: 'sk_live_[0-9a-zA-Z]{24,}' },
  { name: 'Stripe restricted key', regex: 'rk_live_[0-9a-zA-Z]{24,}' },
  { name: 'GitHub token',          regex: 'gh[pousr]_[0-9a-zA-Z]{36}' },
  { name: 'Generic API key',       regex: '(api[_-]?key|apikey)["\']?\\s*[:=]\\s*["\'][^"\']{20,}["\']', flags: 'i' },
  { name: 'Private key block',     regex: '-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----' },
  { name: 'JWT token',             regex: 'eyJ[A-Za-z0-9_-]{20,}\\.[A-Za-z0-9_-]{20,}\\.[A-Za-z0-9_-]{20,}' },
  { name: 'Slack webhook',         regex: 'https://hooks\\.slack\\.com/services/T[A-Z0-9]+/B[A-Z0-9]+/[a-zA-Z0-9]+' },
];

class NoSecretsBundledPlugin {
  constructor(options = {}) {
    validate(schema, options, { name: 'NoSecretsBundledPlugin', baseDataPath: 'options' });
    this.patterns = (options.patterns ?? DEFAULT_PATTERNS).map((p) => ({
      name: p.name,
      regex: new RegExp(p.regex, p.flags ?? 'g'),
    }));
    this.extensions = new Set(options.extensions ?? ['.js', '.mjs', '.css', '.html', '.json']);
    this.allowlist = new Set(options.allowlist ?? []);
  }

  apply(compiler) {
    const { Compilation, WebpackError } = compiler.webpack;

    compiler.hooks.thisCompilation.tap('NoSecretsBundledPlugin', (compilation) => {
      compilation.hooks.processAssets.tap(
        {
          name: 'NoSecretsBundledPlugin',
          // After all transformations and hashing — content is final
          stage: Compilation.PROCESS_ASSETS_STAGE_ANALYSE,
        },
        (assets) => {
          for (const name of Object.keys(assets)) {
            if (![...this.extensions].some((ext) => name.endsWith(ext))) continue;

            const content = compilation.getAsset(name).source.source().toString();

            for (const pattern of this.patterns) {
              pattern.regex.lastIndex = 0;  // reset between assets
              let match;
              while ((match = pattern.regex.exec(content)) !== null) {
                if (this.allowlist.has(match[0])) continue;

                const redacted = match[0].slice(0, 6) + '…' + match[0].slice(-4);
                const err = new WebpackError(
                  `NoSecretsBundledPlugin: ${pattern.name} detected in ${name}\n` +
                  `  Match: ${redacted}\n` +
                  `  Context: ${contextAround(content, match.index, 80)}\n` +
                  `\n  Either:\n` +
                  `    1. Remove the secret from source (do not commit secrets)\n` +
                  `    2. Add to allowlist if a false positive (NoSecretsBundledPlugin.allowlist)\n` +
                  `    3. Confirm this code path is server-only and excluded from client bundles`,
                );
                err.file = name;
                err.hideStack = true;
                compilation.errors.push(err);
              }
            }
          }
        },
      );
    });
  }
}

function contextAround(text, index, radius) {
  const start = Math.max(0, index - radius);
  const end = Math.min(text.length, index + radius);
  return text.slice(start, end).replace(/\s+/g, ' ');
}

module.exports = NoSecretsBundledPlugin;
```

## How it works

- **`PROCESS_ASSETS_STAGE_ANALYSE`** runs after every other transformation is done — checking earlier would miss secrets injected by another plugin's transform; checking later (in `emit`) is too late to fail
- **`source().toString()`** is fine here because we filter by extension to text-only assets first; binary assets would be wasted work and could throw on the toString (see [`webpack-plugin-authoring/asset-buffer-not-source-for-binary`])
- **Redacted preview** (`sk_liv…ENRX`) shows enough to locate the leak in the source without making the error log a secret-leak itself (CI logs are often public)
- **The allowlist mechanism is explicit**, not pattern-based — users opt in to specific known-public test keys (`pk_test_...`) rather than entire pattern families

## Variations

- **Build-blocking vs reporting**:
  ```js
  // Warn in dev (false positives are common), error in CI
  failOn: process.env.CI ? 'error' : 'warning',
  ```
- **Exclude sourcemaps from scan** (they include original source; will trigger on intentional server-only code if maps emitted): add `.map` to default-exclude
- **Per-pattern severity**: some patterns (AWS secret key) ALWAYS fail; others (generic api-key regex) warn first
- **Source-map decode** for production builds: when a secret is detected, decode source-map back to original file:line to point at where in source the leak originated

## When NOT to use this pattern

- You have a strong pre-commit hook (`gitleaks`, `trufflehog`) — catches at commit time, not build time, which is earlier and cheaper
- Your build environment has access to real secrets and you intentionally substitute them (server-side bundles for Node deployment); use `extensions: ['.js']` and exclude the server entrypoint
- You have many false positives — secret-shape regexes are inherently fuzzy, and a noisy guard gets ignored

Reference: [gitleaks](https://github.com/gitleaks/gitleaks) · [trufflehog patterns](https://github.com/trufflesecurity/trufflehog) · [DefinePlugin](https://webpack.js.org/plugins/define-plugin/)
