---
title: Convert schemas with native z.toJSONSchema(), not zod-to-json-schema
tags: compose, json-schema, metadata, dependencies
---

## Convert schemas with native z.toJSONSchema(), not zod-to-json-schema

The wrong default is reaching for the `zod-to-json-schema` package, the mandatory Zod 3 companion for OpenAPI and JSON Schema output. zod@4 ships conversion natively: `z.toJSONSchema(schema, { target, io, ... })` supports draft-2020-12 (default), draft-07, draft-04, and openapi-3.0 targets, and metadata registered via `.meta({ id, title, description, examples })` flows into the output. Since 4.3 the inverse `z.fromJSONSchema()` exists too. Keeping the external package on a zod@4 project means a second, drifting implementation of conversion semantics the library now owns.

**Evidence of violation:** `zod-to-json-schema` in `package.json` dependencies or imported in source, while `package.json` pins `zod` at major 4.

**Incorrect (external converter on zod@4):**

```ts
import { zodToJsonSchema } from "zod-to-json-schema"

const ProductJson = zodToJsonSchema(ProductSchema)
```

**Correct (native conversion, metadata included):**

```ts
const ProductSchema = z.object({
  sku: z.string().meta({ description: "Stock keeping unit" }),
  price: z.int().positive(),
}).meta({ id: "Product", title: "Product" })

const ProductJson = z.toJSONSchema(ProductSchema, { target: "openapi-3.0" })
```

Reference: [Zod — JSON Schema](https://zod.dev/json-schema), [Zod — metadata and registries](https://zod.dev/metadata)
