---
title: "Schema Basics"
impact: CRITICAL
impactDescription: "Prevents invalid data from entering the system — covers schema definitions, classes, constructors, decoding"
tags: schema, validation, decoding, classes
---
# [Introduction to Effect Schema](https://effect.website/docs/schema/introduction/)

## Overview


Welcome to the documentation for `effect/Schema`, a module for defining and using schemas to validate and transform data in TypeScript.

The `effect/Schema` module allows you to define a `Schema<Type, Encoded, Requirements>` that provides a blueprint for describing the structure and data types of your data. Once defined, you can leverage this schema to perform a range of operations, including:

| Operation       | Description                                                                          |
| --------------- | ------------------------------------------------------------------------------------ |
| Decoding        | Transforming data from an input type `Encoded` to an output type `Type`.             |
| Encoding        | Converting data from an output type `Type` back to an input type `Encoded`.          |
| Asserting       | Verifying that a value adheres to the schema's output type `Type`.                   |
| Standard Schema | Generate a [Standard Schema V1](https://standardschema.dev/).                        |
| Arbitraries     | Generate arbitraries for [fast-check](https://github.com/dubzzz/fast-check) testing. |
| JSON Schemas    | Create JSON Schemas based on defined schemas.                                        |
| Equivalence     | Create [Equivalence](/docs/schema/equivalence/) based on defined schemas.            |
| Pretty printing | Support pretty printing for data structures.                                         |

## Requirements

- TypeScript 5.4 or newer.
- The `strict` flag enabled in your `tsconfig.json` file.
- (Optional) The `exactOptionalPropertyTypes` flag enabled in your `tsconfig.json` file.

```json
{
  "compilerOptions": {
    "strict": true,
    "exactOptionalPropertyTypes": true // optional
  }
}
```

### The exactOptionalPropertyTypes Option

The `effect/Schema` module takes advantage of the `exactOptionalPropertyTypes` option of `tsconfig.json`. This option affects how optional properties are typed (to learn more about this option, you can refer to the official [TypeScript documentation](https://www.typescriptlang.org/tsconfig#exactOptionalPropertyTypes)).

**Example** (With `exactOptionalPropertyTypes` Enabled)

```ts

const Person = Schema.Struct({
  name: Schema.optionalWith(Schema.NonEmptyString, { exact: true })
})

type Type = Schema.Schema.Type<typeof Person>
/*
type Type = {
    readonly name?: string;
}
*/

// @errors: 2379
Schema.decodeSync(Person)({ name: undefined })
```

Here, notice that the type of `name` is "exact" (`string`), which means the type checker will catch any attempt to assign an invalid value (like `undefined`).

**Example** (With `exactOptionalPropertyTypes` Disabled)

If, for some reason, you can't enable the `exactOptionalPropertyTypes` option (perhaps due to conflicts with other third-party libraries), you can still use `effect/Schema`. However, there will be a mismatch between the types and the runtime behavior:

```ts

const Person = Schema.Struct({
  name: Schema.optionalWith(Schema.NonEmptyString, { exact: true })
})

type Type = Schema.Schema.Type<typeof Person>
/*
type Type = {
    readonly name?: string | undefined;
}
*/

// No type error, but a decoding failure occurs
Schema.decodeSync(Person)({ name: undefined })
/*
throws:
ParseError: { readonly name?: NonEmptyString }
└─ ["name"]
   └─ NonEmptyString
      └─ From side refinement failure
         └─ Expected string, actual undefined
*/
```

In this case, the type of `name` is widened to `string | undefined`, which means the type checker won't catch the invalid value (`undefined`). However, during decoding, you'll encounter an error, indicating that `undefined` is not allowed.

## The Schema Type

A schema is an immutable value that describes the structure of your data, and it is represented by the `Schema` type.

Here is the general form of a `Schema`:

```text
         ┌─── Type of the decoded value
         │        ┌─── Encoded type (input/output)
         │        │      ┌─── Requirements (context)
         ▼        ▼      ▼
Schema<Type, Encoded, Requirements>
```

The `Schema` type has three type parameters with the following meanings:

| Parameter        | Description                                                                                                                                                                                                                                                                                                   |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Type**         | Represents the type of value that a schema can succeed with during decoding.                                                                                                                                                                                                                                  |
| **Encoded**      | Represents the type of value that a schema can succeed with during encoding. By default, it's equal to `Type` if not explicitly provided.                                                                                                                                                                     |
| **Requirements** | Similar to the [`Effect`](https://effect.website/docs/getting-started/the-effect-type) type, it represents the contextual data required by the schema to execute both decoding and encoding. If this type parameter is `never` (default if not explicitly provided), it means the schema has no requirements. |

**Examples**

- `Schema<string>` (defaulted to `Schema<string, string, never>`) represents a schema that decodes to `string`, encodes to `string`, and has no requirements.
- `Schema<number, string>` (defaulted to `Schema<number, string, never>`) represents a schema that decodes to `number` from `string`, encodes a `number` to a `string`, and has no requirements.

> **Note: Type Parameter Abbreviations**
  In the Effect ecosystem, you may often encounter the type parameters of
  `Schema` abbreviated as `A`, `I`, and `R` respectively. This is just
  shorthand for the type value of type **A**, **I**nput, and
  **R**equirements.


## Understanding Schema Values

**Immutability**. `Schema` values are immutable, and every function in the `effect/Schema` module produces a new `Schema` value.

**Modeling Data Structure**. These values do not perform any actions themselves, they simply model or describe the structure of your data.

**Interpretation by Compilers**. A `Schema` can be interpreted by various "compilers" into specific operations, depending on the compiler type (decoding, encoding, pretty printing, arbitraries, etc...).

## Understanding Decoding and Encoding

When working with data in TypeScript, you often need to handle data coming from or being sent to external systems. This data may not always match the format or types you expect, especially when dealing with user input, data from APIs, or data stored in different formats. To handle these discrepancies, we use **decoding** and **encoding**.

| Term         | Description                                                                                                  |
| ------------ | ------------------------------------------------------------------------------------------------------------ |
| **Decoding** | Used for parsing data from external sources where you have no control over the data format.                  |
| **Encoding** | Used when sending data out to external sources, converting it to a format that is expected by those sources. |

For instance, when working with forms in the frontend, you often receive untyped data in the form of strings. This data can be tampered with and does not natively support arrays or booleans. Decoding helps you validate and parse this data into more useful types like numbers, dates, and arrays. Encoding allows you to convert these types back into the string format expected by forms.

Below is a diagram that shows the relationship between encoding and decoding using a `Schema<A, I, R>`:

```text
┌─────────┐       ┌───┐       ┌───┐       ┌─────────┐
| unknown |       | A |       | I |       | unknown |
└─────────┘       └───┘       └───┘       └─────────┘
     |              |           |              |
     | validate     |           |              |
     |─────────────►│           |              |
     |              |           |              |
     | is           |           |              |
     |─────────────►│           |              |
     |              |           |              |
     | asserts      |           |              |
     |─────────────►│           |              |
     |              |           |              |
     | encodeUnknown|           |              |
     |─────────────────────────►|              |
                    |           |              |
                    | encode    |              |
                    |──────────►│              |
                    |           |              |
                    |    decode |              |
                    | ◄─────────|              |
                    |           |              |
                    |           | decodeUnknown|
                    | ◄────────────────────────|
```

We'll break down these concepts using an example with a `Schema<Date, string, never>`. This schema serves as a tool to transform a `string` into a `Date` and vice versa.

### Encoding

When we talk about "encoding," we are referring to the process of changing a `Date` into a `string`. To put it simply, it's the act of converting data from one format to another.

### Decoding

Conversely, "decoding" entails transforming a `string` back into a `Date`. It's essentially the reverse operation of encoding, where data is returned to its original form.

### Decoding From Unknown

Decoding from `unknown` involves two key steps:

1. **Checking:** Initially, we verify that the input data (which is of the `unknown` type) matches the expected structure. In our specific case, this means ensuring that the input is indeed a `string`.

2. **Decoding:** Following the successful check, we proceed to convert the `string` into a `Date`. This process completes the decoding operation, where the data is both validated and transformed.

### Encoding From Unknown

Encoding from `unknown` involves two key steps:

1. **Checking:** Initially, we verify that the input data (which is of the `unknown` type) matches the expected structure. In our specific case, this means ensuring that the input is indeed a `Date`.

2. **Encoding:** Following the successful check, we proceed to convert the `Date` into a `string`. This process completes the encoding operation, where the data is both validated and transformed.

## The Rule of Schemas

When working with schemas, there's an important rule to keep in mind: your schemas should be crafted in a way that when you perform both encoding and decoding operations, you should end up with the original value.

In simpler terms, if you encode a value and then immediately decode it, the result should match the original value you started with. This rule ensures that your data remains consistent and reliable throughout the encoding and decoding process.

> **Tip: Ensure Consistency**
  As a general rule, schemas should be defined such that encode + decode
  return the original value.



---

# [Getting Started](https://effect.website/docs/schema/getting-started/)

## Overview


You can import the necessary types and functions from the `effect/Schema` module:

**Example** (Namespace Import)

```ts
import * as Schema from "effect/Schema"
```

**Example** (Named Import)

```ts
```

## Defining a schema

One common way to define a `Schema` is by utilizing the `Struct` constructor.
This constructor allows you to create a new schema that outlines an object with specific properties.
Each property in the object is defined by its own schema, which specifies the data type and any validation rules.

**Example** (Defining a Simple Object Schema)

This `Person` schema describes an object with a `name` (string) and `age` (number) property:

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})
```

## Extracting Inferred Types

### Type

Once you've defined a schema (`Schema<Type, Encoded, Context>`), you can extract the inferred type `Type` in two ways:

1. Using the `Schema.Type` utility
2. Accessing the `Type` field directly on your schema

**Example** (Extracting Inferred Type)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// 1. Using the Schema.Type utility
type Person = Schema.Schema.Type<typeof Person>

// 2. Accessing the Type field directly
type Person2 = typeof Person.Type
```

The resulting type will look like this:

```ts
type Person = {
  readonly name: string
  readonly age: number
}
```

Alternatively, you can extract the `Person` type using the `interface` keyword, which may improve readability and performance in some cases.

**Example** (Extracting Type with an Interface)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

interface Person extends Schema.Schema.Type<typeof Person> {}
```

Both approaches yield the same result, but using an interface provides benefits such as performance advantages and improved readability.

### Encoded

In a `Schema<Type, Encoded, Context>`, the `Encoded` type can differ from the `Type` type, representing the format in which data is encoded. You can extract the `Encoded` type in two ways:

1. Using the `Schema.Encoded` utility
2. Accessing the `Encoded` field directly on the schema

**Example** (Extracting the Encoded Type)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  // a schema that decodes a string to a number
  age: Schema.NumberFromString
})

// 1. Using the Schema.Encoded utility
type PersonEncoded = Schema.Schema.Encoded<typeof Person>

// 2. Accessing the Encoded field directly
type PersonEncoded2 = typeof Person.Encoded
```

The resulting type is:

```ts
type PersonEncoded = {
  readonly name: string
  readonly age: string
}
```

Note that `age` is of type `string` in the `Encoded` type of the schema and is of type `number` in the `Type` type of the schema.

Alternatively, you can define the `PersonEncoded` type using the `interface` keyword, which can enhance readability and performance.

**Example** (Extracting Encoded Type with an Interface)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  // a schema that decodes a string to a number
  age: Schema.NumberFromString
})

interface PersonEncoded extends Schema.Schema.Encoded<typeof Person> {}
```

Both approaches yield the same result, but using an interface provides benefits such as performance advantages and improved readability.

### Context

In a `Schema<Type, Encoded, Context>`, the `Context` type represents any external data or dependencies that the schema requires to perform encoding or decoding. You can extract the inferred `Context` type in two ways:

1. Using the `Schema.Context` utility.
2. Accessing the `Context` field on the schema.

**Example** (Extracting the Context Type)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// 1. Using the Schema.Context utility
type PersonContext = Schema.Schema.Context<typeof Person>

// 2. Accessing the Context field directly
type PersonContext2 = typeof Person.Context
```

### Schemas with Opaque Types

When defining a schema, you may want to create a schema with an opaque type. This is useful when you want to hide the internal structure of the schema and only expose the type of the schema.

**Example** (Creating an Opaque Schema)

To create a schema with an opaque type, you can use the following technique that re-declares the schema:

```ts

// Define the schema structure
const _Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Declare the type interface to make it opaque
interface Person extends Schema.Schema.Type<typeof _Person> {}

// Re-declare the schema as opaque
const Person: Schema.Schema<Person> = _Person
```

Alternatively, you can use the Class APIs (see the [Class APIs](/docs/schema/classes/) section for more details).

Note that the technique shown above becomes more complex when the schema is defined such that `Type` is different from `Encoded`.

**Example** (Opaque Schema with Different Type and Encoded)

```ts

// Define the schema structure, with a field that
// decodes a string to a number
const _Person = Schema.Struct({
  name: Schema.String,
  age: Schema.NumberFromString
})

// Create the `Type` interface for an opaque schema
interface Person extends Schema.Schema.Type<typeof _Person> {}

// Create the `Encoded` interface for an opaque schema
interface PersonEncoded extends Schema.Schema.Encoded<typeof _Person> {}

// Re-declare the schema with opaque Type and Encoded
const Person: Schema.Schema<Person, PersonEncoded> = _Person
```

In this case, the field `"age"` is of type `string` in the `Encoded` type of the schema and is of type `number` in the `Type` type of the schema. Therefore, we need to define **two** interfaces (`PersonEncoded` and `Person`) and use both to redeclare our final schema `Person`.

## Readonly Types by Default

It's important to note that by default, most constructors exported by
`effect/Schema` return `readonly` types.

**Example** (Readonly Types in a Schema)

For instance, in the `Person` schema below:

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})
```

the resulting inferred `Type` would be:

```ts
{
  readonly name: string;
  readonly age: number;
}
```

## Decoding

When working with unknown data types in TypeScript, decoding them into a known structure can be challenging. Luckily, `effect/Schema` provides several functions to help with this process. Let's explore how to decode unknown values using these functions.

| API                    | Description                                                                      |
| ---------------------- | -------------------------------------------------------------------------------- |
| `decodeUnknownSync`    | Synchronously decodes a value and throws an error if parsing fails.              |
| `decodeUnknownOption`  | Decodes a value and returns an [Option](/docs/data-types/option/) type.          |
| `decodeUnknownEither`  | Decodes a value and returns an [Either](/docs/data-types/either/) type.          |
| `decodeUnknownPromise` | Decodes a value and returns a `Promise`.                                         |
| `decodeUnknown`        | Decodes a value and returns an [Effect](/docs/getting-started/the-effect-type/). |

### decodeUnknownSync

The `Schema.decodeUnknownSync` function is useful when you want to parse a value and immediately throw an error if the parsing fails.

**Example** (Using `decodeUnknownSync` for Immediate Decoding)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Simulate an unknown input
const input: unknown = { name: "Alice", age: 30 }

// Example of valid input matching the schema
console.log(Schema.decodeUnknownSync(Person)(input))
// Output: { name: 'Alice', age: 30 }

// Example of invalid input that does not match the schema
console.log(Schema.decodeUnknownSync(Person)(null))
/*
throws:
ParseError: Expected { readonly name: string; readonly age: number }, actual null
*/
```

### decodeUnknownEither

The `Schema.decodeUnknownEither` function allows you to parse a value and receive the result as an [Either](/docs/data-types/either/), representing success (`Right`) or failure (`Left`). This approach lets you handle parsing errors more gracefully without throwing exceptions.

**Example** (Using `Schema.decodeUnknownEither` for Error Handling)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decodeUnknownEither(Person)

// Simulate an unknown input
const input: unknown = { name: "Alice", age: 30 }

// Attempt decoding a valid input
const result1 = decode(input)
if (Either.isRight(result1)) {
  console.log(result1.right)
  /*
  Output:
  { name: "Alice", age: 30 }
  */
}

// Simulate decoding an invalid input
const result2 = decode(null)
if (Either.isLeft(result2)) {
  console.log(result2.left)
  /*
  Output:
  {
    _id: 'ParseError',
    message: 'Expected { readonly name: string; readonly age: number }, actual null'
  }
  */
}
```

### decodeUnknown

If your schema involves asynchronous transformations, the `Schema.decodeUnknownSync` and `Schema.decodeUnknownEither` functions will not be suitable.
In such cases, you should use the `Schema.decodeUnknown` function, which returns an [Effect](/docs/getting-started/the-effect-type/).

**Example** (Handling Asynchronous Decoding)

```ts

const PersonId = Schema.Number

const Person = Schema.Struct({
  id: PersonId,
  name: Schema.String,
  age: Schema.Number
})

const asyncSchema = Schema.transformOrFail(PersonId, Person, {
  strict: true,
  // Decode with simulated async transformation
  decode: (id) =>
    Effect.succeed({ id, name: "name", age: 18 }).pipe(
      Effect.delay("10 millis")
    ),
  encode: (person) =>
    Effect.succeed(person.id).pipe(Effect.delay("10 millis"))
})

// Attempting to use a synchronous decoder on an async schema
console.log(Schema.decodeUnknownEither(asyncSchema)(1))
/*
Output:
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(number <-> { readonly id: number; readonly name: string; readonly age: number })\n' +
      '└─ cannot be be resolved synchronously, this is caused by using runSync on an effect that performs async work'
  }
}
*/

// Decoding asynchronously with `Schema.decodeUnknown`
Effect.runPromise(Schema.decodeUnknown(asyncSchema)(1)).then(console.log)
/*
Output:
{ id: 1, name: 'name', age: 18 }
*/
```

In the code above, the first approach using `Schema.decodeUnknownEither` results in an error indicating that the transformation cannot be resolved synchronously.
This occurs because `Schema.decodeUnknownEither` is not designed for async operations.
The second approach, which uses `Schema.decodeUnknown`, works correctly, allowing you to handle asynchronous transformations and return the expected result.

## Encoding

The `Schema` module provides several `encode*` functions to encode data according to a schema:

| API             | Description                                                                                          |
| --------------- | ---------------------------------------------------------------------------------------------------- |
| `encodeSync`    | Synchronously encodes data and throws an error if encoding fails.                                    |
| `encodeOption`  | Encodes data and returns an [Option](/docs/data-types/option/) type.                                 |
| `encodeEither`  | Encodes data and returns an [Either](/docs/data-types/either/) type representing success or failure. |
| `encodePromise` | Encodes data and returns a `Promise`.                                                                |
| `encode`        | Encodes data and returns an [Effect](/docs/getting-started/the-effect-type/).                        |

**Example** (Using `Schema.encodeSync` for Immediate Encoding)

```ts

const Person = Schema.Struct({
  // Ensure name is a non-empty string
  name: Schema.NonEmptyString,
  // Allow age to be decoded from a string and encoded to a string
  age: Schema.NumberFromString
})

// Valid input: encoding succeeds and returns expected types
console.log(Schema.encodeSync(Person)({ name: "Alice", age: 30 }))
// Output: { name: 'Alice', age: '30' }

// Invalid input: encoding fails due to empty name string
console.log(Schema.encodeSync(Person)({ name: "", age: 30 }))
/*
throws:
ParseError: { readonly name: NonEmptyString; readonly age: NumberFromString }
└─ ["name"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected a non empty string, actual ""
*/
```

Note that during encoding, the number value `30` was converted to a string `"30"`.

### Handling Unsupported Encoding

In certain cases, it may not be feasible to support encoding for a schema. While it is generally advised to define schemas that allow both decoding and encoding, there are situations where encoding a particular type is either unsupported or unnecessary. In these instances, the `Forbidden` issue can signal that encoding is not available for certain values.

**Example** (Using `Forbidden` to Indicate Unsupported Encoding)

Here is an example of a transformation that never fails during decoding. It returns an [Either](/docs/data-types/either/) containing either the decoded value or the original input. For encoding, it is reasonable to not support it and use `Forbidden` as the result.

```ts

// Define a schema that safely decodes to Either type
export const SafeDecode = <A, I>(self: Schema.Schema<A, I, never>) => {
  const decodeUnknownEither = Schema.decodeUnknownEither(self)
  return Schema.transformOrFail(
    Schema.Unknown,
    Schema.EitherFromSelf({
      left: Schema.Unknown,
      right: Schema.typeSchema(self)
    }),
    {
      strict: true,
      // Decode: map a failed result to the input as Left,
      // successful result as Right
      decode: (input) =>
        ParseResult.succeed(
          Either.mapLeft(decodeUnknownEither(input), () => input)
        ),
      // Encode: only support encoding Right values,
      // Left values raise Forbidden error
      encode: (actual, _, ast) =>
        Either.match(actual, {
          onLeft: () =>
            ParseResult.fail(
              new ParseResult.Forbidden(
                ast,
                actual,
                "cannot encode a Left"
              )
            ),
          // Successfully encode a Right value
          onRight: ParseResult.succeed
        })
    }
  )
}
```

**Explanation**

- **Decoding**: The `SafeDecode` function ensures that decoding never fails. It wraps the decoded value in an [Either](/docs/data-types/either/), where a successful decoding results in a `Right` and a failed decoding results in a `Left` containing the original input.
- **Encoding**: The encoding process uses the `Forbidden` error to indicate that encoding a `Left` value is not supported. Only `Right` values are successfully encoded.

## ParseError

The `Schema.decodeUnknownEither` and `Schema.encodeEither` functions returns a [Either](/docs/data-types/either/):

```ts
Either<Type, ParseError>
```

where `ParseError` is defined as follows (simplified):

```ts
interface ParseError {
  readonly _tag: "ParseError"
  readonly issue: ParseIssue
}
```

In this structure, `ParseIssue` represents an error that might occur during the parsing process.
It is wrapped in a tagged error to make it easier to catch errors using [Effect.catchTag](/docs/error-management/expected-errors/#catchtag).
The result `Either<Type, ParseError>` contains the inferred data type described by the schema (`Type`).
A successful parse yields a `Right` value with the parsed data `Type`, while a failed parse results in a `Left` value containing a `ParseError`.

> **Tip: Returning All Errors**
  By default only the first error is returned. You can use the
  [`errors`](#receive-all-errors) option to receive all errors.


## Parse Options

The options below provide control over both decoding and encoding behaviors.

### Managing Excess properties

By default, any properties not defined in the schema are removed from the output when parsing a value. This ensures the parsed data conforms strictly to the expected structure.

If you want to detect and handle unexpected properties, use the `onExcessProperty` option (default value: `"ignore"`), which allows you to raise an error for excess properties. This can be helpful when you need to validate and catch unanticipated properties.

**Example** (Setting `onExcessProperty` to `"error"`)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Excess properties are ignored by default
console.log(
  Schema.decodeUnknownSync(Person)({
    name: "Bob",
    age: 40,
    email: "bob@example.com" // Ignored
  })
)
/*
Output:
{ name: 'Bob', age: 40 }
*/

// With `onExcessProperty` set to "error",
// an error is thrown for excess properties
Schema.decodeUnknownSync(Person)(
  {
    name: "Bob",
    age: 40,
    email: "bob@example.com" // Will raise an error
  },
  { onExcessProperty: "error" }
)
/*
throws
ParseError: { readonly name: string; readonly age: number }
└─ ["email"]
   └─ is unexpected, expected: "name" | "age"
*/
```

To retain extra properties, set `onExcessProperty` to `"preserve"`.

**Example** (Setting `onExcessProperty` to `"preserve"`)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Excess properties are preserved in the output
console.log(
  Schema.decodeUnknownSync(Person)(
    {
      name: "Bob",
      age: 40,
      email: "bob@example.com"
    },
    { onExcessProperty: "preserve" }
  )
)
/*
{ email: 'bob@example.com', name: 'Bob', age: 40 }
*/
```

### Receive all errors

The `errors` option enables you to retrieve all errors encountered during parsing. By default, only the first error is returned. Setting `errors` to `"all"` provides comprehensive error feedback, which can be useful for debugging or offering detailed validation feedback.

**Example** (Setting `errors` to `"all"`)

```ts

const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Attempt to parse with multiple issues in the input data
Schema.decodeUnknownSync(Person)(
  {
    name: "Bob",
    age: "abc",
    email: "bob@example.com"
  },
  { errors: "all", onExcessProperty: "error" }
)
/*
throws
ParseError: { readonly name: string; readonly age: number }
├─ ["email"]
│  └─ is unexpected, expected: "name" | "age"
└─ ["age"]
   └─ Expected number, actual "abc"
*/
```

### Managing Property Order

The `propertyOrder` option provides control over the order of object fields in the output. This feature is particularly useful when the sequence of keys is important for the consuming processes or when maintaining the input order enhances readability and usability.

By default, the `propertyOrder` option is set to `"none"`. This means that the internal system decides the order of keys to optimize parsing speed.
The order of keys in this mode should not be considered stable, and it's recommended not to rely on key ordering as it may change in future updates.

Setting `propertyOrder` to `"original"` ensures that the keys are ordered as they appear in the input during the decoding/encoding process.

**Example** (Synchronous Decoding)

```ts

const schema = Schema.Struct({
  a: Schema.Number,
  b: Schema.Literal("b"),
  c: Schema.Number
})

// Default decoding, where property order is system-defined
console.log(Schema.decodeUnknownSync(schema)({ b: "b", c: 2, a: 1 }))
// Output may vary: { a: 1, b: 'b', c: 2 }

// Decoding while preserving input order
console.log(
  Schema.decodeUnknownSync(schema)(
    { b: "b", c: 2, a: 1 },
    { propertyOrder: "original" }
  )
)
// Output preserves input order: { b: 'b', c: 2, a: 1 }
```

**Example** (Asynchronous Decoding)

```ts
import type { Duration } from "effect"

// Helper function to simulate an async operation in schema
const effectify = (duration: Duration.DurationInput) =>
  Schema.Number.pipe(
    Schema.transformOrFail(Schema.Number, {
      strict: true,
      decode: (x) =>
        Effect.sleep(duration).pipe(
          Effect.andThen(ParseResult.succeed(x))
        ),
      encode: ParseResult.succeed
    })
  )

// Define a structure with asynchronous behavior in each field
const schema = Schema.Struct({
  a: effectify("200 millis"),
  b: effectify("300 millis"),
  c: effectify("100 millis")
}).annotations({ concurrency: 3 })

// Default decoding, where property order is system-defined
Schema.decode(schema)({ a: 1, b: 2, c: 3 })
  .pipe(Effect.runPromise)
  .then(console.log)
// Output decided internally: { c: 3, a: 1, b: 2 }

// Decoding while preserving input order
Schema.decode(schema)({ a: 1, b: 2, c: 3 }, { propertyOrder: "original" })
  .pipe(Effect.runPromise)
  .then(console.log)
// Output preserving input order: { a: 1, b: 2, c: 3 }
```

### Customizing Parsing Behavior at the Schema Level

The `parseOptions` annotation allows you to customize parsing behavior at different schema levels, enabling you to apply unique parsing settings to nested schemas within a structure. Options defined within a schema override parent-level settings and apply to all nested schemas.

**Example** (Using `parseOptions` to Customize Error Handling)

```ts

const schema = Schema.Struct({
  a: Schema.Struct({
    b: Schema.String,
    c: Schema.String
  }).annotations({
    title: "first error only",
    // Limit errors to the first in this sub-schema
    parseOptions: { errors: "first" }
  }),
  d: Schema.String
}).annotations({
  title: "all errors",
  // Capture all errors for the main schema
  parseOptions: { errors: "all" }
})

// Decode input with custom error-handling behavior
const result = Schema.decodeUnknownEither(schema)(
  { a: {} },
  { errors: "first" }
)
if (Either.isLeft(result)) {
  console.log(result.left.message)
}
/*
all errors
├─ ["a"]
│  └─ first error only
│     └─ ["b"]
│        └─ is missing
└─ ["d"]
   └─ is missing
*/
```

**Detailed Output Explanation:**

In this example:

- The main schema is configured to display all errors. Hence, you will see errors related to both the `d` field (since it's missing) and any errors from the `a` subschema.
- The subschema (`a`) is set to display only the first error. Although both `b` and `c` fields are missing, only the first missing field (`b`) is reported.

## Type Guards

The `Schema.is` function provides a way to verify if a value conforms to a given schema. It acts as a [type guard](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#using-type-predicates), taking a value of type `unknown` and determining if it matches the structure and type constraints defined in the schema.

Here's how the `Schema.is` function works:

1. **Schema Definition**: Define a schema to describe the structure and constraints of the data type you expect. For instance, `Schema<Type, Encoded, Context>`, where `Type` is the target type you want to validate against.

2. **Type Guard Creation**: Use the schema to create a user-defined type guard, `(u: unknown) => u is Type`. This function can be used at runtime to check if a value meets the requirements of the schema.

> **Note: Role of the Encoded Type in Type Guards**
  The type `Encoded`, which is often used in schema transformations, does
  not affect the creation of the type guard. The main purpose is to ensure
  that the input matches the desired type `Type`.


**Example** (Creating and Using a Type Guard)

```ts

// Define a schema for a Person object
const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Generate a type guard from the schema
const isPerson = Schema.is(Person)

// Test the type guard with various inputs
console.log(isPerson({ name: "Alice", age: 30 }))
// Output: true

console.log(isPerson(null))
// Output: false

console.log(isPerson({}))
// Output: false
```

The generated `isPerson` function has the following signature:

```ts
const isPerson: (
  u: unknown,
  overrideOptions?: number | ParseOptions
) => u is {
  readonly name: string
  readonly age: number
}
```

## Assertions

While type guards verify whether a value conforms to a specific type, the `Schema.asserts` function goes further by asserting that an input matches the schema type `Type` (from `Schema<Type, Encoded, Context>`).
If the input does not match the schema, it throws a detailed error, making it useful for runtime validation.

> **Note: Role of the Encoded Type in Assertions**
  The type `Encoded`, which is often used in schema transformations, does
  not affect the creation of the assertion. The main purpose is to ensure
  that the input matches the desired type `Type`.


**Example** (Creating and Using an Assertion)

```ts

// Define a schema for a Person object
const Person = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// Generate an assertion function from the schema
const assertsPerson: Schema.Schema.ToAsserts<typeof Person> =
  Schema.asserts(Person)

try {
  // Attempt to assert that the input matches the Person schema
  assertsPerson({ name: "Alice", age: "30" })
} catch (e) {
  console.error("The input does not match the schema:")
  console.error(e)
}
/*
throws:
The input does not match the schema:
{
  _id: 'ParseError',
  message: '{ readonly name: string; readonly age: number }\n' +
    '└─ ["age"]\n' +
    '   └─ Expected number, actual "30"'
}
*/

// This input matches the schema and will not throw an error
assertsPerson({ name: "Alice", age: 30 })
```

The `assertsPerson` function generated from the schema has the following signature:

```ts
const assertsPerson: (
  input: unknown,
  overrideOptions?: number | ParseOptions
) => asserts input is {
  readonly name: string
  readonly age: number
}
```

## Managing Missing Properties

When decoding, it's important to understand how missing properties are processed. By default, if a property is not present in the input, it is treated as if it were present with an `undefined` value.

**Example** (Default Behavior of Missing Properties)

```ts

const schema = Schema.Struct({ a: Schema.Unknown })
const input = {}

console.log(Schema.decodeUnknownSync(schema)(input))
// Output: { a: undefined }
```

In this example, although the key `"a"` is not present in the input, it is treated as `{ a: undefined }` by default.

If you need your validation logic to differentiate between genuinely missing properties and those explicitly set to `undefined`, you can enable the `exact` option.

**Example** (Setting `exact: true` to Distinguish Missing Properties)

```ts

const schema = Schema.Struct({ a: Schema.Unknown })
const input = {}

console.log(Schema.decodeUnknownSync(schema)(input, { exact: true }))
/*
throws
ParseError: { readonly a: unknown }
└─ ["a"]
   └─ is missing
*/
```

For the APIs `Schema.is` and `Schema.asserts`, however, the default behavior is to treat missing properties strictly, where the default for `exact` is `true`:

**Example** (Strict Handling of Missing Properties with `Schema.is` and `Schema.asserts`)

```ts
import type { SchemaAST } from "effect"

const schema = Schema.Struct({ a: Schema.Unknown })
const input = {}

console.log(Schema.is(schema)(input))
// Output: false

console.log(Schema.is(schema)(input, { exact: false }))
// Output: true

const asserts: (
  u: unknown,
  overrideOptions?: SchemaAST.ParseOptions
) => asserts u is {
  readonly a: unknown
} = Schema.asserts(schema)

try {
  asserts(input)
  console.log("asserts passed")
} catch (e: any) {
  console.error("asserts failed")
  console.error(e.message)
}
/*
Output:
asserts failed
{ readonly a: unknown }
└─ ["a"]
  └─ is missing
*/

try {
  asserts(input, { exact: false })
  console.log("asserts passed")
} catch (e: any) {
  console.error("asserts failed")
  console.error(e.message)
}
// Output: asserts passed
```

## Naming Conventions

The naming conventions in `effect/Schema` are designed to be straightforward and logical, **focusing primarily on compatibility with JSON serialization**. This approach simplifies the understanding and use of schemas, especially for developers who are integrating web technologies where JSON is a standard data interchange format.

### Overview of Naming Strategies

**JSON-Compatible Types**

Schemas that naturally serialize to JSON-compatible formats are named directly after their data types.

For instance:

- `Schema.Date`: serializes JavaScript Date objects to ISO-formatted strings, a typical method for representing dates in JSON.
- `Schema.Number`: used directly as it maps precisely to the JSON number type, requiring no special transformation to remain JSON-compatible.

**Non-JSON-Compatible Types**

When dealing with types that do not have a direct representation in JSON, the naming strategy incorporates additional details to indicate the necessary transformation. This helps in setting clear expectations about the schema's behavior:

For instance:

- `Schema.DateFromSelf`: indicates that the schema handles `Date` objects, which are not natively JSON-serializable.
- `Schema.NumberFromString`: this naming suggests that the schema processes numbers that are initially represented as strings, emphasizing the transformation from string to number when decoding.

The primary goal of these schemas is to ensure that domain objects can be easily serialized ("encoded") and deserialized ("decoded") for transmission over network connections, thus facilitating their transfer between different parts of an application or across different applications.

### Rationale

While JSON's ubiquity justifies its primary consideration in naming, the conventions also accommodate serialization for other types of transport. For instance, converting a `Date` to a string is a universally useful method for various communication protocols, not just JSON. Thus, the selected naming conventions serve as sensible defaults that prioritize clarity and ease of use, facilitating the serialization and deserialization processes across diverse technological environments.


---

# [Basic Usage](https://effect.website/docs/schema/basic-usage/)

## Overview


## Primitives

The Schema module provides built-in schemas for common primitive types.

| Schema                  | Equivalent TypeScript Type |
| ----------------------- | -------------------------- |
| `Schema.String`         | `string`                   |
| `Schema.Number`         | `number`                   |
| `Schema.Boolean`        | `boolean`                  |
| `Schema.BigIntFromSelf` | `BigInt`                   |
| `Schema.SymbolFromSelf` | `symbol`                   |
| `Schema.Object`         | `object`                   |
| `Schema.Undefined`      | `undefined`                |
| `Schema.Void`           | `void`                     |
| `Schema.Any`            | `any`                      |
| `Schema.Unknown`        | `unknown`                  |
| `Schema.Never`          | `never`                    |

**Example** (Using a Primitive Schema)

```ts

const schema = Schema.String

// Infers the type as string
//
//     ┌─── string
//     ▼
type Type = typeof schema.Type

// Attempt to decode a null value, which will throw a parse error
Schema.decodeUnknownSync(schema)(null)
/*
throws:
ParseError: Expected string, actual null
*/
```

## asSchema

To make it easier to work with schemas, built-in schemas are exposed with shorter, opaque types when possible.

The `Schema.asSchema` function allows you to view any schema as `Schema<Type, Encoded, Context>`.

**Example** (Expanding a Schema with `asSchema`)

For example, while `Schema.String` is defined as a class with a type of `typeof Schema.String`, using `Schema.asSchema` provides the schema in its extended form as `Schema<string, string, never>`.

```ts

//     ┌─── typeof Schema.String
//     ▼
const schema = Schema.String

//     ┌─── Schema<string, string, never>
//     ▼
const nomalized = Schema.asSchema(schema)
```

## Unique Symbols

You can create a schema for unique symbols using `Schema.UniqueSymbolFromSelf`.

**Example** (Creating a Schema for a Unique Symbol)

```ts

const mySymbol = Symbol.for("mySymbol")

const schema = Schema.UniqueSymbolFromSelf(mySymbol)

//     ┌─── typeof mySymbol
//     ▼
type Type = typeof schema.Type

Schema.decodeUnknownSync(schema)(null)
/*
throws:
ParseError: Expected Symbol(mySymbol), actual null
*/
```

## Literals

Literal schemas represent a [literal type](https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#literal-types).
You can use them to specify exact values that a type must have.

Literals can be of the following types:

- `string`
- `number`
- `boolean`
- `null`
- `bigint`

**Example** (Defining Literal Schemas)

```ts

// Define various literal schemas
Schema.Null // Same as S.Literal(null)
Schema.Literal("a") // string literal
Schema.Literal(1) // number literal
Schema.Literal(true) // boolean literal
Schema.Literal(2n) // BigInt literal
```

**Example** (Defining a Literal Schema for `"a"`)

```ts

//     ┌─── Literal<["a"]>
//     ▼
const schema = Schema.Literal("a")

//     ┌─── "a"
//     ▼
type Type = typeof schema.Type

console.log(Schema.decodeUnknownSync(schema)("a"))
// Output: "a"

console.log(Schema.decodeUnknownSync(schema)("b"))
/*
throws:
ParseError: Expected "a", actual "b"
*/
```

### Union of Literals

You can create a union of multiple literals by passing them as arguments to the `Schema.Literal` constructor:

**Example** (Defining a Union of Literals)

```ts

//     ┌─── Literal<["a", "b", "c"]>
//     ▼
const schema = Schema.Literal("a", "b", "c")

//     ┌─── "a" | "b" | "c"
//     ▼
type Type = typeof schema.Type

Schema.decodeUnknownSync(schema)(null)
/*
throws:
ParseError: "a" | "b" | "c"
├─ Expected "a", actual null
├─ Expected "b", actual null
└─ Expected "c", actual null
*/
```

If you want to set a custom error message for the entire union of literals, you can use the `override: true` option (see [Custom Error Messages](/docs/schema/error-messages/#custom-error-messages) for more details) to specify a unified message.

**Example** (Adding a Custom Message to a Union of Literals)

```ts

// Schema with individual messages for each literal
const individualMessages = Schema.Literal("a", "b", "c")

console.log(Schema.decodeUnknownSync(individualMessages)(null))
/*
throws:
ParseError: "a" | "b" | "c"
├─ Expected "a", actual null
├─ Expected "b", actual null
└─ Expected "c", actual null
*/

// Schema with a unified custom message for all literals
const unifiedMessage = Schema.Literal("a", "b", "c").annotations({
  message: () => ({ message: "Not a valid code", override: true })
})

console.log(Schema.decodeUnknownSync(unifiedMessage)(null))
/*
throws:
ParseError: Not a valid code
*/
```

### Exposed Values

You can access the literals defined in a literal schema using the `literals` property:

```ts

const schema = Schema.Literal("a", "b", "c")

//      ┌─── readonly ["a", "b", "c"]
//      ▼
const literals = schema.literals
```

### The pickLiteral Utility

You can use `Schema.pickLiteral` with a literal schema to narrow down its possible values.

**Example** (Using `pickLiteral` to Narrow Values)

```ts

// Create a schema for a subset of literals ("a" and "b") from a larger set
//
//      ┌─── Literal<["a", "b"]>
//      ▼
const schema = Schema.Literal("a", "b", "c").pipe(
  Schema.pickLiteral("a", "b")
)
```

Sometimes, you may need to reuse a literal schema in other parts of your code. Below is an example demonstrating how to do this:

**Example** (Creating a Subtype from a Literal Schema)

```ts

// Define the base set of fruit categories
const FruitCategory = Schema.Literal("sweet", "citrus", "tropical")

// Define a general Fruit schema with the base category set
const Fruit = Schema.Struct({
  id: Schema.Number,
  category: FruitCategory
})

// Define a specific Fruit schema for only "sweet" and "citrus" categories
const SweetAndCitrusFruit = Schema.Struct({
  id: Schema.Number,
  category: FruitCategory.pipe(Schema.pickLiteral("sweet", "citrus"))
})
```

In this example, `FruitCategory` serves as the source of truth for the different fruit categories.
We reuse it to create a subtype of `Fruit` called `SweetAndCitrusFruit`, ensuring that only the specified categories (`"sweet"` and `"citrus"`) are allowed.
This approach helps maintain consistency throughout your code and provides type safety if the category definition changes.

## Template literals

In TypeScript, [template literals types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html) allow you to embed expressions within string literals.
The `Schema.TemplateLiteral` constructor allows you to create a schema for these template literal types.

**Example** (Defining Template Literals)

```ts

// This creates a schema for: `a${string}`
//
//      ┌─── TemplateLiteral<`a${string}`>
//      ▼
const schema1 = Schema.TemplateLiteral("a", Schema.String)

// This creates a schema for:
// `https://${string}.com` | `https://${string}.net`
const schema2 = Schema.TemplateLiteral(
  "https://",
  Schema.String,
  ".",
  Schema.Literal("com", "net")
)
```

**Example** (From [template literals types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html) Documentation)

Let's look at a more complex example. Suppose you have two sets of locale IDs for emails and footers.
You can use the `Schema.TemplateLiteral` constructor to create a schema that combines these IDs:

```ts

const EmailLocaleIDs = Schema.Literal("welcome_email", "email_heading")
const FooterLocaleIDs = Schema.Literal("footer_title", "footer_sendoff")

// This creates a schema for:
// "welcome_email_id" | "email_heading_id" |
// "footer_title_id" | "footer_sendoff_id"
const schema = Schema.TemplateLiteral(
  Schema.Union(EmailLocaleIDs, FooterLocaleIDs),
  "_id"
)
```

### Supported Span Types

The `Schema.TemplateLiteral` constructor supports the following types of spans:

- `Schema.String`
- `Schema.Number`
- Literals: `string | number | boolean | null | bigint`. These can be either wrapped by `Schema.Literal` or used directly
- Unions of the above types
- Brands of the above types

**Example** (Using a Branded String in a Template Literal)

```ts

// Create a branded string schema for an authorization token
const AuthorizationToken = Schema.String.pipe(
  Schema.brand("AuthorizationToken")
)

// This creates a schema for:
// `Bearer ${string & Brand<"AuthorizationToken">}`
const schema = Schema.TemplateLiteral("Bearer ", AuthorizationToken)
```

### TemplateLiteralParser

The `Schema.TemplateLiteral` constructor, while useful as a simple validator, only verifies that an input conforms to a specific string pattern by converting template literal definitions into regular expressions. Similarly, [`Schema.pattern`](/docs/schema/filters/#string-filters) employs regular expressions directly for the same purpose. Post-validation, both methods require additional manual parsing to convert the validated string into a usable data format.

To address these limitations and eliminate the need for manual post-validation parsing, the `Schema.TemplateLiteralParser` API has been developed. It not only validates the input format but also automatically parses it into a more structured and type-safe output, specifically into a **tuple** format.

The `Schema.TemplateLiteralParser` constructor supports the same types of [spans](#supported-span-types) as `Schema.TemplateLiteral`.

**Example** (Using TemplateLiteralParser for Parsing and Encoding)

```ts

//      ┌─── Schema<readonly [number, "a", string], `${string}a${string}`>
//      ▼
const schema = Schema.TemplateLiteralParser(
  Schema.NumberFromString,
  "a",
  Schema.NonEmptyString
)

console.log(Schema.decodeSync(schema)("100afoo"))
// Output: [ 100, 'a', 'foo' ]

console.log(Schema.encodeSync(schema)([100, "a", "foo"]))
// Output: '100afoo'
```

## Native enums

The Schema module provides support for native TypeScript enums. You can define a schema for an enum using `Schema.Enums`, allowing you to validate values that belong to the enum.

**Example** (Defining a Schema for an Enum)

```ts

enum Fruits {
  Apple,
  Banana
}

//      ┌─── Enums<typeof Fruits>
//      ▼
const schema = Schema.Enums(Fruits)

//
//     ┌─── Fruits
//     ▼
type Type = typeof schema.Type
```

### Exposed Values

Enums are accessible through the `enums` property of the schema. You can use this property to retrieve individual members or the entire set of enum values.

```ts

enum Fruits {
  Apple,
  Banana
}

const schema = Schema.Enums(Fruits)

schema.enums // Returns all enum members
schema.enums.Apple // Access the Apple member
schema.enums.Banana // Access the Banana member
```

## Unions

The Schema module includes a built-in `Schema.Union` constructor for creating "OR" types, allowing you to define schemas that can represent multiple types.

**Example** (Defining a Union Schema)

```ts

//      ┌─── Union<[typeof Schema.String, typeof Schema.Number]>
//      ▼
const schema = Schema.Union(Schema.String, Schema.Number)

//     ┌─── string | number
//     ▼
type Type = typeof schema.Type
```

### Union Member Evaluation Order

When decoding, union members are evaluated in the order they are defined. If a value matches the first member, it will be decoded using that schema. If not, the decoding process moves on to the next member.

If multiple schemas could decode the same value, the order matters. Placing a more general schema before a more specific one may result in missing properties, as the first matching schema will be used.

**Example** (Handling Overlapping Schemas in a Union)

```ts

// Define two overlapping schemas

const Member1 = Schema.Struct({
  a: Schema.String
})

const Member2 = Schema.Struct({
  a: Schema.String,
  b: Schema.Number
})

// ❌ Define a union where Member1 appears first
const Bad = Schema.Union(Member1, Member2)

console.log(Schema.decodeUnknownSync(Bad)({ a: "a", b: 12 }))
// Output: { a: 'a' }  (Member1 matched first, so `b` was ignored)

// ✅ Define a union where Member2 appears first
const Good = Schema.Union(Member2, Member1)

console.log(Schema.decodeUnknownSync(Good)({ a: "a", b: 12 }))
// Output: { a: 'a', b: 12 } (Member2 matched first, so `b` was included)
```

### Union of Literals

While you can create a union of literals by combining individual literal schemas:

**Example** (Using Individual Literal Schemas)

```ts

//      ┌─── Union<[Schema.Literal<["a"]>, Schema.Literal<["b"]>, Schema.Literal<["c"]>]>
//      ▼
const schema = Schema.Union(
  Schema.Literal("a"),
  Schema.Literal("b"),
  Schema.Literal("c")
)
```

You can simplify the process by passing multiple literals directly to the `Schema.Literal` constructor:

**Example** (Defining a Union of Literals)

```ts

//     ┌─── Literal<["a", "b", "c"]>
//     ▼
const schema = Schema.Literal("a", "b", "c")

//     ┌─── "a" | "b" | "c"
//     ▼
type Type = typeof schema.Type
```

If you want to set a custom error message for the entire union of literals, you can use the `override: true` option (see [Custom Error Messages](/docs/schema/error-messages/#custom-error-messages) for more details) to specify a unified message.

**Example** (Adding a Custom Message to a Union of Literals)

```ts

// Schema with individual messages for each literal
const individualMessages = Schema.Literal("a", "b", "c")

console.log(Schema.decodeUnknownSync(individualMessages)(null))
/*
throws:
ParseError: "a" | "b" | "c"
├─ Expected "a", actual null
├─ Expected "b", actual null
└─ Expected "c", actual null
*/

// Schema with a unified custom message for all literals
const unifiedMessage = Schema.Literal("a", "b", "c").annotations({
  message: () => ({ message: "Not a valid code", override: true })
})

console.log(Schema.decodeUnknownSync(unifiedMessage)(null))
/*
throws:
ParseError: Not a valid code
*/
```

### Nullables

The Schema module includes utility functions for defining schemas that allow nullable types, helping to handle values that may be `null`, `undefined`, or both.

**Example** (Creating Nullable Schemas)

```ts

// Represents a schema for a string or null value
Schema.NullOr(Schema.String)

// Represents a schema for a string, null, or undefined value
Schema.NullishOr(Schema.String)

// Represents a schema for a string or undefined value
Schema.UndefinedOr(Schema.String)
```

### Discriminated unions

[Discriminated unions](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions) in TypeScript are a way of modeling complex data structures that may take on different forms based on a specific set of conditions or properties. They allow you to define a type that represents multiple related shapes, where each shape is uniquely identified by a shared discriminant property.

In a discriminated union, each variant of the union has a common property, called the discriminant. The discriminant is a literal type, which means it can only have a finite set of possible values. Based on the value of the discriminant property, TypeScript can infer which variant of the union is currently in use.

**Example** (Defining a Discriminated Union in TypeScript)

```ts
type Circle = {
  readonly kind: "circle"
  readonly radius: number
}

type Square = {
  readonly kind: "square"
  readonly sideLength: number
}

type Shape = Circle | Square
```

In the `Schema` module, you can define a discriminated union similarly by specifying a literal field as the discriminant for each type.

**Example** (Defining a Discriminated Union Using Schema)

```ts

const Circle = Schema.Struct({
  kind: Schema.Literal("circle"),
  radius: Schema.Number
})

const Square = Schema.Struct({
  kind: Schema.Literal("square"),
  sideLength: Schema.Number
})

const Shape = Schema.Union(Circle, Square)
```

In this example, the `Schema.Literal` constructor sets up the `kind` property as the discriminant for both `Circle` and `Square` schemas. The `Shape` schema then represents a union of these two types, allowing TypeScript to infer the specific shape based on the `kind` value.

### Transforming a Simple Union into a Discriminated Union

If you start with a simple union and want to transform it into a discriminated union, you can add a special property to each member. This allows TypeScript to automatically infer the correct type based on the value of the discriminant property.

**Example** (Initial Simple Union)

For example, let's say you've defined a `Shape` union as a combination of `Circle` and `Square` without any special property:

```ts

const Circle = Schema.Struct({
  radius: Schema.Number
})

const Square = Schema.Struct({
  sideLength: Schema.Number
})

const Shape = Schema.Union(Circle, Square)
```

To make your code more manageable, you may want to transform the simple union into a discriminated union. This way, TypeScript will be able to automatically determine which member of the union you're working with based on the value of a specific property.

To achieve this, you can add a special property to each member of the union, which will allow TypeScript to know which type it's dealing with at runtime.
Here's how you can [transform](/docs/schema/transformations/#transform) the `Shape` schema into another schema that represents a discriminated union:

**Example** (Adding Discriminant Property)

```ts

const Circle = Schema.Struct({
  radius: Schema.Number
})

const Square = Schema.Struct({
  sideLength: Schema.Number
})

const DiscriminatedShape = Schema.Union(
  Schema.transform(
    Circle,
    // Add a "kind" property with the literal value "circle" to Circle
    Schema.Struct({ ...Circle.fields, kind: Schema.Literal("circle") }),
    {
      strict: true,
      // Add the discriminant property to Circle
      decode: (circle) => ({ ...circle, kind: "circle" as const }),
      // Remove the discriminant property
      encode: ({ kind: _kind, ...rest }) => rest
    }
  ),

  Schema.transform(
    Square,
    // Add a "kind" property with the literal value "square" to Square
    Schema.Struct({ ...Square.fields, kind: Schema.Literal("square") }),
    {
      strict: true,
      // Add the discriminant property to Square
      decode: (square) => ({ ...square, kind: "square" as const }),
      // Remove the discriminant property
      encode: ({ kind: _kind, ...rest }) => rest
    }
  )
)

console.log(Schema.decodeUnknownSync(DiscriminatedShape)({ radius: 10 }))
// Output: { radius: 10, kind: 'circle' }

console.log(
  Schema.decodeUnknownSync(DiscriminatedShape)({ sideLength: 10 })
)
// Output: { sideLength: 10, kind: 'square' }
```

The previous solution works perfectly and shows how we can add properties to our schema at will, making it easier to consume the result within our domain model.
However, it requires a lot of boilerplate. Fortunately, there is an API called `Schema.attachPropertySignature` designed specifically for this use case, which allows us to achieve the same result with much less effort:

**Example** (Using `Schema.attachPropertySignature` for Less Code)

```ts

const Circle = Schema.Struct({
  radius: Schema.Number
})

const Square = Schema.Struct({
  sideLength: Schema.Number
})

const DiscriminatedShape = Schema.Union(
  Circle.pipe(Schema.attachPropertySignature("kind", "circle")),
  Square.pipe(Schema.attachPropertySignature("kind", "square"))
)

// decoding
console.log(Schema.decodeUnknownSync(DiscriminatedShape)({ radius: 10 }))
// Output: { radius: 10, kind: 'circle' }

// encoding
console.log(
  Schema.encodeSync(DiscriminatedShape)({
    kind: "circle",
    radius: 10
  })
)
// Output: { radius: 10 }
```

> **Caution: Property Addition Only**
  Please note that with `Schema.attachPropertySignature`, you can only add
  a property, it cannot replace or override an existing one.


### Exposed Values

You can access the individual members of a union schema represented as a tuple:

```ts

const schema = Schema.Union(Schema.String, Schema.Number)

// Accesses the members of the union
const members = schema.members

//      ┌─── typeof Schema.String
//      ▼
const firstMember = members[0]

//      ┌─── typeof Schema.Number
//      ▼
const secondMember = members[1]
```

## Tuples

The Schema module allows you to define tuples, which are ordered collections of elements that may have different types.
You can define tuples with required, optional, or rest elements.

### Required Elements

To define a tuple with required elements, you can use the `Schema.Tuple` constructor and simply list the element schemas in order:

**Example** (Defining a Tuple with Required Elements)

```ts

// Define a tuple with a string and a number as required elements
//
//      ┌─── Tuple<[typeof Schema.String, typeof Schema.Number]>
//      ▼
const schema = Schema.Tuple(Schema.String, Schema.Number)

//     ┌─── readonly [string, number]
//     ▼
type Type = typeof schema.Type
```

### Append a Required Element

You can append additional required elements to an existing tuple by using the spread operator:

**Example** (Adding an Element to an Existing Tuple)

```ts

const tuple1 = Schema.Tuple(Schema.String, Schema.Number)

// Append a boolean to the existing tuple
const tuple2 = Schema.Tuple(...tuple1.elements, Schema.Boolean)

//     ┌─── readonly [string, number, boolean]
//     ▼
type Type = typeof tuple2.Type
```

### Optional Elements

To define an optional element, use the `Schema.optionalElement` constructor.

**Example** (Defining a Tuple with Optional Elements)

```ts

// Define a tuple with a required string and an optional number
const schema = Schema.Tuple(
  Schema.String, // required element
  Schema.optionalElement(Schema.Number) // optional element
)

//     ┌─── readonly [string, number?]
//     ▼
type Type = typeof schema.Type
```

### Rest Element

To define a rest element, add it after the list of required or optional elements.
The rest element allows the tuple to accept additional elements of a specific type.

**Example** (Using a Rest Element)

```ts

// Define a tuple with required elements and a rest element of type boolean
const schema = Schema.Tuple(
  [Schema.String, Schema.optionalElement(Schema.Number)], // elements
  Schema.Boolean // rest element
)

//     ┌─── readonly [string, number?, ...boolean[]]
//     ▼
type Type = typeof schema.Type
```

You can also include other elements after the rest:

**Example** (Including Additional Elements After a Rest Element)

```ts

// Define a tuple with required elements, a rest element,
// and an additional element
const schema = Schema.Tuple(
  [Schema.String, Schema.optionalElement(Schema.Number)], // elements
  Schema.Boolean, // rest element
  Schema.String // additional element
)

//     ┌─── readonly [string, number | undefined, ...boolean[], string]
//     ▼
type Type = typeof schema.Type
```

### Annotations

Annotations are useful for adding metadata to tuple elements, making it easier to describe their purpose or requirements.
This is especially helpful for generating documentation or JSON schemas.

**Example** (Adding Annotations to Tuple Elements)

```ts

// Define a tuple representing a point with annotations for each coordinate
const Point = Schema.Tuple(
  Schema.element(Schema.Number).annotations({
    title: "X",
    description: "X coordinate"
  }),
  Schema.optionalElement(Schema.Number).annotations({
    title: "Y",
    description: "optional Y coordinate"
  })
)

// Generate a JSON Schema from the tuple
console.log(JSONSchema.make(Point))
/*
Output:
{
  '$schema': 'http://json-schema.org/draft-07/schema#',
  type: 'array',
  minItems: 1,
  items: [
    { type: 'number', description: 'X coordinate', title: 'X' },
    {
      type: 'number',
      description: 'optional Y coordinate',
      title: 'Y'
    }
  ],
  additionalItems: false
}
*/
```

### Exposed Values

You can access the elements and rest elements of a tuple schema using the `elements` and `rest` properties:

**Example** (Accessing Elements and Rest Element in a Tuple Schema)

```ts

// Define a tuple with required, optional, and rest elements
const schema = Schema.Tuple(
  [Schema.String, Schema.optionalElement(Schema.Number)], // elements
  Schema.Boolean, // rest element
  Schema.String // additional element
)

// Access the required and optional elements of the tuple
//
//      ┌─── readonly [typeof Schema.String, Schema.Element<typeof Schema.Number, "?">]
//      ▼
const tupleElements = schema.elements

// Access the rest element of the tuple
//
//      ┌─── readonly [typeof Schema.Boolean, typeof Schema.String]
//      ▼
const restElement = schema.rest
```

## Arrays

The Schema module allows you to define schemas for arrays, making it easy to validate collections of elements of a specific type.

**Example** (Defining an Array Schema)

```ts

// Define a schema for an array of numbers
//
//      ┌─── Array$<typeof Schema.Number>
//      ▼
const schema = Schema.Array(Schema.Number)

//     ┌─── readonly number[]
//     ▼
type Type = typeof schema.Type
```

### Mutable Arrays

By default, `Schema.Array` generates a type marked as `readonly`.
To create a schema for a mutable array, you can use the `Schema.mutable` function, which makes the array type mutable in a **shallow** manner.

**Example** (Creating a Mutable Array Schema)

```ts

// Define a schema for a mutable array of numbers
//
//      ┌─── mutable<Schema.Array$<typeof Schema.Number>>
//      ▼
const schema = Schema.mutable(Schema.Array(Schema.Number))

//     ┌─── number[]
//     ▼
type Type = typeof schema.Type
```

### Exposed Values

You can access the value type of an array schema using the `value` property:

**Example** (Accessing the Value Type of an Array Schema)

```ts

const schema = Schema.Array(Schema.Number)

// Access the value type of the array schema
//
//      ┌─── typeof Schema.Number
//      ▼
const value = schema.value
```

## Non Empty Arrays

The Schema module also provides a way to define schemas for non-empty arrays, ensuring that the array always contains at least one element.

**Example** (Defining a Non-Empty Array Schema)

```ts

// Define a schema for a non-empty array of numbers
//
//      ┌─── NonEmptyArray<typeof Schema.Number>
//      ▼
const schema = Schema.NonEmptyArray(Schema.Number)

//     ┌─── readonly [number, ...number[]]
//     ▼
type Type = typeof schema.Type
```

### Exposed Values

You can access the value type of a non-empty array schema using the `value` property:

**Example** (Accessing the Value Type of a Non-Empty Array Schema)

```ts

// Define a schema for a non-empty array of numbers
const schema = Schema.NonEmptyArray(Schema.Number)

// Access the value type of the non-empty array schema
//
//      ┌─── typeof Schema.Number
//      ▼
const value = schema.value
```

## Records

The Schema module provides support for defining record types, which are collections of key-value pairs where the key can be a string, symbol, or other types, and the value has a defined schema.

### String Keys

You can define a record with string keys and a specified type for the values.

**Example** (String Keys with Number Values)

```ts

// Define a record schema with string keys and number values
//
//      ┌─── Record$<typeof Schema.String, typeof Schema.Number>
//      ▼
const schema = Schema.Record({ key: Schema.String, value: Schema.Number })

//     ┌─── { readonly [x: string]: number; }
//     ▼
type Type = typeof schema.Type
```

### Symbol Keys

Records can also use symbols as keys.

**Example** (Symbol Keys with Number Values)

```ts

// Define a record schema with symbol keys and number values
const schema = Schema.Record({
  key: Schema.SymbolFromSelf,
  value: Schema.Number
})

//     ┌─── { readonly [x: symbol]: number; }
//     ▼
type Type = typeof schema.Type
```

### Union of Literal Keys

Use a union of literals to restrict keys to a specific set of values.

**Example** (Union of String Literals as Keys)

```ts

// Define a record schema where keys are limited
// to specific string literals ("a" or "b")
const schema = Schema.Record({
  key: Schema.Union(Schema.Literal("a"), Schema.Literal("b")),
  value: Schema.Number
})

//     ┌─── { readonly a: number; readonly b: number; }
//     ▼
type Type = typeof schema.Type
```

### Template Literal Keys

Records can use template literals as keys, allowing for more complex key patterns.

**Example** (Template Literal Keys with Number Values)

```ts

// Define a record schema with keys that match
// the template literal pattern "a${string}"
const schema = Schema.Record({
  key: Schema.TemplateLiteral(Schema.Literal("a"), Schema.String),
  value: Schema.Number
})

//     ┌─── { readonly [x: `a${string}`]: number; }
//     ▼
type Type = typeof schema.Type
```

### Refined Keys

You can refine the key type with additional constraints.

**Example** (Filtering Keys by Minimum Length)

```ts

// Define a record schema where keys are strings with a minimum length of 2
const schema = Schema.Record({
  key: Schema.String.pipe(Schema.minLength(2)),
  value: Schema.Number
})

//     ┌─── { readonly [x: string]: number; }
//     ▼
type Type = typeof schema.Type
```

Refinements on keys act as filters rather than causing a decoding failure.
If a key does not meet the constraints (such as a pattern or minimum length check),
it is removed from the decoded output instead of triggering an error.

**Example** (Keys That Do Not Meet Constraints Are Removed)

```ts

const schema = Schema.Record({
  key: Schema.String.pipe(Schema.minLength(2)),
  value: Schema.Number
})

console.log(Schema.decodeUnknownSync(schema)({ a: 1, bb: 2 }))
// Output: { bb: 2 } ("a" is removed because it is too short)
```

If you want decoding to fail when a key does not meet the constraints,
you can set [`onExcessProperty`](/docs/schema/getting-started/#managing-excess-properties) to `"error"`.

**Example** (Forcing an Error on Invalid Keys)

```ts

const schema = Schema.Record({
  key: Schema.String.pipe(Schema.minLength(2)),
  value: Schema.Number
})

console.log(
  Schema.decodeUnknownSync(schema, { onExcessProperty: "error" })({
    a: 1,
    bb: 2
  })
)
/*
throws:
ParseError: { readonly [x: minLength(2)]: number }
└─ ["a"]
   └─ is unexpected, expected: minLength(2)
*/
```

### Transforming Keys

The `Schema.Record` API does not support transformations on key schemas.
Attempting to apply a transformation to keys will result in an `Unsupported key schema` error:

**Example** (Attempting to Transform Keys)

```ts

const schema = Schema.Record({
  key: Schema.Trim,
  value: Schema.NumberFromString
})
/*
throws:
Error: Unsupported key schema
schema (Transformation): Trim
*/
```

> **Note: Why Key Transformations Are Not Allowed**
  This restriction exists because transformations can create conflicts if
  multiple keys map to the same value after transformation. To prevent
  these issues, key transformations must be handled explicitly by the
  user.


To modify record keys, you must apply transformations outside of `Schema.Record`.
A common approach is to use [Schema.transform](/docs/schema/transformations/#transform) to adjust keys during decoding.

**Example** (Trimming Keys While Decoding)

```ts

const schema = Schema.transform(
  // Define the input schema with unprocessed keys
  Schema.Record({
    key: Schema.String,
    value: Schema.NumberFromString
  }),
  // Define the output schema with transformed keys
  Schema.Record({
    key: Schema.Trimmed,
    value: Schema.Number
  }),
  {
    strict: true,
    // Trim keys during decoding
    decode: (record) => Record.mapKeys(record, (key) => key.trim()),
    encode: identity
  }
)

console.log(
  Schema.decodeUnknownSync(schema)({ " key1 ": "1", key2: "2" })
)
// Output: { key1: 1, key2: 2 }
```

### Mutable Records

By default, `Schema.Record` generates a type marked as `readonly`.
To create a schema for a mutable record, you can use the `Schema.mutable` function, which makes the record type mutable in a **shallow** manner.

**Example** (Creating a Mutable Record Schema)

```ts

// Create a schema for a mutable record with string keys and number values
const schema = Schema.mutable(
  Schema.Record({ key: Schema.String, value: Schema.Number })
)

//     ┌─── { [x: string]: number; }
//     ▼
type Type = typeof schema.Type
```

### Exposed Values

You can access the `key` and `value` types of a record schema using the `key` and `value` properties:

**Example** (Accessing Key and Value Types)

```ts

const schema = Schema.Record({ key: Schema.String, value: Schema.Number })

// Accesses the key
//
//     ┌─── typeof Schema.String
//     ▼
const key = schema.key

// Accesses the value
//
//      ┌─── typeof Schema.Number
//      ▼
const value = schema.value
```

## Structs

### Property Signatures

The `Schema.Struct` constructor defines a schema for an object with specific properties.

**Example** (Defining a Struct Schema)

This example defines a struct schema for an object with the following properties:

- `name`: a string
- `age`: a number

```ts

//      ┌─── Schema.Struct<{
//      │      name: typeof Schema.String;
//      │      age: typeof Schema.Number;
//      │    }>
//      ▼
const schema = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

// The inferred TypeScript type from the schema
//
//     ┌─── {
//     │      readonly name: string;
//     │      readonly age: number;
//     │    }
//     ▼
type Type = typeof schema.Type
```

> **Caution: Empty Structs Allow Any Data**
  Using `Schema.Struct({})` results in a TypeScript type `{}`, which
  behaves similarly to `unknown`. This means that any data will be
  considered valid, as there are no defined constraints.


### Index Signatures

The `Schema.Struct` constructor can optionally accept a list of key/value pairs representing index signatures, allowing you to define additional dynamic properties.

```ts
declare const Struct: (props, ...indexSignatures) => Struct<...>
```

**Example** (Adding an Index Signature)

```ts

// Define a struct with a specific property "a"
// and an index signature allowing additional properties
const schema = Schema.Struct(
  // Defined properties
  { a: Schema.Number },
  // Index signature: allows additional string keys with number values
  { key: Schema.String, value: Schema.Number }
)

// The inferred TypeScript type:
//
//     ┌─── {
//     │      readonly [x: string]: number;
//     │      readonly a: number;
//     │    }
//     ▼
type Type = typeof schema.Type
```

**Example** (Using `Schema.Record`)

You can achieve the same result using `Schema.Record`:

```ts

// Define a struct with a fixed property "a"
// and a dynamic index signature using Schema.Record
const schema = Schema.Struct(
  { a: Schema.Number },
  Schema.Record({ key: Schema.String, value: Schema.Number })
)

// The inferred TypeScript type:
//
//     ┌─── {
//     │      readonly [x: string]: number;
//     │      readonly a: number;
//     │    }
//     ▼
type Type = typeof schema.Type
```

### Multiple Index Signatures

You can define **one** index signature per key type (`string` or `symbol`). Defining multiple index signatures of the same type is not allowed.

**Example** (Valid Multiple Index Signatures)

```ts

// Define a struct with a fixed property "a"
// and valid index signatures for both strings and symbols
const schema = Schema.Struct(
  { a: Schema.Number },
  // String index signature
  { key: Schema.String, value: Schema.Number },
  // Symbol index signature
  { key: Schema.SymbolFromSelf, value: Schema.Number }
)

// The inferred TypeScript type:
//
//     ┌─── {
//     │      readonly [x: string]: number;
//     │      readonly [x: symbol]: number;
//     │      readonly a: number;
//     │    }
//     ▼
type Type = typeof schema.Type
```

Defining multiple index signatures of the same key type (`string` or `symbol`) will cause an error.

**Example** (Invalid Multiple Index Signatures)

```ts

Schema.Struct(
  { a: Schema.Number },
  // Attempting to define multiple string index signatures
  { key: Schema.String, value: Schema.Number },
  { key: Schema.String, value: Schema.Boolean }
)
/*
throws:
Error: Duplicate index signature
details: string index signature
*/
```

### Conflicting Index Signatures

When defining schemas with index signatures, conflicts can arise if a fixed property has a different type than the values allowed by the index signature.
This can lead to unexpected TypeScript behavior.

**Example** (Conflicting Index Signature)

```ts

// Attempting to define a struct with a conflicting index signature
// - The fixed property "a" is a string
// - The index signature requires all values to be numbers
const schema = Schema.Struct(
  { a: Schema.String },
  { key: Schema.String, value: Schema.Number }
)

// ❌ Incorrect TypeScript type:
//
//     ┌─── {
//     │      readonly [x: string]: number;
//     │      readonly a: string;
//     │    }
//     ▼
type Type = typeof schema.Type
```

The TypeScript compiler flags this as an error when defining the type manually:

```ts
// @errors: 2411
// This type is invalid because the index signature
// conflicts with the fixed property `a`
type Test = {
  readonly a: string
  readonly [x: string]: number
}
```

This happens because TypeScript does not allow an index signature to contradict a fixed property.

#### Workaround for Conflicting Index Signatures

When working with schemas, a conflict can occur if a fixed property has a different type than the values allowed by an index signature. This situation often arises when dealing with external APIs that do not follow strict TypeScript conventions.

To prevent conflicts, you can separate the fixed properties from the indexed properties and handle them as distinct parts of the schema.

**Example** (Extracting Fixed and Indexed Properties)

Consider an object where:

- `"a"` is a fixed property of type `string`.
- All other keys store numbers, which conflict with `"a"`.

```ts
// @errors: 2411
// This type is invalid because the index signature
// conflicts with the fixed property `a`
type Test = {
  a: string
  [x: string]: number
}
```

To avoid this issue, we can separate the properties into two distinct types:

```ts
// Fixed properties schema
type FixedProperties = {
  readonly a: string
}

// Index signature properties schema
type IndexSignatureProperties = {
  readonly [x: string]: number
}

// The final output groups both properties in a tuple
type OutputData = readonly [FixedProperties, IndexSignatureProperties]
```

By using [Schema.transform](/docs/schema/transformations/#transform) and [Schema.compose](/docs/schema/transformations/#composition),
you can preprocess the input data before validation. This approach ensures that fixed properties and index signature properties are treated independently.

```ts

// Define a schema for the fixed property "a"
const FixedProperties = Schema.Struct({
  a: Schema.String
})

// Define a schema for index signature properties
const IndexSignatureProperties = Schema.Record({
  // Exclude keys that are already present in FixedProperties
  key: Schema.String.pipe(
    Schema.filter(
      (key) => !Object.keys(FixedProperties.fields).includes(key)
    )
  ),
  value: Schema.Number
})

// Create a schema that duplicates an object into two parts
const Duplicate = Schema.transform(
  Schema.Object,
  Schema.Tuple(Schema.Object, Schema.Object),
  {
    strict: true,
    // Create a tuple containing the input twice
    decode: (a) => [a, a] as const,
    // Merge both parts back when encoding
    encode: ([a, b]) => ({ ...a, ...b })
  }
)

//      ┌─── Schema<readonly [
//      |      { readonly a: string; },
//      |      { readonly [x: string]: number; }
//      |    ], object>
//      ▼
const Result = Schema.compose(
  Duplicate,
  Schema.Tuple(FixedProperties, IndexSignatureProperties).annotations({
    parseOptions: { onExcessProperty: "ignore" }
  })
)

// Decoding: Separates fixed and indexed properties
console.log(Schema.decodeUnknownSync(Result)({ a: "a", b: 1, c: 2 }))
// Output: [ { a: 'a' }, { b: 1, c: 2 } ]

// Encoding: Combines them back into an object
console.log(Schema.encodeSync(Result)([{ a: "a" }, { b: 1, c: 2 }]))
// Output: { a: 'a', b: 1, c: 2 }
```

### Exposed Values

You can access the fields and records of a struct schema using the `fields` and `records` properties:

**Example** (Accessing Fields and Records)

```ts

const schema = Schema.Struct(
  { a: Schema.Number },
  Schema.Record({ key: Schema.String, value: Schema.Number })
)

// Accesses the fields
//
//      ┌─── { readonly a: typeof Schema.Number; }
//      ▼
const fields = schema.fields

// Accesses the records
//
//      ┌─── readonly [Schema.Record$<typeof Schema.String, typeof Schema.Number>]
//      ▼
const records = schema.records
```

### Mutable Structs

By default, `Schema.Struct` generates a type with properties marked as `readonly`.
To create a mutable version of the struct, use the `Schema.mutable` function, which makes the properties mutable in a **shallow** manner.

**Example** (Creating a Mutable Struct Schema)

```ts

const schema = Schema.mutable(
  Schema.Struct({ a: Schema.String, b: Schema.Number })
)

//     ┌─── { a: string; b: number; }
//     ▼
type Type = typeof schema.Type
```

## Tagged Structs

In TypeScript tags help to enhance type discrimination and pattern matching by providing a simple yet powerful way to define and recognize different data types.

### What is a Tag?

A tag is a literal value added to data structures, commonly used in structs, to distinguish between various object types or variants within tagged unions. This literal acts as a discriminator, making it easier to handle and process different types of data correctly and efficiently.

### Using the tag Constructor

The `Schema.tag` constructor is specifically designed to create a property signature that holds a specific literal value, serving as the discriminator for object types.

**Example** (Defining a Tagged Struct)

```ts

const User = Schema.Struct({
  _tag: Schema.tag("User"),
  name: Schema.String,
  age: Schema.Number
})

//     ┌─── { readonly _tag: "User"; readonly name: string; readonly age: number; }
//     ▼
type Type = typeof User.Type

console.log(User.make({ name: "John", age: 44 }))
/*
Output:
{ _tag: 'User', name: 'John', age: 44 }
*/
```

In the example above, `Schema.tag("User")` attaches a `_tag` property to the `User` struct schema, effectively labeling objects of this struct type as "User".
This label is automatically applied when using the `make` method to create new instances, simplifying object creation and ensuring consistent tagging.

### Simplifying Tagged Structs with TaggedStruct

The `Schema.TaggedStruct` constructor streamlines the process of creating tagged structs by directly integrating the tag into the struct definition. This method provides a clearer and more declarative approach to building data structures with embedded discriminators.

**Example** (Using `TaggedStruct` for a Simplified Tagged Struct)

```ts

const User = Schema.TaggedStruct("User", {
  name: Schema.String,
  age: Schema.Number
})

// `_tag` is automatically applied when constructing an instance
console.log(User.make({ name: "John", age: 44 }))
// Output: { _tag: 'User', name: 'John', age: 44 }

// `_tag` is required when decoding from an unknown source
console.log(Schema.decodeUnknownSync(User)({ name: "John", age: 44 }))
/*
throws:
ParseError: { readonly _tag: "User"; readonly name: string; readonly age: number }
└─ ["_tag"]
   └─ is missing
*/
```

In this example:

- The `_tag` property is optional when constructing an instance with `make`, allowing the schema to automatically apply it.
- When decoding unknown data, `_tag` is required to ensure correct type identification. This distinction between instance construction and decoding is useful for preserving the tag’s role as a type discriminator while simplifying instance creation.

If you need `_tag` to be applied automatically during decoding as well, you can create a customized version of `Schema.TaggedStruct`:

**Example** (Custom `TaggedStruct` with `_tag` Applied during Decoding)

```ts
import type { SchemaAST } from "effect"

const TaggedStruct = <
  Tag extends SchemaAST.LiteralValue,
  Fields extends Schema.Struct.Fields
>(
  tag: Tag,
  fields: Fields
) =>
  Schema.Struct({
    _tag: Schema.Literal(tag).pipe(
      Schema.optional,
      Schema.withDefaults({
        constructor: () => tag, // Apply _tag during instance construction
        decoding: () => tag // Apply _tag during decoding
      })
    ),
    ...fields
  })

const User = TaggedStruct("User", {
  name: Schema.String,
  age: Schema.Number
})

console.log(User.make({ name: "John", age: 44 }))
// Output: { _tag: 'User', name: 'John', age: 44 }

console.log(Schema.decodeUnknownSync(User)({ name: "John", age: 44 }))
// Output: { _tag: 'User', name: 'John', age: 44 }
```

### Multiple Tags

While a primary tag is often sufficient, TypeScript allows you to define multiple tags for more complex data structuring needs. Here's an example demonstrating the use of multiple tags within a single struct:

**Example** (Adding Multiple Tags to a Struct)

This example defines a product schema with a primary tag (`"Product"`) and an additional category tag (`"Electronics"`), adding further specificity to the data structure.

```ts

const Product = Schema.TaggedStruct("Product", {
  category: Schema.tag("Electronics"),
  name: Schema.String,
  price: Schema.Number
})

// `_tag` and `category` are optional when creating an instance
console.log(Product.make({ name: "Smartphone", price: 999 }))
/*
Output:
{
  _tag: 'Product',
  category: 'Electronics',
  name: 'Smartphone',
  price: 999
}
*/
```

## instanceOf

When you need to define a schema for your custom data type defined through a `class`, the most convenient and fast way is to use the `Schema.instanceOf` constructor.

**Example** (Defining a Schema with `instanceOf`)

```ts

// Define a custom class
class MyData {
  constructor(readonly name: string) {}
}

// Create a schema for the class
const MyDataSchema = Schema.instanceOf(MyData)

//     ┌─── MyData
//     ▼
type Type = typeof MyDataSchema.Type

console.log(Schema.decodeUnknownSync(MyDataSchema)(new MyData("name")))
// Output: MyData { name: 'name' }

console.log(Schema.decodeUnknownSync(MyDataSchema)({ name: "name" }))
/*
throws:
ParseError: Expected MyData, actual {"name":"name"}
*/
```

The `Schema.instanceOf` constructor is just a lightweight wrapper of the [Schema.declare](/docs/schema/advanced-usage/#declaring-new-data-types) API, which is the primitive in `effect/Schema` for declaring new custom data types.

### Private Constructors

Note that `Schema.instanceOf` can only be used for classes that expose a **public constructor**.
If you try to use it with classes that, for some reason, have marked the constructor as `private`, you'll receive a TypeScript error:

**Example** (Error With Private Constructors)

```ts

class MyData {
  static make = (name: string) => new MyData(name)
  private constructor(readonly name: string) {}
}

// @errors: 2345
const MyDataSchema = Schema.instanceOf(MyData)
```

In such cases, you cannot use `Schema.instanceOf`, and you must rely on [Schema.declare](/docs/schema/advanced-usage/#declaring-new-data-types) like this:

**Example** (Using `Schema.declare` With Private Constructors)

```ts

class MyData {
  static make = (name: string) => new MyData(name)
  private constructor(readonly name: string) {}
}

const MyDataSchema = Schema.declare(
  (input: unknown): input is MyData => input instanceof MyData
).annotations({ identifier: "MyData" })

console.log(Schema.decodeUnknownSync(MyDataSchema)(MyData.make("name")))
// Output: MyData { name: 'name' }

console.log(Schema.decodeUnknownSync(MyDataSchema)({ name: "name" }))
/*
throws:
ParseError: Expected MyData, actual {"name":"name"}
*/
```

### Validating Fields of the Instance

To validate the fields of a class instance, you can use a [filter](/docs/schema/filters/). This approach combines instance validation with additional checks on the instance's fields.

**Example** (Adding Field Validation to an Instance Schema)

```ts

class MyData {
  constructor(readonly name: string) {}
}

const MyDataFields = Schema.Struct({
  name: Schema.NonEmptyString
})

// Define a schema for the class instance with additional field validation
const MyDataSchema = Schema.instanceOf(MyData).pipe(
  Schema.filter((a, options) =>
    // Validate the fields of the instance
    ParseResult.validateEither(MyDataFields)(a, options).pipe(
      // Invert success and failure for filtering
      Either.flip,
      // Return undefined if validation succeeds, or an error if it fails
      Either.getOrUndefined
    )
  )
)

// Example: Valid instance
console.log(Schema.validateSync(MyDataSchema)(new MyData("John")))
// Output: MyData { name: 'John' }

// Example: Invalid instance (empty name)
console.log(Schema.validateSync(MyDataSchema)(new MyData("")))
/*
throws:
ParseError: { MyData | filter }
└─ Predicate refinement failure
   └─ { readonly name: NonEmptyString }
      └─ ["name"]
         └─ NonEmptyString
            └─ Predicate refinement failure
               └─ Expected a non empty string, actual ""
*/
```

## Picking

The `pick` static function available on each struct schema can be used to create a new `Struct` by selecting specific properties from an existing `Struct`.

**Example** (Picking Properties from a Struct)

```ts

// Define a struct schema with properties "a", "b", and "c"
const MyStruct = Schema.Struct({
  a: Schema.String,
  b: Schema.Number,
  c: Schema.Boolean
})

// Create a new schema that picks properties "a" and "c"
//
//      ┌─── Struct<{
//      |      a: typeof Schema.String;
//      |      c: typeof Schema.Boolean;
//      |    }>
//      ▼
const PickedSchema = MyStruct.pick("a", "c")
```

The `Schema.pick` function can be applied more broadly beyond just `Struct` types, such as with unions of schemas.
However it returns a generic `SchemaClass`.

**Example** (Picking Properties from a Union)

```ts

// Define a union of two struct schemas
const MyUnion = Schema.Union(
  Schema.Struct({ a: Schema.String, b: Schema.String, c: Schema.String }),
  Schema.Struct({ a: Schema.Number, b: Schema.Number, d: Schema.Number })
)

// Create a new schema that picks properties "a" and "b"
//
//      ┌─── SchemaClass<{
//      |      readonly a: string | number;
//      |      readonly b: string | number;
//      |    }>
//      ▼
const PickedSchema = MyUnion.pipe(Schema.pick("a", "b"))
```

## Omitting

The `omit` static function available in each struct schema can be used to create a new `Struct` by excluding particular properties from an existing `Struct`.

**Example** (Omitting Properties from a Struct)

```ts

// Define a struct schema with properties "a", "b", and "c"
const MyStruct = Schema.Struct({
  a: Schema.String,
  b: Schema.Number,
  c: Schema.Boolean
})

// Create a new schema that omits property "b"
//
//      ┌─── Schema.Struct<{
//      |      a: typeof Schema.String;
//      |      c: typeof Schema.Boolean;
//      |    }>
//      ▼
const PickedSchema = MyStruct.omit("b")
```

The `Schema.omit` function can be applied more broadly beyond just `Struct` types, such as with unions of schemas.
However it returns a generic `Schema`.

**Example** (Omitting Properties from a Union)

```ts

// Define a union of two struct schemas
const MyUnion = Schema.Union(
  Schema.Struct({ a: Schema.String, b: Schema.String, c: Schema.String }),
  Schema.Struct({ a: Schema.Number, b: Schema.Number, d: Schema.Number })
)

// Create a new schema that omits property "b"
//
//      ┌─── SchemaClass<{
//      |      readonly a: string | number;
//      |    }>
//      ▼
const PickedSchema = MyUnion.pipe(Schema.omit("b"))
```

## partial

The `Schema.partial` function makes all properties within a schema optional.

**Example** (Making All Properties Optional)

```ts

// Create a schema with an optional property "a"
const schema = Schema.partial(Schema.Struct({ a: Schema.String }))

//     ┌─── { readonly a?: string | undefined; }
//     ▼
type Type = typeof schema.Type
```

By default, the `Schema.partial` operation adds `undefined` to the type of each property. If you want to avoid this, you can use `Schema.partialWith` and pass `{ exact: true }` as an argument.

**Example** (Defining an Exact Partial Schema)

```ts

// Create a schema with an optional property "a" without allowing undefined
const schema = Schema.partialWith(
  Schema.Struct({
    a: Schema.String
  }),
  { exact: true }
)

//     ┌─── { readonly a?: string; }
//     ▼
type Type = typeof schema.Type
```

## required

The `Schema.required` function ensures that all properties in a schema are mandatory.

**Example** (Making All Properties Required)

```ts

// Create a schema and make all properties required
const schema = Schema.required(
  Schema.Struct({
    a: Schema.optionalWith(Schema.String, { exact: true }),
    b: Schema.optionalWith(Schema.Number, { exact: true })
  })
)

//     ┌─── { readonly a: string; readonly b: number; }
//     ▼
type Type = typeof schema.Type
```

In this example, both `a` and `b` are made required, even though they were initially defined as optional.

## keyof

The `Schema.keyof` operation creates a schema that represents the keys of a given object schema.

**Example** (Extracting Keys from an Object Schema)

```ts

const schema = Schema.Struct({
  a: Schema.String,
  b: Schema.Number
})

const keys = Schema.keyof(schema)

//     ┌─── "a" | "b"
//     ▼
type Type = typeof keys.Type
```


---

# [Class APIs](https://effect.website/docs/schema/classes/)

## Overview


When working with schemas, you have a choice beyond the [Schema.Struct](/docs/schema/basic-usage/#structs) constructor.
You can leverage the power of classes through the `Schema.Class` utility, which comes with its own set of advantages tailored to common use cases:

Classes offer several features that simplify the schema creation process:

- **All-in-One Definition**: With classes, you can define both a schema and an opaque type simultaneously.
- **Shared Functionality**: You can incorporate shared functionality using class methods or getters.
- **Value Hashing and Equality**: Utilize the built-in capability for checking value equality and applying hashing (thanks to `Class` implementing [Data.Class](/docs/data-types/data/#class)).

> **Caution: Class Schemas Are Transformations**
  Classes defined with `Schema.Class` act as
  [transformations](/docs/schema/transformations/). See [Class Schemas are
  Transformations](#class-schemas-are-transformations) for details.


## Definition

To define a class using `Schema.Class`, you need to specify:

- The **type** of the class being created.
- A unique **identifier** for the class.
- The desired **fields**.

**Example** (Defining a Schema Class)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}
```

In this example, `Person` is both a schema and a TypeScript class. Instances of `Person` are created using the defined schema, ensuring compliance with the specified fields.

**Example** (Creating Instances)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

console.log(new Person({ id: 1, name: "John" }))
/*
Output:
Person { id: 1, name: 'John' }
*/

// Using the factory function
console.log(Person.make({ id: 1, name: "John" }))
/*
Output:
Person { id: 1, name: 'John' }
*/
```

> **Note: Why Use Identifiers?**
  You need to specify an identifier to make the class global. This ensures that two classes with the same identifier refer to the same instance, avoiding reliance on `instanceof` checks.

This behavior is similar to how we handle other class-based APIs like [Context.Tag](/docs/requirements-management/services/#creating-a-service).

Using a unique identifier is particularly useful in scenarios where live reloads can occur, as it helps preserve the instance across reloads. It ensures there is no duplication of instances (although it shouldn't happen, some bundlers and frameworks can behave unpredictably).



### Class Schemas are Transformations

Class schemas [transform](/docs/schema/transformations/) a struct schema into a [declaration](/docs/schema/advanced-usage/#declaring-new-data-types) schema that represents a class type.

- When decoding, a plain object is converted into an instance of the class.
- When encoding, a class instance is converted back into a plain object.

**Example** (Decoding and Encoding a Class)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

const person = Person.make({ id: 1, name: "John" })

// Decode from a plain object into a class instance
const decoded = Schema.decodeUnknownSync(Person)({ id: 1, name: "John" })
console.log(decoded)
// Output: Person { id: 1, name: 'John' }

// Encode a class instance back into a plain object
const encoded = Schema.encodeUnknownSync(Person)(person)
console.log(encoded)
// Output: { id: 1, name: 'John' }
```

### Defining Classes Without Fields

When your schema does not require any fields, you can define a class with an empty object.

**Example** (Defining and Using a Class Without Arguments)

```ts

// Define a class with no fields
class NoArgs extends Schema.Class<NoArgs>("NoArgs")({}) {}

// Create an instance using the default constructor
const noargs1 = new NoArgs()

// Alternatively, create an instance by explicitly passing an empty object
const noargs2 = new NoArgs({})
```

### Defining Classes With Filters

Filters allow you to validate input when decoding, encoding, or creating an instance. Instead of specifying raw fields, you can pass a `Schema.Struct` with a filter applied.

**Example** (Applying a Filter to a Schema Class)

```ts

class WithFilter extends Schema.Class<WithFilter>("WithFilter")(
  Schema.Struct({
    a: Schema.NumberFromString,
    b: Schema.NumberFromString
  }).pipe(
    Schema.filter(({ a, b }) => a >= b || "a must be greater than b")
  )
) {}

// Constructor
console.log(new WithFilter({ a: 1, b: 2 }))
/*
throws:
ParseError: WithFilter (Constructor)
└─ Predicate refinement failure
   └─ a must be greater than b
*/

// Decoding
console.log(Schema.decodeUnknownSync(WithFilter)({ a: "1", b: "2" }))
/*
throws:
ParseError: (WithFilter (Encoded side) <-> WithFilter)
└─ Encoded side transformation failure
   └─ WithFilter (Encoded side)
      └─ Predicate refinement failure
         └─ a must be greater than b
*/
```

## Validating Properties via Class Constructors

When you define a class using `Schema.Class`, the constructor automatically checks that the provided properties adhere to the schema's rules.

### Defining and Instantiating a Valid Class Instance

The constructor ensures that each property, like `id` and `name`, adheres to the schema. For instance, `id` must be a number, and `name` must be a non-empty string.

**Example** (Creating a Valid Instance)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

// Create an instance with valid properties
const john = new Person({ id: 1, name: "John" })
```

### Handling Invalid Properties

If invalid properties are provided during instantiation, the constructor throws an error, explaining why the validation failed.

**Example** (Creating an Instance with Invalid Properties)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

// Attempt to create an instance with an invalid `name`
new Person({ id: 1, name: "" })
/*
throws:
ParseError: Person (Constructor)
└─ ["name"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/
```

The error clearly specifies that the `name` field failed to meet the `NonEmptyString` requirement.

### Bypassing Validation

In some scenarios, you might want to bypass the validation logic. While not generally recommended, the library provides an option to do so.

**Example** (Bypassing Validation)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

// Bypass validation during instantiation
const john = new Person({ id: 1, name: "" }, true)

// Or use the `disableValidation` option explicitly
new Person({ id: 1, name: "" }, { disableValidation: true })
```

## Automatic Hashing and Equality in Classes

Instances of classes created with `Schema.Class` support the [Equal](/docs/trait/equal/) trait through their integration with [Data.Class](/docs/data-types/data/#class). This enables straightforward value comparisons, even across different instances.

### Basic Equality Check

Two class instances are considered equal if their properties have identical values.

**Example** (Comparing Instances with Equal Properties)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

const john1 = new Person({ id: 1, name: "John" })
const john2 = new Person({ id: 1, name: "John" })

// Compare instances
console.log(Equal.equals(john1, john2))
// Output: true
```

### Nested or Complex Properties

The `Equal` trait performs comparisons at the first level. If a property is a more complex structure, such as an array, instances may not be considered equal, even if the arrays themselves have identical values.

**Example** (Shallow Equality for Arrays)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
  hobbies: Schema.Array(Schema.String) // Standard array schema
}) {}

const john1 = new Person({
  id: 1,
  name: "John",
  hobbies: ["reading", "coding"]
})
const john2 = new Person({
  id: 1,
  name: "John",
  hobbies: ["reading", "coding"]
})

// Equality fails because `hobbies` are not deeply compared
console.log(Equal.equals(john1, john2))
// Output: false
```

To achieve deep equality for nested structures like arrays, use `Schema.Data` in combination with `Data.array`. This enables the library to compare each element of the array rather than treating it as a single entity.

**Example** (Using `Schema.Data` for Deep Equality)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString,
  hobbies: Schema.Data(Schema.Array(Schema.String)) // Enable deep equality
}) {}

const john1 = new Person({
  id: 1,
  name: "John",
  hobbies: Data.array(["reading", "coding"])
})
const john2 = new Person({
  id: 1,
  name: "John",
  hobbies: Data.array(["reading", "coding"])
})

// Equality succeeds because `hobbies` are deeply compared
console.log(Equal.equals(john1, john2))
// Output: true
```

## Extending Classes with Custom Logic

Schema classes provide the flexibility to include custom getters and methods, allowing you to extend their functionality beyond the defined fields.

### Adding Custom Getters

A getter can be used to derive computed values from the fields of the class. For example, a `Person` class can include a getter to return the `name` property in uppercase.

**Example** (Adding a Getter for Uppercase Name)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {
  // Custom getter to return the name in uppercase
  get upperName() {
    return this.name.toUpperCase()
  }
}

const john = new Person({ id: 1, name: "John" })

// Use the custom getter
console.log(john.upperName)
// Output: "JOHN"
```

### Adding Custom Methods

In addition to getters, you can define methods to encapsulate more complex logic or operations involving the class's fields.

**Example** (Adding a Method)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {
  // Custom method to return a greeting
  greet() {
    return `Hello, my name is ${this.name}.`
  }
}

const john = new Person({ id: 1, name: "John" })

// Use the custom method
console.log(john.greet())
// Output: "Hello, my name is John."
```

## Leveraging Classes as Schema Definitions

When you define a class with `Schema.Class`, it serves both as a schema and as a class. This dual functionality allows the class to be used wherever a schema is required.

**Example** (Using a Class in an Array Schema)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

// Use the Person class in an array schema
const Persons = Schema.Array(Person)

//     ┌─── readonly Person[]
//     ▼
type Type = typeof Persons.Type
```

### Exposed Values

The class also includes a `fields` static property, which outlines the fields defined during the class creation.

**Example** (Accessing the `fields` Property)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

//       ┌─── {
//       |      readonly id: typeof Schema.Number;
//       |      readonly name: typeof Schema.NonEmptyString;
//       |    }
//       ▼
Person.fields
```

## Adding Annotations

Defining a class with `Schema.Class` is similar to creating a [transformation](/docs/schema/transformations/) schema that converts a struct schema into a [declaration](/docs/schema/advanced-usage/#declaring-new-data-types) schema representing the class type.

For example, consider the following class definition:

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}
```

Under the hood, this definition creates a transformation schema that maps:

```ts
Schema.Struct({
  id: Schema.Number,
  name: Schema.NonEmptyString
})
```

to a schema representing the `Person` class:

```ts
Schema.declare((input) => input instanceof Person)
```

So, defining a schema with `Schema.Class` involves three schemas:

- The "from" schema (the struct)
- The "to" schema (the class)
- The "transformation" schema (struct -> class)

You can annotate each of these schemas by passing a tuple as the second argument to the `Schema.Class` API.

**Example** (Annotating Different Parts of the Class Schema)

```ts

class Person extends Schema.Class<Person>("Person")(
  {
    id: Schema.Number,
    name: Schema.NonEmptyString
  },
  [
    // Annotations for the "to" schema
    { description: `"to" description` },

    // Annotations for the "transformation schema
    { description: `"transformation" description` },

    // Annotations for the "from" schema
    { description: `"from" description` }
  ]
) {}

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.to))
// Output: { _id: 'Option', _tag: 'Some', value: '"to" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast))
// Output: { _id: 'Option', _tag: 'Some', value: '"transformation" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.from))
// Output: { _id: 'Option', _tag: 'Some', value: '"from" description' }
```

If you do not want to annotate all three schemas, you can pass `undefined` for the ones you wish to skip.

**Example** (Skipping Annotations)

```ts

class Person extends Schema.Class<Person>("Person")(
  {
    id: Schema.Number,
    name: Schema.NonEmptyString
  },
  [
    // No annotations for the "to" schema
    undefined,

    // Annotations for the "transformation schema
    { description: `"transformation" description` }
  ]
) {}

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.to))
// Output: { _id: 'Option', _tag: 'None' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast))
// Output: { _id: 'Option', _tag: 'Some', value: '"transformation" description' }

console.log(SchemaAST.getDescriptionAnnotation(Person.ast.from))
// Output: { _id: 'Option', _tag: 'None' }
```

By default, the unique identifier used to define the class is also applied as the default `identifier` annotation for the Class Schema.

**Example** (Default Identifier Annotation)

```ts

// Used as default identifier annotation ────┐
//                                           |
//                                           ▼
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {}

console.log(SchemaAST.getIdentifierAnnotation(Person.ast.to))
// Output: { _id: 'Option', _tag: 'Some', value: 'Person' }
```

## Recursive Schemas

The `Schema.suspend` combinator is useful when you need to define a schema that depends on itself, like in the case of recursive data structures.
In this example, the `Category` schema depends on itself because it has a field `subcategories` that is an array of `Category` objects.

**Example** (Self-Referencing Schema)

```ts

// Define a Category schema with a recursive subcategories field
class Category extends Schema.Class<Category>("Category")({
  name: Schema.String,
  subcategories: Schema.Array(
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
}) {}
```

> **Note: Correct Inference**
  It is necessary to add an explicit type annotation because otherwise
  TypeScript would struggle to infer types correctly. Without this
  annotation, you might encounter this error message:


**Example** (Missing Type Annotation Error)

```ts

// @errors: 2506 7024
class Category extends Schema.Class<Category>("Category")({
  name: Schema.String,
  subcategories: Schema.Array(Schema.suspend(() => Category))
}) {}
```

### Mutually Recursive Schemas

Sometimes, schemas depend on each other in a mutually recursive way. For instance, an arithmetic expression tree might include `Expression` nodes that can either be numbers or `Operation` nodes, which in turn reference `Expression` nodes.

**Example** (Arithmetic Expression Tree)

```ts

class Expression extends Schema.Class<Expression>("Expression")({
  type: Schema.Literal("expression"),
  value: Schema.Union(
    Schema.Number,
    Schema.suspend((): Schema.Schema<Operation> => Operation)
  )
}) {}

class Operation extends Schema.Class<Operation>("Operation")({
  type: Schema.Literal("operation"),
  operator: Schema.Literal("+", "-"),
  left: Expression,
  right: Expression
}) {}
```

### Recursive Types with Different Encoded and Type

Defining recursive schemas where the `Encoded` type differs from the `Type` type introduces additional complexity. For instance, if a schema includes fields that transform data (e.g., `NumberFromString`), the `Encoded` and `Type` types may not align.

In such cases, we need to define an interface for the `Encoded` type.

Let's consider an example: suppose we want to add an `id` field to the `Category` schema, where the schema for `id` is `NumberFromString`.
It's important to note that `NumberFromString` is a schema that transforms a string into a number, so the `Type` and `Encoded` types of `NumberFromString` differ, being `number` and `string` respectively.
When we add this field to the `Category` schema, TypeScript raises an error:

```ts

class Category extends Schema.Class<Category>("Category")({
  id: Schema.NumberFromString,
  name: Schema.String,
  subcategories: Schema.Array(
// @errors: 2322
    Schema.suspend((): Schema.Schema<Category> => Category)
  )
}) {}
```

This error occurs because the explicit annotation `S.suspend((): S.Schema<Category> => Category` is no longer sufficient and needs to be adjusted by explicitly adding the `Encoded` type:

**Example** (Adjusting the Schema with Explicit `Encoded` Type)

```ts

interface CategoryEncoded {
  readonly id: string
  readonly name: string
  readonly subcategories: ReadonlyArray<CategoryEncoded>
}

class Category extends Schema.Class<Category>("Category")({
  id: Schema.NumberFromString,
  name: Schema.String,
  subcategories: Schema.Array(
    Schema.suspend(
      (): Schema.Schema<Category, CategoryEncoded> => Category
    )
  )
}) {}
```

As we've observed, it's necessary to define an interface for the `Encoded` of the schema to enable recursive schema definition, which can complicate things and be quite tedious.
One pattern to mitigate this is to **separate the field responsible for recursion** from all other fields.

**Example** (Separating Recursive Field)

```ts

const fields = {
  id: Schema.NumberFromString,
  name: Schema.String
  // ...possibly other fields
}

interface CategoryEncoded extends Schema.Struct.Encoded<typeof fields> {
  // Define `subcategories` using recursion
  readonly subcategories: ReadonlyArray<CategoryEncoded>
}

class Category extends Schema.Class<Category>("Category")({
  ...fields, // Include the fields
  subcategories: Schema.Array(
    // Define `subcategories` using recursion
    Schema.suspend(
      (): Schema.Schema<Category, CategoryEncoded> => Category
    )
  )
}) {}
```

## Tagged Class variants

You can also create classes that extend [TaggedClass](/docs/data-types/data/#taggedclass) and [TaggedError](/docs/data-types/data/#taggederror) from the `effect/Data` module.

**Example** (Creating Tagged Classes and Errors)

```ts

// Define a tagged class with a "name" field
class TaggedPerson extends Schema.TaggedClass<TaggedPerson>()(
  "TaggedPerson",
  {
    name: Schema.String
  }
) {}

// Define a tagged error with a "status" field
class HttpError extends Schema.TaggedError<HttpError>()("HttpError", {
  status: Schema.Number
}) {}

const joe = new TaggedPerson({ name: "Joe" })
console.log(joe._tag)
// Output: "TaggedPerson"

const error = new HttpError({ status: 404 })
console.log(error._tag)
// Output: "HttpError"

console.log(error.stack) // access the stack trace
```

## Extending existing Classes

The `extend` static utility allows you to enhance an existing schema class by adding **additional** fields and functionality. This approach helps in building on top of existing schemas without redefining them from scratch.

**Example** (Extending a Schema Class)

```ts

// Define the base class
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {
  // A custom getter that converts the name to uppercase
  get upperName() {
    return this.name.toUpperCase()
  }
}

// Extend the base class to include an "age" field
class PersonWithAge extends Person.extend<PersonWithAge>("PersonWithAge")(
  {
    age: Schema.Number
  }
) {
  // A custom getter to check if the person is an adult
  get isAdult() {
    return this.age >= 18
  }
}

// Usage
const john = new PersonWithAge({ id: 1, name: "John", age: 25 })
console.log(john.upperName) // Output: "JOHN"
console.log(john.isAdult) // Output: true
```

Note that you can only add additional fields when extending a class.

**Example** (Attempting to Overwrite Existing Fields)

```ts

class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.NonEmptyString
}) {
  get upperName() {
    return this.name.toUpperCase()
  }
}

class BadExtension extends Person.extend<BadExtension>("BadExtension")({
  name: Schema.Number
}) {}
/*
throws:
Error: Duplicate property signature
details: Duplicate key "name"
*/
```

This error occurs because allowing fields to be overwritten is not safe. It could interfere with any getters or methods defined on the class that rely on the original definition. For example, in this case, the `upperName` getter would break if the `name` field was changed to a number.

## Transformations

You can enhance schema classes with effectful transformations to enrich or validate entities, particularly when working with data sourced from external systems like databases or APIs.

**Example** (Effectful Transformation)

The following example demonstrates adding an `age` field to a `Person` class. The `age` value is derived asynchronously based on the `id` field.

```ts

// Base class definition
class Person extends Schema.Class<Person>("Person")({
  id: Schema.Number,
  name: Schema.String
}) {}

console.log(Schema.decodeUnknownSync(Person)({ id: 1, name: "name" }))
/*
Output:
Person { id: 1, name: 'name' }
*/

// Simulate fetching age asynchronously based on id
function getAge(id: number): Effect.Effect<number, Error> {
  return Effect.succeed(id + 2)
}

// Extended class with a transformation
class PersonWithTransform extends Person.transformOrFail<PersonWithTransform>(
  "PersonWithTransform"
)(
  {
    age: Schema.optionalWith(Schema.Number, { exact: true, as: "Option" })
  },
  {
    // Decoding logic for the new field
    decode: (input) =>
      Effect.mapBoth(getAge(input.id), {
        onFailure: (e) =>
          new ParseResult.Type(Schema.String.ast, input.id, e.message),
        // Must return { age: Option<number> }
        onSuccess: (age) => ({ ...input, age: Option.some(age) })
      }),
    encode: ParseResult.succeed
  }
) {}

Schema.decodeUnknownPromise(PersonWithTransform)({
  id: 1,
  name: "name"
}).then(console.log)
/*
Output:
PersonWithTransform {
  id: 1,
  name: 'name',
  age: { _id: 'Option', _tag: 'Some', value: 3 }
}
*/

// Extended class with a conditional Transformation
class PersonWithTransformFrom extends Person.transformOrFailFrom<PersonWithTransformFrom>(
  "PersonWithTransformFrom"
)(
  {
    age: Schema.optionalWith(Schema.Number, { exact: true, as: "Option" })
  },
  {
    decode: (input) =>
      Effect.mapBoth(getAge(input.id), {
        onFailure: (e) =>
          new ParseResult.Type(Schema.String.ast, input, e.message),
        // Must return { age?: number }
        onSuccess: (age) => (age > 18 ? { ...input, age } : { ...input })
      }),
    encode: ParseResult.succeed
  }
) {}

Schema.decodeUnknownPromise(PersonWithTransformFrom)({
  id: 1,
  name: "name"
}).then(console.log)
/*
Output:
PersonWithTransformFrom {
  id: 1,
  name: 'name',
  age: { _id: 'Option', _tag: 'None' }
}
*/
```

The decision of which API to use, either `transformOrFail` or `transformOrFailFrom`, depends on when you wish to execute the transformation:

1. Using `transformOrFail`:

   - The transformation occurs at the end of the process.
   - It expects you to provide a value of type `{ age: Option<number> }`.
   - After processing the initial input, the new transformation comes into play, and you need to ensure the final output adheres to the specified structure.

2. Using `transformOrFailFrom`:
   - The new transformation starts as soon as the initial input is handled.
   - You should provide a value `{ age?: number }`.
   - Based on this fresh input, the subsequent transformation `Schema.optionalWith(Schema.Number, { exact: true, as: "Option" })` is executed.
   - This approach allows for immediate handling of the input, potentially influencing the subsequent transformations.


---

# [Default Constructors](https://effect.website/docs/schema/default-constructors/)

## Overview


When working with data structures, it can be helpful to create values that conform to a schema with minimal effort.
For this purpose, the Schema module provides default constructors for various schema types, including `Structs`, `Records`, `filters`, and `brands`.

> **Note: Constructor Scope**
  Default constructors associated with a schema of type `Schema<A, I, R>` operate specifically on the **decoded type** (`A`), not the encoded type (`I`).

- **`A` (Decoded Type)**: This is the type produced after decoding and validation. The constructor creates values of this type.
- `I` (Encoded Type): This is the type expected when decoding raw input. The constructor does not accept this type directly.

This distinction is important when working with schemas that transform data. For example, if a schema **decodes a string into a number**, the default constructor will only accept **numbers**, not strings.



Default constructors are **unsafe**, meaning they **throw an error** if the input does not conform to the schema.
If you need a safer alternative, consider using [Schema.validateEither](#error-handling-in-constructors), which returns a result indicating success or failure instead of throwing an error.

**Example** (Using a Refinement Default Constructor)

```ts

const schema = Schema.NumberFromString.pipe(Schema.between(1, 10))

// The constructor only accepts numbers
console.log(schema.make(5))
// Output: 5

// This will throw an error because the number is outside the valid range
console.log(schema.make(20))
/*
throws:
ParseError: between(1, 10)
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/
```

## Structs

Struct schemas allow you to define objects with specific fields and constraints. The `make` function can be used to create instances of a struct schema.

**Example** (Creating Struct Instances)

```ts

const Struct = Schema.Struct({
  name: Schema.NonEmptyString
})

// Successful creation
Struct.make({ name: "a" })

// This will throw an error because the name is empty
Struct.make({ name: "" })
/*
throws
ParseError: { readonly name: NonEmptyString }
└─ ["name"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/
```

In some cases, you might need to bypass validation. While not recommended in most scenarios, `make` provides an option to disable validation.

**Example** (Bypassing Validation)

```ts

const Struct = Schema.Struct({
  name: Schema.NonEmptyString
})

// Bypass validation during instantiation
Struct.make({ name: "" }, true)

// Or use the `disableValidation` option explicitly
Struct.make({ name: "" }, { disableValidation: true })
```

## Records

Record schemas allow you to define key-value mappings where the keys and values must meet specific criteria.

**Example** (Creating Record Instances)

```ts

const Record = Schema.Record({
  key: Schema.String,
  value: Schema.NonEmptyString
})

// Successful creation
Record.make({ a: "a", b: "b" })

// This will throw an error because 'b' is empty
Record.make({ a: "a", b: "" })
/*
throws
ParseError: { readonly [x: string]: NonEmptyString }
└─ ["b"]
   └─ NonEmptyString
      └─ Predicate refinement failure
         └─ Expected NonEmptyString, actual ""
*/

// Bypasses validation
Record.make({ a: "a", b: "" }, { disableValidation: true })
```

## Filters

Filters allow you to define constraints on individual values.

**Example** (Using Filters to Enforce Ranges)

```ts

const MyNumber = Schema.Number.pipe(Schema.between(1, 10))

// Successful creation
const n = MyNumber.make(5)

// This will throw an error because the number is outside the valid range
MyNumber.make(20)
/*
throws
ParseError: a number between 1 and 10
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/

// Bypasses validation
MyNumber.make(20, { disableValidation: true })
```

## Branded Types

Branded schemas add metadata to a value to give it a more specific type, while still retaining its original type.

**Example** (Creating Branded Values)

```ts

const BrandedNumberSchema = Schema.Number.pipe(
  Schema.between(1, 10),
  Schema.brand("MyNumber")
)

// Successful creation
const n = BrandedNumberSchema.make(5)

// This will throw an error because the number is outside the valid range
BrandedNumberSchema.make(20)
/*
throws
ParseError: a number between 1 and 10 & Brand<"MyNumber">
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10 & Brand<"MyNumber">, actual 20
*/

// Bypasses validation
BrandedNumberSchema.make(20, { disableValidation: true })
```

When using default constructors, it is helpful to understand the type of value they produce.

For instance, in the `BrandedNumberSchema` example, the return type of the constructor is `number & Brand<"MyNumber">`. This indicates that the resulting value is a `number` with additional branding information, `"MyNumber"`.

This behavior contrasts with the filter example, where the return type is simply `number`. Branding adds an extra layer of type information, which can assist in identifying and working with your data more effectively.

## Error Handling in Constructors

Default constructors are considered "unsafe" because they throw an error if the input does not conform to the schema. This error includes a detailed description of what went wrong. The intention behind default constructors is to provide a straightforward way to create valid values, such as for tests or configurations, where invalid inputs are expected to be exceptional cases.

If you need a "safe" constructor that does not throw errors but instead returns a result indicating success or failure, you can use `Schema.validateEither`.

**Example** (Using `Schema.validateEither` for Safe Validation)

```ts

const schema = Schema.NumberFromString.pipe(Schema.between(1, 10))

// Create a safe constructor that validates an unknown input
const safeMake = Schema.validateEither(schema)

// Valid input returns a Right value
console.log(safeMake(5))
/*
Output:
{ _id: 'Either', _tag: 'Right', right: 5 }
*/

// Invalid input returns a Left value with detailed error information
console.log(safeMake(20))
/*
Output:
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: 'between(1, 10)\n' +
      '└─ Predicate refinement failure\n' +
      '   └─ Expected a number between 1 and 10, actual 20'
  }
}
*/

// This will throw an error because it's unsafe
schema.make(20)
/*
throws:
ParseError: between(1, 10)
└─ Predicate refinement failure
   └─ Expected a number between 1 and 10, actual 20
*/
```

## Setting Default Values

When creating objects, you might want to assign default values to certain fields to simplify object construction. The `Schema.withConstructorDefault` function lets you handle default values, making fields optional in the default constructor.

**Example** (Struct with Required Fields)

In this example, all fields are required when creating a new instance.

```ts

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number
})

// Both name and age must be provided
console.log(Person.make({ name: "John", age: 30 }))
/*
Output: { name: 'John', age: 30 }
*/
```

**Example** (Struct with Default Value)

Here, the `age` field is optional because it has a default value of `0`.

```ts

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0)
  )
})

// The age field is optional and defaults to 0
console.log(Person.make({ name: "John" }))
/*
Output:
{ name: 'John', age: 0 }
*/

console.log(Person.make({ name: "John", age: 30 }))
/*
Output:
{ name: 'John', age: 30 }
*/
```

### Nested Structs and Shallow Defaults

Default values in schemas are shallow, meaning that defaults defined in nested structs do not automatically propagate to the top-level constructor.

**Example** (Shallow Defaults in Nested Structs)

```ts

const Config = Schema.Struct({
  // Define a nested struct with a default value
  web: Schema.Struct({
    application_url: Schema.String.pipe(
      Schema.propertySignature,
      Schema.withConstructorDefault(() => "http://localhost")
    ),
    application_port: Schema.Number
  })
})

// This will cause a type error because `application_url`
// is missing in the nested struct
// @errors: 2741
Config.make({ web: { application_port: 3000 } })
```

This behavior occurs because the `Schema` interface does not include a type parameter to carry over default constructor types from nested structs.

To work around this limitation, extract the constructor for the nested struct and apply it to its fields directly. This ensures that the nested defaults are respected.

**Example** (Using Nested Struct Constructors)

```ts

const Config = Schema.Struct({
  web: Schema.Struct({
    application_url: Schema.String.pipe(
      Schema.propertySignature,
      Schema.withConstructorDefault(() => "http://localhost")
    ),
    application_port: Schema.Number
  })
})

// Extract the nested struct constructor
const { web: Web } = Config.fields

// Use the constructor for the nested struct
console.log(Config.make({ web: Web.make({ application_port: 3000 }) }))
/*
Output:
{
  web: {
    application_url: 'http://localhost',
    application_port: 3000
  }
}
*/
```

### Lazy Evaluation of Defaults

Defaults are lazily evaluated, meaning that a new instance of the default is generated every time the constructor is called:

**Example** (Lazy Evaluation of Defaults)

In this example, the `timestamp` field generates a new value for each instance.

```ts

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0)
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime())
  )
})

console.log(Person.make({ name: "name1" }))
/*
Example Output:
{ age: 0, timestamp: 1714232909221, name: 'name1' }
*/

console.log(Person.make({ name: "name2" }))
/*
Example Output:
{ age: 0, timestamp: 1714232909227, name: 'name2' }
*/
```

### Reusing Defaults Across Schemas

Default values are also "portable", meaning that if you reuse the same property signature in another schema, the default is carried over:

**Example** (Reusing Defaults in Another Schema)

```ts

const Person = Schema.Struct({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0)
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime())
  )
})

const AnotherSchema = Schema.Struct({
  foo: Schema.String,
  age: Person.fields.age
})

console.log(AnotherSchema.make({ foo: "bar" }))
/*
Output:
{ foo: 'bar', age: 0 }
*/
```

### Using Defaults in Classes

Default values can also be applied when working with the `Class` API, ensuring consistency across class-based schemas.

**Example** (Defaults in a Class)

```ts

class Person extends Schema.Class<Person>("Person")({
  name: Schema.NonEmptyString,
  age: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => 0)
  ),
  timestamp: Schema.Number.pipe(
    Schema.propertySignature,
    Schema.withConstructorDefault(() => new Date().getTime())
  )
}) {}

console.log(new Person({ name: "name1" }))
/*
Example Output:
Person { age: 0, timestamp: 1714400867208, name: 'name1' }
*/

console.log(new Person({ name: "name2" }))
/*
Example Output:
Person { age: 0, timestamp: 1714400867215, name: 'name2' }
*/
```


---

# [Effect Data Types](https://effect.website/docs/schema/effect-data-types/)

## Overview


## Interop With Data

The [Data](/docs/data-types/data/) module in the Effect ecosystem simplifies value comparison by automatically implementing the [Equal](/docs/trait/equal/) and [Hash](/docs/trait/hash/) traits. This eliminates the need for manual implementations, making equality checks straightforward.

**Example** (Comparing Structs with Data)

```ts

const person1 = Data.struct({ name: "Alice", age: 30 })
const person2 = Data.struct({ name: "Alice", age: 30 })

console.log(Equal.equals(person1, person2))
// Output: true
```

By default, schemas like `Schema.Struct` do not implement the `Equal` and `Hash` traits. This means that two decoded objects with identical values will not be considered equal.

**Example** (Default Behavior Without `Equal` and `Hash`)

```ts

const schema = Schema.Struct({
  name: Schema.String,
  age: Schema.Number
})

const decode = Schema.decode(schema)

const person1 = decode({ name: "Alice", age: 30 })
const person2 = decode({ name: "Alice", age: 30 })

console.log(Equal.equals(person1, person2))
// Output: false
```

The `Schema.Data` function can be used to enhance a schema by including the `Equal` and `Hash` traits. This allows the resulting objects to support value-based equality.

**Example** (Using `Schema.Data` to Add Equality)

```ts

const schema = Schema.Data(
  Schema.Struct({
    name: Schema.String,
    age: Schema.Number
  })
)

const decode = Schema.decode(schema)

const person1 = decode({ name: "Alice", age: 30 })
const person2 = decode({ name: "Alice", age: 30 })

console.log(Equal.equals(person1, person2))
// Output: true
```

## Config

The `Schema.Config` function allows you to decode and manage application configuration settings using structured schemas.
It ensures consistency in configuration data and provides detailed feedback for decoding errors.

**Syntax**

```ts
Config: <A, I extends string>(name: string, schema: Schema<A, I>) =>
  Config<A>
```

This function takes two arguments:

- `name`: Identifier for the configuration setting.
- `schema`: Schema describing the expected data type and structure.

It returns a [Config](/docs/configuration/) object that integrates with your application's configuration system.

The Encoded type `I` must extend `string`, so the schema must be able to decode from a string, this includes schemas like `Schema.String`, `Schema.Literal("...")`, or `Schema.NumberFromString`, possibly with refinements applied.

Behind the scenes, `Schema.Config` follows these steps:

1. **Fetch the value** using the provided name (e.g. from an environment variable).
2. **Decode the value** using the given schema. If the value is invalid, decoding fails.
3. **Format any errors** using [TreeFormatter.formatErrorSync](/docs/schema/error-formatters/#treeformatter-default), which helps produce readable and detailed error messages.

**Example** (Decoding a Configuration Value)

```ts

// Define a config that expects a string with at least 4 characters
const myConfig = Schema.Config(
  "Foo",
  Schema.String.pipe(Schema.minLength(4))
)

const program = Effect.gen(function* () {
  const foo = yield* myConfig
  console.log(`ok: ${foo}`)
})

Effect.runSync(program)
```

To test the configuration, execute the following commands:

**Test** (with Missing Configuration Data)

```sh
npx tsx config.ts
# Output:

---

# [(Missing data at Foo: "Expected Foo to exist in the process context")]
```

**Test** (with Invalid Data)

```sh
Foo=bar npx tsx config.ts
# Output:
# [(Invalid data at Foo: "a string at least 4 character(s) long
# └─ Predicate refinement failure
#    └─ Expected a string at least 4 character(s) long, actual "bar"")]
```

**Test** (with Valid Data)

```sh
Foo=foobar npx tsx config.ts
# Output:
# ok: foobar
```

## Option

### Option

The `Schema.Option` function is useful for converting an `Option` into a JSON-serializable format.

**Syntax**

```ts
Schema.Option(schema: Schema<A, I, R>)
```

##### Decoding

| Input                        | Output                                                                              |
| ---------------------------- | ----------------------------------------------------------------------------------- |
| `{ _tag: "None" }`           | Converted to `Option.none()`                                                        |
| `{ _tag: "Some", value: I }` | Converted to `Option.some(a)`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                                          |
| ---------------- | ----------------------------------------------------------------------------------------------- |
| `Option.none()`  | Converted to `{ _tag: "None" }`                                                                 |
| `Option.some(A)` | Converted to `{ _tag: "Some", value: I }`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Option } from "effect"

const schema = Schema.Option(Schema.NumberFromString)

//     ┌─── OptionEncoded<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode({ _tag: "None" }))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode({ _tag: "Some", value: "1" }))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()))
// Output: { _tag: 'None' }

console.log(encode(Option.some(1)))
// Output: { _tag: 'Some', value: '1' }
```

### OptionFromSelf

The `Schema.OptionFromSelf` function is designed for scenarios where `Option` values are already in the `Option` format and need to be decoded or encoded while transforming the inner value according to the provided schema.

**Syntax**

```ts
Schema.OptionFromSelf(schema: Schema<A, I, R>)
```

#### Decoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `Option.none()`  | Remains as `Option.none()`                                                          |
| `Option.some(I)` | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

#### Encoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `Option.none()`  | Remains as `Option.none()`                                                          |
| `Option.some(A)` | Converted to `Option.some(I)`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Option } from "effect"

const schema = Schema.OptionFromSelf(Schema.NumberFromString)

//     ┌─── Option<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(Option.none()))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(Option.some("1")))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()))
// Output: { _id: 'Option', _tag: 'None' }

console.log(encode(Option.some(1)))
// Output: { _id: 'Option', _tag: 'Some', value: '1' }
```

### OptionFromUndefinedOr

The `Schema.OptionFromUndefinedOr` function handles cases where `undefined` is treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema.

**Syntax**

```ts
Schema.OptionFromUndefinedOr(schema: Schema<A, I, R>)
```

#### Decoding

| Input       | Output                                                                              |
| ----------- | ----------------------------------------------------------------------------------- |
| `undefined` | Converted to `Option.none()`                                                        |
| `I`         | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

#### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `Option.none()`  | Converted to `undefined`                                               |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Option } from "effect"

const schema = Schema.OptionFromUndefinedOr(Schema.NumberFromString)

//     ┌─── string | undefined
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(undefined))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()))
// Output: undefined

console.log(encode(Option.some(1)))
// Output: "1"
```

### OptionFromNullOr

The `Schema.OptionFromUndefinedOr` function handles cases where `null` is treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema.

**Syntax**

```ts
Schema.OptionFromNullOr(schema: Schema<A, I, R>)
```

#### Decoding

| Input  | Output                                                                              |
| ------ | ----------------------------------------------------------------------------------- |
| `null` | Converted to `Option.none()`                                                        |
| `I`    | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

#### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `Option.none()`  | Converted to `null`                                                    |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Option } from "effect"

const schema = Schema.OptionFromNullOr(Schema.NumberFromString)

//     ┌─── string | null
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(null))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()))
// Output: null
console.log(encode(Option.some(1)))
// Output: "1"
```

### OptionFromNullishOr

The `Schema.OptionFromNullishOr` function handles cases where `null` or `undefined` are treated as `Option.none()`, and all other values are interpreted as `Option.some()` based on the provided schema. Additionally, it allows customization of how `Option.none()` is encoded (`null` or `undefined`).

**Syntax**

```ts
Schema.OptionFromNullishOr(
  schema: Schema<A, I, R>,
  onNoneEncoding: null | undefined
)
```

#### Decoding

| Input       | Output                                                                              |
| ----------- | ----------------------------------------------------------------------------------- |
| `undefined` | Converted to `Option.none()`                                                        |
| `null`      | Converted to `Option.none()`                                                        |
| `I`         | Converted to `Option.some(A)`, where `I` is decoded into `A` using the inner schema |

#### Encoding

| Input            | Output                                                                     |
| ---------------- | -------------------------------------------------------------------------- |
| `Option.none()`  | Converted to `undefined` or `null` based on user choice (`onNoneEncoding`) |
| `Option.some(A)` | Converted to `I`, where `A` is encoded into `I` using the inner schema     |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Option } from "effect"

const schema = Schema.OptionFromNullishOr(
  Schema.NumberFromString,
  undefined // Encode Option.none() as undefined
)

//     ┌─── string | null | undefined
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Option<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(null))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(undefined))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode("1"))
// Output: { _id: 'Option', _tag: 'Some', value: 1 }

// Encoding examples

console.log(encode(Option.none()))
// Output: undefined

console.log(encode(Option.some(1)))
// Output: "1"
```

### OptionFromNonEmptyTrimmedString

The `Schema.OptionFromNonEmptyTrimmedString` schema is designed for handling strings where trimmed empty strings are treated as `Option.none()`, and all other strings are converted to `Option.some()`.

#### Decoding

| Input       | Output                                                  |
| ----------- | ------------------------------------------------------- |
| `s: string` | Converted to `Option.some(s)`, if `s.trim().length > 0` |
|             | Converted to `Option.none()` otherwise                  |

#### Encoding

| Input                    | Output            |
| ------------------------ | ----------------- |
| `Option.none()`          | Converted to `""` |
| `Option.some(s: string)` | Converted to `s`  |

**Example**

```ts twoslash
import { Schema, Option } from "effect"

//     ┌─── string
//     ▼
type Encoded = typeof Schema.OptionFromNonEmptyTrimmedString

//     ┌─── Option<string>
//     ▼
type Type = typeof Schema.OptionFromNonEmptyTrimmedString

const decode = Schema.decodeUnknownSync(
  Schema.OptionFromNonEmptyTrimmedString
)
const encode = Schema.encodeSync(Schema.OptionFromNonEmptyTrimmedString)

// Decoding examples

console.log(decode(""))
// Output: { _id: 'Option', _tag: 'None' }

console.log(decode(" a "))
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }

console.log(decode("a"))
// Output: { _id: 'Option', _tag: 'Some', value: 'a' }

// Encoding examples

console.log(encode(Option.none()))
// Output: ""

console.log(encode(Option.some("example")))
// Output: "example"
```

## Either

### Either

The `Schema.Either` function is useful for converting an `Either` into a JSON-serializable format.

**Syntax**

```ts
Schema.Either(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input                          | Output                                                                                          |
| ------------------------------ | ----------------------------------------------------------------------------------------------- |
| `{ _tag: "Left", left: LI }`   | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `{ _tag: "Right", right: RI }` | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                                                      |
| ------------------ | ----------------------------------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `{ _tag: "Left", left: LI }`, where `LA` is encoded into `LI` using the inner `left` schema    |
| `Either.right(RA)` | Converted to `{ _tag: "Right", right: RI }`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts twoslash
import { Schema, Either } from "effect"

const schema = Schema.Either({
  left: Schema.Trim,
  right: Schema.NumberFromString
})

//     ┌─── EitherEncoded<string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Either<number, string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode({ _tag: "Left", left: " a " }))
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(decode({ _tag: "Right", right: "1" }))
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left("a")))
// Output: { _tag: 'Left', left: 'a' }

console.log(encode(Either.right(1)))
// Output: { _tag: 'Right', right: '1' }
```

### EitherFromSelf

The `Schema.EitherFromSelf` function is designed for scenarios where `Either` values are already in the `Either` format and need to be decoded or encoded while transforming the inner valued according to the provided schemas.

**Syntax**

```ts
Schema.EitherFromSelf(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input              | Output                                                                                          |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| `Either.left(LI)`  | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `Either.right(RI)` | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                                          |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `Either.left(LI)`, where `LA` is encoded into `LI` using the inner `left` schema   |
| `Either.right(RA)` | Converted to `Either.right(RI)`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts twoslash
import { Schema, Either } from "effect"

const schema = Schema.EitherFromSelf({
  left: Schema.Trim,
  right: Schema.NumberFromString
})

//     ┌─── Either<string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Either<number, string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(Either.left(" a ")))
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(decode(Either.right("1")))
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left("a")))
// Output: { _id: 'Either', _tag: 'Left', left: 'a' }

console.log(encode(Either.right(1)))
// Output: { _id: 'Either', _tag: 'Right', right: '1' }
```

### EitherFromUnion

The `Schema.EitherFromUnion` function is designed to decode and encode `Either` values where the `left` and `right` sides are represented as distinct types. This schema enables conversions between raw union types and structured `Either` types.

**Syntax**

```ts
Schema.EitherFromUnion(options: {
  left: Schema<LA, LI, LR>,
  right: Schema<RA, RI, RR>
})
```

##### Decoding

| Input | Output                                                                                          |
| ----- | ----------------------------------------------------------------------------------------------- |
| `LI`  | Converted to `Either.left(LA)`, where `LI` is decoded into `LA` using the inner `left` schema   |
| `RI`  | Converted to `Either.right(RA)`, where `RI` is decoded into `RA` using the inner `right` schema |

##### Encoding

| Input              | Output                                                                            |
| ------------------ | --------------------------------------------------------------------------------- |
| `Either.left(LA)`  | Converted to `LI`, where `LA` is encoded into `LI` using the inner `left` schema  |
| `Either.right(RA)` | Converted to `RI`, where `RA` is encoded into `RI` using the inner `right` schema |

**Example**

```ts twoslash
import { Schema, Either } from "effect"

const schema = Schema.EitherFromUnion({
  left: Schema.Boolean,
  right: Schema.NumberFromString
})

//     ┌─── string | boolean
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Either<number, boolean>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(true))
// Output: { _id: 'Either', _tag: 'Left', left: true }

console.log(decode("1"))
// Output: { _id: 'Either', _tag: 'Right', right: 1 }

// Encoding examples

console.log(encode(Either.left(true)))
// Output: true

console.log(encode(Either.right(1)))
// Output: "1"
```

## Exit

### Exit

The `Schema.Exit` function is useful for converting an `Exit` into a JSON-serializable format.

**Syntax**

```ts
Schema.Exit(options: {
  failure: Schema<FA, FI, FR>,
  success: Schema<SA, SI, SR>,
  defect: Schema<DA, DI, DR>
})
```

##### Decoding

| Input                                              | Output                                                                                                                                            |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `{ _tag: "Failure", cause: CauseEncoded<FI, DI> }` | Converted to `Exit.failCause(Cause<FA>)`, where `CauseEncoded<FI, DI>` is decoded into `Cause<FA>` using the inner `failure` and `defect` schemas |
| `{ _tag: "Success", value: SI }`                   | Converted to `Exit.succeed(SA)`, where `SI` is decoded into `SA` using the inner `success` schema                                                 |

##### Encoding

| Input                       | Output                                                                                                                                                                   |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Exit.failCause(Cause<FA>)` | Converted to `{ _tag: "Failure", cause: CauseEncoded<FI, DI> }`, where `Cause<FA>` is encoded into `CauseEncoded<FI, DI>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SA)`          | Converted to `{ _tag: "Success", value: SI }`, where `SA` is encoded into `SI` using the inner `success` schema                                                          |

**Example**

```ts twoslash
import { Schema, Exit } from "effect"

const schema = Schema.Exit({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.String
})

//     ┌─── ExitEncoded<string, string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Exit<number, string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode({ _tag: "Failure", cause: { _tag: "Fail", error: "a" } })
)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(decode({ _tag: "Success", value: "1" }))
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 1 }
*/

// Encoding examples

console.log(encode(Exit.fail("a")))
/*
Output:
{ _tag: 'Failure', cause: { _tag: 'Fail', error: 'a' } }
 */

console.log(encode(Exit.succeed(1)))
/*
Output:
{ _tag: 'Success', value: '1' }
*/
```

### Handling Defects in Serialization

Effect provides a built-in `Defect` schema to handle JavaScript errors (`Error` instances) and other types of unrecoverable defects.

- When decoding, it reconstructs `Error` instances if the input has a `message` and optionally a `name` and `stack`.
- When encoding, it converts `Error` instances into plain objects that retain only essential properties.

This is useful when transmitting errors across network requests or logging systems where `Error` objects do not serialize by default.

**Example** (Encoding and Decoding Defects)

```ts twoslash
import { Schema, Exit } from "effect"

const schema = Schema.Exit({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.Defect
})

const decode = Schema.decodeSync(schema)
const encode = Schema.encodeSync(schema)

console.log(encode(Exit.die(new Error("Message"))))
/*
Output:
{
  _tag: 'Failure',
  cause: { _tag: 'Die', defect: { name: 'Error', message: 'Message' } }
}
*/

console.log(encode(Exit.fail("a")))

console.log(
  decode({
    _tag: "Failure",
    cause: { _tag: "Die", defect: { name: "Error", message: "Message" } }
  })
)
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: {
    _id: 'Cause',
    _tag: 'Die',
    defect: [Error: Message] { [cause]: [Object] }
  }
}
*/
```

### ExitFromSelf

The `Schema.ExitFromSelf` function is designed for scenarios where `Exit` values are already in the `Exit` format and need to be decoded or encoded while transforming the inner valued according to the provided schemas.

**Syntax**

```ts
Schema.ExitFromSelf(options: {
  failure: Schema<FA, FI, FR>,
  success: Schema<SA, SI, SR>,
  defect: Schema<DA, DI, DR>
})
```

##### Decoding

| Input                       | Output                                                                                                                                 |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `Exit.failCause(Cause<FI>)` | Converted to `Exit.failCause(Cause<FA>)`, where `Cause<FI>` is decoded into `Cause<FA>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SI)`          | Converted to `Exit.succeed(SA)`, where `SI` is decoded into `SA` using the inner `success` schema                                      |

##### Encoding

| Input                       | Output                                                                                                                                 |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `Exit.failCause(Cause<FA>)` | Converted to `Exit.failCause(Cause<FI>)`, where `Cause<FA>` is decoded into `Cause<FI>` using the inner `failure` and `defect` schemas |
| `Exit.succeed(SA)`          | Converted to `Exit.succeed(SI)`, where `SA` is encoded into `SI` using the inner `success` schema                                      |

**Example**

```ts twoslash
import { Schema, Exit } from "effect"

const schema = Schema.ExitFromSelf({
  failure: Schema.String,
  success: Schema.NumberFromString,
  defect: Schema.String
})

//     ┌─── Exit<string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Exit<number, string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(Exit.fail("a")))
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(decode(Exit.succeed("1")))
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: 1 }
*/

// Encoding examples

console.log(encode(Exit.fail("a")))
/*
Output:
{
  _id: 'Exit',
  _tag: 'Failure',
  cause: { _id: 'Cause', _tag: 'Fail', failure: 'a' }
}
*/

console.log(encode(Exit.succeed(1)))
/*
Output:
{ _id: 'Exit', _tag: 'Success', value: '1' }
*/
```

## ReadonlySet

### ReadonlySet

The `Schema.ReadonlySet` function is useful for converting a `ReadonlySet` into a JSON-serializable format.

**Syntax**

```ts
Schema.ReadonlySet(schema: Schema<A, I, R>)
```

##### Decoding

| Input              | Output                                                                              |
| ------------------ | ----------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converted to `ReadonlySet<A>`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                   |
| ---------------- | ------------------------------------------------------------------------ |
| `ReadonlySet<A>` | `ReadonlyArray<I>`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.ReadonlySet(Schema.NumberFromString)

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlySet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(["1", "2", "3"]))
// Output: Set(3) { 1, 2, 3 }

// Encoding examples

console.log(encode(new Set([1, 2, 3])))
// Output: [ '1', '2', '3' ]
```

### ReadonlySetFromSelf

The `Schema.ReadonlySetFromSelf` function is designed for scenarios where `ReadonlySet` values are already in the `ReadonlySet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.ReadonlySetFromSelf(schema: Schema<A, I, R>)
```

##### Decoding

| Input            | Output                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| `ReadonlySet<I>` | Converted to `ReadonlySet<A>`, where `I` is decoded into `A` using the inner schema |

##### Encoding

| Input            | Output                                                                 |
| ---------------- | ---------------------------------------------------------------------- |
| `ReadonlySet<A>` | `ReadonlySet<I>`, where `A` is encoded into `I` using the inner schema |

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.ReadonlySetFromSelf(Schema.NumberFromString)

//     ┌─── ReadonlySet<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlySet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(new Set(["1", "2", "3"])))
// Output: Set(3) { 1, 2, 3 }

// Encoding examples

console.log(encode(new Set([1, 2, 3])))
// Output: Set(3) { '1', '2', '3' }
```

## ReadonlyMap

The `Schema.ReadonlyMap` function is useful for converting a `ReadonlyMap` into a JSON-serializable format.

### ReadonlyMap

**Syntax**

```ts
Schema.ReadonlyMap(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

##### Decoding

| Input                              | Output                                                                                                                                                        |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<readonly [KI, VI]>` | Converted to `ReadonlyMap<KA, VA>`, where `KI` is decoded into `KA` using the inner `key` schema and `VI` is decoded into `VA` using the inner `value` schema |

##### Encoding

| Input                 | Output                                                                                                                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converted to `ReadonlyArray<readonly [KI, VI]>`, where `KA` is decoded into `KI` using the inner `key` schema and `VA` is decoded into `VI` using the inner `value` schema |

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.ReadonlyMap({
  key: Schema.String,
  value: Schema.NumberFromString
})

//     ┌─── readonly (readonly [string, string])[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlyMap<string, number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode([
    ["a", "2"],
    ["b", "2"],
    ["c", "3"]
  ])
)
// Output: Map(3) { 'a' => 2, 'b' => 2, 'c' => 3 }

// Encoding examples

console.log(
  encode(
    new Map([
      ["a", 1],
      ["b", 2],
      ["c", 3]
    ])
  )
)
// Output: [ [ 'a', '1' ], [ 'b', '2' ], [ 'c', '3' ] ]
```

### ReadonlyMapFromSelf

The `Schema.ReadonlyMapFromSelf` function is designed for scenarios where `ReadonlyMap` values are already in the `ReadonlyMap` format and need to be decoded or encoded while transforming the inner values according to the provided schemas.

**Syntax**

```ts
Schema.ReadonlyMapFromSelf(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

##### Decoding

| Input                 | Output                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KI, VI>` | Converted to `ReadonlyMap<KA, VA>`, where `KI` is decoded into `KA` using the inner `key` schema and `VI` is decoded into `VA` using the inner `value` schema |

##### Encoding

| Input                 | Output                                                                                                                                                        |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converted to `ReadonlyMap<KI, VI>`, where `KA` is decoded into `KI` using the inner `key` schema and `VA` is decoded into `VI` using the inner `value` schema |

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.ReadonlyMapFromSelf({
  key: Schema.String,
  value: Schema.NumberFromString
})

//     ┌─── ReadonlyMap<string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlyMap<string, number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode(
    new Map([
      ["a", "2"],
      ["b", "2"],
      ["c", "3"]
    ])
  )
)
// Output: Map(3) { 'a' => 2, 'b' => 2, 'c' => 3 }

// Encoding examples

console.log(
  encode(
    new Map([
      ["a", 1],
      ["b", 2],
      ["c", 3]
    ])
  )
)
// Output: Map(3) { 'a' => '1', 'b' => '2', 'c' => '3' }
```

### ReadonlyMapFromRecord

The `Schema.ReadonlyMapFromRecord` function is a utility to transform a `ReadonlyMap` into an object format, where keys are strings and values are serializable, and vice versa.

**Syntax**

```ts
Schema.ReadonlyMapFromRecord({
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

#### Decoding

| Input                          | Output                                                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| `{ readonly [x: string]: VI }` | Converts to `ReadonlyMap<KA, VA>`, where `x` is decoded into `KA` using the `key` schema and `VI` into `VA` using the `value` schema |

#### Encoding

| Input                 | Output                                                                                                                                        |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `ReadonlyMap<KA, VA>` | Converts to `{ readonly [x: string]: VI }`, where `KA` is encoded into `x` using the `key` schema and `VA` into `VI` using the `value` schema |

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.ReadonlyMapFromRecord({
  key: Schema.NumberFromString,
  value: Schema.NumberFromString
})

//     ┌─── { readonly [x: string]: string; }
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── ReadonlyMap<number, number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode({
    "1": "4",
    "2": "5",
    "3": "6"
  })
)
// Output: Map(3) { 1 => 4, 2 => 5, 3 => 6 }

// Encoding examples

console.log(
  encode(
    new Map([
      [1, 4],
      [2, 5],
      [3, 6]
    ])
  )
)
// Output: { '1': '4', '2': '5', '3': '6' }
```

## HashSet

### HashSet

The `Schema.HashSet` function provides a way to map between `HashSet` and an array representation, allowing for JSON serialization and deserialization.

**Syntax**

```ts
Schema.HashSet(schema: Schema<A, I, R>)
```

#### Decoding

| Input              | Output                                                                                              |
| ------------------ | --------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converts to `HashSet<A>`, where each element in the array is decoded into type `A` using the schema |

#### Encoding

| Input        | Output                                                                                                        |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| `HashSet<A>` | Converts to `ReadonlyArray<I>`, where each element in the `HashSet` is encoded into type `I` using the schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { HashSet } from "effect"

const schema = Schema.HashSet(Schema.NumberFromString)

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── HashSet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(["1", "2", "3"]))
// Output: { _id: 'HashSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(HashSet.fromIterable([1, 2, 3])))
// Output: [ '1', '2', '3' ]
```

### HashSetFromSelf

The `Schema.HashSetFromSelf` function is designed for scenarios where `HashSet` values are already in the `HashSet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.HashSetFromSelf(schema: Schema<A, I, R>)
```

#### Decoding

| Input        | Output                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------ |
| `HashSet<I>` | Converts to `HashSet<A>`, decoding each element from type `I` to type `A` using the schema |

#### Encoding

| Input        | Output                                                                                     |
| ------------ | ------------------------------------------------------------------------------------------ |
| `HashSet<A>` | Converts to `HashSet<I>`, encoding each element from type `A` to type `I` using the schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { HashSet } from "effect"

const schema = Schema.HashSetFromSelf(Schema.NumberFromString)

//     ┌─── HashSet<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── HashSet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(HashSet.fromIterable(["1", "2", "3"])))
// Output: { _id: 'HashSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(HashSet.fromIterable([1, 2, 3])))
// Output: { _id: 'HashSet', values: [ '1', '3', '2' ] }
```

## HashMap

### HashMap

The `Schema.HashMap` function is useful for converting a `HashMap` into a JSON-serializable format.

**Syntax**

```ts
Schema.HashMap(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

| Input                              | Output                                                                                                                   |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `ReadonlyArray<readonly [KI, VI]>` | Converts to `HashMap<KA, VA>`, where `KI` is decoded into `KA` and `VI` is decoded into `VA` using the specified schemas |

#### Encoding

| Input             | Output                                                                                                                                    |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `HashMap<KA, VA>` | Converts to `ReadonlyArray<readonly [KI, VI]>`, where `KA` is encoded into `KI` and `VA` is encoded into `VI` using the specified schemas |

**Example**

```ts twoslash
import { Schema } from "effect"
import { HashMap } from "effect"

const schema = Schema.HashMap({
  key: Schema.String,
  value: Schema.NumberFromString
})

//     ┌─── readonly (readonly [string, string])[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── HashMap<string, number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode([
    ["a", "2"],
    ["b", "2"],
    ["c", "3"]
  ])
)
// Output: { _id: 'HashMap', values: [ [ 'a', 2 ], [ 'c', 3 ], [ 'b', 2 ] ] }

// Encoding examples

console.log(
  encode(
    HashMap.fromIterable([
      ["a", 1],
      ["b", 2],
      ["c", 3]
    ])
  )
)
// Output: [ [ 'a', '1' ], [ 'c', '3' ], [ 'b', '2' ] ]
```

### HashMapFromSelf

The `Schema.HashMapFromSelf` function is designed for scenarios where `HashMap` values are already in the `HashMap` format and need to be decoded or encoded while transforming the inner values according to the provided schemas.

**Syntax**

```ts
Schema.HashMapFromSelf(options: {
  key: Schema<KA, KI, KR>,
  value: Schema<VA, VI, VR>
})
```

#### Decoding

| Input             | Output                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `HashMap<KI, VI>` | Converts to `HashMap<KA, VA>`, where `KI` is decoded into `KA` and `VI` is decoded into `VA` using the specified schemas |

#### Encoding

| Input             | Output                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `HashMap<KA, VA>` | Converts to `HashMap<KI, VI>`, where `KA` is encoded into `KI` and `VA` is encoded into `VI` using the specified schemas |

**Example**

```ts twoslash
import { Schema } from "effect"
import { HashMap } from "effect"

const schema = Schema.HashMapFromSelf({
  key: Schema.String,
  value: Schema.NumberFromString
})

//     ┌─── HashMap<string, string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── HashMap<string, number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(
  decode(
    HashMap.fromIterable([
      ["a", "2"],
      ["b", "2"],
      ["c", "3"]
    ])
  )
)
// Output: { _id: 'HashMap', values: [ [ 'a', 2 ], [ 'c', 3 ], [ 'b', 2 ] ] }

// Encoding examples

console.log(
  encode(
    HashMap.fromIterable([
      ["a", 1],
      ["b", 2],
      ["c", 3]
    ])
  )
)
// Output: { _id: 'HashMap', values: [ [ 'a', '1' ], [ 'c', '3' ], [ 'b', '2' ] ] }
```

## SortedSet

### SortedSet

The `Schema.SortedSet` function provides a way to map between `SortedSet` and an array representation, allowing for JSON serialization and deserialization.

**Syntax**

```ts
Schema.SortedSet(schema: Schema<A, I, R>, order: Order<A>)
```

#### Decoding

| Input              | Output                                                                                                |
| ------------------ | ----------------------------------------------------------------------------------------------------- |
| `ReadonlyArray<I>` | Converts to `SortedSet<A>`, where each element in the array is decoded into type `A` using the schema |

#### Encoding

| Input          | Output                                                                                                          |
| -------------- | --------------------------------------------------------------------------------------------------------------- |
| `SortedSet<A>` | Converts to `ReadonlyArray<I>`, where each element in the `SortedSet` is encoded into type `I` using the schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Number, SortedSet } from "effect"

const schema = Schema.SortedSet(Schema.NumberFromString, Number.Order)

//     ┌─── readonly string[]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── SortedSet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(["1", "2", "3"]))
// Output: { _id: 'SortedSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(SortedSet.fromIterable(Number.Order)([1, 2, 3])))
// Output: [ '1', '2', '3' ]
```

### SortedSetFromSelf

The `Schema.SortedSetFromSelf` function is designed for scenarios where `SortedSet` values are already in the `SortedSet` format and need to be decoded or encoded while transforming the inner values according to the provided schema.

**Syntax**

```ts
Schema.SortedSetFromSelf(
  schema: Schema<A, I, R>,
  decodeOrder: Order<A>,
  encodeOrder: Order<I>
)
```

#### Decoding

| Input          | Output                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------- |
| `SortedSet<I>` | Converts to `SortedSet<A>`, decoding each element from type `I` to type `A` using the schema |

#### Encoding

| Input          | Output                                                                                       |
| -------------- | -------------------------------------------------------------------------------------------- |
| `SortedSet<A>` | Converts to `SortedSet<I>`, encoding each element from type `A` to type `I` using the schema |

**Example**

```ts twoslash
import { Schema } from "effect"
import { Number, SortedSet, String } from "effect"

const schema = Schema.SortedSetFromSelf(
  Schema.NumberFromString,
  Number.Order,
  String.Order
)

//     ┌─── SortedSet<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── SortedSet<number>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)
const encode = Schema.encodeSync(schema)

// Decoding examples

console.log(decode(SortedSet.fromIterable(String.Order)(["1", "2", "3"])))
// Output: { _id: 'SortedSet', values: [ 1, 2, 3 ] }

// Encoding examples

console.log(encode(SortedSet.fromIterable(Number.Order)([1, 2, 3])))
// Output: { _id: 'SortedSet', values: [ '1', '2', '3' ] }
```

## Duration

The `Duration` schema family enables the transformation and validation of duration values across various formats, including `hrtime`, milliseconds, and nanoseconds.

### Duration

Converts an hrtime(i.e. `[seconds: number, nanos: number]`) into a `Duration`.

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.Duration

//     ┌─── readonly [seconds: number, nanos: number]
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode([0, 0]))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode([5000, 0]))
// Output: { _id: 'Duration', _tag: 'Nanos', hrtime: [ 5000, 0 ] }
```

### DurationFromSelf

The `DurationFromSelf` schema is designed to validate that a given value conforms to the `Duration` type.

**Example**

```ts twoslash
import { Schema, Duration } from "effect"

const schema = Schema.DurationFromSelf

//     ┌─── Duration
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode(Duration.seconds(2)))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 2000 }

console.log(decode(null))
/*
throws:
ParseError: Expected DurationFromSelf, actual null
*/
```

### DurationFromMillis

Converts a `number` into a `Duration` where the number represents the number of milliseconds.

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.DurationFromMillis

//     ┌─── number
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode(0))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode(5000))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 5000 }
```

### DurationFromNanos

Converts a `BigInt` into a `Duration` where the number represents the number of nanoseconds.

**Example**

```ts twoslash
import { Schema } from "effect"

const schema = Schema.DurationFromNanos

//     ┌─── bigint
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode(0n))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 0 }

console.log(decode(5000000000n))
// Output: { _id: 'Duration', _tag: 'Nanos', hrtime: [ 5, 0 ] }
```

### clampDuration

Clamps a `Duration` between a minimum and a maximum value.

**Example**

```ts twoslash
import { Schema, Duration } from "effect"

const schema = Schema.DurationFromSelf.pipe(
  Schema.clampDuration("5 seconds", "10 seconds")
)

//     ┌─── Duration
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Duration
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode(Duration.decode("2 seconds")))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 5000 }

console.log(decode(Duration.decode("6 seconds")))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 6000 }

console.log(decode(Duration.decode("11 seconds")))
// Output: { _id: 'Duration', _tag: 'Millis', millis: 10000 }
```

## Redacted

### Redacted

The `Schema.Redacted` function is specifically designed to handle sensitive information by converting a `string` into a [Redacted](/docs/data-types/redacted/) object.
This transformation ensures that the sensitive data is not exposed in the application's output.

**Example** (Basic Redacted Schema)

```ts twoslash
import { Schema } from "effect"

const schema = Schema.Redacted(Schema.String)

//     ┌─── string
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Redacted<string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode("keep it secret, keep it safe"))
// Output: <redacted>
```

It's important to note that when successfully decoding a `Redacted`, the output is intentionally obscured (`<redacted>`) to prevent the actual secret from being revealed in logs or console outputs.

> **Caution: Potential Risks**
  When composing the `Redacted` schema with other schemas, care must be
  taken as decoding or encoding errors could potentially expose sensitive
  information.
</Aside>

**Example** (Exposure Risks During Errors)

In the example below, if the input string does not meet the criteria (e.g., contains spaces), the error message generated might inadvertently expose sensitive information included in the input.

```ts twoslash
import { Schema } from "effect"
import { Redacted } from "effect"

const schema = Schema.Trimmed.pipe(
  Schema.compose(Schema.Redacted(Schema.String))
)

console.log(Schema.decodeUnknownEither(schema)(" SECRET"))
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Trimmed\n' +
      '      └─ Predicate refinement failure\n' +
      '         └─ Expected Trimmed (a string with no leading or trailing whitespace), actual " SECRET"'
  }
}
*/

console.log(Schema.encodeEither(schema)(Redacted.make(" SECRET")))
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Trimmed\n' +
      '      └─ Predicate refinement failure\n' +
      '         └─ Expected Trimmed (a string with no leading or trailing whitespace), actual " SECRET"'
  }
}
*/
```

#### Mitigating Exposure Risks

To reduce the risk of sensitive information leakage in error messages, you can customize the error messages to obscure sensitive details:

**Example** (Customizing Error Messages)

```ts twoslash
import { Schema } from "effect"
import { Redacted } from "effect"

const schema = Schema.Trimmed.annotations({
  message: () => "Expected Trimmed, actual <redacted>"
}).pipe(Schema.compose(Schema.Redacted(Schema.String)))

console.log(Schema.decodeUnknownEither(schema)(" SECRET"))
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Expected Trimmed, actual <redacted>'
  }
}
*/

console.log(Schema.encodeEither(schema)(Redacted.make(" SECRET")))
/*
{
  _id: 'Either',
  _tag: 'Left',
  left: {
    _id: 'ParseError',
    message: '(Trimmed <-> (string <-> Redacted(<redacted>)))\n' +
      '└─ Encoded side transformation failure\n' +
      '   └─ Expected Trimmed, actual <redacted>'
  }
}
*/
```

### RedactedFromSelf

The `Schema.RedactedFromSelf` schema is designed to validate that a given value conforms to the `Redacted` type from the `effect` library.

**Example**

```ts twoslash
import { Schema } from "effect"
import { Redacted } from "effect"

const schema = Schema.RedactedFromSelf(Schema.String)

//     ┌─── Redacted<string>
//     ▼
type Encoded = typeof schema.Encoded

//     ┌─── Redacted<string>
//     ▼
type Type = typeof schema.Type

const decode = Schema.decodeUnknownSync(schema)

// Decoding examples

console.log(decode(Redacted.make("mysecret")))
// Output: <redacted>

console.log(decode(null))
/*
throws:
ParseError: Expected Redacted(<redacted>), actual null
*/
```

It's important to note that when successfully decoding a `Redacted`, the output is intentionally obscured (`<redacted>`) to prevent the actual secret from being revealed in logs or console outputs.


## Common Mistakes

**Incorrect (using decode for unknown input):**

```ts
const result = Schema.decodeSync(User)(unknownData)
// May not validate correctly for truly unknown input
```

**Correct (using decodeUnknown for external data):**

```ts
const result = Schema.decodeUnknownSync(User)(unknownData)
// Properly validates unknown input from API, forms, env
```
