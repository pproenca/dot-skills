---
title: Never Mutate the User's Options Object
impact: HIGH
impactDescription: prevents corrupting config across compiler instances
tags: life, options, immutability, defensive-copy
---

## Never Mutate the User's Options Object

The `options` argument passed to the constructor often comes from the user's frozen `webpack.config.js` module exports. Mutating it (filling in defaults, normalizing paths, adding computed fields) corrupts the source-of-truth config object, and in MultiCompiler setups where the same options object is passed to multiple plugin instances, the second instance sees the first instance's mutations. The contract is one-directional: the user owns `options`; the plugin owns `this.options`, which is a derived copy.

**Incorrect (mutates the user's options — defaults leak into config inspect output):**

```js
class CompressPlugin {
  constructor(options = {}) {
    options.algorithm ??= 'gzip';            // mutates user's object
    options.threshold ??= 10240;             // again
    options.include = options.include ?? /\.(js|css|html)$/;
    options.exclude ??= /\.map$/;
    this.options = options;                  // alias of the mutated input
  }
}
// User's `webpack --inspect-config` now shows defaults they didn't write,
// and a second CompressPlugin sharing the same options object inherits them.
```

**Correct (validate then build an independent normalized object):**

```js
const { validate } = require('schema-utils');
const optionsSchema = require('./options-schema.json');

const DEFAULTS = {
  algorithm: 'gzip',
  threshold: 10240,
  include: /\.(js|css|html)$/,
  exclude: /\.map$/,
};

class CompressPlugin {
  constructor(options = {}) {
    validate(optionsSchema, options, { name: 'CompressPlugin', baseDataPath: 'options' });
    // Shallow-merge into a NEW object — user's options untouched
    this.options = { ...DEFAULTS, ...options };
  }
}
```

**For nested options, deep-clone the parts you'll mutate:**

```js
class CopyPlugin {
  constructor({ patterns } = { patterns: [] }) {
    this.options = {
      patterns: patterns.map((p) => ({
        ...p,
        // Normalize relative paths to absolute — must NOT mutate user's pattern object
        from: path.isAbsolute(p.from) ? p.from : path.resolve(p.from),
        // Don't share Maps/Sets between user's object and ours
        info: p.info ? { ...p.info } : undefined,
      })),
    };
  }
}
```

**What "mutation" hides:**

- `Object.assign(options, defaults)` — defaults go INTO user object
- `options.foo = options.foo || {}` — creates `foo` on user object
- `options.list.push(...)` — mutates user's array
- `options.regex = new RegExp(options.regex)` — replaces field on user object

**The `Object.freeze` test:** A useful defensive check during plugin development —

```js
constructor(options = {}) {
  if (process.env.NODE_ENV === 'test') Object.freeze(options);
  // Any mutation now throws in strict mode → caught in tests
  this.options = { ...DEFAULTS, ...options };
}
```

**Why webpack itself does this:** webpack normalizes user config into an `options` object via `WebpackOptionsApply` — but it creates a NEW normalized object rather than mutating the input. Plugin authors should follow the same contract.

Reference: [schema-utils — validation](https://github.com/webpack/schema-utils) · [webpack/webpack-contrib/copy-webpack-plugin (options normalization)](https://github.com/webpack-contrib/copy-webpack-plugin/blob/master/src/index.js)
