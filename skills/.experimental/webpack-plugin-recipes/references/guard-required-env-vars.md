---
title: Fail Builds When Required Environment Variables Are Missing
impact: CRITICAL
impactDescription: prevents deploying with unset secrets that crash on first request
tags: guard, env-vars, secrets, configuration
---

## Fail Builds When Required Environment Variables Are Missing

## Problem

Your production code does `process.env.STRIPE_SECRET_KEY` (or rather, `DefinePlugin` substitutes it at build time). When `STRIPE_SECRET_KEY` isn't set in the build environment, `DefinePlugin` substitutes `undefined` silently — no warning, no error. The build succeeds, the deploy goes through, and the first checkout attempt crashes with `Cannot read properties of undefined (reading 'charges')` 30 minutes into production traffic. You want the build to **fail** at the very start when a required env var isn't set, naming exactly which one — before any compilation work even runs.

You can do part of this with `dotenv` validation in `webpack.config.js`, but that runs in every developer's terminal and clutters the config with check logic. A plugin centralizes the rule and runs once at the right moment.

## Pattern

Tap `compiler.hooks.beforeRun` and `compiler.hooks.watchRun` (so the check runs before every build and rebuild), iterate the required env var list, and throw with a clear list when any are missing — `beforeRun` is one of the few places where throwing is correct (the build hasn't started).

**Incorrect (without a plugin — relying on DefinePlugin alone):**

```js
// webpack.config.js
new webpack.DefinePlugin({
  'process.env.STRIPE_SECRET_KEY': JSON.stringify(process.env.STRIPE_SECRET_KEY),
});
// When STRIPE_SECRET_KEY is unset: substitutes the literal `undefined`.
// Build succeeds. First checkout request in production fails with:
//   TypeError: Cannot read properties of undefined (reading 'charges')
```

**Correct (with this plugin — fails the build immediately, before compilation starts):**

```js
const { validate } = require('schema-utils');

const schema = {
  type: 'object',
  properties: {
    required: {
      type: 'array',
      items: { type: 'string', minLength: 1 },
      minItems: 1,
    },
    when: {
      type: 'object',
      additionalProperties: { type: 'string' },
      description: 'Map of env var → expected value; the `required` list applies only when these match',
    },
    expose: {
      type: 'array',
      items: { type: 'string' },
      description: 'Env vars to expose via DefinePlugin as process.env.X. Defaults to `required`.',
    },
  },
  required: ['required'],
  additionalProperties: false,
};

class RequiredEnvPlugin {
  constructor(options) {
    validate(schema, options, { name: 'RequiredEnvPlugin', baseDataPath: 'options' });
    this.options = options;
  }

  apply(compiler) {
    const { DefinePlugin } = compiler.webpack;

    const check = () => {
      // Conditional activation
      if (this.options.when) {
        for (const [k, expected] of Object.entries(this.options.when)) {
          if (process.env[k] !== expected) return; // condition not met, skip
        }
      }

      const missing = this.options.required.filter((name) => {
        const value = process.env[name];
        return value === undefined || value === '';
      });

      if (missing.length > 0) {
        const message =
          `RequiredEnvPlugin: missing required environment variables:\n` +
          missing.map((n) => `  - ${n}`).join('\n') +
          `\n\nSet them before building, e.g.:\n` +
          `  ${missing.map((n) => `${n}=...`).join(' ')} npm run build`;
        throw new Error(message);
      }
    };

    compiler.hooks.beforeRun.tap('RequiredEnvPlugin', check);
    compiler.hooks.watchRun.tap('RequiredEnvPlugin', check);

    // Expose the vars via DefinePlugin so source can use them
    const exposed = this.options.expose ?? this.options.required;
    const definitions = Object.fromEntries(
      exposed.map((name) => [
        `process.env.${name}`,
        JSON.stringify(process.env[name] ?? ''),
      ]),
    );
    new DefinePlugin(definitions).apply(compiler);
  }
}

module.exports = RequiredEnvPlugin;
```

## Usage

```js
new RequiredEnvPlugin({
  // These MUST be set, every build
  required: ['NEXT_PUBLIC_API_URL', 'SENTRY_DSN'],

  // These additionally MUST be set, but only in production
  ...(process.env.NODE_ENV === 'production' ? {
    required: ['STRIPE_SECRET_KEY', 'DATABASE_URL', 'SESSION_SECRET'],
  } : {}),
})
```

Or conditionally based on a flag:

```js
new RequiredEnvPlugin({
  required: ['STRIPE_SECRET_KEY', 'DATABASE_URL'],
  when: { NODE_ENV: 'production' },  // only enforce in prod
})
```

## How it works

- **`beforeRun` + `watchRun`** are the earliest places to throw — webpack hasn't done any compilation work yet, so error messages aren't buried under stats output. Throwing in a tap after `compile` is what [`webpack-plugin-authoring/diag-push-webpack-error-not-throw`] specifically warns against; throwing in `beforeRun` is the exception (the build hasn't started).
- **`process.env[name] === ''`** check catches CI systems that pass `KEY=""` for unset vars (common with GitHub Actions secrets that weren't configured)
- **`DefinePlugin(definitions)`** is composed in — the plugin both validates AND exposes, so users don't need to wire DefinePlugin separately
- **The error message tells the user exactly how to fix it** — a copy-pasteable command, not just "set this variable"

## Variations

- **Validate via regex** (e.g., `STRIPE_SECRET_KEY` must start with `sk_live_` in prod):
  ```js
  validators: {
    STRIPE_SECRET_KEY: (v) => /^sk_(live|test)_/.test(v) || 'must start with sk_live_ or sk_test_',
  }
  ```
- **Load from `.env.local` first** (use `dotenv` inside `beforeRun`)
- **Distinguish required vs recommended** (warn for recommended, error for required)
- **Exclude from client bundles automatically** (only expose vars prefixed with `PUBLIC_` via DefinePlugin)

## When NOT to use this pattern

- You're using a framework that already does this (Next.js validates `NEXT_PUBLIC_*` and the experimental `env` field; Vite validates `VITE_*`)
- Your env vars are loaded from a vault at runtime (the build doesn't know them — runtime validation is the right place)
- You have only 1–2 env vars and the cost of a plugin > the cost of a manual check at the top of `webpack.config.js`

Reference: [DefinePlugin](https://webpack.js.org/plugins/define-plugin/) · [Next.js — Required env vars](https://nextjs.org/docs/pages/api-reference/next-config-js/env) · [twelve-factor — Config](https://12factor.net/config)
