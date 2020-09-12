
### `OpenAPI.Server` `url` property removed
In order to support server URLs with variables in them, you can no longer access a Foundation `URL` on the `Server` type. The `url` property has been replaced with the `urlTemplate` property. You will need to account for the possibility that the given `urlTemplate` is not a valid Foundation `URL` (because it can have variables for which values are not known yet).

#### Options
- Change from `server.url` (`URL`) to `server.urlTemplate.url` (`URL?`).
- Change from `server.url` (`URL`) to `server.urlTemplate.absoluteString` (`String`).

### `OpenAPI.Content` `schema` became optional
The OpenAPI Specification does not require the `schema` property on the Media Type Object (`OpenAPI.Content`) so v2 fixes a bug where it was previously required. You will need to handle its optionality.

#### Options
- Handle the optionality of the `OpenAPI.Content` and `OpenAPI.DereferencedContent` `schema` property.

### `DereferencedJSONSchema` underlying schema property renamed
The `DereferencedJSONSchema` property previously named `underlyingJSONSchema` has been renamed `jsonSchema` to better reflect the fact that the schema is _built_ from the dereferenced schema rather than being stored as an underlying type from which the dereferenced schema was built.

#### Options
- Rename `dereferncedSchema.underlyingJSONSchema` to `dereferencedSchema.jsonSchema`.

### `JSONSchema` dereferenced methods renamed
`JSONSchema` used to have `dereferencedSchemaObject()` and `dereferencedSchemaObject(resolvingIn:)` methods. The former dereferenced a schema object if it already had no references and returned `nil` if it failed. The latter attempting to look references up in the given `OpenAPI.Components` and threw an error if it failed. Both of these dereferencing options are still available, but they have been renamed to `dereferenced()` and `dereferenced(in:)`, respectively.

The new names align with that of the `LocallyDereferenceable` protocol that is conformed to by most types in OpenAPIKit v2.

#### Options
- Rename `schema.dereferencedSchemaObject()` to `schema.dereferenced()` and `schema.dereferencedSchemaObject(resolvingIn:)` to `schema.dereferenced(in:)`.

### `JSONSchema` context optionality
In order to support schema fragments as part of the `JSONSchema` type (or in other words just make the `JSONSchema` type actually expressive enough to handle all schemas), a number of properties on some schema contexts needed to become optional. This was accomplished without changing the encoding/decoding behavior or indeed even the results returned by public accessors. However, the fact remains that whereas schemas could previously have `nullable` of `true` or `false`, they can now have `nullable` of `true`, `false`, and `nil` (interpreted as `false` at the time of encoding/decoding). 

These changes will have no effect on the outputs of programs, but you may need to adjust logic that assumes, for example, that a schema with no `nullable` property will decode equivalently to a schema constructed in code with `nullable` `false` -- these are now two distinct schemas that just happen to have the same meaning.

### `JSONSchemaFragment` rolled into `JSONSchema`
In OpenAPIKit v1.x there was a type `JSONSchemaFragment` that represented schemas that were not "complete" enough to be `JSONSchemas`. The problem was, this was largely an arbitrary distinction and certainly not one motivated by the _very_ open-ended JSON Schema specification. In OpenAPIKit v2, `JSONSchema` can represent many more schemas and the cases represented by `JSONSchemaFragment` are not represented as one of the cases under `JSONSchema`. This also motivated the renaming of the (now much-more-powerful) `JSONSchema` case `undefined` to `fragment`.

#### Options
- Anywhere you have explicitly named the `JSONSchemaFragment` type, rename to `JSONSchema`. Update `JSONSchema.undefined` to `JSONSchema.fragment`. Update `JSONSchemaFragment.general` to `JSONSchema.fragment`.
