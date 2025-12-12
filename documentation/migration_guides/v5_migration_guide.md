## OpenAPIKit v5 Migration Guide
For general information on the v5 release, see the release notes on GitHub. The
rest of this guide will be formatted as a series of changes and what options you
have to migrate code from v4 to v5. You can also refer back to the release notes
for each of the v4 pre-releases for the most thorough look at what changed.

This guide will not spend time on strictly additive features of version 5. See
the release notes, README, and documentation for information on new features.

### Swift version support
OpenAPIKit v5.0 drops support for Swift versions prior to 5.10 (i.e. it supports
v5.10 and greater).

### MacOS version support
Only relevant when compiling OpenAPIKit on iOS: Now v12+ is required.

### OpenAPI Specification Versions
There are no breaking changes for the `OpenAPIKit30` module (OAS 3.0.x
specification) in this section.

The OpenAPIKit module's `OpenAPI.Document.Version` enum gained `v3_1_2`,
`v3_2_0` and `v3_2_x(x: Int)`.

If you have exhaustive switches over values of those types then your switch
statements will need to be updated.

If you use `v3_1_x(x: 2)` you should replace it with `v3_1_2`.

### Content Types
The `application/x-yaml` media type is officially superseded by
`application/yaml`. OpenAPIKit will continue to support reading the
`application/x-yaml` media type, but it will always choose to encode the YAML
media type as `application/yaml`.

### Http Methods
The `OpenAPIKit30` module's `OpenAPI.HttpMethod` type has been renamed to
`OpenAPI.BuiltinHttpMethod` and gained the `.query` method (though this method
cannot be represented on the OAS 3.0.x Path Item Object).

The `OpenAPI` module's `OpenAPI.HttpMethod` type has been updated to support
non-builtin HTTP methods with the pre-existing HTTP methods moving to the
`OpenAPI.BuiltinHttpMethod` type and `HttpMethod` having just two cases:
`.builtin(BuiltinHttpMethod)` and `.other(String)`.

Switch statements over `OpenAPI.HttpMethod` should be updated to first check if
the method is builtin or not:
```swift
switch httpMethod {
case .builtin(let builtin):
    switch builtin {
    case .delete: // ...
    case .get: // ...
    case .head: // ...
    case .options: // ...
    case .patch: // ...
    case .post: // ...
    case .put: // ...
    case .trace: // ...
    case .query: // ...
    }
case .other(let other):
    // new stuff to handle here
}
```

You can continue to use static constructors on `OpenAPI.HttpMethod` to construct
builtin methods so the following code _does not need to change_:
```swift
let httpMethod : OpenAPI.HttpMethod = .post
```

### Parameters
There are no breaking changes for the `OpenAPIKit30` module (OAS 3.0.x
specification) in this section.

For the `OpenAPIKit` module (OAS 3.1.x and 3.2.x versions) read on.

An additional parameter location of `querystring` has been added. This is a
breaking change to code that exhaustively switches on `OpenAPI.Parameter.Context`
or `OpenAPI.Parameter.Context.Location`.

To support the new `querystring` location, `schemaOrContent` has been moved into
the `OpenAPI.Parameter.Context` because it only applies to locations other than
`querystring`. You can still access `schemaOrContent` as a property on the
`Parameter`. Code that pattern matches on cases of `OpenAPI.Parameter.Context`
will need to add the new `schemaOrContent` values associated with each case.

```swift
// BEFORE
switch parameter.context {
case .query(required: _)
}

// AFTER
switch parameter.context {
case .query(required: _, schemaOrContent: _)
}
```

#### Constructors
The following only applies if you construct parameters in-code (use Swift to
build an OpenAPI Document).

Unfortunately, the change that made `schemaOrContent` not apply to all possible
locations means that the existing convenience constructors and static functions
that created parameters in-code do not make sense anymore. There were fairly
substantial changes to what is available with an aim to continue to offer
simular convenience as before.

Following are a few changes you made need to make with examples.

Code that populates the `parameters` array of the `OpenAPI.Operation` type with the
`.parameter(name:,context:,schema:)` function needs to be updated. The `schema`
has moved into the `context` so you change your code in the following way:
```swift
// BEFORE
.parameter(
  name: "name",
  context: .header,
  schema: .string
)

// AFTER
.parameter(
  name: "name",
  context: .header(schema: .string)
)
```

Code that initializes `OpenAPI.Parameter` via one of its `init` functions will
most likely need to change. Many of the initializers have been removed but you can
replace `.init(name:,context:,schema:)` or similar initializers with
`.header(name:,schema:)` (same goes for `query`, `path`, and `cookie`). So you change
your code in the following way:
```swift
// BEFORE
.init(
  name: "name",
  context: .header,
  schema: .string
)

// AFTER
.header(
  name: "name",
  schema: .string
)
```

Because the `ParameterContext` has taken on the `schemaOrContent` of the
`Parameter`, convenience constructors like `ParameterContext.header` (and
similar for the other locations) no longer make sense and have been removed. You
must also specify the schema or content, e.g. `ParameterContext.header(schema: .string)`.

### Parameter Styles
There are no breaking changes for the `OpenAPIKit30` module (OAS 3.0.x
specification) in this section.

A new `cookie` style has been added. Code that exhaustively switches on the
`OpenAPI.Parameter.SchemaContext.Style` enum will need to be updated.

### Response Objects
There are no breaking changes for the `OpenAPIKit30` module (OAS 3.0.x
specification) in this section.

The Response Object `description` field is not optional so code may need to
change to account for it possibly being `nil`.

### Components Object
There are changes for the `OpenAPIKit30` module (OAS 3.0.x specification) in
this section.

Entries in the Components Object's `responses`, `parameters`, `examples`,
`requestBodies`, `headers`, `securitySchemes`, `links`, and `callbacks`
dictionaries have all gained support for references. Note that `pathItems` and
`schemas` still do not support references (per the specification), though
`schemas` can be JSON references by their very nature already.

This change fixes a gap in OpenAPIKit's ability to represent valid documents.

If you are using subscript access or `lookup()` functions to retrieve entries
from the Components Object, you do _not_ need to change that code. These
functions have learned how to follow references they encounter until they land
on the type of entity being looked up. If you want the behavior of just
doing a regular lookup and passing the result back even if it is a reference,
you can use the new `lookupOnce()` function. The existing `lookup()` functions
can now throw an error they would never throw before: `ReferenceCycleError`.

Error message phrasing has changed subtly which is unlikely to cause problems
but if you have tests that compare exact error messages then you may need to
update the test expectations.

If you construct `Components` in-code then you have two options. You can swap
out existing calls to the `Components` `init()` initializer with calls to the
new `Components.direct()` convenience constructor or you can nest each component
entry in an `Either` like follows:
```swift
// BEFORE
Components(
  parameters: [
    "param1": .cookie(name: "cookie", schema: .string)
  ]
)

// AFTER
Components(
  parameters: [
    "param1": .parameter(.cookie(name: "cookie", schema: .string))
  ]
)
```

If your code uses the `static` `openAPIComponentsKeyPath` variable on types that
can be found in the Components Object (likely very uncommon), you will now need
to handle two possibilities: the key path either refers to an object (of generic
type `T`) or it refers to an `Either<OpenAPI.Reference<T>, T>`.

### Media Type Object (`OpenAPI.Content`)
#### Schema property
The `schema` property has changed from either an `OpenAPI.Reference` or a
`JOSNSchema` to just a `JSONSchema`. This both reflects the specification and
also works just as well because `JSONSchema` has its own `.reference` case.
However, this does result in some necessary code changes.

You now have one fewer layer to traverse to get to a schema.
```swift
/// BEFORE
let JSONSchema? = content[.json]?.schema?.schemaValue

/// AFTER
let JSONSchema? = content[.json]?.schema
```

Switches over the `schema` now should look directly at the `JSONSchema` `value`
to switch on whether the `schema` is a reference or not.
```swift
/// BEFORE
guard let schema = content[.json]?.schema else { return }
switch schema {
case .a(let reference):
  print(reference)
case .b(let schema):
  print(schema)
}

/// AFTER
guard let schema = content[.json]?.schema else { return }
switch schema.value {
case .reference(let reference, _):
  print(reference)
default:
  print(schema)
}
```

The `OpenAPI.Content(schema:example:encoding:vendorExtensions:)` initializer
takes a schema directly so if you were passing in a schema anyway you just
remove one layer of wrapping (the `Either` that was previously there). If you
were passing in a reference, just make sure you are using the `JSONSchema`
`reference()` convenience constructor where it would have previously been the
`Either` `reference()` convenience constructor; they should be source-code
compatible.

#### Encoding property
The `OpenAPI.Content` `encoding` property has changed from being a map of
encodings (`OrderedDictionary<String, Encoding>`) to an `Either` in order to
support the new OAS 3.2.0 `prefixEncoding` and `itemEncoding` options which are
mutually exclusive with the existing map of encodings.

Anywhere you read the `encoding` property in your existing code, you can switch
to the `encodingMap` property if you want a short term solution that compiles
and behaves the same way for any OpenAPI Documents that do not use the new
positional encoding properties.
```swift
/// BEFORE
let encoding: Encoding? = content.encoding

/// AFTER
let encoding: Encoding? = content.encodingMap
```

If you wish to handle the new encoding options, you will need to switch over the
`Either` or otherwise handle the additional `prefixEncoding` and `itemEncoding`
properties.
```swift
guard let encoding = content.encoding else { return }
switch encoding {
case .a(let encodingMap):
  print(encodingMap)
case .b(let positionalEncoding):
  print(positionalEncoding.prefixEncoding)
  print(positionalEncoding.itemEncoding)
}
```

### Security Scheme Object (`OpenAPI.SecurityScheme`)
The `type` property's enumeration gains a new associated value on the `oauth2`
case.

Existing code that switches on that property will need to be updated to match on
`oauth2(flows: OAuthFlows, metadataUrl: URL?)` now.

### Errors
Some error messages have been tweaked in small ways. If you match on the
string descriptions of any OpenAPIKit errors, you may need to update the
expected values.
