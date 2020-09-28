## OpenAPIKit v2 Migration Guide
For general information on the v2 release, see the release notes on GitHub. The rest of this guide will be formatted as a series of changes and what options you have to migrate code from v1 to v2. Many people will not need to do anything to switch to OpenAPIKit v2, but if you find yourself curious or facing a compilation error, take a look at this guide.

#### `OpenAPI.Server` `url` property removed
In order to support server URLs with variables in them, you can no longer access a Foundation `URL` on the `Server` type. The `url` property has been replaced with the `urlTemplate` property. You will need to account for the possibility that the given `urlTemplate` is not a valid Foundation `URL` (because it can have variables for which values are not known yet).

##### Options
- Change from `server.url` (`URL`) to `server.urlTemplate.url` (`URL?`).
- Change from `server.url` (`URL`) to `server.urlTemplate.absoluteString` (`String`).

#### `OpenAPI.Content` `schema` became optional
The OpenAPI Specification does not require the `schema` property on the Media Type Object (`OpenAPI.Content`) so v2 fixes a bug where it was previously required. You will need to handle its optionality.

##### Options
- Handle the optionality of the `OpenAPI.Content` and `OpenAPI.DereferencedContent` `schema` property.

#### `OpenAPI.Components` dereferencing methods refactored.
In OpenAPIKit v1, the `OpenAPI.Components` type offered the methods `dereference(_:)` and `forceDereference(_:)` to perform lookup of components by their references. These were overloaded to allow looking up `Either` types representing either a reference to a component or the component itself.

In OpenAPIKit v1.4, true dereferencing was introduced. True dereferencing does not just turn a reference into the value it refers to, it removes references deeply for all properties of the given value. That made the use of the word dereference in the `OpenAPI.Components` type's methods misleading -- these methods "looked up" values but did not "dereference" them.

OpenAPIKit v2 fixes this confusing naming by supporting component lookup via `subscript` (non-throwing) and `lookup(_:)` (throwing) methods. It no longer offers any methods that truly (deeply) dereference types. At the same time, OpenAPIKit v2 adds the `dereferenced(in:)` method to most OpenAPI types. This new method takes an `OpenAPI.Components` value and returns a fully dereferenced version of `self`. The `dereferenced(in:)` method offers the same deep dereferencing behavior exposed by the `OpenAPI.Document` `locallyDereferenced()` method that was added in OpenAPIKit v1.4.

##### Options
- Switch from `components.dereference(resourceReference)` to `components[resourceReference]` and from `try components.forceDereference(resourceReference)` to `components.lookup(resourceReference)`.
- Consider deep dereferencing with `try resource.dereferenced(in: components)`.

#### `DereferencedJSONSchema` underlying schema property renamed
The `DereferencedJSONSchema` property previously named `underlyingJSONSchema` has been renamed `jsonSchema` to better reflect the fact that the schema is _built_ from the dereferenced schema rather than being stored as an underlying type from which the dereferenced schema was built.

##### Options
- Rename `dereferncedSchema.underlyingJSONSchema` to `dereferencedSchema.jsonSchema`.

#### `JSONSchema` dereferenced methods renamed
`JSONSchema` used to have `dereferencedSchemaObject()` and `dereferencedSchemaObject(resolvingIn:)` methods. The former dereferenced a schema object if it already had no references and returned `nil` if it failed. The latter attempting to look references up in the given `OpenAPI.Components` and threw an error if it failed. Both of these dereferencing options are still available, but they have been renamed to `dereferenced()` and `dereferenced(in:)`, respectively.

The new names align with that of the `LocallyDereferenceable` protocol that is conformed to by most types in OpenAPIKit v2.

##### Options
- Rename `schema.dereferencedSchemaObject()` to `schema.dereferenced()` and `schema.dereferencedSchemaObject(resolvingIn:)` to `schema.dereferenced(in:)`.

#### `JSONSchema` and `DereferencedJSONSchema` `Context` types renamed
The `JSONSchema.Context` and `DereferencedJSONSchema.Context` types have both been renamed to `CoreContext`. Accordingly, the `JSONSchema` `generalContext` property has been renamed to `coreContext`. This new naming was originally inspired by naming chosen for the now-removed `JSONSchemaFragment` type (see below) but I kept them because the names `coreContext`/`CoreContext` do a good job of describing the context shared by all schema types.

##### Options
- Rename `generalContext` property uses to `coreContext` and rename `Context` type uses to `CoreContext`.

#### `JSONSchema` context optionality
In order to support schema fragments as part of the `JSONSchema` type (or in other words just make the `JSONSchema` type actually expressive enough to handle all schemas), a number of properties on some schema contexts needed to become optional. This was accomplished without changing the encoding/decoding behavior or indeed even the results returned by public accessors. However, the fact remains that whereas schemas could previously have `nullable` of `true` or `false`, they can now have `nullable` of `true`, `false`, and `nil` (interpreted as `false` at the time of encoding/decoding). 

These changes will have no effect on the outputs of programs, but you may need to adjust logic that assumes, for example, that a schema with no `nullable` property will decode equivalently to a schema constructed in code with `nullable` `false` -- these are now two distinct schemas that just happen to have the same meaning.

#### `JSONSchemaFragment` rolled into `JSONSchema`
In OpenAPIKit v1.x there was a type `JSONSchemaFragment` that represented schemas that were not "complete" enough to be `JSONSchemas`. The problem was, this was largely an arbitrary distinction and certainly not one motivated by the _very_ open-ended JSON Schema specification. In OpenAPIKit v2, `JSONSchema` can represent many more schemas and the cases represented by `JSONSchemaFragment` are not represented as one of the cases under `JSONSchema`. This also motivated the renaming of the (now much-more-powerful) `JSONSchema` case `undefined` to `fragment`.

##### Options
- Anywhere you have explicitly named the `JSONSchemaFragment` type, rename to `JSONSchema`. Update `JSONSchema.undefined` to `JSONSchema.fragment`. Update `JSONSchemaFragment.general` to `JSONSchema.fragment`.

#### `JSONSchema` compound cases gained a full `CoreContext`
Whereas the `all(of:)`, `any(of:)`, and `one(of:)` cases used to have a `discriminator` as their second associated value and the `not()` case did not have a second associated value at all, they all have gained a full `CoreContext` as their second associated value. This allows `JSONSchema` to express more valid OpenAPI schemas without too much sacrifice. There is an opportunity to add some `Validations` in the future to get back some of the strictness for which the OpenAPIKit library strives.

##### Options
- Update your case matching for these cases. If you need to access the discriminator, it now lives within the `CoreContext` of each case.