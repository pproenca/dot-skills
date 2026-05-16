---
title: Set name and baseDataPath on validate()
impact: MEDIUM-HIGH
impactDescription: prevents anonymous "an options object" errors that don't name the plugin
tags: schema, schema-utils, error-messages, baseDataPath
---

## Set name and baseDataPath on validate()

`schema-utils.validate()` produces useful errors only when you tell it WHO is validating and WHERE in the user's config the value lives. Without `name`, the error header reads "An options object that does not match the API schema" — useless when ten plugins are loaded. Without `baseDataPath`, errors reference `data.foo` instead of `options.foo` — users have to grep for the offending key. Both options are one line each.

**Incorrect (anonymous validation — user can't tell which plugin failed):**

```js
class MyPlugin {
  constructor(options = {}) {
    validate(schema, options); // no name, no baseDataPath
    this.options = options;
  }
}

// Error message:
//   ValidationError: Invalid options object. An options object has been
//   initialized using an options object that does not match the API schema.
//    - data.minimizers[0] should be one of these:
//      object { test, ... }
```

**Correct (named + path-rooted error messages):**

```js
class CssMinimizerPlugin {
  constructor(options = {}) {
    validate(schema, options, {
      name: 'Css Minimizer Plugin',
      baseDataPath: 'options',
    });
    this.options = options;
  }
}

// Error message:
//   ValidationError: Invalid options object. Css Minimizer Plugin has been
//   initialized using an options object that does not match the API schema.
//    - options.minimizers[0] should be one of these:
//      object { test, ... }
```

**Full validate() options reference:**

| Option | Purpose |
|---|---|
| `name` | Replaces "An options object" in the error header. Use the human-readable plugin name (with spaces) — e.g., `'Mini CSS Extract Plugin'`, not `'MiniCssExtractPlugin'` |
| `baseDataPath` | Replaces `data` as the root path in error messages. Use `'options'` for plugin options, `'loader'` for loader options |
| `postFormatter` | `(formattedError, error) => string` — append context-specific guidance to specific error types |

**postFormatter pattern for "did you mean…":**

```js
validate(schema, options, {
  name: 'Compression Plugin',
  baseDataPath: 'options',
  postFormatter: (formatted, err) => {
    if (err.keyword === 'additionalProperties') {
      const bad = err.params.additionalProperty;
      const valid = Object.keys(err.parentSchema.properties);
      const guess = closestMatch(bad, valid);
      if (guess) return `${formatted}\n   Did you mean '${guess}'?`;
    }
    return formatted;
  },
});
```

This is the pattern `css-loader` uses to surface `{ modlues: true }` → "did you mean 'modules'?"

**For loader options, use `loader` as baseDataPath:**

```js
// inside a loader
validate(schema, getOptions(this), {
  name: 'My Loader',
  baseDataPath: 'options', // loader options also show as `options.X`
});
```

Reference: [schema-utils README — Arguments](https://github.com/webpack/schema-utils#arguments)
