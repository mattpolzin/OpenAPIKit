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
specification).

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

### Errors
Some error messages have been tweaked in small ways. If you match on the
string descriptions of any OpenAPIKit errors, you may need to update the
expected values.
