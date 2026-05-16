---
title: "Set additionalProperties: false on Every Object"
impact: MEDIUM-HIGH
impactDescription: catches ~90% of misconfigurations (typo-driven default activation)
tags: schema, additionalProperties, typos, strict
---

## Set additionalProperties: false on Every Object

JSON Schema by default IGNORES properties not listed in `properties`. `{ filenmae: 'foo.html' }` (typo) passes validation, the plugin reads `options.filename` (undefined), and the default kicks in. The user sees no error and produces wrong output. `additionalProperties: false` flips the contract: unknown keys are errors. This single attribute is responsible for catching ~90% of misconfigurations in `webpack-contrib` plugins.

**Incorrect (typos silently pass):**

```json
{
  "type": "object",
  "properties": {
    "filename": { "type": "string" },
    "template": { "type": "string" },
    "minify": { "type": "boolean" }
  }
}
```

```js
new HtmlPlugin({ filenmae: 'index.html', tempalte: './src/index.html' });
// Schema validates — both typos accepted as "additional properties"
// Plugin uses defaults; output is wrong; user has no warning
```

**Correct (additionalProperties false on every object):**

```json
{
  "type": "object",
  "properties": {
    "filename": { "type": "string" },
    "template": { "type": "string" },
    "minify": { "type": "boolean" }
  },
  "additionalProperties": false
}
```

```js
new HtmlPlugin({ filenmae: 'index.html' });
// ValidationError:
//   options has an unknown property 'filenmae'. These properties are valid:
//   object { filename?, template?, minify? }
```

**Apply to EVERY nested object, including in `$defs`/`definitions`:**

```json
{
  "definitions": {
    "Pattern": {
      "type": "object",
      "properties": {
        "from": { "type": "string" },
        "to": { "type": "string" },
        "context": { "type": "string" }
      },
      "required": ["from"],
      "additionalProperties": false   ← THIS
    }
  },
  "type": "object",
  "properties": {
    "patterns": {
      "type": "array",
      "items": { "$ref": "#/definitions/Pattern" }
    }
  },
  "required": ["patterns"],
  "additionalProperties": false       ← AND THIS
}
```

**The exception: forwarding options to a sub-tool.** When your plugin wraps another tool (e.g., `terser-webpack-plugin` wraps `terser`, `compression-webpack-plugin` wraps `zlib`), the `terserOptions` / `compressionOptions` field is intentionally pass-through. Allow it via:

```json
"terserOptions": {
  "type": "object",
  "additionalProperties": true,
  "description": "Forwarded to terser — see https://github.com/terser/terser#minify-options"
}
```

Document this in the description so users know typos in `terserOptions` won't be caught.

**The `oneOf` / `anyOf` gotcha:** When using `oneOf` with multiple object shapes, EACH shape needs its own `additionalProperties: false` — the parent schema's setting doesn't propagate into the alternatives.

Reference: [JSON Schema — additionalProperties](https://json-schema.org/understanding-json-schema/reference/object#additionalproperties)
