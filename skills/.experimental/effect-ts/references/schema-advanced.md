---
title: "Schema Advanced"
impact: CRITICAL
impactDescription: "Enables complex data transformations and output format generation — covers filters, annotations, JSON Schema"
tags: schema, transformations, filters, json-schema
---
# [Advanced Usage](https://effect.website/docs/schema/advanced-usage/)

## Overview


## Declaring New Data Types

### Primitive Data Types

To declare a schema for a primitive data type, such as `File`, you can use the `Schema.declare` function along with a type guard.

**Example** (Declaring a Schema for `File`)

```ts

// Declare a schema for the File type using a type guard
const FileFromSelf = Schema.declare(
  (input: unknown): input is File => input instanceof File
)

const decode = Schema.decodeUnknownSync(FileFromSelf)

// Decoding a valid File object
console.log(decode(new File([], "")))
/*
Output:
File { size: 0, type: '', name: '', lastModified: 1724774163056 }
*/

// Decoding an invalid input
decode(null)
/*
throws
ParseError: Expected <declaration schema>, actual null
*/
```

> **Tip: Adding Annotations**
  Annotations like `identifier` and `description` are useful for improving
  error messages and making schemas self-documenting.


To enhance the default error message, you can add annotations, particularly the `identifier`, `title`, and `description` annotations (none of these annotations are required, but they are encouraged for good practice and can make your schema "self-documenting"). These annotations will be utilized by the messaging system to return more meaningful messages.

- **Identifier**: a unique name for the schema
- **Title**: a brief, descriptive title
- **Description**: a detailed explanation of the schema's purpose

**Example** (Declaring a Schema with Annotations)

```ts

// Declare a schema for the File type with additional annotations
const FileFromSelf = Schema.declare(
  (input: unknown): input is File => input instanceof File,
  {
    // A unique identifier for the schema
    identifier: "FileFromSelf",
    // Detailed description of the schema
    description: "The `File` type in JavaScript"
  }
)

const decode = Schema.decodeUnknownSync(FileFromSelf)

// Decoding a valid File object
console.log(decode(new File([], "")))
/*
Output:
File { size: 0, type: '', name: '', lastModified: 1724774163056 }
*/

// Decoding an invalid input
decode(null)
/*
throws
ParseError: Expected FileFromSelf, actual null
*/
```

### Type Constructors

Type constructors are generic types that take one or more types as arguments and return a new type. To define a schema for a type constructor, you can use the `Schema.declare` function.

**Example** (Declaring a Schema for `ReadonlySet<A>`)

```ts

export const MyReadonlySet = <A, I, R>(
  // Schema for the elements of the Set
  item: Schema.Schema<A, I, R>
): Schema.Schema<ReadonlySet<A>, ReadonlySet<I>, R> =>
  Schema.declare(
    // Store the schema for the Set's elements
    [item],
    {
      // Decoding function
      decode: (item) => (input, parseOptions, ast) => {
        if (input instanceof Set) {
          // Decode each element in the Set
          const elements = ParseResult.decodeUnknown(Schema.Array(item))(
            Array.from(input.values()),
            parseOptions
          )
          // Return a ReadonlySet containing the decoded elements
          return ParseResult.map(
            elements,
            (as): ReadonlySet<A> => new Set(as)
          )
        }
        // Handle invalid input
        return ParseResult.fail(new ParseResult.Type(ast, input))
      },
      // Encoding function
      encode: (item) => (input, parseOptions, ast) => {
        if (input instanceof Set) {
          // Encode each element in the Set
          const elements = ParseResult.encodeUnknown(Schema.Array(item))(
            Array.from(input.values()),
            parseOptions
          )
          // Return a ReadonlySet containing the encoded elements
          return ParseResult.map(
            elements,
            (is): ReadonlySet<I> => new Set(is)
          )
        }
        // Handle invalid input
        return ParseResult.fail(new ParseResult.Type(ast, input))
      }
    },
    {
      description: `ReadonlySet<${Schema.format(item)}>`
    }
  )

// Define a schema for a ReadonlySet of numbers
const setOfNumbers = MyReadonlySet(Schema.NumberFromString)

const decode = Schema.decodeUnknownSync(setOfNumbers)

console.log(decode(new Set(["1", "2", "3"]))) // Set(3) { 1, 2, 3 }

// Decode an invalid input
decode(null)
/*
throws
ParseError: Expected ReadonlySet<NumberFromString>, actual null
*/

// Decode a Set with an invalid element
decode(new Set(["1", null, "3"]))
/*
throws
ParseError: ReadonlyArray<NumberFromString>
└─ [1]
   └─ NumberFromString
      └─ Encoded side transformation failure
         └─ Expected string, actual null
*/
```

> **Caution: Decoding/Encoding Limitations**
  The decoding and encoding functions cannot rely on context (the
  `Requirements` type parameter) and cannot handle asynchronous effects.
  This means that only synchronous operations are supported within these
  functions.


### Adding Compilers Annotations

When defining a new data type, some compilers like [Arbitrary](/docs/schema/arbitrary/) or [Pretty](/docs/schema/pretty/) may not know how to handle the new type.
This can result in an error, as the compiler may lack the necessary information for generating instances or producing readable output:

**Example** (Attempting to Generate Arbitrary Values Without Required Annotations)

```ts

// Define a schema for the File type
const FileFromSelf = Schema.declare(
  (input: unknown): input is File => input instanceof File,
  {
    identifier: "FileFromSelf"
  }
)

// Try creating an Arbitrary instance for the schema
const arb = Arbitrary.make(FileFromSelf)
/*
throws:
Error: Missing annotation
details: Generating an Arbitrary for this schema requires an "arbitrary" annotation
schema (Declaration): FileFromSelf
*/
```

In the above example, attempting to generate arbitrary values for the `FileFromSelf` schema fails because the compiler lacks necessary annotations. To resolve this, you need to provide annotations for generating arbitrary data:

**Example** (Adding Arbitrary Annotation for Custom `File` Schema)

```ts

const FileFromSelf = Schema.declare(
  (input: unknown): input is File => input instanceof File,
  {
    identifier: "FileFromSelf",
    // Provide a function to generate random File instances
    arbitrary: () => (fc) =>
      fc
        .tuple(fc.string(), fc.string())
        .map(([content, path]) => new File([content], path))
  }
)

// Create an Arbitrary instance for the schema
const arb = Arbitrary.make(FileFromSelf)

// Generate sample files using the Arbitrary instance
const files = FastCheck.sample(arb, 2)
console.log(files)
/*
Example Output:
[
  File { size: 5, type: '', name: 'C', lastModified: 1706435571176 },
  File { size: 1, type: '', name: '98Ggmc', lastModified: 1706435571176 }
]
*/
```

For more details on how to add annotations for the Arbitrary compiler, refer to the [Arbitrary](/docs/schema/arbitrary/) documentation.

## Branded types

TypeScript's type system is structural, which means that any two types that are structurally equivalent are considered the same.
This can cause issues when types that are semantically different are treated as if they were the same.

**Example** (Structural Typing Issue)

```ts
type UserId = string
type Username = string

declare const getUser: (id: UserId) => object

const myUsername: Username = "gcanti"

getUser(myUsername) // This erroneously works
```

In the above example, `UserId` and `Username` are both aliases for the same type, `string`. This means that the `getUser` function can mistakenly accept a `Username` as a valid `UserId`, causing bugs and errors.

To prevent this, Effect introduces **branded types**. These types attach a unique identifier (or "brand") to a type, allowing you to differentiate between structurally similar but semantically distinct types.

**Example** (Defining Branded Types)

```ts

type UserId = string & Brand.Brand<"UserId">
type Username = string

declare const getUser: (id: UserId) => object

const myUsername: Username = "gcanti"

// @errors: 2345
getUser(myUsername)
```

By defining `UserId` as a branded type, the `getUser` function can accept only values of type `UserId`, and not plain strings or other types that are compatible with strings. This helps to prevent bugs caused by accidentally passing the wrong type of value to the function.

There are two ways to define a schema for a branded type, depending on whether you:

- want to define the schema from scratch
- have already defined a branded type via [`effect/Brand`](/docs/code-style/branded-types/) and want to reuse it to define a schema

### Defining a brand schema from scratch

To define a schema for a branded type from scratch, use the `Schema.brand` function.

**Example** (Creating a schema for a Branded Type)

```ts

const UserId = Schema.String.pipe(Schema.brand("UserId"))

// string & Brand<"UserId">
type UserId = typeof UserId.Type
```

Note that you can use `unique symbol`s as brands to ensure uniqueness across modules / packages.

**Example** (Using a unique symbol as a Brand)

```ts

const UserIdBrand: unique symbol = Symbol.for("UserId")

const UserId = Schema.String.pipe(Schema.brand(UserIdBrand))

// string & Brand<typeof UserIdBrand>
type UserId = typeof UserId.Type
```

### Reusing an existing branded constructor

If you have already defined a branded type using the [`effect/Brand`](/docs/code-style/branded-types/) module, you can reuse it to define a schema using the `Schema.fromBrand` function.

**Example** (Reusing an Existing Branded Type)

```ts

// the existing branded type
type UserId = string & Brand.Brand<"UserId">

const UserId = Brand.nominal<UserId>()

// Define a schema for the branded type
const UserIdSchema = Schema.String.pipe(Schema.fromBrand(UserId))
```

### Utilizing Default Constructors

The `Schema.brand` function includes a default constructor to facilitate the creation of branded values.

```ts

const UserId = Schema.String.pipe(Schema.brand("UserId"))

const userId = UserId.make("123") // Creates a branded UserId
```

## Property Signatures

A `PropertySignature` represents a transformation from a "From" field to a "To" field. This allows you to define mappings between incoming data fields and your internal model.

### Basic Usage

A property signature can be defined with annotations to provide additional context about a field.

**Example** (Adding Annotations to a Property Signature)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.propertySignature(Schema.NumberFromString).annotations({
    title: "Age" // Annotation to label the age field
  })
})
```

A `PropertySignature` type contains several parameters, each providing details about the transformation between the source field (From) and the target field (To). Let's take a look at what each of these parameters represents:

```ts
age: PropertySignature<
  ToToken,
  ToType,
  FromKey,
  FromToken,
  FromType,
  HasDefault,
  Context
>
```

| Parameter    | Description                                                                                                         |
| ------------ | ------------------------------------------------------------------------------------------------------------------- |
| `age`        | Key of the "To" field                                                                                               |
| `ToToken`    | Indicates field requirement: `"?:"` for optional, `":"` for required                                                |
| `ToType`     | Type of the "To" field                                                                                              |
| `FromKey`    | (Optional, default = `never`) Indicates the source field key, typically the same as "To" field key unless specified |
| `FromToken`  | Indicates source field requirement: `"?:"` for optional, `":"` for required                                         |
| `FromType`   | Type of the "From" field                                                                                            |
| `HasDefault` | Indicates if there is a constructor default value (Boolean)                                                         |

In the example above, the `PropertySignature` type for `age` is:

```ts
PropertySignature<":", number, never, ":", string, false, never>
```

This means:

| Parameter    | Description                                                                |
| ------------ | -------------------------------------------------------------------------- |
| `age`        | Key of the "To" field                                                      |
| `ToToken`    | `":"` indicates that the `age` field is required                           |
| `ToType`     | Type of the `age` field is `number`                                        |
| `FromKey`    | `never` indicates that the decoding occurs from the same field named `age` |
| `FromToken`  | `":"` indicates that the decoding occurs from a required `age` field       |
| `FromType`   | Type of the "From" field is `string`                                       |
| `HasDefault` | `false`: indicates there is no default value                               |

Sometimes, the source field (the "From" field) may have a different name from the field in your internal model. You can map between these fields using the `Schema.fromKey` function.

**Example** (Mapping from a Different Key)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.propertySignature(Schema.NumberFromString).pipe(
    Schema.fromKey("AGE") // Maps from "AGE" to "age"
  )
})

console.log(Schema.decodeUnknownSync(Person)({ name: "name", AGE: "18" }))
// Output: { name: 'name', age: 18 }
```

When you map from `"AGE"` to `"age"`, the `PropertySignature` type changes to:

```tsAGE"" del={1} ins={2}
PropertySignature<":", number, never, ":", string, false, never>
PropertySignature<":", number, "AGE", ":", string, false, never>
```

### Optional Fields

#### Basic Optional Property

The syntax:

```ts
Schema.optional(schema: Schema<A, I, R>)
```

creates an optional property within a schema, allowing fields to be omitted or set to `undefined`.

##### Decoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `undefined`       | remains `undefined`       |
| `i: I`            | transforms to `a: A`      |

##### Encoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `undefined`       | remains `undefined`       |
| `a: A`            | transforms back to `i: I` |

**Example** (Defining an Optional Number Field)

```ts

const Product = Schema.Struct({
  quantity: Schema.optional(Schema.NumberFromString)
})

//     ┌─── { readonly quantity?: string | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: number | undefined; }
//     ▼
type Type = typeof Product.Type

// Decoding examples

console.log(Schema.decodeUnknownSync(Product)({ quantity: "1" }))
// Output: { quantity: 1 }
console.log(Schema.decodeUnknownSync(Product)({}))
// Output: {}
console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: undefined }

// Encoding examples

console.log(Schema.encodeSync(Product)({ quantity: 1 }))
// Output: { quantity: "1" }
console.log(Schema.encodeSync(Product)({}))
// Output: {}
console.log(Schema.encodeSync(Product)({ quantity: undefined }))
// Output: { quantity: undefined }
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optional(Schema.NumberFromString)
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Optional with Nullability

The syntax:

```ts
Schema.optionalWith(schema: Schema<A, I, R>, { nullable: true })
```

creates an optional property within a schema, treating `null` values the same as missing values.

##### Decoding

| Input             | Output                          |
| ----------------- | ------------------------------- |
| `<missing value>` | remains `<missing value>`       |
| `undefined`       | remains `undefined`             |
| `null`            | transforms to `<missing value>` |
| `i: I`            | transforms to `a: A`            |

##### Encoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `undefined`       | remains `undefined`       |
| `a: A`            | transforms back to `i: I` |

**Example** (Handling Null as Missing Value)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    nullable: true
  })
})

//     ┌─── { readonly quantity?: string | null | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: number | undefined; }
//     ▼
type Type = typeof Product.Type

// Decoding examples

console.log(Schema.decodeUnknownSync(Product)({ quantity: "1" }))
// Output: { quantity: 1 }
console.log(Schema.decodeUnknownSync(Product)({}))
// Output: {}
console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: undefined }
console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: {}

// Encoding examples

console.log(Schema.encodeSync(Product)({ quantity: 1 }))
// Output: { quantity: "1" }
console.log(Schema.encodeSync(Product)({}))
// Output: {}
console.log(Schema.encodeSync(Product)({ quantity: undefined }))
// Output: { quantity: undefined }
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    nullable: true
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Optional with Exactness

The syntax:

```ts
Schema.optionalWith(schema: Schema<A, I, R>, { exact: true })
```

creates an optional property while enforcing strict typing. This means that only the specified type (excluding `undefined`) is accepted. Any attempt to decode `undefined` results in an error.

##### Decoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `undefined`       | `ParseError`              |
| `i: I`            | transforms to `a: A`      |

##### Encoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `a: A`            | transforms back to `i: I` |

**Example** (Using Exactness with Optional Field)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, { exact: true })
})

//     ┌─── { readonly quantity?: string; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: number; }
//     ▼
type Type = typeof Product.Type

// Decoding examples

console.log(Schema.decodeUnknownSync(Product)({ quantity: "1" }))
// Output: { quantity: 1 }
console.log(Schema.decodeUnknownSync(Product)({}))
// Output: {}
console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: { readonly quantity?: NumberFromString }
└─ ["quantity"]
   └─ NumberFromString
      └─ Encoded side transformation failure
         └─ Expected string, actual undefined
*/

// Encoding examples

console.log(Schema.encodeSync(Product)({ quantity: 1 }))
// Output: { quantity: "1" }
console.log(Schema.encodeSync(Product)({}))
// Output: {}
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, { exact: true })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Combining Nullability and Exactness

The syntax:

```ts
Schema.optionalWith(schema: Schema<A, I, R>, { exact: true, nullable: true })
```

allows you to define an optional property that enforces strict typing (exact type only) while also treating `null` as equivalent to a missing value.

##### Decoding

| Input             | Output                          |
| ----------------- | ------------------------------- |
| `<missing value>` | remains `<missing value>`       |
| `null`            | transforms to `<missing value>` |
| `undefined`       | `ParseError`                    |
| `i: I`            | transforms to `a: A`            |

##### Encoding

| Input             | Output                    |
| ----------------- | ------------------------- |
| `<missing value>` | remains `<missing value>` |
| `a: A`            | transforms back to `i: I` |

**Example** (Using Exactness and Handling Null as Missing Value with Optional Field)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    exact: true,
    nullable: true
  })
})

//     ┌─── { readonly quantity?: string | null; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: number; }
//     ▼
type Type = typeof Product.Type

// Decoding examples

console.log(Schema.decodeUnknownSync(Product)({ quantity: "1" }))
// Output: { quantity: 1 }
console.log(Schema.decodeUnknownSync(Product)({}))
// Output: {}
console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: (Struct (Encoded side) <-> Struct (Type side))
└─ Encoded side transformation failure
   └─ Struct (Encoded side)
      └─ ["quantity"]
         └─ NumberFromString | null
            ├─ NumberFromString
            │  └─ Encoded side transformation failure
            │     └─ Expected string, actual undefined
            └─ Expected null, actual undefined
*/
console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: {}

// Encoding examples

console.log(Schema.encodeSync(Product)({ quantity: 1 }))
// Output: { quantity: "1" }
console.log(Schema.encodeSync(Product)({}))
// Output: {}
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    exact: true,
    nullable: true
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

### Representing Optional Fields with never Type

When creating a schema to replicate a TypeScript type that includes optional fields with the `never` type, like:

```ts
type MyType = {
  readonly quantity?: never
}
```

the handling of these fields depends on the `exactOptionalPropertyTypes` setting in your `tsconfig.json`.
This setting affects whether the schema should treat optional `never`-typed fields as simply absent or allow `undefined` as a value.

**Example** (`exactOptionalPropertyTypes: false`)

When this feature is turned off, you can employ the `Schema.optional` function. This approach allows the field to implicitly accept `undefined` as a value.

```ts

const Product = Schema.Struct({
  quantity: Schema.optional(Schema.Never)
})

//     ┌─── { readonly quantity?: undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: undefined; }
//     ▼
type Type = typeof Product.Type
```

**Example** (`exactOptionalPropertyTypes: true`)

When this feature is turned on, the `Schema.optionalWith` function is recommended.
It ensures stricter enforcement of the field's absence.

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.Never, { exact: true })
})

//     ┌─── { readonly quantity?: never; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity?: never; }
//     ▼
type Type = typeof Product.Type
```

### Default Values

The `default` option in `Schema.optionalWith` allows you to set default values that are applied during both decoding and object construction phases.
This feature ensures that even if certain properties are not provided by the user, the system will automatically use the specified default values.

The `Schema.optionalWith` function offers several ways to control how defaults are applied during decoding and encoding. You can fine-tune whether defaults are applied only when the input is completely missing, or even when `null` or `undefined` values are provided.

#### Basic Default

This is the simplest use case. If the input is missing or `undefined`, the default value will be applied.

**Syntax**

```ts
Schema.optionalWith(schema: Schema<A, I, R>, { default: () => A })
```

| Operation    | Behavior                                                         |
| ------------ | ---------------------------------------------------------------- |
| **Decoding** | Applies the default value if the input is missing or `undefined` |
| **Encoding** | Transforms the input `a: A` back to `i: I`                       |

**Example** (Applying Default When Field Is Missing or `undefined`)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    default: () => 1 // Default value for quantity
  })
})

//     ┌─── { readonly quantity?: string | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: number; }
//     ▼
type Type = typeof Product.Type

// Decoding examples with default applied

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: 2 }

// Object construction examples with default applied

console.log(Product.make({}))
// Output: { quantity: 1 }

console.log(Product.make({ quantity: 2 }))
// Output: { quantity: 2 }
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    default: () => 1 // Default value for quantity
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Default with Exactness

When you want the default value to be applied only if the field is completely missing (not when it's `undefined`), you can use the `exact` option.

**Syntax**

```ts
Schema.optionalWith(schema: Schema<A, I, R>, {
  default: () => A,
  exact: true
})
```

| Operation    | Behavior                                               |
| ------------ | ------------------------------------------------------ |
| **Decoding** | Applies the default value only if the input is missing |
| **Encoding** | Transforms the input `a: A` back to `i: I`             |

**Example** (Applying Default Only When Field Is Missing)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    default: () => 1, // Default value for quantity
    exact: true // Only apply default if quantity is not provided
  })
})

//     ┌─── { readonly quantity?: string; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: number; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: 2 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: (Struct (Encoded side) <-> Struct (Type side))
└─ Encoded side transformation failure
   └─ Struct (Encoded side)
      └─ ["quantity"]
         └─ NumberFromString
            └─ Encoded side transformation failure
               └─ Expected string, actual undefined
*/
```

#### Default with Nullability

In cases where you want `null` values to trigger the default behavior, you can use the `nullable` option. This ensures that if a field is set to `null`, it will be replaced by the default value.

**Syntax**

```ts
Schema.optionalWith(schema: Schema<A, I, R>, {
  default: () => A,
  nullable: true
})
```

| Operation    | Behavior                                                                   |
| ------------ | -------------------------------------------------------------------------- |
| **Decoding** | Applies the default value if the input is missing or `undefined` or `null` |
| **Encoding** | Transforms the input `a: A` back to `i: I`                                 |

**Example** (Applying Default When Field Is Missing or `undefined` or `null`)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    default: () => 1, // Default value for quantity
    nullable: true // Apply default if quantity is null
  })
})

//     ┌─── { readonly quantity?: string | null | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: number; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: 2 }
```

#### Combining Exactness and Nullability

For a more strict approach, you can combine both `exact` and `nullable` options. This way, the default value is applied only when the field is `null` or missing, and not when it's explicitly set to `undefined`.

**Syntax**

```ts
Schema.optionalWith(schema: Schema<A, I, R>, {
  default: () => A,
  exact: true,
  nullable: true
})
```

| Operation    | Behavior                                                    |
| ------------ | ----------------------------------------------------------- |
| **Decoding** | Applies the default value if the input is missing or `null` |
| **Encoding** | Transforms the input `a: A` back to `i: I`                  |

**Example** (Applying Default Only When Field Is Missing or `null`)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    default: () => 1, // Default value for quantity
    exact: true, // Only apply default if quantity is not provided
    nullable: true // Apply default if quantity is null
  })
})

//     ┌─── { readonly quantity?: string | null; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: number; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: { quantity: 1 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: 2 }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: (Struct (Encoded side) <-> Struct (Type side))
└─ Encoded side transformation failure
   └─ Struct (Encoded side)
      └─ ["quantity"]
         └─ NumberFromString
            └─ Encoded side transformation failure
               └─ Expected string, actual undefined
*/
```

### Optional Fields as Options

When working with optional fields, you may want to handle them as [Option](/docs/data-types/option/) types. This approach allows you to explicitly manage the presence or absence of a field rather than relying on `undefined` or `null`.

#### Basic Optional with Option Type

You can configure a schema to treat optional fields as `Option` types, where missing or `undefined` values are converted to `Option.none()` and existing values are wrapped in `Option.some()`.

**Syntax**

```ts
optionalWith(schema: Schema<A, I, R>, { as: "Option" })
```

##### Decoding

| Input             | Output                            |
| ----------------- | --------------------------------- |
| `<missing value>` | transforms to `Option.none()`     |
| `undefined`       | transforms to `Option.none()`     |
| `i: I`            | transforms to `Option.some(a: A)` |

##### Encoding

| Input               | Output                          |
| ------------------- | ------------------------------- |
| `Option.none()`     | transforms to `<missing value>` |
| `Option.some(a: A)` | transforms back to `i: I`       |

**Example** (Handling Optional Field as Option)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, { as: "Option" })
})

//     ┌─── { readonly quantity?: string | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: Option<number>; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: { _id: 'Option', _tag: 'Some', value: 2 } }
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, { as: "Option" })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Optional with Exactness

The `exact` option ensures that the default behavior of the optional field applies only when the field is entirely missing, not when it is `undefined`.

**Syntax**

```ts
optionalWith(schema: Schema<A, I, R>, {
  as: "Option",
  exact: true
})
```

##### Decoding

| Input             | Output                            |
| ----------------- | --------------------------------- |
| `<missing value>` | transforms to `Option.none()`     |
| `undefined`       | `ParseError`                      |
| `i: I`            | transforms to `Option.some(a: A)` |

##### Encoding

| Input               | Output                          |
| ------------------- | ------------------------------- |
| `Option.none()`     | transforms to `<missing value>` |
| `Option.some(a: A)` | transforms back to `i: I`       |

**Example** (Using Exactness with Optional Field as Option)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    exact: true
  })
})

//     ┌─── { readonly quantity?: string; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: Option<number>; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: { _id: 'Option', _tag: 'Some', value: 2 } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: (Struct (Encoded side) <-> Struct (Type side))
└─ Encoded side transformation failure
   └─ Struct (Encoded side)
      └─ ["quantity"]
         └─ NumberFromString
            └─ Encoded side transformation failure
               └─ Expected string, actual undefined
*/
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    exact: true
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Optional with Nullability

The `nullable` option extends the default behavior to treat `null` as equivalent to `Option.none()`, alongside missing or `undefined` values.

**Syntax**

```ts
optionalWith(schema: Schema<A, I, R>, {
  as: "Option",
  nullable: true
})
```

##### Decoding

| Input             | Output                            |
| ----------------- | --------------------------------- |
| `<missing value>` | transforms to `Option.none()`     |
| `undefined`       | transforms to `Option.none()`     |
| `null`            | transforms to `Option.none()`     |
| `i: I`            | transforms to `Option.some(a: A)` |

##### Encoding

| Input               | Output                          |
| ------------------- | ------------------------------- |
| `Option.none()`     | transforms to `<missing value>` |
| `Option.some(a: A)` | transforms back to `i: I`       |

**Example** (Handling Null as Missing Value with Optional Field as Option)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    nullable: true
  })
})

//     ┌─── { readonly quantity?: string | null | undefined; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: Option<number>; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: { _id: 'Option', _tag: 'Some', value: 2 } }
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    nullable: true
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

#### Combining Exactness and Nullability

When both `exact` and `nullable` options are used together, only `null` and missing fields are treated as `Option.none()`, while `undefined` is considered an invalid value.

**Syntax**

```ts
optionalWith(schema: Schema<A, I, R>, {
  as: "Option",
  exact: true,
  nullable: true
})
```

##### Decoding

| Input             | Output                            |
| ----------------- | --------------------------------- |
| `<missing value>` | transforms to `Option.none()`     |
| `undefined`       | `ParseError`                      |
| `null`            | transforms to `Option.none()`     |
| `i: I`            | transforms to `Option.some(a: A)` |

##### Encoding

| Input               | Output                          |
| ------------------- | ------------------------------- |
| `Option.none()`     | transforms to `<missing value>` |
| `Option.some(a: A)` | transforms back to `i: I`       |

**Example** (Using Exactness and Handling Null as Missing Value with Optional Field as Option)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    exact: true,
    nullable: true
  })
})

//     ┌─── { readonly quantity?: string | null; }
//     ▼
type Encoded = typeof Product.Encoded

//     ┌─── { readonly quantity: Option<number>; }
//     ▼
type Type = typeof Product.Type

console.log(Schema.decodeUnknownSync(Product)({}))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: null }))
// Output: { quantity: { _id: 'Option', _tag: 'None' } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: "2" }))
// Output: { quantity: { _id: 'Option', _tag: 'Some', value: 2 } }

console.log(Schema.decodeUnknownSync(Product)({ quantity: undefined }))
/*
throws:
ParseError: (Struct (Encoded side) <-> Struct (Type side))
└─ Encoded side transformation failure
   └─ Struct (Encoded side)
      └─ ["quantity"]
         └─ NumberFromString
            └─ Encoded side transformation failure
               └─ Expected string, actual undefined
*/
```

##### Exposed Values

You can access the original schema type (before it was marked as optional) using the `from` property.

**Example** (Accessing the Original Schema)

```ts

const Product = Schema.Struct({
  quantity: Schema.optionalWith(Schema.NumberFromString, {
    as: "Option",
    exact: true,
    nullable: true
  })
})

//      ┌─── typeof Schema.NumberFromString
//      ▼
const from = Product.fields.quantity.from
```

## Optional Fields Primitives

### optionalToOptional

The `Schema.optionalToOptional` API allows you to manage transformations from an optional field in the input to an optional field in the output. This can be useful for controlling both the output type and whether a field is present or absent based on specific criteria.

One common use case for `optionalToOptional` is handling fields where a specific input value, such as an empty string, should be treated as an absent field in the output.

**Syntax**

```ts
const optionalToOptional = <FA, FI, FR, TA, TI, TR>(
  from: Schema<FA, FI, FR>,
  to: Schema<TA, TI, TR>,
  options: {
    readonly decode: (o: Option.Option<FA>) => Option.Option<TI>,
    readonly encode: (o: Option.Option<TI>) => Option.Option<FA>
  }
): PropertySignature<"?:", TA, never, "?:", FI, false, FR | TR>
```

In this function:

- The `from` parameter specifies the input schema, and `to` specifies the output schema.
- The `decode` and `encode` functions define how the field should be interpreted on both sides:
  - `Option.none()` as an input argument indicates a missing field in the input.
  - Returning `Option.none()` from either function will omit the field in the output.

**Example** (Omitting Empty Strings from the Output)

Consider an optional field of type `string` where empty strings in the input should be removed from the output.

```ts

const schema = Schema.Struct({
  nonEmpty: Schema.optionalToOptional(Schema.String, Schema.String, {
    //         ┌─── Option<string>
    //         ▼
    decode: (maybeString) => {
      if (Option.isNone(maybeString)) {
        // If `maybeString` is `None`, the field is absent in the input.
        // Return Option.none() to omit it in the output.
        return Option.none()
      }
      // Extract the value from the `Some` instance
      const value = maybeString.value
      if (value === "") {
        // Treat empty strings as missing in the output
        // by returning Option.none().
        return Option.none()
      }
      // Include non-empty strings in the output.
      return Option.some(value)
    },
    // In the encoding phase, you can decide to process the field
    // similarly to the decoding phase or use a different logic.
    // Here, the logic is left unchanged.
    //
    //         ┌─── Option<string>
    //         ▼
    encode: (maybeString) => maybeString
  })
})

// Decoding examples

const decode = Schema.decodeUnknownSync(schema)

console.log(decode({}))
// Output: {}
console.log(decode({ nonEmpty: "" }))
// Output: {}
console.log(decode({ nonEmpty: "a non-empty string" }))
// Output: { nonEmpty: 'a non-empty string' }

// Encoding examples

const encode = Schema.encodeSync(schema)

console.log(encode({}))
// Output: {}
console.log(encode({ nonEmpty: "" }))
// Output: { nonEmpty: '' }
console.log(encode({ nonEmpty: "a non-empty string" }))
// Output: { nonEmpty: 'a non-empty string' }
```

You can simplify the decoding logic with `Option.filter`, which filters out unwanted values in a concise way.

**Example** (Using `Option.filter` for Decoding)

```ts

const schema = Schema.Struct({
  nonEmpty: Schema.optionalToOptional(Schema.String, Schema.String, {
    decode: Option.filter((s) => s !== ""),
    encode: identity
  })
})
```

### optionalToRequired

The `Schema.optionalToRequired` API lets you transform an optional field into a required one, with custom logic to handle cases when the field is missing in the input.

**Syntax**

```ts
const optionalToRequired = <FA, FI, FR, TA, TI, TR>(
  from: Schema<FA, FI, FR>,
  to: Schema<TA, TI, TR>,
  options: {
    readonly decode: (o: Option.Option<FA>) => TI,
    readonly encode: (ti: TI) => Option.Option<FA>
  }
): PropertySignature<":", TA, never, "?:", FI, false, FR | TR>
```

In this function:

- `from` specifies the input schema, while `to` specifies the output schema.
- The `decode` and `encode` functions define the transformation behavior:
  - Passing `Option.none()` to `decode` means the field is absent in the input. The function can then return a default value for the output.
  - Returning `Option.none()` in `encode` will omit the field in the output.

**Example** (Setting `null` as Default for Missing Field)

This example demonstrates how to use `optionalToRequired` to provide a `null` default value when the `nullable` field is missing in the input. During encoding, fields with a value of `null` are omitted from the output.

```ts

const schema = Schema.Struct({
  nullable: Schema.optionalToRequired(
    // Input schema for an optional string
    Schema.String,
    // Output schema allowing null or string
    Schema.NullOr(Schema.String),
    {
      //         ┌─── Option<string>
      //         ▼
      decode: (maybeString) => {
        if (Option.isNone(maybeString)) {
          // If `maybeString` is `None`, the field is absent in the input.
          // Return `null` as the default value for the output.
          return null
        }
        // Extract the value from the `Some` instance
        // and use it as the output.
        return maybeString.value
      },
      // During encoding, treat `null` as an absent field
      //
      //         ┌─── string | null
      //         ▼
      encode: (stringOrNull) =>
        stringOrNull === null
          ? // Omit the field by returning `None`
            Option.none()
          : // Include the field by returning `Some`
            Option.some(stringOrNull)
    }
  )
})

// Decoding examples

const decode = Schema.decodeUnknownSync(schema)

console.log(decode({}))
// Output: { nullable: null }
console.log(decode({ nullable: "a value" }))
// Output: { nullable: 'a value' }

// Encoding examples

const encode = Schema.encodeSync(schema)

console.log(encode({ nullable: "a value" }))
// Output: { nullable: 'a value' }
console.log(encode({ nullable: null }))
// Output: {}
```

You can streamline the decoding and encoding logic using `Option.getOrElse` and `Option.liftPredicate` for concise and readable transformations.

**Example** (Using `Option.getOrElse` and `Option.liftPredicate`)

```ts

const schema = Schema.Struct({
  nullable: Schema.optionalToRequired(
    Schema.String,
    Schema.NullOr(Schema.String),
    {
      decode: Option.getOrElse(() => null),
      encode: Option.liftPredicate((value) => value !== null)
    }
  )
})
```

### requiredToOptional

The `requiredToOptional` API allows you to transform a required field into an optional one, applying custom logic to determine when the field can be omitted.

**Syntax**

```ts
const requiredToOptional = <FA, FI, FR, TA, TI, TR>(
  from: Schema<FA, FI, FR>,
  to: Schema<TA, TI, TR>,
  options: {
    readonly decode: (fa: FA) => Option.Option<TI>
    readonly encode: (o: Option.Option<TI>) => FA
  }
): PropertySignature<"?:", TA, never, ":", FI, false, FR | TR>
```

With `decode` and `encode` functions, you control the presence or absence of the field:

- `Option.none()` as an argument in `decode` means the field is missing in the input.
- `Option.none()` as a return value from `encode` means the field will be omitted in the output.

**Example** (Handling Empty String as Missing Value)

In this example, the `name` field is required but treated as optional if it is an empty string. During decoding, an empty string in `name` is considered absent, while encoding ensures a value (using an empty string as a default if `name` is absent).

```ts

const schema = Schema.Struct({
  name: Schema.requiredToOptional(Schema.String, Schema.String, {
    //         ┌─── string
    //         ▼
    decode: (string) => {
      // Treat empty string as a missing value
      if (string === "") {
        // Omit the field by returning `None`
        return Option.none()
      }
      // Otherwise, return the string as is
      return Option.some(string)
    },
    //         ┌─── Option<string>
    //         ▼
    encode: (maybeString) => {
      // Check if the field is missing
      if (Option.isNone(maybeString)) {
        // Provide an empty string as default
        return ""
      }
      // Otherwise, return the string as is
      return maybeString.value
    }
  })
})

// Decoding examples

const decode = Schema.decodeUnknownSync(schema)

console.log(decode({ name: "John" }))
// Output: { name: 'John' }
console.log(decode({ name: "" }))
// Output: {}

// Encoding examples

const encode = Schema.encodeSync(schema)

console.log(encode({ name: "John" }))
// Output: { name: 'John' }
console.log(encode({}))
// Output: { name: '' }
```

You can streamline the decoding and encoding logic using `Option.liftPredicate` and `Option.getOrElse` for concise and readable transformations.

**Example** (Using `Option.liftPredicate` and `Option.getOrElse`)

```ts

const schema = Schema.Struct({
  name: Schema.requiredToOptional(Schema.String, Schema.String, {
    decode: Option.liftPredicate((s) => s !== ""),
    encode: Option.getOrElse(() => "")
  })
})
```

## Extending Schemas

Schemas in `effect` can be extended in multiple ways, allowing you to combine or enhance existing types with additional fields or functionality. One common method is to use the `fields` property available in `Struct` schemas. This property provides a convenient way to add fields or merge fields from different structs while retaining the original `Struct` type. This approach also makes it easier to access and modify fields.

For more complex cases, such as extending a struct with a union, you may want to use the `Schema.extend` function, which offers flexibility in scenarios where direct field spreading may not be sufficient.

> **Tip: Retaining Struct Type with Field Spreading**
  By using field spreading with `...Struct.fields`, you maintain the
  schema's `Struct` type, which allows continued access to the `fields`
  property for further modifications.


### Spreading Struct fields

Structs provide access to their fields through the `fields` property, which allows you to extend an existing struct by adding additional fields or combining fields from multiple structs.

**Example** (Adding New Fields)

```ts

const Original = Schema.Struct({
  a: Schema.String,
  b: Schema.String
})

const Extended = Schema.Struct({
  ...Original.fields,
  // Adding new fields
  c: Schema.String,
  d: Schema.String
})

//     ┌─── {
//     |      readonly a: string;
//     |      readonly b: string;
//     |      readonly c: string;
//     |      readonly d: string;
//     |    }
//     ▼
type Type = typeof Extended.Type
```

**Example** (Adding Additional Index Signatures)

```ts

const Original = Schema.Struct({
  a: Schema.String,
  b: Schema.String
})

const Extended = Schema.Struct(
  Original.fields,
  // Adding an index signature
  Schema.Record({ key: Schema.String, value: Schema.String })
)

//     ┌─── {
//     │      readonly [x: string]: string;
//     |      readonly a: string;
//     |      readonly b: string;
//     |    }
//     ▼
type Type = typeof Extended.Type
```

**Example** (Combining Fields from Multiple Structs)

```ts

const Struct1 = Schema.Struct({
  a: Schema.String,
  b: Schema.String
})

const Struct2 = Schema.Struct({
  c: Schema.String,
  d: Schema.String
})

const Extended = Schema.Struct({
  ...Struct1.fields,
  ...Struct2.fields
})

//     ┌─── {
//     |      readonly a: string;
//     |      readonly b: string;
//     |      readonly c: string;
//     |      readonly d: string;
//     |    }
//     ▼
type Type = typeof Extended.Type
```

### The extend function

The `Schema.extend` function provides a structured method to expand schemas, especially useful when direct [field spreading](#spreading-struct-fields) isn't sufficient—such as when you need to extend a struct with a union of other structs.

> **Caution: Extension Support Limitations**
  Not all extensions are supported, and compatibility depends on the type
  of schemas involved in the extension.


Supported extensions include:

- `Schema.String` with another `Schema.String` refinement or a string literal
- `Schema.Number` with another `Schema.Number` refinement or a number literal
- `Schema.Boolean` with another `Schema.Boolean` refinement or a boolean literal
- A struct with another struct where overlapping fields support extension
- A struct with in index signature
- A struct with a union of supported schemas
- A refinement of a struct with a supported schema
- A `suspend` of a struct with a supported schema
- A transformation between structs where the "from" and "to" sides have no overlapping fields with the target struct

**Example** (Extending a Struct with a Union of Structs)

```ts

const Struct = Schema.Struct({
  a: Schema.String
})

const UnionOfStructs = Schema.Union(
  Schema.Struct({ b: Schema.String }),
  Schema.Struct({ c: Schema.String })
)

const Extended = Schema.extend(Struct, UnionOfStructs)

//     ┌─── {
//     |        readonly a: string;
//     |    } & ({
//     |        readonly b: string;
//     |    } | {
//     |        readonly c: string;
//     |    })
//     ▼
type Type = typeof Extended.Type
```

**Example** (Attempting to Extend Structs with Conflicting Fields)

This example demonstrates an attempt to extend a struct with another struct that contains overlapping field names, resulting in an error due to conflicting types.

```ts

const Struct = Schema.Struct({
  a: Schema.String
})

const OverlappingUnion = Schema.Union(
  Schema.Struct({ a: Schema.Number }), // conflicting type for key "a"
  Schema.Struct({ d: Schema.String })
)

const Extended = Schema.extend(Struct, OverlappingUnion)
/*
throws:
Error: Unsupported schema or overlapping types
at path: ["a"]
details: cannot extend string with number
*/
```

**Example** (Extending a Refinement with Another Refinement)

In this example, we extend two refinements, `Integer` and `Positive`, creating a schema that enforces both integer and positivity constraints.

```ts

const Integer = Schema.Int.pipe(Schema.brand("Int"))
const Positive = Schema.Positive.pipe(Schema.brand("Positive"))

//      ┌─── Schema<number & Brand<"Positive"> & Brand<"Int">, number, never>
//      ▼
const PositiveInteger = Schema.asSchema(Schema.extend(Positive, Integer))

Schema.decodeUnknownSync(PositiveInteger)(-1)
/*
throws
ParseError: positive & Brand<"Positive"> & int & Brand<"Int">
└─ From side refinement failure
   └─ positive & Brand<"Positive">
      └─ Predicate refinement failure
         └─ Expected a positive number, actual -1
*/

Schema.decodeUnknownSync(PositiveInteger)(1.1)
/*
throws
ParseError: positive & Brand<"Positive"> & int & Brand<"Int">
└─ Predicate refinement failure
   └─ Expected an integer, actual 1.1
*/
```

## Renaming Properties

### Renaming a Property During Definition

To rename a property directly during schema creation, you can utilize the `Schema.fromKey` function.

**Example** (Renaming a Required Property)

```ts

const schema = Schema.Struct({
  a: Schema.propertySignature(Schema.String).pipe(Schema.fromKey("c")),
  b: Schema.Number
})

//     ┌─── { readonly c: string; readonly b: number; }
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── { readonly a: string; readonly b: number; }
//     ▼
type Type = typeof schema.Type

console.log(Schema.decodeUnknownSync(schema)({ c: "c", b: 1 }))
// Output: { a: "c", b: 1 }
```

**Example** (Renaming an Optional Property)

```ts

const schema = Schema.Struct({
  a: Schema.optional(Schema.String).pipe(Schema.fromKey("c")),
  b: Schema.Number
})

//     ┌─── { readonly b: number; readonly c?: string | undefined; }
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── { readonly a?: string | undefined; readonly b: number; }
//     ▼
type Type = typeof schema.Type

console.log(Schema.decodeUnknownSync(schema)({ c: "c", b: 1 }))
// Output: { a: 'c', b: 1 }

console.log(Schema.decodeUnknownSync(schema)({ b: 1 }))
// Output: { b: 1 }
```

Using `Schema.optional` automatically returns a `PropertySignature`, making it unnecessary to explicitly use `Schema.propertySignature` as required for renaming required fields in the previous example.

### Renaming Properties of an Existing Schema

For existing schemas, the `Schema.rename` API offers a way to systematically change property names across a schema, even within complex structures like unions, though in case of structs you lose the original field types.

**Example** (Renaming Properties in a Struct Schema)

```ts

const Original = Schema.Struct({
  c: Schema.String,
  b: Schema.Number
})

// Renaming the "c" property to "a"
//
//
//      ┌─── SchemaClass<{
//      |      readonly a: string;
//      |      readonly b: number;
//      |    }>
//      ▼
const Renamed = Schema.rename(Original, { c: "a" })

console.log(Schema.decodeUnknownSync(Renamed)({ c: "c", b: 1 }))
// Output: { a: "c", b: 1 }
```

**Example** (Renaming Properties in Union Schemas)

```ts

const Original = Schema.Union(
  Schema.Struct({
    c: Schema.String,
    b: Schema.Number
  }),
  Schema.Struct({
    c: Schema.String,
    d: Schema.Boolean
  })
)

// Renaming the "c" property to "a" for all members
//
//      ┌─── SchemaClass<{
//      |      readonly a: string;
//      |      readonly b: number;
//      |    } | {
//      |      readonly a: string;
//      |      readonly d: number;
//      |    }>
//      ▼
const Renamed = Schema.rename(Original, { c: "a" })

console.log(Schema.decodeUnknownSync(Renamed)({ c: "c", b: 1 }))
// Output: { a: "c", b: 1 }

console.log(Schema.decodeUnknownSync(Renamed)({ c: "c", d: false }))
// Output: { a: 'c', d: false }
```

## Recursive Schemas

The `Schema.suspend` function is designed for defining schemas that reference themselves, such as in recursive data structures.

**Example** (Self-Referencing Schema)

In this example, the `Category` schema references itself through the `subcategories` field, which is an array of `Category` objects.

```ts

interface Category {
  readonly name: string
  readonly subcategories: ReadonlyArray<Category>
}

const Category = Schema.Struct({
  name: Schema.String,
  subcategories: Schema.Array(
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
})
```

> **Note: Correct Inference**
  It is necessary to define the `Category` type and add an explicit type
  annotation because otherwise TypeScript would struggle to infer types
  correctly. Without this annotation, you might encounter the error
  message:


**Example** (Type Inference Error)

```ts

// @errors: 7022
const Category = Schema.Struct({
  name: Schema.String,
// @errors: 7022 7024
  subcategories: Schema.Array(Schema.suspend(() => Category))
})
```

### A Helpful Pattern to Simplify Schema Definition

As we've observed, it's necessary to define an interface for the `Type` of the schema to enable recursive schema definition, which can complicate things and be quite tedious.
One pattern to mitigate this is to **separate the field responsible for recursion** from all other fields.

**Example** (Separating Recursive Fields)

```ts

const fields = {
  name: Schema.String
  // ...other fields as needed
}

// Define an interface for the Category schema,
// extending the Type of the defined fields
interface Category extends Schema.Struct.Type<typeof fields> {
  // Define `subcategories` using recursion
  readonly subcategories: ReadonlyArray<Category>
}

const Category = Schema.Struct({
  ...fields, // Spread in the base fields
  subcategories: Schema.Array(
    // Define `subcategories` using recursion
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
})
```

### Mutually Recursive Schemas

You can also use `Schema.suspend` to create mutually recursive schemas, where two schemas reference each other. In the following example, `Expression` and `Operation` form a simple arithmetic expression tree by referencing each other.

**Example** (Defining Mutually Recursive Schemas)

```ts

interface Expression {
  readonly type: "expression"
  readonly value: number | Operation
}

interface Operation {
  readonly type: "operation"
  readonly operator: "+" | "-"
  readonly left: Expression
  readonly right: Expression
}

const Expression = Schema.Struct({
  type: Schema.Literal("expression"),
  value: Schema.Union(
    Schema.Number,
    Schema.suspend((): Schema.Schema<Operation> => Operation)
  )
})

const Operation = Schema.Struct({
  type: Schema.Literal("operation"),
  operator: Schema.Literal("+", "-"),
  left: Expression,
  right: Expression
})
```

### Recursive Types with Different Encoded and Type

Defining a recursive schema where the `Encoded` type differs from the `Type` type adds another layer of complexity. In such cases, we need to define two interfaces: one for the `Type` type, as seen previously, and another for the `Encoded` type.

**Example** (Recursive Schema with Different Encoded and Type Definitions)

Let's consider an example: suppose we want to add an `id` field to the `Category` schema, where the schema for `id` is `NumberFromString`.
It's important to note that `NumberFromString` is a schema that transforms a string into a number, so the `Type` and `Encoded` types of `NumberFromString` differ, being `number` and `string` respectively.
When we add this field to the `Category` schema, TypeScript raises an error:

```ts

const fields = {
  id: Schema.NumberFromString,
  name: Schema.String
}

interface Category extends Schema.Struct.Type<typeof fields> {
  readonly subcategories: ReadonlyArray<Category>
}

const Category = Schema.Struct({
  ...fields,
  subcategories: Schema.Array(
// @errors: 2322
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
})
```

This error occurs because the explicit annotation `Schema.Schema<Category>` is no longer sufficient and needs to be adjusted by explicitly adding the `Encoded` type:

```ts

const fields = {
  id: Schema.NumberFromString,
  name: Schema.String
}

interface Category extends Schema.Struct.Type<typeof fields> {
  readonly subcategories: ReadonlyArray<Category>
}

interface CategoryEncoded extends Schema.Struct.Encoded<typeof fields> {
  readonly subcategories: ReadonlyArray<CategoryEncoded>
}

const Category = Schema.Struct({
  ...fields,
  subcategories: Schema.Array(
    Schema.suspend(
      (): Schema.Schema<Category, CategoryEncoded> => Category
    )
  )
})
```


---

# [Schema Transformations](https://effect.website/docs/schema/transformations/)

## Overview


Transformations are important when working with schemas. They allow you to change data from one type to another. For example, you might parse a string into a number or convert a date string into a `Date` object.

The [Schema.transform](#transform) and [Schema.transformOrFail](#transformorfail) functions help you connect two schemas so you can convert data between them.

## transform

`Schema.transform` creates a new schema by taking the output of one schema (the "source") and making it the input of another schema (the "target"). Use this when you know the transformation will always succeed. If it might fail, use [Schema.transformOrFail](#transformorfail) instead.

### Understanding Input and Output

"Output" and "input" depend on what you are doing (decoding or encoding):

**When decoding:**

- The source schema `Schema<SourceType, SourceEncoded>` produces a `SourceType`.
- The target schema `Schema<TargetType, TargetEncoded>` expects a `TargetEncoded`.
- The decoding path looks like this: `SourceEncoded` → `TargetType`.

If `SourceType` and `TargetEncoded` differ, you can provide a `decode` function to convert the source schema's output into the target schema's input.

**When encoding:**

- The target schema `Schema<TargetType, TargetEncoded>` produces a `TargetEncoded`.
- The source schema `Schema<SourceType, SourceEncoded>` expects a `SourceType`.
- The encoding path looks like this: `TargetType` → `SourceEncoded`.

If `TargetEncoded` and `SourceType` differ, you can provide an `encode` function to convert the target schema's output into the source schema's input.

### Combining Two Primitive Schemas

In this example, we start with a schema that accepts `"on"` or `"off"` and transform it into a boolean schema. The `decode` function turns `"on"` into `true` and `"off"` into `false`. The `encode` function does the reverse. This gives us a `Schema<boolean, "on" | "off">`.

**Example** (Converting a String to a Boolean)

```ts

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  // Source schema: "on" or "off"
  Schema.Literal("on", "off"),
  // Target schema: boolean
  Schema.Boolean,
  {
    // optional but you get better error messages from TypeScript
    strict: true,
    // Transformation to convert the output of the
    // source schema ("on" | "off") into the input of the
    // target schema (boolean)
    decode: (literal) => literal === "on", // Always succeeds here
    // Reverse transformation
    encode: (bool) => (bool ? "on" : "off")
  }
)

//     ┌─── "on" | "off"
//     ▼
type Encoded = typeof BooleanFromString.Encoded

//     ┌─── boolean
//     ▼
type Type = typeof BooleanFromString.Type

console.log(Schema.decodeUnknownSync(BooleanFromString)("on"))
// Output: true
```

The `decode` function above never fails by itself. However, the full decoding process can still fail if the input does not fit the source schema. For example, if you provide `"wrong"` instead of `"on"` or `"off"`, the source schema will fail before calling `decode`.

**Example** (Handling Invalid Input)

```ts

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  Schema.Literal("on", "off"),
  Schema.Boolean,
  {
    strict: true,
    decode: (s) => s === "on",
    encode: (bool) => (bool ? "on" : "off")
  }
)

// Providing input not allowed by the source schema
Schema.decodeUnknownSync(BooleanFromString)("wrong")
/*
throws:
ParseError: ("on" | "off" <-> boolean)
└─ Encoded side transformation failure
   └─ "on" | "off"
      ├─ Expected "on", actual "wrong"
      └─ Expected "off", actual "wrong"
*/
```

### Combining Two Transformation Schemas

Below is an example where both the source and target schemas transform their data:

- The source schema is `Schema.NumberFromString`, which is `Schema<number, string>`.
- The target schema is `BooleanFromString` (defined above), which is `Schema<boolean, "on" | "off">`.

This example involves four types and requires two conversions:

- When decoding, convert a `number` into `"on" | "off"`. For example, treat any positive number as `"on"`.
- When encoding, convert `"on" | "off"` back into a `number`. For example, treat `"on"` as `1` and `"off"` as `-1`.

By composing these transformations, we get a schema that decodes a string into a boolean and encodes a boolean back into a string. The resulting schema is `Schema<boolean, string>`.

**Example** (Combining Two Transformation Schemas)

```ts

// Convert "on"/"off" to boolean and back
const BooleanFromString = Schema.transform(
  Schema.Literal("on", "off"),
  Schema.Boolean,
  {
    strict: true,
    decode: (s) => s === "on",
    encode: (bool) => (bool ? "on" : "off")
  }
)

const BooleanFromNumericString = Schema.transform(
  // Source schema: Convert string -> number
  Schema.NumberFromString,
  // Target schema: Convert "on"/"off" -> boolean
  BooleanFromString,
  {
    strict: true,
    // If number is positive, use "on", otherwise "off"
    decode: (n) => (n > 0 ? "on" : "off"),
    // If boolean is "on", use 1, otherwise -1
    encode: (bool) => (bool === "on" ? 1 : -1)
  }
)

//     ┌─── string
//     ▼
type Encoded = typeof BooleanFromNumericString.Encoded

//     ┌─── boolean
//     ▼
type Type = typeof BooleanFromNumericString.Type

console.log(Schema.decodeUnknownSync(BooleanFromNumericString)("100"))
// Output: true
```

**Example** (Converting an array to a ReadonlySet)

In this example, we convert an array into a `ReadonlySet`. The `decode` function takes an array and creates a new `ReadonlySet`. The `encode` function converts the set back into an array. We also provide the schema of the array items so they are properly validated.

```ts

// This function builds a schema that converts between a readonly array
// and a readonly set of items
const ReadonlySetFromArray = <A, I, R>(
  itemSchema: Schema.Schema<A, I, R>
): Schema.Schema<ReadonlySet<A>, ReadonlyArray<I>, R> =>
  Schema.transform(
    // Source schema: array of items
    Schema.Array(itemSchema),
    // Target schema: readonly set of items
    // **IMPORTANT** We use `Schema.typeSchema` here to obtain the schema
    // of the items to avoid decoding the elements twice
    Schema.ReadonlySetFromSelf(Schema.typeSchema(itemSchema)),
    {
      strict: true,
      decode: (items) => new Set(items),
      encode: (set) => Array.from(set.values())
    }
  )

const schema = ReadonlySetFromArray(Schema.String)

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlySet<string>
//     ▼
type Type = typeof schema.Type

console.log(Schema.decodeUnknownSync(schema)(["a", "b", "c"]))
// Output: Set(3) { 'a', 'b', 'c' }

console.log(Schema.encodeSync(schema)(new Set(["a", "b", "c"])))
// Output: [ 'a', 'b', 'c' ]
```

> **Note: Why Schema.typeSchema is used**
  Please note that to define the target schema, we used
  [Schema.typeSchema](/docs/schema/projections/#typeschema). This is
  because the decoding/encoding of the elements is already handled by the
  `from` schema: `Schema.Array(itemSchema)`, avoiding double decoding.


### Non-strict option

In some cases, strict type checking can create issues during data transformations, especially when the types might slightly differ in specific transformations. To address these scenarios, `Schema.transform` offers the option `strict: false`, which relaxes type constraints and allows more flexible transformations.

**Example** (Creating a Clamping Constructor)

Let's consider the scenario where you need to define a constructor `clamp` that ensures a number falls within a specific range. This function returns a schema that "clamps" a number to a specified minimum and maximum range:

```ts

const clamp =
  (minimum: number, maximum: number) =>
  <A extends number, I, R>(self: Schema.Schema<A, I, R>) =>
    Schema.transform(
      // Source schema
      self,
      // Target schema: filter based on min/max range
      self.pipe(
        Schema.typeSchema,
        Schema.filter((a) => a <= minimum || a >= maximum)
      ),
// @errors: 2345
      {
        strict: true,
        // Clamp the number within the specified range
        decode: (a) => Number.clamp(a, { minimum, maximum }),
        encode: (a) => a
      }
    )
```

In this example, `Number.clamp` returns a `number` that might not be recognized as the specific `A` type, which leads to a type mismatch under strict checking.

There are two ways to resolve this issue:

1. **Using Type Assertion**:
   Adding a type cast can enforce the return type to be treated as type `A`:

   ```ts
   decode: (a) => Number.clamp(a, { minimum, maximum }) as A
   ```

2. **Using the Non-Strict Option**:
   Setting `strict: false` in the transformation options allows the schema to bypass some of TypeScript's type-checking rules, accommodating the type discrepancy:

   ```ts
   import { Schema, Number } from "effect"

   const clamp =
     (minimum: number, maximum: number) =>
     <A extends number, I, R>(self: Schema.Schema<A, I, R>) =>
       Schema.transform(
         self,
         self.pipe(
           Schema.typeSchema,
           Schema.filter((a) => a >= minimum && a <= maximum)
         ),
         {
           strict: false,
           decode: (a) => Number.clamp(a, { minimum, maximum }),
           encode: (a) => a
         }
       )
   ```

## transformOrFail

While the [Schema.transform](#transform) function is suitable for error-free transformations,
the `Schema.transformOrFail` function is designed for more complex scenarios where **transformations
can fail** during the decoding or encoding stages.

This function enables decoding/encoding functions to return either a successful result or an error,
making it particularly useful for validating and processing data that might not always conform to expected formats.

### Error Handling

The `Schema.transformOrFail` function utilizes the ParseResult module to manage potential errors:

| Constructor           | Description                                                                                      |
| --------------------- | ------------------------------------------------------------------------------------------------ |
| `ParseResult.succeed` | Indicates a successful transformation, where no errors occurred.                                 |
| `ParseResult.fail`    | Signals a failed transformation, creating a new `ParseError` based on the provided `ParseIssue`. |

Additionally, the ParseResult module provides constructors for dealing with various types of parse issues, such as:

| Parse Issue Type | Description                                                                                   |
| ---------------- | --------------------------------------------------------------------------------------------- |
| `Type`           | Indicates a type mismatch error.                                                              |
| `Missing`        | Used when a required field is missing.                                                        |
| `Unexpected`     | Used for unexpected fields that are not allowed in the schema.                                |
| `Forbidden`      | Flags the decoding or encoding operation being forbidden by the schema.                       |
| `Pointer`        | Points to a specific location in the data where an issue occurred.                            |
| `Refinement`     | Used when a value does not meet a specific refinement or constraint.                          |
| `Transformation` | Flags issues that occur during transformation from one type to another.                       |
| `Composite`      | Represents a composite error, combining multiple issues into one, helpful for grouped errors. |

These tools allow for detailed and specific error handling, enhancing the reliability of data processing operations.

**Example** (Converting a String to a Number)

A common use case for `Schema.transformOrFail` is converting string representations of numbers into actual numeric types. This scenario is typical when dealing with user inputs or data from external sources.

```ts

export const NumberFromString = Schema.transformOrFail(
  // Source schema: accepts any string
  Schema.String,
  // Target schema: expects a number
  Schema.Number,
  {
    // optional but you get better error messages from TypeScript
    strict: true,
    decode: (input, options, ast) => {
      const parsed = parseFloat(input)
      // If parsing fails (NaN), return a ParseError with a custom error
      if (isNaN(parsed)) {
        return ParseResult.fail(
          // Create a Type Mismatch error
          new ParseResult.Type(
            // Provide the schema's abstract syntax tree for context
            ast,
            // Include the problematic input
            input,
            // Optional custom error message
            "Failed to convert string to number"
          )
        )
      }
      return ParseResult.succeed(parsed)
    },
    encode: (input, options, ast) => ParseResult.succeed(input.toString())
  }
)

//     ┌─── string
//     ▼
type Encoded = typeof NumberFromString.Encoded

//     ┌─── number
//     ▼
type Type = typeof NumberFromString.Type

console.log(Schema.decodeUnknownSync(NumberFromString)("123"))
// Output: 123

console.log(Schema.decodeUnknownSync(NumberFromString)("-"))
/*
throws:
ParseError: (string <-> number)
└─ Transformation process failure
   └─ Failed to convert string to number
*/
```

Both `decode` and `encode` functions not only receive the value to transform (`input`), but also the [parse options](/docs/schema/getting-started/#parse-options) that the user sets when using the resulting schema, and the `ast`, which represents the low level definition of the schema you're transforming.

### Async Transformations

In modern applications, especially those interacting with external APIs, you might need to transform data asynchronously. `Schema.transformOrFail` supports asynchronous transformations by allowing you to return an `Effect`.

**Example** (Validating Data with an API Call)

Consider a scenario where you need to validate a person's ID by making an API call. Here's how you can implement it:

```ts

// Define a function to make API requests
const get = (url: string): Effect.Effect<unknown, Error> =>
  Effect.tryPromise({
    try: () =>
      fetch(url).then((res) => {
        if (res.ok) {
          return res.json() as Promise<unknown>
        }
        throw new Error(String(res.status))
      }),
    catch: (e) => new Error(String(e))
  })

// Create a branded schema for a person's ID
const PeopleId = Schema.String.pipe(Schema.brand("PeopleId"))

// Define a schema with async transformation
const PeopleIdFromString = Schema.transformOrFail(
  Schema.String,
  PeopleId,
  {
    strict: true,
    decode: (s, _, ast) =>
      // Make an API call to validate the ID
      Effect.mapBoth(get(`https://swapi.dev/api/people/${s}`), {
        // Error handling for failed API call
        onFailure: (e) => new ParseResult.Type(ast, s, e.message),
        // Return the ID if the API call succeeds
        onSuccess: () => s
      }),
    encode: ParseResult.succeed
  }
)

//     ┌─── string
//     ▼
type Encoded = typeof PeopleIdFromString.Encoded

//     ┌─── string & Brand<"PeopleId">
//     ▼
type Type = typeof PeopleIdFromString.Type

//     ┌─── never
//     ▼
type Context = typeof PeopleIdFromString.Context

// Run a successful decode operation
Effect.runPromiseExit(Schema.decodeUnknown(PeopleIdFromString)("1")).then(
  console.log
)
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/

// Run a decode operation that will fail
Effect.runPromiseExit(
  Schema.decodeUnknown(PeopleIdFromString)("fail")
).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: {
      _id: 'ParseError',
      message: '(string <-> string & Brand<"PeopleId">)\n' +
        '└─ Transformation process failure\n' +
        '   └─ Error: 404'
    }
  }
}
*/
```

### Declaring Dependencies

In cases where your transformation depends on external services, you can inject these services in the `decode` or `encode` functions. These dependencies are then tracked in the `Requirements` channel of the schema:

```text
Schema<Type, Encoded, Requirements>
```

**Example** (Validating Data with a Service)

```ts

// Define a Validation service for dependency injection
class Validation extends Context.Tag("Validation")<
  Validation,
  {
    readonly validatePeopleid: (s: string) => Effect.Effect<void, Error>
  }
>() {}

// Create a branded schema for a person's ID
const PeopleId = Schema.String.pipe(Schema.brand("PeopleId"))

// Transform a string into a validated PeopleId,
// using an external validation service
const PeopleIdFromString = Schema.transformOrFail(
  Schema.String,
  PeopleId,
  {
    strict: true,
    decode: (s, _, ast) =>
      // Asynchronously validate the ID using the injected service
      Effect.gen(function* () {
        // Access the validation service
        const validator = yield* Validation
        // Use service to validate ID
        yield* validator.validatePeopleid(s)
        return s
      }).pipe(
        Effect.mapError((e) => new ParseResult.Type(ast, s, e.message))
      ),
    encode: ParseResult.succeed // Encode by simply returning the string
  }
)

//     ┌─── string
//     ▼
type Encoded = typeof PeopleIdFromString.Encoded

//     ┌─── string & Brand<"PeopleId">
//     ▼
type Type = typeof PeopleIdFromString.Type

//     ┌─── Validation
//     ▼
type Context = typeof PeopleIdFromString.Context

// Layer to provide a successful validation service
const SuccessTest = Layer.succeed(Validation, {
  validatePeopleid: (_) => Effect.void
})

// Run a successful decode operation
Effect.runPromiseExit(
  Schema.decodeUnknown(PeopleIdFromString)("1").pipe(
    Effect.provide(SuccessTest)
  )
).then(console.log)
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/

// Layer to provide a failing validation service
const FailureTest = Layer.succeed(Validation, {
  validatePeopleid: (_) => Effect.fail(new Error("404"))
})

// Run a decode operation that will fail
Effect.runPromiseExit(
  Schema.decodeUnknown(PeopleIdFromString)("fail").pipe(
    Effect.provide(FailureTest)
  )
).then(console.log)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Fail',
    failure: {
      _id: 'ParseError',
      message: '(string <-> string & Brand<"PeopleId">)\n' +
        '└─ Transformation process failure\n' +
        '   └─ Error: 404'
    }
  }
}
*/
```

## One-Way Transformations with Forbidden Encoding

In some cases, encoding a value back to its original form may not make sense or may be undesirable. You can use `Schema.transformOrFail` to define a one-way transformation and explicitly return a `Forbidden` parse error during the encoding process. This ensures that once a value is transformed, it cannot be reverted to its original form.

**Example** (Password Hashing with Forbidden Encoding)

Consider a scenario where you need to hash a user's plain text password for secure storage. It is important that the hashed password cannot be reversed back to plain text. By using `Schema.transformOrFail`, you can enforce this restriction, ensuring a one-way transformation from plain text to a hashed password.

```ts

// Define a schema for plain text passwords
// with a minimum length requirement
const PlainPassword = Schema.String.pipe(
  Schema.minLength(6),
  Schema.brand("PlainPassword", { identifier: "PlainPassword" })
)

// Define a schema for hashed passwords as a separate branded type
const HashedPassword = Schema.String.pipe(
  Schema.brand("HashedPassword", { identifier: "HashedPassword" })
)

// Define a one-way transformation from plain passwords to hashed passwords
export const PasswordHashing = Schema.transformOrFail(
  PlainPassword,
  // Wrap the output in Redacted for added safety
  Schema.RedactedFromSelf(HashedPassword),
  {
    strict: true,
    // Decode: Transform a plain password into a hashed password
    decode: (plainPassword) => {
      const hash = createHash("sha256")
        .update(plainPassword)
        .digest("hex")
      // Wrap the hash in Redacted
      return ParseResult.succeed(Redacted.make(hash))
    },
    // Encode: Forbid reversing the hashed password back to plain text
    encode: (hashedPassword, _, ast) =>
      ParseResult.fail(
        new ParseResult.Forbidden(
          ast,
          hashedPassword,
          "Encoding hashed passwords back to plain text is forbidden."
        )
      )
  }
)

//     ┌─── string
//     ▼
type Encoded = typeof PasswordHashing.Encoded

//     ┌─── Redacted<string & Brand<"HashedPassword">>
//     ▼
type Type = typeof PasswordHashing.Type

// Example: Decoding a plain password into a hashed password
console.log(
  Schema.decodeUnknownSync(PasswordHashing)("myPlainPassword123")
)
// Output: <redacted>

// Example: Attempting to encode a hashed password back to plain text
console.log(
  Schema.encodeUnknownSync(PasswordHashing)(Redacted.make("2ef2b7..."))
)
/*
throws:
ParseError: (PlainPassword <-> Redacted(<redacted>))
└─ Transformation process failure
   └─ (PlainPassword <-> Redacted(<redacted>))
      └─ Encoding hashed passwords back to plain text is forbidden.
*/
```

## Composition

Combining and reusing schemas is often needed in complex applications, and the `Schema.compose` combinator provides an efficient way to do this. With `Schema.compose`, you can chain two schemas, `Schema<B, A, R1>` and `Schema<C, B, R2>`, into a single schema `Schema<C, A, R1 | R2>`:

**Example** (Composing Schemas to Parse a Delimited String into Numbers)

```ts

// Schema to split a string by commas into an array of strings
//
//     ┌─── Schema<readonly string[], string, never>
//     ▼
const schema1 = Schema.asSchema(Schema.split(","))

// Schema to convert an array of strings to an array of numbers
//
//     ┌─── Schema<readonly number[], readonly string[], never>
//     ▼
const schema2 = Schema.asSchema(Schema.Array(Schema.NumberFromString))

// Composed schema that takes a string, splits it by commas,
// and converts the result into an array of numbers
//
//     ┌─── Schema<readonly number[], string, never>
//     ▼
const ComposedSchema = Schema.asSchema(Schema.compose(schema1, schema2))
```

### Non-strict Option

When composing schemas, you may encounter cases where the output of one schema does not perfectly match the input of the next, for example, if you have `Schema<R1, A, B>` and `Schema<R2, C, D>` where `C` differs from `B`. To handle these cases, you can use the `{ strict: false }` option to relax type constraints.

**Example** (Using Non-strict Option in Composition)

```ts

// Without the `strict: false` option,
// this composition raises a TypeScript error
Schema.compose(
// @errors: 2769
  Schema.Union(Schema.Null, Schema.Literal("0")),
  Schema.NumberFromString
)

// Use `strict: false` to allow type flexibility
Schema.compose(
  Schema.Union(Schema.Null, Schema.Literal("0")),
  Schema.NumberFromString,
  { strict: false }
)
```

## Effectful Filters

The `Schema.filterEffect` function enables validations that require asynchronous or dynamic scenarios, making it suitable for cases where validations involve side effects like network requests or database queries. For simple synchronous validations, see [`Schema.filter`](/docs/schema/filters/#declaring-filters).

**Example** (Asynchronous Username Validation)

```ts

// Mock async function to validate a username
async function validateUsername(username: string) {
  return Promise.resolve(username === "gcanti")
}

// Define a schema with an effectful filter
const ValidUsername = Schema.String.pipe(
  Schema.filterEffect((username) =>
    Effect.promise(() =>
      // Validate the username asynchronously,
      // returning an error message if invalid
      validateUsername(username).then(
        (valid) => valid || "Invalid username"
      )
    )
  )
).annotations({ identifier: "ValidUsername" })

Effect.runPromise(Schema.decodeUnknown(ValidUsername)("xxx")).then(
  console.log
)
/*
ParseError: ValidUsername
└─ Transformation process failure
   └─ Invalid username
*/
```

## String Transformations

### split

Splits a string by a specified delimiter into an array of substrings.

**Example** (Splitting a String by Comma)

```ts

const schema = Schema.split(",")

const decode = Schema.decodeUnknownSync(schema)

console.log(decode("")) // [""]
console.log(decode(",")) // ["", ""]
console.log(decode("a,")) // ["a", ""]
console.log(decode("a,b")) // ["a", "b"]
```

### Trim

Removes whitespace from the beginning and end of a string.

**Example** (Trimming Whitespace)

```ts

const decode = Schema.decodeUnknownSync(Schema.Trim)

console.log(decode("a")) // "a"
console.log(decode(" a")) // "a"
console.log(decode("a ")) // "a"
console.log(decode(" a ")) // "a"
```

> **Tip: Trimmed Check**
  If you were looking for a combinator to check if a string is trimmed,
  check out the `Schema.trimmed` filter.


### Lowercase

Converts a string to lowercase.

**Example** (Converting to Lowercase)

```ts

const decode = Schema.decodeUnknownSync(Schema.Lowercase)

console.log(decode("A")) // "a"
console.log(decode(" AB")) // " ab"
console.log(decode("Ab ")) // "ab "
console.log(decode(" ABc ")) // " abc "
```

> **Tip: Lowercase And Lowercased**
  If you were looking for a combinator to check if a string is lowercased,
  check out the `Schema.Lowercased` schema or the `Schema.lowercased`
  filter.


### Uppercase

Converts a string to uppercase.

**Example** (Converting to Uppercase)

```ts

const decode = Schema.decodeUnknownSync(Schema.Uppercase)

console.log(decode("a")) // "A"
console.log(decode(" ab")) // " AB"
console.log(decode("aB ")) // "AB "
console.log(decode(" abC ")) // " ABC "
```

> **Tip: Uppercase And Uppercased**
  If you were looking for a combinator to check if a string is uppercased,
  check out the `Schema.Uppercased` schema or the `Schema.uppercased`
  filter.


### Capitalize

Converts the first character of a string to uppercase.

**Example** (Capitalizing a String)

```ts

const decode = Schema.decodeUnknownSync(Schema.Capitalize)

console.log(decode("aa")) // "Aa"
console.log(decode(" ab")) // " ab"
console.log(decode("aB ")) // "AB "
console.log(decode(" abC ")) // " abC "
```

> **Tip: Capitalize And Capitalized**
  If you were looking for a combinator to check if a string is
  capitalized, check out the `Schema.Capitalized` schema or the
  `Schema.capitalized` filter.


### Uncapitalize

Converts the first character of a string to lowercase.

**Example** (Uncapitalizing a String)

```ts

const decode = Schema.decodeUnknownSync(Schema.Uncapitalize)

console.log(decode("AA")) // "aA"
console.log(decode(" AB")) // " AB"
console.log(decode("Ab ")) // "ab "
console.log(decode(" AbC ")) // " AbC "
```

> **Tip: Uncapitalize And Uncapitalized**
  If you were looking for a combinator to check if a string is
  uncapitalized, check out the `Schema.Uncapitalized` schema or the
  `Schema.uncapitalized` filter.


### parseJson

The `Schema.parseJson` constructor offers a method to convert JSON strings into the `unknown` type using the underlying functionality of `JSON.parse`.
It also employs `JSON.stringify` for encoding.

**Example** (Parsing JSON Strings)

```ts

const schema = Schema.parseJson()
const decode = Schema.decodeUnknownSync(schema)

// Parse valid JSON strings
console.log(decode("{}")) // Output: {}
console.log(decode(`{"a":"b"}`)) // Output: { a: "b" }

// Attempting to decode an empty string results in an error
decode("")
/*
throws:
ParseError: (JsonString <-> unknown)
└─ Transformation process failure
   └─ Unexpected end of JSON input
*/
```

To further refine the result of JSON parsing, you can provide a schema to the `Schema.parseJson` constructor. This schema will validate that the parsed JSON matches a specific structure.

**Example** (Parsing JSON with Structured Validation)

In this example, `Schema.parseJson` uses a struct schema to ensure the parsed JSON is an object with a numeric property `a`. This adds validation to the parsed data, confirming that it follows the expected structure.

```ts

//     ┌─── SchemaClass<{ readonly a: number; }, string, never>
//     ▼
const schema = Schema.parseJson(Schema.Struct({ a: Schema.Number }))
```

### StringFromBase64

Decodes a base64 (RFC4648) encoded string into a UTF-8 string.

**Example** (Decoding Base64)

```ts

const decode = Schema.decodeUnknownSync(Schema.StringFromBase64)

console.log(decode("Zm9vYmFy"))
// Output: "foobar"
```

### StringFromBase64Url

Decodes a base64 (URL) encoded string into a UTF-8 string.

**Example** (Decoding Base64 URL)

```ts

const decode = Schema.decodeUnknownSync(Schema.StringFromBase64Url)

console.log(decode("Zm9vYmFy"))
// Output: "foobar"
```

### StringFromHex

Decodes a hex encoded string into a UTF-8 string.

**Example** (Decoding Hex String)

```ts

const decode = Schema.decodeUnknownSync(Schema.StringFromHex)

console.log(new TextEncoder().encode(decode("0001020304050607")))
/*
Output:
Uint8Array(8) [
  0, 1, 2, 3,
  4, 5, 6, 7
]
*/
```

### StringFromUriComponent

Decodes a URI-encoded string into a UTF-8 string. It is useful for encoding and decoding data in URLs.

**Example** (Decoding URI Component)

```ts

const PaginationSchema = Schema.Struct({
  maxItemPerPage: Schema.Number,
  page: Schema.Number
})

const UrlSchema = Schema.compose(
  Schema.StringFromUriComponent,
  Schema.parseJson(PaginationSchema)
)

console.log(Schema.encodeSync(UrlSchema)({ maxItemPerPage: 10, page: 1 }))
// Output: %7B%22maxItemPerPage%22%3A10%2C%22page%22%3A1%7D
```

## Number Transformations

### NumberFromString

Transforms a string into a number by parsing the string using the `parse` function of the `effect/Number` module.

It returns an error if the value can't be converted (for example when non-numeric characters are provided).

The following special string values are supported: "NaN", "Infinity", "-Infinity".

**Example** (Parsing Number from String)

```ts

const schema = Schema.NumberFromString

const decode = Schema.decodeUnknownSync(schema)

// success cases
console.log(decode("1")) // 1
console.log(decode("-1")) // -1
console.log(decode("1.5")) // 1.5
console.log(decode("NaN")) // NaN
console.log(decode("Infinity")) // Infinity
console.log(decode("-Infinity")) // -Infinity

// failure cases
decode("a")
/*
throws:
ParseError: NumberFromString
└─ Transformation process failure
   └─ Expected NumberFromString, actual "a"
*/
```

### clamp

Restricts a number within a specified range.

**Example** (Clamping a Number)

```ts

// clamps the input to -1 <= x <= 1
const schema = Schema.Number.pipe(Schema.clamp(-1, 1))

const decode = Schema.decodeUnknownSync(schema)

console.log(decode(-3)) // -1
console.log(decode(0)) // 0
console.log(decode(3)) // 1
```

### parseNumber

Transforms a string into a number by parsing the string using the `parse` function of the `effect/Number` module.

It returns an error if the value can't be converted (for example when non-numeric characters are provided).

The following special string values are supported: "NaN", "Infinity", "-Infinity".

**Example** (Parsing and Validating Numbers)

```ts

const schema = Schema.String.pipe(Schema.parseNumber)

const decode = Schema.decodeUnknownSync(schema)

console.log(decode("1")) // 1
console.log(decode("Infinity")) // Infinity
console.log(decode("NaN")) // NaN
console.log(decode("-"))
/*
throws
ParseError: (string <-> number)
└─ Transformation process failure
   └─ Expected (string <-> number), actual "-"
*/
```

## Boolean Transformations

### Not

Negates a boolean value.

**Example** (Negating Boolean)

```ts

const decode = Schema.decodeUnknownSync(Schema.Not)

console.log(decode(true)) // false
console.log(decode(false)) // true
```

## Symbol transformations

### Symbol

Converts a string to a symbol using `Symbol.for`.

**Example** (Creating Symbols from Strings)

```ts

const decode = Schema.decodeUnknownSync(Schema.Symbol)

console.log(decode("a")) // Symbol(a)
```

## BigInt transformations

### BigInt

Converts a string to a `BigInt` using the `BigInt` constructor.

**Example** (Parsing BigInt from String)

```ts

const decode = Schema.decodeUnknownSync(Schema.BigInt)

// success cases
console.log(decode("1")) // 1n
console.log(decode("-1")) // -1n

// failure cases
decode("a")
/*
throws:
ParseError: bigint
└─ Transformation process failure
   └─ Expected bigint, actual "a"
*/
decode("1.5") // throws
decode("NaN") // throws
decode("Infinity") // throws
decode("-Infinity") // throws
```

### BigIntFromNumber

Converts a number to a `BigInt` using the `BigInt` constructor.

**Example** (Parsing BigInt from Number)

```ts

const decode = Schema.decodeUnknownSync(Schema.BigIntFromNumber)
const encode = Schema.encodeSync(Schema.BigIntFromNumber)

// success cases
console.log(decode(1)) // 1n
console.log(decode(-1)) // -1n
console.log(encode(1n)) // 1
console.log(encode(-1n)) // -1

// failure cases
decode(1.5)
/*
throws:
ParseError: BigintFromNumber
└─ Transformation process failure
   └─ Expected BigintFromNumber, actual 1.5
*/

decode(NaN) // throws
decode(Infinity) // throws
decode(-Infinity) // throws
encode(BigInt(Number.MAX_SAFE_INTEGER) + 1n) // throws
encode(BigInt(Number.MIN_SAFE_INTEGER) - 1n) // throws
```

### clampBigInt

Restricts a `BigInt` within a specified range.

**Example** (Clamping BigInt)

```ts

// clamps the input to -1n <= x <= 1n
const schema = Schema.BigIntFromSelf.pipe(Schema.clampBigInt(-1n, 1n))

const decode = Schema.decodeUnknownSync(schema)

console.log(decode(-3n))
// Output: -1n

console.log(decode(0n))
// Output: 0n

console.log(decode(3n))
// Output: 1n
```

## Date transformations

### Date

Converts a string into a **valid** `Date`, ensuring that invalid dates, such as `new Date("Invalid Date")`, are rejected.

**Example** (Parsing and Validating Date)

```ts

const decode = Schema.decodeUnknownSync(Schema.Date)

console.log(decode("1970-01-01T00:00:00.000Z"))
// Output: 1970-01-01T00:00:00.000Z

decode("a")
/*
throws:
ParseError: Date
└─ Predicate refinement failure
   └─ Expected Date, actual Invalid Date
*/

const validate = Schema.validateSync(Schema.Date)

console.log(validate(new Date(0)))
// Output: 1970-01-01T00:00:00.000Z

console.log(validate(new Date("Invalid Date")))
/*
throws:
ParseError: Date
└─ Predicate refinement failure
   └─ Expected Date, actual Invalid Date
*/
```

## BigDecimal Transformations

### BigDecimal

Converts a string to a `BigDecimal`.

**Example** (Parsing BigDecimal from String)

```ts

const decode = Schema.decodeUnknownSync(Schema.BigDecimal)

console.log(decode(".124"))
// Output: { _id: 'BigDecimal', value: '124', scale: 3 }
```

### BigDecimalFromNumber

Converts a number to a `BigDecimal`.

> **Caution: Invalid Range**
  When encoding, this Schema will produce incorrect results if the
  BigDecimal exceeds the 64-bit range of a number.


**Example** (Parsing BigDecimal from Number)

```ts

const decode = Schema.decodeUnknownSync(Schema.BigDecimalFromNumber)

console.log(decode(0.111))
// Output: { _id: 'BigDecimal', value: '111', scale: 3 }
```

### clampBigDecimal

Clamps a `BigDecimal` within a specified range.

**Example** (Clamping BigDecimal)

```ts

const schema = Schema.BigDecimal.pipe(
  Schema.clampBigDecimal(
    BigDecimal.fromNumber(-1),
    BigDecimal.fromNumber(1)
  )
)

const decode = Schema.decodeUnknownSync(schema)

console.log(decode("-2"))
// Output: { _id: 'BigDecimal', value: '-1', scale: 0 }

console.log(decode("0"))
// Output: { _id: 'BigDecimal', value: '0', scale: 0 }

console.log(decode("3"))
// Output: { _id: 'BigDecimal', value: '1', scale: 0 }
```


---

# [Filters](https://effect.website/docs/schema/filters/)

## Overview


Developers can define custom validation logic beyond basic type checks, giving more control over how data is validated.

## Declaring Filters

Filters are declared using the `Schema.filter` function. This function requires two arguments: the schema to be validated and a predicate function. The predicate function is user-defined and determines whether the data satisfies the condition. If the data fails the validation, an error message can be provided.

**Example** (Defining a Minimum String Length Filter)

```ts

// Define a string schema with a filter to ensure the string
// is at least 10 characters long
const LongString = Schema.String.pipe(
  Schema.filter(
    // Custom error message for strings shorter than 10 characters
    (s) => s.length >= 10 || "a string at least 10 characters long"
  )
)

//     ┌─── string
//     ▼
type Type = typeof LongString.Type

console.log(Schema.decodeUnknownSync(LongString)("a"))
/*
throws:
ParseError: { string | filter }
└─ Predicate refinement failure
   └─ a string at least 10 characters long
*/
```

Note that the filter does not alter the schema's `Type`:

```ts
//     ┌─── string
//     ▼
type Type = typeof LongString.Type
```

Filters add additional validation constraints without modifying the schema's underlying type.

> **Tip**
  If you need to modify the `Type`, consider using [Branded
  types](/docs/schema/advanced-usage/#branded-types).


## The Predicate Function

The predicate function in a filter follows this structure:

```ts
type Predicate = (
  a: A,
  options: ParseOptions,
  self: AST.Refinement
) => FilterReturnType
```

where

```ts
interface FilterIssue {
  readonly path: ReadonlyArray<PropertyKey>
  readonly issue: string | ParseResult.ParseIssue
}

type FilterOutput =
  | undefined
  | boolean
  | string
  | ParseResult.ParseIssue
  | FilterIssue

type FilterReturnType = FilterOutput | ReadonlyArray<FilterOutput>
```

The filter's predicate can return several types of values, each affecting validation in a different way:

| Return Type                   | Behavior                                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------------------------ |
| `true` or `undefined`         | The data satisfies the filter's condition and passes validation.                                 |
| `false`                       | The data does not meet the condition, and no specific error message is provided.                 |
| `string`                      | The validation fails, and the provided string is used as the error message.                      |
| `ParseResult.ParseIssue`      | The validation fails with a detailed error structure, specifying where and why it failed.        |
| `FilterIssue`                 | Allows for more detailed error messages with specific paths, providing enhanced error reporting. |
| `ReadonlyArray<FilterOutput>` | An array of issues can be returned if multiple validation errors need to be reported.            |

> **Tip: Effectful Filters**
  Normal filters only handle synchronous, non-effectful validations. If
  you need filters that involve asynchronous logic or side effects,
  consider using
  [Schema.filterEffect](/docs/schema/transformations/#effectful-filters).


## Adding Annotations

Embedding metadata within the schema, such as identifiers, JSON schema specifications, and descriptions, enhances understanding and analysis of the schema's constraints and purpose.

**Example** (Adding Metadata with Annotations)

```ts

const LongString = Schema.String.pipe(
  Schema.filter(
    (s) =>
      s.length >= 10 ? undefined : "a string at least 10 characters long",
    {
      identifier: "LongString",
      jsonSchema: { minLength: 10 },
      description: "Lorem ipsum dolor sit amet, ..."
    }
  )
)

console.log(Schema.decodeUnknownSync(LongString)("a"))
/*
throws:
ParseError: LongString
└─ Predicate refinement failure
   └─ a string at least 10 characters long
*/

console.log(JSON.stringify(JSONSchema.make(LongString), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "LongString": {
      "type": "string",
      "description": "Lorem ipsum dolor sit amet, ...",
      "minLength": 10
    }
  },
  "$ref": "#/$defs/LongString"
}
*/
```

## Specifying Error Paths

When validating forms or structured data, it's possible to associate specific error messages with particular fields or paths. This enhances error reporting and is especially useful when integrating with libraries like [react-hook-form](https://react-hook-form.com/).

**Example** (Matching Passwords)

```ts

const Password = Schema.Trim.pipe(Schema.minLength(2))

const MyForm = Schema.Struct({
  password: Password,
  confirm_password: Password
}).pipe(
  // Add a filter to ensure that passwords match
  Schema.filter((input) => {
    if (input.password !== input.confirm_password) {
      // Return an error message associated
      // with the "confirm_password" field
      return {
        path: ["confirm_password"],
        message: "Passwords do not match"
      }
    }
  })
)

console.log(
  JSON.stringify(
    Schema.decodeUnknownEither(MyForm)({
      password: "abc",
      confirm_password: "abd" // Confirm password does not match
    }).pipe(
      Either.mapLeft((error) =>
        ParseResult.ArrayFormatter.formatErrorSync(error)
      )
    ),
    null,
    2
  )
)
/*
  "_id": "Either",
  "_tag": "Left",
  "left": [
    {
      "_tag": "Type",
      "path": [
        "confirm_password"
      ],
      "message": "Passwords do not match"
    }
  ]
}
*/
```

In this example, we define a `MyForm` schema with two password fields (`password` and `confirm_password`). We use `Schema.filter` to check that both passwords match. If they don't, an error message is returned, specifically associated with the `confirm_password` field. This makes it easier to pinpoint the exact location of the validation failure.

The error is formatted in a structured way using `ArrayFormatter`, allowing for easier post-processing and integration with form libraries.

> **Tip: Using ArrayFormatter for Structured Errors**
  The `ArrayFormatter` provides a detailed and structured error format
  rather than a simple error string. This is especially useful when
  handling complex forms or structured data. For more information, see
  [ArrayFormatter](/docs/schema/error-formatters/#arrayformatter).


## Multiple Error Reporting

The `Schema.filter` API supports reporting multiple validation issues at once, which is especially useful in scenarios like form validation where several checks might fail simultaneously.

**Example** (Reporting Multiple Validation Errors)

```ts

const Password = Schema.Trim.pipe(Schema.minLength(2))
const OptionalString = Schema.optional(Schema.String)

const MyForm = Schema.Struct({
  password: Password,
  confirm_password: Password,
  name: OptionalString,
  surname: OptionalString
}).pipe(
  Schema.filter((input) => {
    const issues: Array<Schema.FilterIssue> = []

    // Check if passwords match
    if (input.password !== input.confirm_password) {
      issues.push({
        path: ["confirm_password"],
        message: "Passwords do not match"
      })
    }

    // Ensure either name or surname is present
    if (!input.name && !input.surname) {
      issues.push({
        path: ["surname"],
        message: "Surname must be present if name is not present"
      })
    }
    return issues
  })
)

console.log(
  JSON.stringify(
    Schema.decodeUnknownEither(MyForm)({
      password: "abc",
      confirm_password: "abd" // Confirm password does not match
    }).pipe(
      Either.mapLeft((error) =>
        ParseResult.ArrayFormatter.formatErrorSync(error)
      )
    ),
    null,
    2
  )
)
/*
{
  "_id": "Either",
  "_tag": "Left",
  "left": [
    {
      "_tag": "Type",
      "path": [
        "confirm_password"
      ],
      "message": "Passwords do not match"
    },
    {
      "_tag": "Type",
      "path": [
        "surname"
      ],
      "message": "Surname must be present if name is not present"
    }
  ]
}
*/
```

In this example, we define a `MyForm` schema with fields for password validation and optional name/surname fields. The `Schema.filter` function checks if the passwords match and ensures that either a name or surname is provided. If either validation fails, the corresponding error message is associated with the relevant field and both errors are returned in a structured format.

> **Tip: Using ArrayFormatter for Structured Errors**
  The `ArrayFormatter` provides a detailed and structured error format
  rather than a simple error string. This is especially useful when
  handling complex forms or structured data. For more information, see
  [ArrayFormatter](/docs/schema/error-formatters/#arrayformatter).


## Exposed Values

For schemas with filters, you can access the base schema (the schema before the filter was applied) using the `from` property:

```ts

const LongString = Schema.String.pipe(
  Schema.filter((s) => s.length >= 10)
)

// Access the base schema, which is the string schema
// before the filter was applied
//
//      ┌─── typeof Schema.String
//      ▼
const From = LongString.from
```

## Built-in Filters

### String Filters

Here is a list of useful string filters provided by the Schema module:

```ts

// Specifies maximum length of a string
Schema.String.pipe(Schema.maxLength(5))

// Specifies minimum length of a string
Schema.String.pipe(Schema.minLength(5))

// Equivalent to minLength(1)
Schema.String.pipe(Schema.nonEmptyString())
// or
Schema.NonEmptyString

// Specifies exact length of a string
Schema.String.pipe(Schema.length(5))

// Specifies a range for the length of a string
Schema.String.pipe(Schema.length({ min: 2, max: 4 }))

// Matches a string against a regular expression pattern
Schema.String.pipe(Schema.pattern(/^[a-z]+$/))

// Ensures a string starts with a specific substring
Schema.String.pipe(Schema.startsWith("prefix"))

// Ensures a string ends with a specific substring
Schema.String.pipe(Schema.endsWith("suffix"))

// Checks if a string includes a specific substring
Schema.String.pipe(Schema.includes("substring"))

// Validates that a string has no leading or trailing whitespaces
Schema.String.pipe(Schema.trimmed())

// Validates that a string is entirely in lowercase
Schema.String.pipe(Schema.lowercased())

// Validates that a string is entirely in uppercase
Schema.String.pipe(Schema.uppercased())

// Validates that a string is capitalized
Schema.String.pipe(Schema.capitalized())

// Validates that a string is uncapitalized
Schema.String.pipe(Schema.uncapitalized())
```

> **Tip: Trim vs Trimmed**
  The `trimmed` combinator does not make any transformations, it only
  validates. If what you were looking for was a combinator to trim
  strings, then check out the `trim` combinator or the `Trim` schema.


### Number Filters

Here is a list of useful number filters provided by the Schema module:

```ts

// Specifies a number greater than 5
Schema.Number.pipe(Schema.greaterThan(5))

// Specifies a number greater than or equal to 5
Schema.Number.pipe(Schema.greaterThanOrEqualTo(5))

// Specifies a number less than 5
Schema.Number.pipe(Schema.lessThan(5))

// Specifies a number less than or equal to 5
Schema.Number.pipe(Schema.lessThanOrEqualTo(5))

// Specifies a number between -2 and 2, inclusive
Schema.Number.pipe(Schema.between(-2, 2))

// Specifies that the value must be an integer
Schema.Number.pipe(Schema.int())
// or
Schema.Int

// Ensures the value is not NaN
Schema.Number.pipe(Schema.nonNaN())
// or
Schema.NonNaN

// Ensures that the provided value is a finite number
// (excluding NaN, +Infinity, and -Infinity)
Schema.Number.pipe(Schema.finite())
// or
Schema.Finite

// Specifies a positive number (> 0)
Schema.Number.pipe(Schema.positive())
// or
Schema.Positive

// Specifies a non-negative number (>= 0)
Schema.Number.pipe(Schema.nonNegative())
// or
Schema.NonNegative

// A non-negative integer
Schema.NonNegativeInt

// Specifies a negative number (< 0)
Schema.Number.pipe(Schema.negative())
// or
Schema.Negative

// Specifies a non-positive number (<= 0)
Schema.Number.pipe(Schema.nonPositive())
// or
Schema.NonPositive

// Specifies a number that is evenly divisible by 5
Schema.Number.pipe(Schema.multipleOf(5))

// A 8-bit unsigned integer (0 to 255)
Schema.Uint8
```

### ReadonlyArray Filters

Here is a list of useful array filters provided by the Schema module:

```ts

// Specifies the maximum number of items in the array
Schema.Array(Schema.Number).pipe(Schema.maxItems(2))

// Specifies the minimum number of items in the array
Schema.Array(Schema.Number).pipe(Schema.minItems(2))

// Specifies the exact number of items in the array
Schema.Array(Schema.Number).pipe(Schema.itemsCount(2))
```

### Date Filters

```ts

// Specifies a valid date (rejects values like `new Date("Invalid Date")`)
Schema.DateFromSelf.pipe(Schema.validDate())
// or
Schema.ValidDateFromSelf

// Specifies a date greater than the current date
Schema.Date.pipe(Schema.greaterThanDate(new Date()))

// Specifies a date greater than or equal to the current date
Schema.Date.pipe(Schema.greaterThanOrEqualToDate(new Date()))

// Specifies a date less than the current date
Schema.Date.pipe(Schema.lessThanDate(new Date()))

// Specifies a date less than or equal to the current date
Schema.Date.pipe(Schema.lessThanOrEqualToDate(new Date()))

// Specifies a date between two dates
Schema.Date.pipe(Schema.betweenDate(new Date(0), new Date()))
```

### BigInt Filters

Here is a list of useful `BigInt` filters provided by the Schema module:

```ts

// Specifies a BigInt greater than 5
Schema.BigInt.pipe(Schema.greaterThanBigInt(5n))

// Specifies a BigInt greater than or equal to 5
Schema.BigInt.pipe(Schema.greaterThanOrEqualToBigInt(5n))

// Specifies a BigInt less than 5
Schema.BigInt.pipe(Schema.lessThanBigInt(5n))

// Specifies a BigInt less than or equal to 5
Schema.BigInt.pipe(Schema.lessThanOrEqualToBigInt(5n))

// Specifies a BigInt between -2n and 2n, inclusive
Schema.BigInt.pipe(Schema.betweenBigInt(-2n, 2n))

// Specifies a positive BigInt (> 0n)
Schema.BigInt.pipe(Schema.positiveBigInt())
// or
Schema.PositiveBigIntFromSelf

// Specifies a non-negative BigInt (>= 0n)
Schema.BigInt.pipe(Schema.nonNegativeBigInt())
// or
Schema.NonNegativeBigIntFromSelf

// Specifies a negative BigInt (< 0n)
Schema.BigInt.pipe(Schema.negativeBigInt())
// or
Schema.NegativeBigIntFromSelf

// Specifies a non-positive BigInt (<= 0n)
Schema.BigInt.pipe(Schema.nonPositiveBigInt())
// or
Schema.NonPositiveBigIntFromSelf
```

### BigDecimal Filters

Here is a list of useful `BigDecimal` filters provided by the Schema module:

```ts

// Specifies a BigDecimal greater than 5
Schema.BigDecimal.pipe(
  Schema.greaterThanBigDecimal(BigDecimal.unsafeFromNumber(5))
)

// Specifies a BigDecimal greater than or equal to 5
Schema.BigDecimal.pipe(
  Schema.greaterThanOrEqualToBigDecimal(BigDecimal.unsafeFromNumber(5))
)
// Specifies a BigDecimal less than 5
Schema.BigDecimal.pipe(
  Schema.lessThanBigDecimal(BigDecimal.unsafeFromNumber(5))
)

// Specifies a BigDecimal less than or equal to 5
Schema.BigDecimal.pipe(
  Schema.lessThanOrEqualToBigDecimal(BigDecimal.unsafeFromNumber(5))
)

// Specifies a BigDecimal between -2 and 2, inclusive
Schema.BigDecimal.pipe(
  Schema.betweenBigDecimal(
    BigDecimal.unsafeFromNumber(-2),
    BigDecimal.unsafeFromNumber(2)
  )
)

// Specifies a positive BigDecimal (> 0)
Schema.BigDecimal.pipe(Schema.positiveBigDecimal())

// Specifies a non-negative BigDecimal (>= 0)
Schema.BigDecimal.pipe(Schema.nonNegativeBigDecimal())

// Specifies a negative BigDecimal (< 0)
Schema.BigDecimal.pipe(Schema.negativeBigDecimal())

// Specifies a non-positive BigDecimal (<= 0)
Schema.BigDecimal.pipe(Schema.nonPositiveBigDecimal())
```

### Duration Filters

Here is a list of useful [Duration](/docs/data-types/duration/) filters provided by the Schema module:

```ts

// Specifies a duration greater than 5 seconds
Schema.Duration.pipe(Schema.greaterThanDuration("5 seconds"))

// Specifies a duration greater than or equal to 5 seconds
Schema.Duration.pipe(Schema.greaterThanOrEqualToDuration("5 seconds"))

// Specifies a duration less than 5 seconds
Schema.Duration.pipe(Schema.lessThanDuration("5 seconds"))

// Specifies a duration less than or equal to 5 seconds
Schema.Duration.pipe(Schema.lessThanOrEqualToDuration("5 seconds"))

// Specifies a duration between 5 seconds and 10 seconds, inclusive
Schema.Duration.pipe(Schema.betweenDuration("5 seconds", "10 seconds"))
```


---

# [Schema Annotations](https://effect.website/docs/schema/annotations/)

## Overview

One of the key features of the Schema design is its flexibility and ability to be customized.
This is achieved through "annotations."
Each node in the `ast` field of a schema has an `annotations: Record<string | symbol, unknown>` field,
which allows you to attach additional information to the schema.
You can manage these annotations using the `annotations` method or the `Schema.annotations` API.

**Example** (Using Annotations to Customize Schema)

```ts

// Define a Password schema, starting with a string type
const Password = Schema.String
  // Add a custom error message for non-string values
  .annotations({ message: () => "not a string" })
  .pipe(
    // Enforce non-empty strings and provide a custom error message
    Schema.nonEmptyString({ message: () => "required" }),
    // Restrict the string length to 10 characters or fewer
    // with a custom error message for exceeding length
    Schema.maxLength(10, {
      message: (issue) => `${issue.actual} is too long`
    })
  )
  .annotations({
    // Add a unique identifier for the schema
    identifier: "Password",
    // Provide a title for the schema
    title: "password",
    // Include a description explaining what this schema represents
    description:
      "A password is a secret string used to authenticate a user",
    // Add examples for better clarity
    examples: ["1Ki77y", "jelly22fi$h"],
    // Include any additional documentation
    documentation: `...technical information on Password schema...`
  })
```

## Built-in Annotations

The following table provides an overview of common built-in annotations and their uses:

| Annotation         | Description                                                                                                                                                                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `identifier`       | Assigns a unique identifier to the schema, ideal for TypeScript identifiers and code generation purposes. Commonly used in tools like [TreeFormatter](/docs/schema/error-formatters/#customizing-the-output) to clarify output. Examples include `"Person"`, `"Product"`.           |
| `title`            | Sets a short, descriptive title for the schema, similar to a JSON Schema title. Useful for documentation or UI headings. It is also used by [TreeFormatter](/docs/schema/error-formatters/#customizing-the-output) to enhance readability of error messages.                        |
| `description`      | Provides a detailed explanation about the schema's purpose, akin to a JSON Schema description. Used by [TreeFormatter](/docs/schema/error-formatters/#customizing-the-output) to provide more detailed error messages.                                                              |
| `documentation`    | Extends detailed documentation for the schema, beneficial for developers or automated documentation generation.                                                                                                                                                                     |
| `examples`         | Lists examples of valid schema values, akin to the examples attribute in JSON Schema, useful for documentation and validation testing.                                                                                                                                              |
| `default`          | Defines a default value for the schema, similar to the default attribute in JSON Schema, to ensure schemas are pre-populated where applicable.                                                                                                                                      |
| `message`          | Customizes the error message for validation failures, improving clarity in outputs from tools like [TreeFormatter](/docs/schema/error-formatters/#customizing-the-output) and [ArrayFormatter](/docs/schema/error-formatters/#arrayformatter) during decoding or validation errors. |
| `jsonSchema`       | Specifies annotations that affect the generation of [JSON Schema](/docs/schema/json-schema/) documents, customizing how schemas are represented.                                                                                                                                    |
| `arbitrary`        | Configures settings for generating [Arbitrary](/docs/schema/arbitrary/) test data.                                                                                                                                                                                                  |
| `pretty`           | Configures settings for generating [Pretty](/docs/schema/pretty/) output.                                                                                                                                                                                                           |
| `equivalence`      | Configures settings for evaluating data [Equivalence](/docs/schema/equivalence/).                                                                                                                                                                                                   |
| `concurrency`      | Controls concurrency behavior, ensuring schemas perform optimally under concurrent operations. Refer to [Concurrency Annotation](#concurrency-annotation) for detailed usage.                                                                                                       |
| `batching`         | Manages settings for batching operations to enhance performance when operations can be grouped.                                                                                                                                                                                     |
| `parseIssueTitle`  | Provides a custom title for parsing issues, enhancing error descriptions in outputs from [TreeFormatter](/docs/schema/error-formatters/#treeformatter-default). See [ParseIssueTitle Annotation](/docs/schema/error-formatters/#parseissuetitle-annotation) for more information.   |
| `parseOptions`     | Allows overriding of parsing options at the schema level, offering granular control over parsing behaviors. See [Customizing Parsing Behavior at the Schema Level](/docs/schema/getting-started/#customizing-parsing-behavior-at-the-schema-level) for application details.         |
| `decodingFallback` | Provides a way to define custom fallback behaviors that trigger when decoding operations fail. Refer to [Handling Decoding Errors with Fallbacks](#handling-decoding-errors-with-fallbacks) for detailed usage.                                                                     |

## Concurrency Annotation

For more complex schemas like `Struct`, `Array`, or `Union` that contain multiple nested schemas, the `concurrency` annotation provides a way to control how validations are executed concurrently.

```ts
type ConcurrencyAnnotation = number | "unbounded" | "inherit" | undefined
```

Here's a shorter version presented in a table:

| Value         | Description                                                     |
| ------------- | --------------------------------------------------------------- |
| `number`      | Limits the maximum number of concurrent tasks.                  |
| `"unbounded"` | All tasks run concurrently with no limit.                       |
| `"inherit"`   | Inherits concurrency settings from the parent context.          |
| `undefined`   | Tasks run sequentially, one after the other (default behavior). |

**Example** (Sequential Execution)

In this example, we define three tasks that simulate asynchronous operations with different durations. Since no concurrency is specified, the tasks are executed sequentially, one after the other.

```ts
import type { Duration } from "effect"

// Simulates an async task
const item = (id: number, duration: Duration.DurationInput) =>
  Schema.String.pipe(
    Schema.filterEffect(() =>
      Effect.gen(function* () {
        yield* Effect.sleep(duration)
        console.log(`Task ${id} done`)
        return true
      })
    )
  )

const Sequential = Schema.Tuple(
  item(1, "30 millis"),
  item(2, "10 millis"),
  item(3, "20 millis")
)

Effect.runPromise(Schema.decode(Sequential)(["a", "b", "c"]))
/*
Output:
Task 1 done
Task 2 done
Task 3 done
*/
```

**Example** (Concurrent Execution)

By adding a `concurrency` annotation set to `"unbounded"`, the tasks can now run concurrently, meaning they don't wait for one another to finish before starting. This allows faster execution when multiple tasks are involved.

```ts
import type { Duration } from "effect"

// Simulates an async task
const item = (id: number, duration: Duration.DurationInput) =>
  Schema.String.pipe(
    Schema.filterEffect(() =>
      Effect.gen(function* () {
        yield* Effect.sleep(duration)
        console.log(`Task ${id} done`)
        return true
      })
    )
  )

const Concurrent = Schema.Tuple(
  item(1, "30 millis"),
  item(2, "10 millis"),
  item(3, "20 millis")
).annotations({ concurrency: "unbounded" })

Effect.runPromise(Schema.decode(Concurrent)(["a", "b", "c"]))
/*
Output:
Task 2 done
Task 3 done
Task 1 done
*/
```

## Handling Decoding Errors with Fallbacks

The `DecodingFallbackAnnotation` allows you to handle decoding errors by providing a custom fallback logic.

```ts
type DecodingFallbackAnnotation<A> = (
  issue: ParseIssue
) => Effect<A, ParseIssue>
```

This annotation enables you to specify fallback behavior when decoding fails, making it possible to recover gracefully from errors.

**Example** (Basic Fallback)

In this basic example, when decoding fails (e.g., the input is `null`), the fallback value is returned instead of an error.

```ts

// Schema with a fallback value
const schema = Schema.String.annotations({
  decodingFallback: () => Either.right("<fallback>")
})

console.log(Schema.decodeUnknownSync(schema)("valid input"))
// Output: valid input

console.log(Schema.decodeUnknownSync(schema)(null))
// Output: <fallback>
```

**Example** (Advanced Fallback with Logging)

In this advanced example, when a decoding error occurs, the schema logs the issue and then returns a fallback value.
This demonstrates how you can incorporate logging and other side effects during error handling.

```ts

// Schema with logging and fallback
const schemaWithLog = Schema.String.annotations({
  decodingFallback: (issue) =>
    Effect.gen(function* () {
      // Log the error issue
      yield* Effect.log(issue._tag)
      // Simulate a delay
      yield* Effect.sleep(10)
      // Return a fallback value
      return yield* Effect.succeed("<fallback>")
    })
})

// Run the effectful fallback logic
Effect.runPromise(Schema.decodeUnknown(schemaWithLog)(null)).then(
  console.log
)
/*
Output:
timestamp=2024-07-25T13:22:37.706Z level=INFO fiber=#0 message=Type
<fallback>
*/
```

## Custom Annotations

In addition to built-in annotations, you can define custom annotations to meet specific requirements. For instance, here's how to create a `deprecated` annotation:

**Example** (Defining a Custom Annotation)

```ts

// Define a unique identifier for your custom annotation
const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation"
)

// Apply the custom annotation to the schema
const MyString = Schema.String.annotations({ [DeprecatedId]: true })

console.log(MyString)
/*
Output:
[class SchemaClass] {
  ast: StringKeyword {
    annotations: {
      [Symbol(@effect/docs/schema/annotation/Title)]: 'string',
      [Symbol(@effect/docs/schema/annotation/Description)]: 'a string',
      [Symbol(some/unique/identifier/for/your/custom/annotation)]: true
    },
    _tag: 'StringKeyword'
  },
  ...
}
*/
```

To make your new custom annotation type-safe, you can use a module augmentation. In the next example, we want our custom annotation to be a boolean.

**Example** (Adding Type Safety to Custom Annotations)

```ts

const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation"
)

// Module augmentation
declare module "effect/Schema" {
  namespace Annotations {
    interface GenericSchema<A> extends Schema<A> {
      [DeprecatedId]?: boolean
    }
  }
}

const MyString = Schema.String.annotations({
// @errors: 2418
  [DeprecatedId]: "bad value"
})
```

You can retrieve custom annotations using the `SchemaAST.getAnnotation` helper function.

**Example** (Retrieving a Custom Annotation)

```ts

const DeprecatedId = Symbol.for(
  "some/unique/identifier/for/your/custom/annotation"
)

declare module "effect/Schema" {
  namespace Annotations {
    interface GenericSchema<A> extends Schema<A> {
      [DeprecatedId]?: boolean
    }
  }
}

const MyString = Schema.String.annotations({ [DeprecatedId]: true })

// Helper function to check if a schema is marked as deprecated
const isDeprecated = <A, I, R>(schema: Schema.Schema<A, I, R>): boolean =>
  SchemaAST.getAnnotation<boolean>(DeprecatedId)(schema.ast).pipe(
    Option.getOrElse(() => false)
  )

console.log(isDeprecated(Schema.String))
// Output: false

console.log(isDeprecated(MyString))
// Output: true
```


---

# [Error Messages](https://effect.website/docs/schema/error-messages/)

## Overview

## Default Error Messages

By default, when a parsing error occurs, the system automatically generates an informative message based on the schema's structure and the nature of the error (see [TreeFormatter](/docs/schema/error-formatters/#treeformatter-default) for more informations).
For example, if a required property is missing or a data type does not match, the error message will clearly state the expectation versus the actual input.

**Example** (Type Mismatch)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

Schema.decodeUnknownSync(Person)(null)
// Output: ParseError: Expected { readonly name: string; readonly age: number }, actual null
```

**Example** (Missing Properties)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

Schema.decodeUnknownSync(Person)({}, { errors: "all" })
/*
throws:
ParseError: { readonly name: string; readonly age: number }
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/
```

**Example** (Incorrect Property Type)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

Schema.decodeUnknownSync(Person)(
  { name: null, age: "age" },
  { errors: "all" }
)
/*
throws:
ParseError: { readonly name: string; readonly age: number }
├─ ["name"]
│  └─ Expected string, actual null
└─ ["age"]
   └─ Expected number, actual "age"
*/
```

### Enhancing Clarity in Error Messages with Identifiers

In scenarios where a schema has multiple fields or nested structures, the default error messages can become overly complex and verbose.
To address this, you can enhance the clarity and brevity of these messages by utilizing annotations such as `identifier`, `title`, and `description`.

**Example** (Using Identifiers for Clarity)

```ts

const Name = Schema.String.annotations({ identifier: "Name" })

const Age = Schema.Number.annotations({ identifier: "Age" })

const Person = Schema.Struct({
  name: Name,
  age: Age
}).annotations({ identifier: "Person" })

Schema.decodeUnknownSync(Person)(null)
/*
throws:
ParseError: Expected Person, actual null
*/

Schema.decodeUnknownSync(Person)({}, { errors: "all" })
/*
throws:
ParseError: Person
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/

Schema.decodeUnknownSync(Person)(
  { name: null, age: null },
  { errors: "all" }
)
/*
throws:
ParseError: Person
├─ ["name"]
│  └─ Expected Name, actual null
└─ ["age"]
   └─ Expected Age, actual null
*/
```

### Refinements

When a refinement fails, the default error message indicates whether the failure occurred in the "from" part or within the predicate defining the refinement:

**Example** (Refinement Errors)

```ts

const Name = Schema.NonEmptyString.annotations({ identifier: "Name" })

const Age = Schema.Positive.pipe(Schema.int({ identifier: "Age" }))

const Person = Schema.Struct({
  name: Name,
  age: Age
}).annotations({ identifier: "Person" })

// From side failure
Schema.decodeUnknownSync(Person)({ name: null, age: 18 })
/*
throws:
ParseError: Person
└─ ["name"]
   └─ Name
      └─ From side refinement failure
         └─ Expected string, actual null
*/

// Predicate refinement failure
Schema.decodeUnknownSync(Person)({ name: "", age: 18 })
/*
throws:
ParseError: Person
└─ ["name"]
   └─ Name
      └─ Predicate refinement failure
         └─ Expected a non empty string, actual ""
*/
```

In the first example, the error message indicates a "from side" refinement failure in the `name` property, specifying that a string was expected but received `null`.
In the second example, a "predicate" refinement failure is reported, indicating that a non-empty string was expected for `name` but an empty string was provided.

### Transformations

Transformations between different types or formats can occasionally result in errors.
The system provides a structured error message to specify where the error occurred:

- **Encoded Side Failure:** Errors on this side typically indicate that the input to the transformation does not match the expected initial type or format. For example, receiving a `null` when a `string` is expected.
- **Transformation Process Failure:** This type of error arises when the transformation logic itself fails, such as when the input does not meet the criteria specified within the transformation functions.
- **Type Side Failure:** Occurs when the output of a transformation does not meet the schema requirements on the decoded side. This can happen if the transformed value fails subsequent validations or conditions.

**Example** (Transformation Errors)

```ts

const schema = Schema.transformOrFail(
  Schema.String,
  Schema.String.pipe(Schema.minLength(2)),
  {
    strict: true,
    decode: (s, _, ast) =>
      s.length > 0
        ? ParseResult.succeed(s)
        : ParseResult.fail(new ParseResult.Type(ast, s)),
    encode: ParseResult.succeed
  }
)

// Encoded side failure
Schema.decodeUnknownSync(schema)(null)
/*
throws:
ParseError: (string <-> minLength(2))
└─ Encoded side transformation failure
   └─ Expected string, actual null
*/

// transformation failure
Schema.decodeUnknownSync(schema)("")
/*
throws:
ParseError: (string <-> minLength(2))
└─ Transformation process failure
   └─ Expected (string <-> minLength(2)), actual ""
*/

// Type side failure
Schema.decodeUnknownSync(schema)("a")
/*
throws:
ParseError: (string <-> minLength(2))
└─ Type side transformation failure
   └─ minLength(2)
      └─ Predicate refinement failure
         └─ Expected a string at least 2 character(s) long, actual "a"
*/
```

## Custom Error Messages

You have the capability to define custom error messages specifically tailored for different parts of your schema using the `message` annotation.
This allows developers to provide more context-specific feedback which can improve the debugging and validation processes.

Here's an overview of the `MessageAnnotation` type, which you can use to craft these messages:

```ts
type MessageAnnotation = (issue: ParseIssue) =>
  | string
  | Effect<string>
  | {
      readonly message: string | Effect<string>
      readonly override: boolean
    }
```

| Return Type                            | Description                                                                                                                                                                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `string`                               | Provides a static message that directly describes the error.                                                                                                                                                                                                 |
| `Effect<string>`                       | Utilizes dynamic messages that can incorporate results from **synchronous** processes or rely on **optional** dependencies.                                                                                                                                  |
| Object (with `message` and `override`) | Allows you to define a specific error message along with a boolean flag (`override`). This flag determines if the custom message should supersede any default or nested custom messages, providing precise control over the error output displayed to users. |

**Example** (Adding a Custom Error Message to a String Schema)

```ts

// Define a string schema without a custom message
const MyString = Schema.String

// Attempt to decode `null`, resulting in a default error message
Schema.decodeUnknownSync(MyString)(null)
/*
throws:
ParseError: Expected string, actual null
*/

// Define a string schema with a custom error message
const MyStringWithMessage = Schema.String.annotations({
  message: () => "not a string"
})

// Decode with the custom schema, showing the new error message
Schema.decodeUnknownSync(MyStringWithMessage)(null)
/*
throws:
ParseError: not a string
*/
```

**Example** (Custom Error Message for a Union Schema with Override Option)

```ts

// Define a union schema without a custom message
const MyUnion = Schema.Union(Schema.String, Schema.Number)

// Decode `null`, resulting in default union error messages
Schema.decodeUnknownSync(MyUnion)(null)
/*
throws:
ParseError: string | number
├─ Expected string, actual null
└─ Expected number, actual null
*/

// Define a union schema with a custom message and override flag
const MyUnionWithMessage = Schema.Union(
  Schema.String,
  Schema.Number
).annotations({
  message: () => ({
    message: "Please provide a string or a number",
    // Ensures this message replaces all nested messages
    override: true
  })
})

// Decode with the custom schema, showing the new error message
Schema.decodeUnknownSync(MyUnionWithMessage)(null)
/*
throws:
ParseError: Please provide a string or a number
*/
```

### General Guidelines for Messages

The general logic followed to determine the messages is as follows:

1. If no custom messages are set, the default message related to the innermost schema where the operation (i.e., decoding or encoding) failed is used.

2. If custom messages are set, then the message corresponding to the **first** failed schema is used, starting from the innermost schema to the outermost. However, if the failing schema does not have a custom message, then **the default message is used**.

3. As an opt-in feature, **you can override guideline 2** by setting the `override` flag to `true`. This allows the custom message to take precedence over all other custom messages from inner schemas. This is to address the scenario where a user wants to define a single cumulative custom message describing the properties that a valid value must have and does not want to see default messages.

Let's see some practical examples.

### Scalar Schemas

**Example** (Simple Custom Message for Scalar Schema)

```ts

const MyString = Schema.String.annotations({
  message: () => "my custom message"
})

const decode = Schema.decodeUnknownSync(MyString)

try {
  decode(null)
} catch (e: any) {
  console.log(e.message) // "my custom message"
}
```

### Refinements

This example demonstrates setting a custom message on the last refinement in a chain of refinements. As you can see, the custom message is only used if the refinement related to `maxLength` fails; otherwise, default messages are used.

**Example** (Custom Message on Last Refinement in Chain)

```ts

const MyString = Schema.String.pipe(
  Schema.minLength(1),
  Schema.maxLength(2)
).annotations({
  // This message is displayed only if the last filter (`maxLength`) fails
  message: () => "my custom message"
})

const decode = Schema.decodeUnknownSync(MyString)

try {
  decode(null)
} catch (e: any) {
  console.log(e.message)
  /*
   minLength(1) & maxLength(2)
   └─ From side refinement failure
      └─ minLength(1)
         └─ From side refinement failure
            └─ Expected string, actual null
  */
}

try {
  decode("")
} catch (e: any) {
  console.log(e.message)
  /*
   minLength(1) & maxLength(2)
   └─ From side refinement failure
      └─ minLength(1)
         └─ Predicate refinement failure
            └─ Expected a string at least 1 character(s) long, actual ""
  */
}

try {
  decode("abc")
} catch (e: any) {
  console.log(e.message)
  // "my custom message"
}
```

When setting multiple custom messages, the one corresponding to the **first** failed predicate is used, starting from the innermost refinement to the outermost:

**Example** (Custom Messages for Multiple Refinements)

```ts

const MyString = Schema.String
  // This message is displayed only if a non-String is passed as input
  .annotations({ message: () => "String custom message" })
  .pipe(
    // This message is displayed only if the filter `minLength` fails
    Schema.minLength(1, { message: () => "minLength custom message" }),
    // This message is displayed only if the filter `maxLength` fails
    Schema.maxLength(2, { message: () => "maxLength custom message" })
  )

const decode = Schema.decodeUnknownSync(MyString)

try {
  decode(null)
} catch (e: any) {
  console.log(e.message) // String custom message
}

try {
  decode("")
} catch (e: any) {
  console.log(e.message) // minLength custom message
}

try {
  decode("abc")
} catch (e: any) {
  console.log(e.message) // maxLength custom message
}
```

You have the option to change the default behavior by setting the `override` flag to `true`. This is useful when you want to create a single comprehensive custom message that describes the required properties of a valid value without displaying default messages.

**Example** (Overriding Default Messages)

```ts

const MyString = Schema.String.pipe(
  Schema.minLength(1),
  Schema.maxLength(2)
).annotations({
  // By setting the `override` flag to `true`, this message will always be shown for any error
  message: () => ({ message: "my custom message", override: true })
})

const decode = Schema.decodeUnknownSync(MyString)

try {
  decode(null)
} catch (e: any) {
  console.log(e.message) // my custom message
}

try {
  decode("")
} catch (e: any) {
  console.log(e.message) // my custom message
}

try {
  decode("abc")
} catch (e: any) {
  console.log(e.message) // my custom message
}
```

### Transformations

In this example, `IntFromString` is a transformation schema that converts strings to integers. It applies specific validation messages based on different scenarios.

**Example** (Custom Error Messages for String-to-Integer Transformation)

```ts

const IntFromString = Schema.transformOrFail(
  // This message is displayed only if the input is not a string
  Schema.String.annotations({ message: () => "please enter a string" }),
  // This message is displayed only if the input can be converted
  // to a number but it's not an integer
  Schema.Int.annotations({ message: () => "please enter an integer" }),
  {
    strict: true,
    decode: (s, _, ast) => {
      const n = Number(s)
      return Number.isNaN(n)
        ? ParseResult.fail(new ParseResult.Type(ast, s))
        : ParseResult.succeed(n)
    },
    encode: (n) => ParseResult.succeed(String(n))
  }
)
  // This message is displayed only if the input
  // cannot be converted to a number
  .annotations({ message: () => "please enter a parseable string" })

const decode = Schema.decodeUnknownSync(IntFromString)

try {
  decode(null)
} catch (e: any) {
  console.log(e.message) // please enter a string
}

try {
  decode("1.2")
} catch (e: any) {
  console.log(e.message) // please enter an integer
}

try {
  decode("not a number")
} catch (e: any) {
  console.log(e.message) // please enter a parseable string
}
```

### Compound Schemas

The custom message system becomes especially handy when dealing with complex schemas, unlike simple scalar values like `string` or `number`. For instance, consider a schema comprising nested structures, such as a struct containing an array of other structs. Let's explore an example demonstrating the advantage of default messages in handling decoding errors within such nested structures:

**Example** (Custom Error Messages in Nested Schemas)

```ts

const schema = Schema.Struct({
  outcomes: pipe(
    Schema.Array(
      Schema.Struct({
        id: Schema.String,
        text: pipe(
          Schema.String.annotations({
            message: () => "error_invalid_outcome_type"
          }),
          Schema.minLength(1, { message: () => "error_required_field" }),
          Schema.maxLength(50, {
            message: () => "error_max_length_field"
          })
        )
      })
    ),
    Schema.minItems(1, { message: () => "error_min_length_field" })
  )
})

Schema.decodeUnknownSync(schema, { errors: "all" })({
  outcomes: []
})
/*
throws
ParseError: { readonly outcomes: minItems(1) }
└─ ["outcomes"]
   └─ error_min_length_field
*/

Schema.decodeUnknownSync(schema, { errors: "all" })({
  outcomes: [
    { id: "1", text: "" },
    { id: "2", text: "this one is valid" },
    { id: "3", text: "1234567890".repeat(6) }
  ]
})
/*
throws
ParseError: { readonly outcomes: minItems(1) }
└─ ["outcomes"]
   └─ minItems(1)
      └─ From side refinement failure
         └─ ReadonlyArray<{ readonly id: string; readonly text: minLength(1) & maxLength(50) }>
            ├─ [0]
            │  └─ { readonly id: string; readonly text: minLength(1) & maxLength(50) }
            │     └─ ["text"]
            │        └─ error_required_field
            └─ [2]
               └─ { readonly id: string; readonly text: minLength(1) & maxLength(50) }
                  └─ ["text"]
                     └─ error_max_length_field
*/
```

### Effectful messages

Error messages can go beyond simple strings by returning an `Effect`, allowing them to access dependencies, such as an internationalization service. This approach lets messages dynamically adjust based on external context or services. Below is an example illustrating how to create effect-based messages.

**Example** (Effect-Based Message with Internationalization Service)

```ts
import {
  Context,
  Effect,
  Either,
  Option,
  Schema,
  ParseResult
} from "effect"

// Define an internationalization service for custom messages
class Messages extends Context.Tag("Messages")<
  Messages,
  {
    NonEmpty: string
  }
>() {}

// Define a schema with an effect-based message
// that depends on the Messages service
const Name = Schema.NonEmptyString.annotations({
  message: () =>
    Effect.gen(function* () {
      // Attempt to retrieve the Messages service
      const service = yield* Effect.serviceOption(Messages)
      // Use a fallback message if the service is not available
      return Option.match(service, {
        onNone: () => "Invalid string",
        onSome: (messages) => messages.NonEmpty
      })
    })
})

// Attempt to decode an empty string without providing the Messages service
Schema.decodeUnknownEither(Name)("").pipe(
  Either.mapLeft((error) =>
    ParseResult.TreeFormatter.formatError(error).pipe(
      Effect.runSync,
      console.log
    )
  )
)
// Output: Invalid string

// Provide the Messages service to customize the error message
Schema.decodeUnknownEither(Name)("").pipe(
  Either.mapLeft((error) =>
    ParseResult.TreeFormatter.formatError(error).pipe(
      Effect.provideService(Messages, {
        NonEmpty: "should be non empty"
      }),
      Effect.runSync,
      console.log
    )
  )
)
// Output: should be non empty
```

### Missing messages

You can provide custom messages for missing fields or tuple elements using the `missingMessage` annotation.

**Example** (Custom Message for Missing Property)

In this example, a custom message is defined for a missing `name` property in the `Person` schema.

```ts

const Person = Schema.Struct({
  name: Schema.propertySignature(Schema.String).annotations({
    // Custom message if "name" is missing
    missingMessage: () => "Name is required"
  })
})

Schema.decodeUnknownSync(Person)({})
/*
throws:
ParseError: { readonly name: string }
└─ ["name"]
   └─ Name is required
*/
```

**Example** (Custom Message for Missing Tuple Elements)

Here, each element in the `Point` tuple schema has a specific custom message if the element is missing.

```ts

const Point = Schema.Tuple(
  Schema.element(Schema.Number).annotations({
    // Message if X is missing
    missingMessage: () => "X coordinate is required"
  }),
  Schema.element(Schema.Number).annotations({
    // Message if Y is missing
    missingMessage: () => "Y coordinate is required"
  })
)

Schema.decodeUnknownSync(Point)([], { errors: "all" })
/*
throws:
ParseError: readonly [number, number]
├─ [0]
│  └─ X coordinate is required
└─ [1]
   └─ Y coordinate is required
*/
```


---

# [Error Formatters](https://effect.website/docs/schema/error-formatters/)

## Overview

When working with Effect Schema, errors encountered during decoding or encoding operations can be formatted using two built-in methods: `TreeFormatter` and `ArrayFormatter`. These formatters help structure and present errors in a readable and actionable manner.

## TreeFormatter (default)

The `TreeFormatter` is the default method for formatting errors. It organizes errors in a tree structure, providing a clear hierarchy of issues.

**Example** (Decoding with Missing Properties)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decodeUnknownEither(Person)

const result = decode({})
if (Either.isLeft(result)) {
  console.error("Decoding failed:")
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left))
}
/*
Decoding failed:
{ readonly name: string; readonly age: number }
└─ ["name"]
   └─ is missing
*/
```

In this example:

- `{ readonly name: string; readonly age: number }` describes the schema's expected structure.
- `["name"]` identifies the specific field causing the error.
- `is missing` explains the issue for the `"name"` field.

### Customizing the Output

You can make the error output more concise and meaningful by annotating the schema with annotations like `identifier`, `title`, or `description`. These annotations replace the default TypeScript-like representation in the error messages.

**Example** (Using `title` Annotation for Clarity)

Adding a `title` annotation replaces the schema structure in the error message with the more human-readable "Person" making it easier to understand.

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
}).annotations({ title: "Person" }) // Add a title annotation

const result = Schema.decodeUnknownEither(Person)({})
if (Either.isLeft(result)) {
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left))
}
/*
Person
└─ ["name"]
   └─ is missing
*/
```

### Handling Multiple Errors

By default, decoding functions like `Schema.decodeUnknownEither` report only the first error. To list all errors, use the `{ errors: "all" }` option.

**Example** (Listing All Errors)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decodeUnknownEither(Person, { errors: "all" })

const result = decode({})
if (Either.isLeft(result)) {
  console.error("Decoding failed:")
  console.error(ParseResult.TreeFormatter.formatErrorSync(result.left))
}
/*
Decoding failed:
{ readonly name: string; readonly age: number }
├─ ["name"]
│  └─ is missing
└─ ["age"]
   └─ is missing
*/
```

### ParseIssueTitle Annotation

The `parseIssueTitle` annotation allows you to add dynamic context to error messages by generating titles based on the value being validated. For instance, it can include an ID from the validated object, making it easier to identify specific issues in complex or nested data structures.

**Annotation Type**

```ts
export type ParseIssueTitleAnnotation = (
  issue: ParseIssue
) => string | undefined
```

**Return Value**:

- If the function returns a `string`, the `TreeFormatter` uses it as the title unless a `message` annotation is present (which takes precedence).
- If the function returns `undefined`, the `TreeFormatter` determines the title based on the following priority:
  1. `identifier` annotation
  2. `title` annotation
  3. `description` annotation
  4. Default TypeScript-like schema representation

**Example** (Dynamic Titles Using `parseIssueTitle`)

```ts
import type { ParseResult } from "effect"

// Function to generate titles for OrderItem issues
const getOrderItemId = ({ actual }: ParseResult.ParseIssue) => {
  if (Schema.is(Schema.Struct({ id: Schema.String }))(actual)) {
    return `OrderItem with id: ${actual.id}`
  }
}

const OrderItem = Schema.Struct({
  id: Schema.String,
  name: Schema.String,
  price: Schema.Number
}).annotations({
  identifier: "OrderItem",
  parseIssueTitle: getOrderItemId
})

// Function to generate titles for Order issues
const getOrderId = ({ actual }: ParseResult.ParseIssue) => {
  if (Schema.is(Schema.Struct({ id: Schema.Number }))(actual)) {
    return `Order with id: ${actual.id}`
  }
}

const Order = Schema.Struct({
  id: Schema.Number,
  name: Schema.String,
  items: Schema.Array(OrderItem)
}).annotations({
  identifier: "Order",
  parseIssueTitle: getOrderId
})

const decode = Schema.decodeUnknownSync(Order, { errors: "all" })

// Case 1: No id available, uses the `identifier` annotation
decode({})
/*
throws
ParseError: Order
├─ ["id"]
│  └─ is missing
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ is missing
*/

// Case 2: ID present, uses the dynamic `parseIssueTitle` annotation
decode({ id: 1 })
/*
throws
ParseError: Order with id: 1
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ is missing
*/

// Case 3: Nested issues with IDs for both Order and OrderItem
decode({ id: 1, items: [{ id: "22b", price: "100" }] })
/*
throws
ParseError: Order with id: 1
├─ ["name"]
│  └─ is missing
└─ ["items"]
   └─ ReadonlyArray<OrderItem>
      └─ [0]
         └─ OrderItem with id: 22b
            ├─ ["name"]
            │  └─ is missing
            └─ ["price"]
               └─ Expected a number, actual "100"
*/
```

## ArrayFormatter

The `ArrayFormatter` provides a structured, array-based approach to formatting errors. It represents each error as an object, making it easier to analyze and address multiple issues during data decoding or encoding. Each error object includes properties like `_tag`, `path`, and `message` for clarity.

**Example** (Single Error in Array Format)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decodeUnknownEither(Person)

const result = decode({})
if (Either.isLeft(result)) {
  console.error("Decoding failed:")
  console.error(ParseResult.ArrayFormatter.formatErrorSync(result.left))
}
/*
Decoding failed:
[ { _tag: 'Missing', path: [ 'name' ], message: 'is missing' } ]
*/
```

In this example:

- `_tag`: Indicates the type of error (`Missing`).
- `path`: Specifies the location of the error in the data (`['name']`).
- `message`: Describes the issue (`'is missing'`).

### Handling Multiple Errors

By default, decoding functions like `Schema.decodeUnknownEither` report only the first error. To list all errors, use the `{ errors: "all" }` option.

**Example** (Listing All Errors)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decodeUnknownEither(Person, { errors: "all" })

const result = decode({})
if (Either.isLeft(result)) {
  console.error("Decoding failed:")
  console.error(ParseResult.ArrayFormatter.formatErrorSync(result.left))
}
/*
Decoding failed:
[
  { _tag: 'Missing', path: [ 'name' ], message: 'is missing' },
  { _tag: 'Missing', path: [ 'age' ], message: 'is missing' }
]
*/
```

## React Hook Form

If you are working with React and need form validation, `@hookform/resolvers` offers an adapter for `effect/Schema`, which can be integrated with React Hook Form for enhanced form validation processes. This integration allows you to leverage the powerful features of `effect/Schema` within your React applications.

For more detailed instructions and examples on how to integrate `effect/Schema` with React Hook Form using `@hookform/resolvers`, you can visit the official npm package page:
[React Hook Form Resolvers](https://www.npmjs.com/package/@hookform/resolvers#effect-ts)


---

# [Schema Projections](https://effect.website/docs/schema/projections/)

## Overview

Sometimes, you may want to create a new schema based on an existing one, focusing specifically on either its `Type` or `Encoded` aspect. The Schema module provides several functions to make this possible.

## typeSchema

The `Schema.typeSchema` function is used to extract the `Type` portion of a schema, resulting in a new schema that retains only the type-specific properties from the original schema. This excludes any initial encoding or transformation logic applied to the original schema.

**Function Signature**

```ts
declare const typeSchema: <A, I, R>(schema: Schema<A, I, R>) => Schema<A>
```

**Example** (Extracting Only Type-Specific Properties)

```ts

const Original = Schema.Struct({
  quantity: Schema.NumberFromString.pipe(Schema.greaterThanOrEqualTo(2))
})

// This creates a schema where 'quantity' is defined as a number
// that must be greater than or equal to 2.
const TypeSchema = Schema.typeSchema(Original)

// TypeSchema is equivalent to:
const TypeSchema2 = Schema.Struct({
  quantity: Schema.Number.pipe(Schema.greaterThanOrEqualTo(2))
})
```

## encodedSchema

The `Schema.encodedSchema` function enables you to extract the `Encoded` portion of a schema, creating a new schema that matches the original properties but **omits any refinements or transformations** applied to the schema.

**Function Signature**

```ts
declare const encodedSchema: <A, I, R>(
  schema: Schema<A, I, R>
) => Schema<I>
```

**Example** (Extracting Encoded Properties Only)

```ts

const Original = Schema.Struct({
  quantity: Schema.String.pipe(Schema.minLength(3))
})

// This creates a schema where 'quantity' is just a string,
// disregarding the minLength refinement.
const Encoded = Schema.encodedSchema(Original)

// Encoded is equivalent to:
const Encoded2 = Schema.Struct({
  quantity: Schema.String
})
```

## encodedBoundSchema

The `Schema.encodedBoundSchema` function is similar to `Schema.encodedSchema` but preserves the refinements up to the first transformation point in the
original schema.

**Function Signature**

```ts
declare const encodedBoundSchema: <A, I, R>(
  schema: Schema<A, I, R>
) => Schema<I>
```

The term "bound" in this context refers to the boundary up to which refinements are preserved when extracting the encoded form of a schema. It essentially marks the limit to which initial validations and structure are maintained before any transformations are applied.

**Example** (Retaining Initial Refinements Only)

```ts

const Original = Schema.Struct({
  foo: Schema.String.pipe(
    Schema.minLength(3),
    Schema.compose(Schema.Trim)
  )
})

// The EncodedBoundSchema schema preserves the minLength(3) refinement,
// ensuring the string length condition is enforced
// but omits the Schema.Trim transformation.
const EncodedBoundSchema = Schema.encodedBoundSchema(Original)

// EncodedBoundSchema is equivalent to:
const EncodedBoundSchema2 = Schema.Struct({
  foo: Schema.String.pipe(Schema.minLength(3))
})
```


---

# [Schema to JSON Schema](https://effect.website/docs/schema/json-schema/)

## Overview

The `JSONSchema.make` function allows you to generate a JSON Schema from a schema.

**Example** (Creating a JSON Schema for a Struct)

The following example defines a `Person` schema with properties for `name` (a string) and `age` (a number). It then generates the corresponding JSON Schema.

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const jsonSchema = JSONSchema.make(Person)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "additionalProperties": false
}
*/
```

The `JSONSchema.make` function aims to produce an optimal JSON Schema representing the input part of the decoding phase.
It does this by traversing the schema from the most nested component, incorporating each refinement, and **stops at the first transformation** encountered.

**Example** (Excluding Transformations in JSON Schema)

Consider modifying the `age` field to include both a refinement and a transformation. Only the refinement is reflected in the JSON Schema.

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number.pipe(
    // Refinement included in the JSON Schema
    Schema.int(),
    // Transformation excluded from the JSON Schema
    Schema.clamp(1, 10)
  )
})

const jsonSchema = JSONSchema.make(Person)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "integer",
      "description": "an integer",
      "title": "integer"
    }
  },
  "additionalProperties": false
}
*/
```

In this case, the JSON Schema reflects the integer refinement but does not include the transformation that clamps the value.

## Targeting a Specific JSON Schema Version

By default, `JSONSchema.make` generates a JSON Schema compatible with **Draft 07**. You can change the target schema version by passing an options object with a `target` property. The supported targets are:

- `"jsonSchema7"` (default) - JSON Schema Draft 07
- `"jsonSchema2019-09"` - JSON Schema Draft 2019-09
- `"jsonSchema2020-12"` - JSON Schema Draft 2020-12
- `"openApi3.1"` - OpenAPI 3.1

Changing the target can affect the generated output. For example, tuple schemas use `items` and `additionalItems` in Draft 07, whereas Draft 2020-12 uses `prefixItems` and `items`.

**Example** (Using JSON Schema 2020-12 for a Tuple)

```ts

const schema = Schema.Tuple(Schema.String, Schema.Number)

const jsonSchema = JSONSchema.make(schema, {
  target: "jsonSchema2020-12"
})

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "array",
  "minItems": 2,
  "prefixItems": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ],
  "items": false
}
*/
```

## Specific Outputs for Schema Types

### Literals

Literals are transformed into `enum` types within JSON Schema.

**Example** (Single Literal)

```ts

const schema = Schema.Literal("a")

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a"
  ]
}
*/
```

**Example** (Union of literals)

```ts

const schema = Schema.Literal("a", "b")

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a",
    "b"
  ]
}
*/
```

### Void

```ts

const schema = Schema.Void

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/void",
  "title": "void"
}
*/
```

### Any

```ts

const schema = Schema.Any

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/any",
  "title": "any"
}
*/
```

### Unknown

```ts

const schema = Schema.Unknown

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/unknown",
  "title": "unknown"
}
*/
```

### Object

```ts

const schema = Schema.Object

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "/schemas/object",
  "anyOf": [
    {
      "type": "object"
    },
    {
      "type": "array"
    }
  ],
  "description": "an object in the TypeScript meaning, i.e. the `object` type",
  "title": "object"
}
*/
```

### String

```ts

const schema = Schema.String

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string"
}
*/
```

### Number

```ts

const schema = Schema.Number

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number"
}
*/
```

### Boolean

```ts

const schema = Schema.Boolean

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "boolean"
}
*/
```

### Tuples

```ts

const schema = Schema.Tuple(Schema.String, Schema.Number)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "minItems": 2,
  "items": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ],
  "additionalItems": false
}
*/
```

### Arrays

```ts

const schema = Schema.Array(Schema.String)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "items": {
    "type": "string"
  }
}
*/
```

### Non Empty Arrays

Represents an array with at least one element.

**Example**

```ts

const schema = Schema.NonEmptyArray(Schema.String)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "array",
  "minItems": 1,
  "items": {
    "type": "string"
  }
}
*/
```

### Structs

```ts

const schema = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "additionalProperties": false
}
*/
```

### Records

```ts

const schema = Schema.Record({
  key: Schema.String,
  value: Schema.Number
})

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [],
  "properties": {},
  "patternProperties": {
    "": {
      "type": "number"
    }
  }
}
*/
```

### Mixed Structs with Records

Combines fixed properties from a struct with dynamic properties from a record.

**Example**

```ts

const schema = Schema.Struct(
  {
    name: Schema.String,
    age: Schema.Number
  },
  Schema.Record({
    key: Schema.String,
    value: Schema.Union(Schema.String, Schema.Number)
  })
)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "type": "string"
    },
    "age": {
      "type": "number"
    }
  },
  "patternProperties": {
    "": {
      "anyOf": [
        {
          "type": "string"
        },
        {
          "type": "number"
        }
      ]
    }
  }
}
*/
```

### Enums

```ts

enum Fruits {
  Apple,
  Banana
}

const schema = Schema.Enums(Fruits)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$comment": "/schemas/enums",
  "anyOf": [
    {
      "type": "number",
      "title": "Apple",
      "enum": [
        0
      ]
    },
    {
      "type": "number",
      "title": "Banana",
      "enum": [
        1
      ]
    }
  ]
}
*/
```

### Template Literals

```ts

const schema = Schema.TemplateLiteral(Schema.Literal("a"), Schema.Number)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "title": "`a${number}`",
  "description": "a template literal",
  "pattern": "^a[+-]?\\d*\\.?\\d+(?:[Ee][+-]?\\d+)?$"
}
*/
```

### Unions

Unions are expressed using `anyOf` or `enum`, depending on the types involved:

**Example** (Generic Union)

```ts

const schema = Schema.Union(Schema.String, Schema.Number)

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "anyOf": [
    {
      "type": "string"
    },
    {
      "type": "number"
    }
  ]
}
*/
```

**Example** (Union of literals)

```ts

const schema = Schema.Literal("a", "b")

console.log(JSON.stringify(JSONSchema.make(schema), null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "enum": [
    "a",
    "b"
  ]
}
*/
```

## Identifier Annotations

You can add `identifier` annotations to schemas to improve structure and maintainability. Annotated schemas are included in a `$defs` object in the root of the JSON Schema and referenced from there.

**Example** (Using Identifier Annotations)

```ts

const Name = Schema.String.annotations({ identifier: "Name" })

const Age = Schema.Number.annotations({ identifier: "Age" })

const Person = Schema.Struct({
  name: Name,
  age: Age
})

const jsonSchema = JSONSchema.make(Person)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "Name": {
      "type": "string",
      "description": "a string",
      "title": "string"
    },
    "Age": {
      "type": "number",
      "description": "a number",
      "title": "number"
    }
  },
  "type": "object",
  "required": [
    "name",
    "age"
  ],
  "properties": {
    "name": {
      "$ref": "#/$defs/Name"
    },
    "age": {
      "$ref": "#/$defs/Age"
    }
  },
  "additionalProperties": false
}
*/
```

By using identifier annotations, schemas can be reused and referenced more easily, especially in complex JSON Schemas.

## Standard JSON Schema Annotations

Standard JSON Schema annotations such as `title`, `description`, `default`, and `examples` are supported.
These annotations allow you to enrich your schemas with metadata that can enhance readability and provide additional information about the data structure.

**Example** (Using Annotations for Metadata)

```ts

const schema = Schema.String.annotations({
  description: "my custom description",
  title: "my custom title",
  default: "",
  examples: ["a", "b"]
})

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "string",
  "description": "my custom description",
  "title": "my custom title",
  "examples": [
    "a",
    "b"
  ],
  "default": ""
}
*/
```

### Adding annotations to Struct properties

To enhance the clarity of your JSON schemas, it's advisable to add annotations directly to the property signatures rather than to the type itself.
This method is more semantically appropriate as it links descriptive titles and other metadata specifically to the properties they describe, rather than to the generic type.

**Example** (Annotated Struct Properties)

```ts

const Person = Schema.Struct({
  firstName: Schema.propertySignature(Schema.String).annotations({
    title: "First name"
  }),
  lastName: Schema.propertySignature(Schema.String).annotations({
    title: "Last Name"
  })
})

const jsonSchema = JSONSchema.make(Person)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "firstName",
    "lastName"
  ],
  "properties": {
    "firstName": {
      "type": "string",
      "title": "First name"
    },
    "lastName": {
      "type": "string",
      "title": "Last Name"
    }
  },
  "additionalProperties": false
}
*/
```

## Recursive and Mutually Recursive Schemas

Recursive and mutually recursive schemas are supported, however it's **mandatory** to use `identifier` annotations for these types of schemas to ensure correct references and definitions within the generated JSON Schema.

**Example** (Recursive Schema with Identifier Annotations)

In this example, the `Category` schema refers to itself, making it necessary to use an `identifier` annotation to facilitate the reference.

```ts

// Define the interface representing a category structure
interface Category {
  readonly name: string
  readonly categories: ReadonlyArray<Category>
}

// Define a recursive schema with a required identifier annotation
const Category = Schema.Struct({
  name: Schema.String,
  categories: Schema.Array(
    // Recursive reference to the Category schema
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
}).annotations({ identifier: "Category" })

const jsonSchema = JSONSchema.make(Category)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$defs": {
    "Category": {
      "type": "object",
      "required": [
        "name",
        "categories"
      ],
      "properties": {
        "name": {
          "type": "string"
        },
        "categories": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/Category"
          }
        }
      },
      "additionalProperties": false
    }
  },
  "$ref": "#/$defs/Category"
}
*/
```

## Customizing JSON Schema Generation

When working with JSON Schema certain data types, such as `bigint`, lack a direct representation because JSON Schema does not natively support them.
This absence typically leads to an error when the schema is generated.

**Example** (Error Due to Missing Annotation)

Attempting to generate a JSON Schema for unsupported types like `bigint` will lead to a missing annotation error:

```ts

const schema = Schema.Struct({
  a_bigint_field: Schema.BigIntFromSelf
})

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
throws:
Error: Missing annotation
at path: ["a_bigint_field"]
details: Generating a JSON Schema for this schema requires a "jsonSchema" annotation
schema (BigIntKeyword): bigint
*/
```

To address this, you can enhance the schema with a custom `jsonSchema` annotation, defining how you intend to represent such types in JSON Schema:

**Example** (Using Custom Annotation for Unsupported Type)

```ts

const schema = Schema.Struct({
  // Adding a custom JSON Schema annotation for the `bigint` type
  a_bigint_field: Schema.BigIntFromSelf.annotations({
    jsonSchema: {
      type: "some custom way to represent a bigint in JSON Schema"
    }
  })
})

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "a_bigint_field"
  ],
  "properties": {
    "a_bigint_field": {
      "type": "some custom way to represent a bigint in JSON Schema"
    }
  },
  "additionalProperties": false
}
*/
```

### Refinements

When defining a refinement (e.g., through the `Schema.filter` function), you can include a JSON Schema annotation to describe the refinement. This annotation is added as a "fragment" that becomes part of the generated JSON Schema. If a schema contains multiple refinements, their respective annotations are merged into the output.

**Example** (Using Refinements with Merged Annotations)

```ts

// Define a schema with a refinement for positive numbers
const Positive = Schema.Number.pipe(
  Schema.filter((n) => n > 0, {
    jsonSchema: { minimum: 0 }
  })
)

// Add an upper bound refinement to the schema
const schema = Positive.pipe(
  Schema.filter((n) => n <= 10, {
    jsonSchema: { maximum: 10 }
  })
)

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number",
  "minimum": 0,
  "maximum": 10
}
*/
```

The `jsonSchema` annotation is defined as a generic object, allowing it to represent non-standard extensions. This flexibility leaves the responsibility of enforcing type constraints to the user.

If you prefer stricter type enforcement or need to support non-standard extensions, you can introduce a `satisfies` constraint on the object literal. This constraint should be used in conjunction with the typing library of your choice.

**Example** (Ensuring Type Correctness)

In the following example, we've used the `@types/json-schema` package to provide TypeScript definitions for JSON Schema. This approach not only ensures type correctness but also enables autocomplete suggestions in your IDE.

```ts
import type { JSONSchema7 } from "json-schema"

const Positive = Schema.Number.pipe(
  Schema.filter((n) => n > 0, {
    jsonSchema: { minimum: 0 } // Generic object, no type enforcement
  })
)

const schema = Positive.pipe(
  Schema.filter((n) => n <= 10, {
    jsonSchema: { maximum: 10 } satisfies JSONSchema7 // Enforces type constraints
  })
)

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "number",
  "minimum": 0,
  "maximum": 10
}
*/
```

For schema types other than refinements, you can override the default generated JSON Schema by providing a custom `jsonSchema` annotation. The content of this annotation will replace the system-generated schema.

**Example** (Custom Annotation for a Struct)

```ts

// Define a struct with a custom JSON Schema annotation
const schema = Schema.Struct({ foo: Schema.String }).annotations({
  jsonSchema: { type: "object" }
})

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object"
}
the default would be:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "foo"
  ],
  "properties": {
    "foo": {
      "type": "string"
    }
  },
  "additionalProperties": false
}
*/
```

## Specialized JSON Schema Generation with Schema.parseJson

The `Schema.parseJson` function provides a unique approach to JSON Schema generation. Instead of defaulting to a schema for a plain string, which represents the "from" side of the transformation, it generates a schema based on the structure provided within the argument.

This behavior ensures that the generated JSON Schema reflects the intended structure of the parsed data, rather than the raw JSON input.

**Example** (Generating JSON Schema for a Parsed Object)

```ts

// Define a schema that parses a JSON string into a structured object
const schema = Schema.parseJson(
  Schema.Struct({
    // Nested parsing: JSON string to a number
    a: Schema.parseJson(Schema.NumberFromString)
  })
)

const jsonSchema = JSONSchema.make(schema)

console.log(JSON.stringify(jsonSchema, null, 2))
/*
Output:
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": [
    "a"
  ],
  "properties": {
    "a": {
      "type": "string",
      "contentMediaType": "application/json"
    }
  },
  "additionalProperties": false
}
*/
```


---

# [Schema to Standard Schema](https://effect.website/docs/schema/standard-schema/)

## Overview


The `Schema.standardSchemaV1` API allows you to generate a [Standard Schema v1](https://standardschema.dev/) object from an Effect `Schema`.

**Example** (Generating a Standard Schema V1)

```ts

const schema = Schema.Struct({
  name: Schema.String
})

// Convert an Effect schema into a Standard Schema V1 object
//
//      ┌─── StandardSchemaV1<{ readonly name: string; }>
//      ▼
const standardSchema = Schema.standardSchemaV1(schema)
```

> **Note: Schema Restrictions**
  Only schemas that do not have dependencies (i.e., `R = never`) can be
  converted to a Standard Schema V1 object.


## Sync vs Async Validation

The `Schema.standardSchemaV1` API creates a schema whose `validate` method attempts to decode and validate the provided input synchronously. If the underlying `Schema` includes any asynchronous components (e.g., asynchronous message resolutions
or checks), then validation will necessarily return a `Promise` instead.

**Example** (Handling Synchronous and Asynchronous Validation)

```ts

// Utility function to display sync and async results
const print = <T>(t: T) =>
  t instanceof Promise
    ? t.then((x) => console.log("Promise", JSON.stringify(x, null, 2)))
    : console.log("Value", JSON.stringify(t, null, 2))

// Define a synchronous schema
const sync = Schema.Struct({
  name: Schema.String
})

// Generate a Standard Schema V1 object
const syncStandardSchema = Schema.standardSchemaV1(sync)

// Validate synchronously
print(syncStandardSchema["~standard"].validate({ name: null }))
/*
Output:
{
  "issues": [
    {
      "path": [
        "name"
      ],
      "message": "Expected string, actual null"
    }
  ]
}
*/

// Define an asynchronous schema with a transformation
const async = Schema.transformOrFail(
  sync,
  Schema.Struct({
    name: Schema.NonEmptyString
  }),
  {
    // Simulate an asynchronous validation delay
    decode: (x) => Effect.sleep("100 millis").pipe(Effect.as(x)),
    encode: Effect.succeed
  }
)

// Generate a Standard Schema V1 object
const asyncStandardSchema = Schema.standardSchemaV1(async)

// Validate asynchronously
print(asyncStandardSchema["~standard"].validate({ name: "" }))
/*
Output:
Promise {
  "issues": [
    {
      "path": [
        "name"
      ],
      "message": "Expected a non empty string, actual \"\""
    }
  ]
}
*/
```

## Defects

If an unexpected defect occurs during validation, it is reported as a single issue without a `path`. This ensures that unexpected errors do not disrupt schema validation but are still captured and reported.

**Example** (Handling Defects)

```ts

// Define a schema with a defect in the decode function
const defect = Schema.transformOrFail(Schema.String, Schema.String, {
  // Simulate an internal failure
  decode: () => Effect.die("Boom!"),
  encode: Effect.succeed
})

// Generate a Standard Schema V1 object
const defectStandardSchema = Schema.standardSchemaV1(defect)

// Validate input, triggering a defect
console.log(defectStandardSchema["~standard"].validate("a"))
/*
Output:
{ issues: [ { message: 'Error: Boom!' } ] }
*/
```


---

# [Schema to Pretty Printer](https://effect.website/docs/schema/pretty/)

## Overview

The `Pretty.make` function is used to create pretty printers that generate a formatted string representation of values based on a schema.

**Example** (Pretty Printer for a Struct Schema)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Create a pretty printer for the schema
const PersonPretty = Pretty.make(Person)

// Format and print a Person object
console.log(PersonPretty({ name: "Alice", age: 30 }))
/*
Output:
'{ "name": "Alice", "age": 30 }'
*/
```

## Customizing Pretty Printer Generation

You can customize how the pretty printer formats output by using the `pretty` annotation within your schema definition.

The `pretty` annotation takes any type parameters provided (`typeParameters`) and formats the value into a string.

**Example** (Custom Pretty Printer for Numbers)

```ts

// Define a schema with a custom pretty annotation
const schema = Schema.Number.annotations({
  pretty: (/**typeParameters**/) => (value) => `my format: ${value}`
})

// Create the pretty printer
const customPrettyPrinter = Pretty.make(schema)

// Format and print a value
console.log(customPrettyPrinter(1))
// Output: "my format: 1"
```


---

# [Schema to Arbitrary](https://effect.website/docs/schema/arbitrary/)

## Overview


The `Arbitrary.make` function allows for the creation of random values that align with a specific `Schema<A, I, R>`.
This function returns an `Arbitrary<A>` from the [fast-check](https://github.com/dubzzz/fast-check) library,
which is particularly useful for generating random test data that adheres to the defined schema constraints.

**Example** (Generating Arbitrary Data for a Schema)

```ts

// Define a Person schema with constraints
const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Int.pipe(Schema.between(1, 80))
})

// Create an Arbitrary based on the schema
const arb = Arbitrary.make(Person)

// Generate random samples from the Arbitrary
console.log(FastCheck.sample(arb, 2))
/*
Example Output:
[ { name: 'q r', age: 3 }, { name: '&|', age: 6 } ]
*/
```

To make the output more realistic, see the [Customizing Arbitrary Data Generation](#customizing-arbitrary-data-generation) section.

> **Tip: Access FastCheck API**
  The entirety of `fast-check`'s API is accessible via the `FastCheck`
  export, allowing direct use of all its functionalities within your
  projects.


## Filters

When generating random values, `Arbitrary` tries to follow the schema's constraints. It uses the most appropriate `fast-check` primitives and applies constraints if the primitive supports them.

For instance, if you define an `age` property as:

```ts
Schema.Int.pipe(Schema.between(1, 80))
```

the arbitrary generation will use:

```ts
FastCheck.integer({ min: 1, max: 80 })
```

to produce values within that range.

> **Note: Avoiding Conflicts in Filters**
When using multiple filters, be aware that conflicting filters might lead to hangs during arbitrary data generation. This can occur when the constraints make it difficult or impossible to produce valid values.

For guidance on mitigating these issues, refer to [this discussion](https://github.com/dubzzz/fast-check/discussions/4659).



### Patterns

To generate efficient arbitraries for strings that must match a certain pattern, use the `Schema.pattern` filter instead of writing a custom filter:

**Example** (Using `Schema.pattern` for Pattern Constraints)

```ts

// ❌ Without using Schema.pattern (less efficient)
const Bad = Schema.String.pipe(Schema.filter((s) => /^[a-z]+$/.test(s)))

// ✅ Using Schema.pattern (more efficient)
const Good = Schema.String.pipe(Schema.pattern(/^[a-z]+$/))
```

By using `Schema.pattern`, arbitrary generation will rely on `FastCheck.stringMatching(regexp)`, which is more efficient and directly aligned with the defined pattern.

When multiple patterns are used, they are combined into a union. For example:

```ts
(?:${pattern1})|(?:${pattern2})
```

This approach ensures all patterns have an equal chance of generating values when using `FastCheck.stringMatching`.

## Transformations and Arbitrary Generation

When generating arbitrary data, it is important to understand how transformations and filters are handled within a schema:

> **Caution: Filters Ignored**
  Filters applied before the last transformation in the transformation
  chain are not considered during the generation of arbitrary data.


**Example** (Filters and Transformations)

```ts

// Schema with filters before the transformation
const schema1 = Schema.compose(Schema.NonEmptyString, Schema.Trim).pipe(
  Schema.maxLength(500)
)

// May produce empty strings due to ignored NonEmpty filter
console.log(FastCheck.sample(Arbitrary.make(schema1), 2))
/*
Example Output:
[ '', '"Ry' ]
*/

// Schema with filters applied after transformations
const schema2 = Schema.Trim.pipe(
  Schema.nonEmptyString(),
  Schema.maxLength(500)
)

// Adheres to all filters, avoiding empty strings
console.log(FastCheck.sample(Arbitrary.make(schema2), 2))
/*
Example Output:
[ ']H+MPXgZKz', 'SNS|waP~\\' ]
*/
```

**Explanation:**

- `schema1`: Takes into account `Schema.maxLength(500)` since it is applied after the `Schema.Trim` transformation, but ignores the `Schema.NonEmptyString` as it precedes the transformations.
- `schema2`: Adheres fully to all filters because they are correctly sequenced after transformations, preventing the generation of undesired data.

### Best Practices

To ensure consistent and valid arbitrary data generation, follow these guidelines:

1. **Apply Filters First**: Define filters for the initial type (`I`).
2. **Apply Transformations**: Add transformations to convert the data.
3. **Apply Final Filters**: Use filters for the transformed type (`A`).

This setup ensures that each stage of data processing is precise and well-defined.

**Example** (Avoid Mixed Filters and Transformations)

Avoid haphazard combinations of transformations and filters:

```ts

// Less optimal approach: Mixing transformations and filters
const problematic = Schema.compose(Schema.Lowercase, Schema.Trim)
```

Prefer a structured approach by separating transformation steps from filter applications:

**Example** (Preferred Structured Approach)

```ts

// Recommended: Separate transformations and filters
const improved = Schema.transform(
  Schema.String,
  Schema.String.pipe(Schema.trimmed(), Schema.lowercased()),
  {
    strict: true,
    decode: (s) => s.trim().toLowerCase(),
    encode: (s) => s
  }
)
```

## Customizing Arbitrary Data Generation

You can customize how arbitrary data is generated using the `arbitrary` annotation in schema definitions.

**Example** (Custom Arbitrary Generator)

```ts

const Name = Schema.NonEmptyString.annotations({
  arbitrary: () => (fc) =>
    fc.constantFrom("Alice Johnson", "Dante Howell", "Marta Reyes")
})

const Age = Schema.Int.pipe(Schema.between(1, 80))

const Person = Schema.Struct({
  name: Name,
  age: Age
})

const arb = Arbitrary.make(Person)

console.log(FastCheck.sample(arb, 2))
/*
Example Output:
[ { name: 'Dante Howell', age: 6 }, { name: 'Marta Reyes', age: 53 } ]
*/
```

The annotation allows access the complete export of the fast-check library (`fc`).
This setup enables you to return an `Arbitrary` that precisely generates the type of data desired.

### Integration with Fake Data Generators

When using mocking libraries like [@faker-js/faker](https://www.npmjs.com/package/@faker-js/faker),
you can combine them with `fast-check` to generate realistic data for testing purposes.

**Example** (Integrating with Faker)

```ts

const Name = Schema.NonEmptyString.annotations({
  arbitrary: () => (fc) =>
    fc.constant(null).map(() => {
      // Each time the arbitrary is sampled, faker generates a new name
      return faker.person.fullName()
    })
})

const Age = Schema.Int.pipe(Schema.between(1, 80))

const Person = Schema.Struct({
  name: Name,
  age: Age
})

const arb = Arbitrary.make(Person)

console.log(FastCheck.sample(arb, 2))
/*
Example Output:
[
  { name: 'Henry Dietrich', age: 68 },
  { name: 'Lucas Haag', age: 52 }
]
*/
```


---

# [Schema to Equivalence](https://effect.website/docs/schema/equivalence/)

## Overview

The `Schema.equivalence` function allows you to generate an [Equivalence](/docs/schema/equivalence/) based on a schema definition.
This function is designed to compare data structures for equivalence according to the rules defined in the schema.

**Example** (Comparing Structs for Equivalence)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Generate an equivalence function based on the schema
const PersonEquivalence = Schema.equivalence(Person)

const john = { name: "John", age: 23 }
const alice = { name: "Alice", age: 30 }

// Use the equivalence function to compare objects

console.log(PersonEquivalence(john, { name: "John", age: 23 }))
// Output: true

console.log(PersonEquivalence(john, alice))
// Output: false
```

## Equivalence for Any, Unknown, and Object

When working with the following schemas:

- `Schema.Any`
- `Schema.Unknown`
- `Schema.Object`
- `Schema.Struct({})` (representing the broad `{}` TypeScript type)

the most sensible form of equivalence is to use `Equal.equals` from the [Equal](/docs/trait/equal/) module, which defaults to reference equality (`===`).
This is because these types can hold almost any kind of value.

**Example** (Comparing Empty Objects Using Reference Equality)

```ts

const schema = Schema.Struct({})

const input1 = {}
const input2 = {}

console.log(Schema.equivalence(schema)(input1, input2))
// Output: false (because they are different references)
```

## Customizing Equivalence Generation

You can customize the equivalence logic by providing an `equivalence` annotation in the schema definition.

The `equivalence` annotation takes any type parameters provided (`typeParameters`) and two values for comparison, returning a boolean based on the desired condition of equivalence.

**Example** (Custom Equivalence for Strings)

```ts

// Define a schema with a custom equivalence annotation
const schema = Schema.String.annotations({
  equivalence: (/**typeParameters**/) => (s1, s2) =>
    // Custom rule: Compare only the first character of the strings
    s1.charAt(0) === s2.charAt(0)
})

// Generate the equivalence function
const customEquivalence = Schema.equivalence(schema)

// Use the custom equivalence function
console.log(customEquivalence("aaa", "abb"))
// Output: true (both start with 'a')

console.log(customEquivalence("aaa", "bba"))
// Output: false (strings start with different characters)
```


---


## Common Mistakes

**Incorrect (manual validation without Schema filters):**

```ts
const validateAge = (age: number) => {
  if (age < 0 || age > 150) throw new Error("invalid age")
  return age
}
```

**Correct (using Schema filters for composable validation):**

```ts
const Age = Schema.Number.pipe(
  Schema.between(0, 150, {
    message: () => "Age must be between 0 and 150"
  })
)
```
