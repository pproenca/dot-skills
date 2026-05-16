---
title: Validate Options With schema-utils
impact: MEDIUM-HIGH
impactDescription: surfaces typos at config-load instead of mid-build
tags: schema, schema-utils, options, validation
---

## Validate Options With schema-utils

A typo in `{ filenmae: 'index.html' }` (note: `filenmae`) silently activates the default and produces wrong output 30 seconds into the build. `schema-utils.validate()` matches the user's options against a JSON Schema you ship with the plugin and throws a formatted error pointing at the exact key — at construction time, before webpack even starts. The same package powers every `webpack-contrib` plugin, so users already recognize the error format.

**Incorrect (manual checks miss most cases — typos silently pass):**

```js
class CopyPlugin {
  constructor(options) {
    if (!options) throw new Error('CopyPlugin: options required');
    if (!options.patterns) throw new Error('CopyPlugin: patterns required');
    // Doesn't catch: { paterns: [...] } (typo) — passes, plugin then does nothing
    // Doesn't catch: { patterns: 'foo' } (wrong type) — crashes later in for-of
    // Doesn't catch: { patterns: [{ form: 'src' }] } (typo in 'from') — silently broken
    this.options = options;
  }
}
```

**Correct (JSON Schema declares every valid shape):**

```js
const { validate } = require('schema-utils');
const schema = require('./options-schema.json');

class CopyPlugin {
  constructor(options = {}) {
    validate(schema, options, {
      name: 'CopyPlugin',
      baseDataPath: 'options',
    });
    this.options = { ...DEFAULTS, ...options };
  }
}
```

**`options-schema.json` template (this is the structure to ship):**

```json
{
  "definitions": {
    "Pattern": {
      "type": "object",
      "properties": {
        "from": { "type": "string", "minLength": 1 },
        "to": { "type": "string" },
        "context": { "type": "string" },
        "globOptions": { "type": "object" }
      },
      "required": ["from"],
      "additionalProperties": false
    }
  },
  "type": "object",
  "properties": {
    "patterns": {
      "type": "array",
      "items": { "$ref": "#/definitions/Pattern" },
      "minItems": 1
    }
  },
  "required": ["patterns"],
  "additionalProperties": false
}
```

**Key fields users get wrong without `additionalProperties: false`:**

- `"additionalProperties": false` on every object — turns typos into errors
- `"minLength": 1` on required strings — catches `from: ""` confusion
- `"required": [...]` on the schema root AND each nested object
- `enum: ["gzip", "brotliCompress", "deflateRaw"]` for algorithm-style options

**Error output example users see:**

```text
ValidationError: Invalid options object. Copy Plugin has been initialized using an
options object that does not match the API schema.
 - options.patterns[0] misses the property 'from'. Should be:
   string with at least one character
 - options.patterns[0] has an unknown property 'form'. These properties are valid:
   object { from?, to?, context?, globOptions? }
```

This is the format users of `mini-css-extract-plugin`, `terser-webpack-plugin`, `css-minimizer-webpack-plugin` already know — consistency reduces support burden.

Reference: [GitHub: webpack/schema-utils](https://github.com/webpack/schema-utils) · [JSON Schema spec](https://json-schema.org/)
