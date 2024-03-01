
## Schema Object
In OpenAPIKit, the Schema Object from the OpenAPI Specification is represented by the `JSONSchema` type. Indeed, OpenAPI 3.1.x fully supports the JSON Schema specification, though OpenAPIKit does not (yet) have 100% complete JSON Schema specification support.

A `JSONSchema` can be:
1. Any of the fundamental types (`boolean`, `number`, `integer`, `string`, and in OpenAPI v3.1 `null`).
2. An `array` of other schemas or and `object` with properties that are other schemas.
3. A `reference` to a schema in the Components Object or elsewhere.
4. `all(of:)`, `one(of:)`, or `any(of:)` a list of other schemas.
5. `not` another schema.
6. `fragment` (which means the type of schema is not specified).

The fundamental schema types and arrays and objects all share a common set of properties (accessible from their `coreContext`) and each (except for `boolean` and `null`) also has some properties that only apply to that one type (accessible from properties named after the type like `objectContext`, `arrayContext`, `integerContext`, etc.).

You can also extract these properties with pattern matching on a `JSONSchema`'s `value`.

**IMPORTANT**: `JSONSchema` is a struct with static convenience functions on it; when pattern matching, always pattern match on the `value` property of the `JSONSchema` type.

```swift
let schema: JSONSchema = ...
switch schema.value {
  case .boolean(let coreContext):
    break
  case .object(let coreContext, let objectContext):
    break
  case .array(let coreContext, let arrayContext):
    break
  case .number(let coreContext, let numberContext):
    break
  case .integer(let coreContext, let integerContext):
    break
  case .string(let coreContext, let stringContext):
    break
  ...
}
```

When creating a new schema, convenience constructors make it possible to specify any or all of the properties that relate to a given schema type without building the context object(s) directly.

```swift
let stringSchema = JSONSchema.string
let otherStringSchema = JSONSchema.string(format: .binary, required: false, title: "test", maxLength: 10) //... and many more properties
```

Certain aspects of a schema can be built out from existing schemas.

```swift
let stringSchema = JSONSchema.string // required and non-nullible by default
let optionalStringSchema =  stringSchema.optionalSchemaObject()
let nullableStringSchema = stringSchema.nullableSchemaObject()

// an optional and nullable string with only 3 allowed values
let buildOut = stringSchema
  .optionalSchemaObject()
  .nullableSchemaObject()
  .with(allowedValues: "red", "green", "blue")
```

Most properties of schemas are encoded as properties of the respective JSON/YAML object. Once notable exception is the `nullable` property of OpenAPIKit `JSONSchema` when encoded for OpenAPI v3.1. See how the following Swift is encoded:
```swift
JSONSchema.string(nullable: true)
```
OpenAPI v3.0
```json
{
  "type": "string",
  "nullable": true
}
```
OpenAPI v3.1
```json
{
  "type": ["string", "null"]
}
```

### Simplifying Schemas
The support for this feature is in its early stages with some gaps in what can be successfully simplified and a lot of room for additional heuristics.

You can take any `JSONSchema` and dereference it with `.dereferenced()` or `.derefererenced(in:)`. You can then take the `DereferencedJSONSchema` and simplify it with `.simplified()`. Simplification will try to take a schema and make it into the simplest alternative schema that still has the same meaning. Many schemas are already in their simplest form, but when you start using schema components like `any`, `all`, `one`, etc. you open the door to schemas that are more complicated than other equivalent schemas.

For example, the following schema with `.all(of:)` the given fragments add up to a simpler `.object` schema with the same rules:
```json
{
  "allOf": [
    {
      "type": "object",
      "properties": {
        "hello": {
          "type": "string"
        }
      }
    },
    {
      "type": "object",
      "additionalProperties": {
        "type": "integer"
      }
    }
  ]
}
```

The above schema gets simplified to the below schema.
```json
{
  "type": "object",
  "properties": {
    "hello": {
      "type": "string"
    }
  },
  "additionalProperties": {
    "type": "integer"
  }
}
```

### Generating Schemas from Swift Types

Some schemas can be easily generated from Swift types. Many of the fundamental Swift types support schema representations out-of-box.

For example, the following are true
```swift
String.openAPISchema == JSONSchema.string

Bool.openAPISchema == JSONSchema.boolean

Double.openAPISchema == JSONSchema.number(format: .double)

Float.openAPISchema == JSONSchema.number(format: .float)
...
```

`Array` and `Optional` are supported out-of-box. For example, the following are true
```swift
[String].openAPISchema == .array(items: .string)

[Int].openAPISchema == .array(items: .integer)

Int32?.openAPISchema == .integer(format: .int32, required: false)

[String?].openAPISchema == .array(items: .string(required: false))
...
```

Additional schema generation support can be found in the [`mattpolzin/OpenAPIReflection`](https://github.com/mattpolzin/OpenAPIReflection) library.

You can conform your own types to `OpenAPISchemaType` to make it convenient to generate `JSONSchemas` from them.
