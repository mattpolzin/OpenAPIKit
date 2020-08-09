
## Schema Object
In OpenAPIKit, the Schema Object from the OpenAPI Specification is represented by the `JSONSchema` type. Indeed, OpenAPIKit borrows most of the details of its Schema Object from the JSON Schema specification.

A `JSONSchema` can be:
1. Any of the fundamental types (`boolean`, `number`, `integer`, or `string`).
2. An `array` of other schemas or and `object` with properties that are other schemas.
3. A `reference` to a schema in the Components Object or elsewhere.
4. `all(of:)`, `one(of:)`, or `any(of:)` a list of other schemas.
5. `not` another schema.
6. `undefined` (which means not even the type of schema is being specified).

The fundamental schema types and arrays and objects all share a common set of properties (accessible from their `coreContext`) and each (except for boolean) also has some properties that only apply to that one type (accessible from properties named after the type like `objectContext`, `arrayContext`, `integerContext`, etc.).

You can also extract these properties with pattern matching on a `JSONSchema`.

```swift
let schema: JSONSchema = ...
switch schema {
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
