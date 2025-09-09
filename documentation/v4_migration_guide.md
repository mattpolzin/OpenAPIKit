## OpenAPIKit v4 Migration Guide
For general information on the v4 release, see the release notes on GitHub. The
rest of this guide will be formatted as a series of changes and what options you
have to migrate code from v3 to v4. You can also refer back to the release notes
for each of the v4 pre-releases for the most thorough look at what changed.

This guide will not spend time on strictly additive features of version 4. See
the release notes, README, and documentation for information on new features.

### Swift version support
OpenAPIKit v4.0 drops support for Swift versions prior to 5.8 (i.e. it supports
v5.8 and greater).

### Yams version support
Yams is only a test dependency of OpenAPIKit, but since it is still a dependency
it will still impact dependency resolution of downstream projects. Yams 5.1.0+
is now required.

### MacOS version support
Only relevant when compiling OpenAPIKit on macOS: Now v10_15+ is required.

### OpenAPI Specification Versions
The OpenAPIKit module's `OpenAPI.Document.Version` enum gained `v3_1_1` and the
OpenAPIKit30 module's `OpenAPI.Document.Version` enum gained `v3_0_4`.

The `OpenAPI.Document.Version` enum in both modules gained a new case
(`v3_0_x(x: Int)` and `v3_1_x(x: Int)` respectively) that represents future OAS
versions not released at the time of the given OpenAPIKit release. This allows
non-breaking addition of support for those new versions.

If you have exhaustive switches over values of those types then your switch
statements will need to be updated.

### Typo corrections
The following typo corrections were made to OpenAPIKit code. These amount to
breaking changes only in so far as you need to correct the same names if they
appear in your codebase.

- `public static Validation.serverVarialbeEnumIsValid` -> `.serverVariableEnumIsValid`
- `spublic static Validation.erverVarialbeDefaultExistsInEnum` -> `.serverVariableDefaultExistsInEnum`

### `AnyCodable`
**NOTE** that the `AnyCodable` type is used extensively for OpenAPIKit examples
and vendor extensions so that is likely where this note will be relevant to you.

1. The constructor for `AnyCodable` now requires knowledge at compile time that
   the value it is initialized with is `Sendable`.
2. Array and Dictionary literal protocol conformances had to be dropped.
   Anywhere you were relying on implicit conversion from e.g. `["hello": 1]` to
   an `AnyCodable`, wrap the literal with an explicit call to init:
   `.init(["hello": 1])`.

### Vendor Extensions
1. The `vendorExtensions` property of any `VendorExtendable` type must now
   implement a setter as well as a getter. This is not likely to impact
   downstream projects, but technically possible.
2. If you are disabling `vendorExtensions` support via the
   `VendorExtensionsConfiguration.isEnabled` property, you need to switch to
   using encoder/decoder `userInfo` to disable vendor extensions. The
   `isEnabled` property has been removed. See the example below.

To set an encoder or decoder up to disable vendor extensions use code like the
following before using the encoder or decoder with an OpenAPIKit type:
```swift
let userInfo = [VendorExtensionsConfiguration.enabledKey: false]
let encoder = JSONEncoder()
encoder.userInfo = userInfo

let decoder = JSONDecoder()
decoder.userInfo = userInfo
```

### `OpenAPI.Content.Encoding`
The `contentType` property has been removed in favor of the newer `contentTypes`
property (plural).

### `JSONSchemaContext`
The default (fallback) implementations of `inferred`, `anchor`, and
`dynamicAnchor` have been removed. Almost no downstream code will break because
of this, but if you've implemented the `JSONSchemaContext` protocol yourself
then this note is for you.

### Errors
The `InconsistencyError` type has been renaemd to `GenericError` and its message
has been tweaked to fit the new name. This error has been used to represent many
errors over time and I would not classify all of them as "inconsistencies."

If you've used the error's type or rely on the exact message, you will need to
update your code accordingly.
