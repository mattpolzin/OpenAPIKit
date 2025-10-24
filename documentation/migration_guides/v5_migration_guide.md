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

### Errors
Some error messages have been tweaked in small ways. If you match on the
string descriptions of any OpenAPIKit errors, you may need to update the
expected values.
