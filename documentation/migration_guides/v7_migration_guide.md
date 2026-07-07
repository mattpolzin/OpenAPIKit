## OpenAPIKit v7 Migration Guide

OpenAPIKit v7 introduces breaking changes to support the JSON Schema 2020-12
`$dynamicRef` / `$dynamicAnchor` keywords (see below).

The minimum Swift version has increased to Swift 6.2.

### `JSONSchema` and `DereferencedJSONSchema` gain a `.dynamicReference` case

Support for the JSON Schema 2020-12 `$dynamicRef` / `$dynamicAnchor` keywords
([§7.7](https://json-schema.org/draft/2020-12/json-schema-core#section-7.7))
has been added. The `JSONSchema.Schema` and `DereferencedJSONSchema` enums each
gained a new `dynamicReference(_:...)` case, and `JSONReference.InternalReference`
gained a `.anchor(String)` case.

These are source-breaking changes for code that performs an exhaustive `switch`
over those enums: existing switches must add a case for `.dynamicReference`
(and `.anchor`, where matching `JSONReference.InternalReference` exhaustively).
Non-exhaustive usage (e.g. `if case` checks) is unaffected.

`JSONDynamicReference` is a new type that wraps `JSONReference<JSONSchema>` and
encodes/decodes the `$dynamicRef` keyword. Schemas whose only attribute is
`$dynamicRef` now decode as `.dynamicReference` instead of decoding as an empty
`.fragment` with an "unsupported attributes" warning.

### Local dereferencing fails on `$dynamicRef`

A `DereferencedJSONSchema` must not contain references. Until dynamic-scope
resolution is added (tracked in #359), `locallyDereferenced()` and
`JSONSchema.dereferenced(in:)` **throw** when they encounter a `$dynamicRef`
they cannot inline, mirroring how unresolvable static `$ref` values fail. The
raw `JSONSchema` AST still carries `.dynamicReference` for tools that read
schemas without dereferencing.

### `$ref` with a plain fragment now round-trips verbatim

As part of anchor support, `JSONReference.InternalReference` now parses a `$ref`
whose fragment has no leading `/` (e.g. `{"$ref": "#foo"}`) as `.anchor("foo")`
rather than `.path(...)`. The practical effect is that such references round-trip
verbatim (`"#foo"`) instead of being rewritten with a slash (`"#/foo"`).
References into the Components Object (`#/components/...`) and JSON-pointer paths
(`#/foo/bar`) are unaffected.


