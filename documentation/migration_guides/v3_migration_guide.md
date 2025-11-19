## OpenAPIKit v3 Migration Guide
For general information on the v3 release, see the release notes on GitHub. The rest of this guide will be formatted as a series of changes and what options you have to migrate code from v2 to v3. You can also refer back to the release notes for each of the v3 pre-releases for the most thorough look at what changed.

If you are migrating from v2 to v3 of OpenAPIKit, skip the next section and go straigh to [Picking a Module](#picking-a-module). The next section is aimed at those migrating between the two new modules in OpenAPIKit v3.

### Migrating between OpenAPIKit v3's modules
If you are migrating from the OpenAPIKit v3 `OpenAPIKit30` module to the `OpenAPIKit` module, you can do a bit of a visual manual diff of the two migration sections below in this document to see the differences but really the differences are almost entirely born of the differences between the OpenAPI 3.0.x specification and the OpenAI 3.1.x specification and they mostly fall into the category of stuff your compiler will let you know about: You'll get errors that _x_ isn't optional or _y_ is optional in places where optionality changed or you'll get an error about not handling all cases of an enum where additional cases were added or you'll get an error where the values associated with an enum case have changed, etc.

If you do migrate between the two new modules and run into unintuitive errors or behavior that you cannot easily explain, please reach out via a GitHub issue and helping you will lead to additional documentation here for the next person.

### Picking a module
You'll either need to migrate your codebase to the new `OpenAPIKit` module (can read and write OpenAPI 3.1.x documents) or the new `OpenAPIKit30` module (can read and write OpenAPI 3.0.x documents **and** be converted to the `OpenAPIKit` module.

If your use-case needs to write out OpenAPI 3.0.x documents, you don't yet have much of a choice. There is not currently a way to convert OpenAPI 3.1.x documents into OpenAPI 3.0.x documents within OpenAPIKit. That is a planned feature, though. In this case, you must switch your imports to `OpenAPIKit30` and see the section below on [Migrating to the OpenAPIKit30 module](#migrating-to-the-openapikit30-module).

If your use-case either doesn't require writing OpenAPI documents out or your use-case only needs to support writing out OpenAPI 3.1.x documents, you should leave your imports for the `OpenAPIKit` module and see the section below on [Migrating to the OpenAPIKit module](#migrating-to-the-openapikit-module).

### Migrating to the OpenAPIKit30 module
This section describes migrating to the module that supports OpenAPI 3.0.x documents. The recommended path for many uses of OpenAPIKit would be to migrate to the `OpenAPIKit` module as described in the next section.

The first order of business is to replace all of your imports.

Before:
```swift
import OpenAPIKit
```

After:
```swift
import OpenAPIKit30
```

If you are using Swift Package Manager, also change your dependency from the string `"OpenAPIKit"` or the product `.product(name: "OpenAPIKit", package: "OpenAPIKit")` to `.product(name: "OpenAPIKit30", package: "OpenAPIKit")`.

#### JSONSchema differences
`JSONSchema` changed from an `enum` to a `struct`. For most code, use will not change, but if you switch over any `JSONSchema`s you should change to switching over the `JSONSchema` `value` property instead.

The `reference` case has gained a `CoreContext` so switching on it will need to change as follows:

Before:
```swift
case .reference(let ref): ...
```

After:
```swift 
case .reference(let ref, let context): ...
```

#### ContentType differences
`ContentType` changed from an `enum` to a `struct`. Equality checks for all of the previous enum's cases will still work against the new static constructors on the struct, but switch statements will no longer be possible.

#### Response.StatusCode differences
`Response.StatusCode` changed from an `enum` to a `struct`. For most code, use will not change, but if you switch over any values of this type your code will need to change to switch over the `StatusCode` `value` property instead.

#### Paths differences
Constructing an entry in the `Document.paths` dictionary now requires specifying `Either` a **JSON reference** to a **Path Item Object** or the **Path Item Object** itself.

This means that where you used to write something like:
```swift
paths: [
  "/hello/world": OpenAPI.PathItem(description: "hi", ...)
]
```

You will now need to wrap it in an `Either` constructor like:
```swift
paths: [
  "/hello/world": .pathItem(OpenAPI.PathItem(description: "hi", ...))
]
```

There is also a convenience initializer for `Either` in this context which means that you can also write:
```swift
paths: [
  "/hello/world": .init(description: "hi", ...)
]
```

You may already have been using the `.init` shorthand to construct `OpenAPI.PathItem`s in which case your code does not need to change.

Accessing an entry in the `Document.paths` dictionary now requires digging into an `Either` that may be a **JSON Reference** or a **Path Item Object** -- this means that where you used to write something like:
```swift
let pathItem = document.paths["hello/world"]
```
You will now need to decide between the following:
```swift
// access the path item (ignoring the possibility that it could be a reference)
let pathItemObject = document.paths["hello/world"]?.pathItemValue

// access the reference directly (ignoring the possibility that it could be a path item object):
let pathItemReference = document.paths["hello/world"]?.reference

// look the path item up in the Components Object (OpenAPIKit module only because this requires OpenAPI 3.1.x):
let pathItem = document.paths["hello/world"].flatMap { document.components[$0] }

// switch on the Either and handle it differently depending on the result:
switch document.paths["hello/world"] {
  case .a(let reference):
    break
  case .b(let pathItem):
    break
  case nil:
    break
}
```

NOTE: The error you will get in places where you need to make the above adjustments will look like:
```
Cannot convert value of type 'OpenAPI.PathItem' to expected dictionary value type 'Either<JSONReference<OpenAPI.PathItem>, OpenAPI.PathItem>'
```

#### Example differences
The `OpenAPI.Example` type's `value` property has become optional so you will now need to handle a `nil` case or use optional chaining in places where you switch-on or otherwise access that property.

#### DereferencedOperation differences
The `DereferencedOperation` type's `callbacks` property is now an `OpenAPI.DereferencedCallbacksMap` instead of an `OpenAPI.CallbacksMap`.

#### DereferencedResponse differences
The `DereferencedResponse` type's `links` property is now an `OrderedDictionary<String, OpenAPI.Link>` instead of an `OpenAPI.Link.Map`.

#### OrderedDictionary proliferation
More `Dictionary` types have been changed to `OrderedDictionary` so that ordering is retained in more situations. This change won't impact most code, but because _some_ `Dictionary` methods are not supported by `OrderedDictionary`, there is a small chance of code breaking. See the following file changes if you need to know which properties switched from `Dictionary` to `OrderedDictionary`: https://github.com/mattpolzin/OpenAPIKit/pull/233/files

An additional location where `OrderedDictionary` replaced `Dictionary` is the `mapping` property of `Discriminator`.

### Migrating to the OpenAPIKit module
This section describes migrating to the module that supports OpenAPI 3.1.x documents.

#### JSONReference differences
All occurrences of `JSONReference` outside of `JSONSchema` have been replaced by `OpenAPI.Reference`, a type that supports OpenAPI 3.1.x's ability to override summary and description.

Anywhere your code used to create a reference with `JSONReference.internal(.path(...))` you will now use `OpenAPI.Reference.internal(path: ...)` (and similarly for external references).

#### JSONSchema differences
`JSONSchema` changed from an `enum` to a `struct`. For most code, use will not change, but if you switch over any `JSONSchema`s you should change to switching over the `JSONSchema` `value` property instead.

The `.reference` case has gained a `CoreContext` so switching on it will need to change as follows:

Before:
```swift
case .reference(let ref): ...
```

After:
```swift 
case .reference(let ref, let context): ...
```

`JSONSchema` only exposes an `examples` (plural) property. This is backwards compatible with the `example` (singular) property when decoding, but code that references the `example` (singular) property will need to be updated to use the `examples` array instead.

In order to support new versions of the JSON Schema specification that allow `$ref` properties to live alongside other annotations like `description`, the `JSONSchema` type's `reference` case had its `ReferenceContext` replaced with a full `CoreContext`.

Because the `ReferenceContext` contained only a `required` property and the `CoreContext` also has a `required` property, some code bases will not need to change at all. However, if you did use the `ReferenceContext` by name in your code, you will need to address compiler errors because of this change.

Another way this change may break code is if you have used the `JSONSchema` `referenceContext` accessor. This accessor has been removed and you can now use the `coreContext` accessor on `JSONSchema` to get the `CoreContext` when it is relevant (which includes `reference` cases going forward).

The `.null` case of `JSONSchema` now has a `CoreContext` property associated with it. If you pattern match on it, your code may need to change (though you are still allowed to match against just `.null` and ignore the associated value if desirable).

The `JSONSchema.null` property that used to serve as a convenient way of creating a null-type `JSONSchema` is now a function. You can call it as `.null()` which means most code will just need to gain the `()` parens.

When a `JSONSchema` only has one `allowedValue`, it will now be encoded as `const` rather than `enum`. There's nothing to change about your code in response to this, but be aware of the difference in encoding behavior.

The `JSONSchema` type's `coreContext` accessor now gives a non-optional value because all cases have a `CoreContext`. The compiler will let you know where you need to stop handling it as Optional.

#### JSONSchema StringFormat differences
There is no longer `.extended` formats for `.string` JSON Schemas. Instead, all existing `.extended` formats are now just regular .`string` formats (e.g. you can just replace `.extended(.uuid)` with `.uuid`).

There are no longer `.byte` or `.binary` formats for `.string` JSON Schemas. Instead, use the `contentEncoding`s of `.base64` and `.binary`, respectively.

The `.uriReference` `.extended` JSON Schema `.string` format used to serialize to `uriref` whereas the new `.uriReference` JSON Schema `.string` format serializes to `uri-reference`, per the JSON Schema standard.

#### ContentType differences
`ContentType` changed from an `enum` to a `struct`. Equality checks for all of the previous enum's cases will still work against the new static constructors on the struct, but switch statements will no longer be possible.

The following ContentTypes have been added as builtins (you can use static functions on the `ContentType` type to construct these content types):
  - `.avi`
  - `.aac`
  - `.doc`
  - `.docx`
  - `.gif`

This also means that if you have previously constructed these media types yourself (e.g. `.other("image/gif")`), those custom types will not compare as equal to the new builtin types. You may find use in comparing the `.rawValue` of such content types instead if you want two content types to be equal as long as their string serializations are the same.  

#### Response.StatusCode differences
`Response.StatusCode` changed from an `enum` to a `struct`. For most code, use will not change, but if you switch over any values of this type your code will need to change to switch over the `StatusCode` `value` property instead.

#### Paths differences
Constructing an entry in the `Document.paths` dictionary now requires specifying `Either` a **JSON reference** to a **Path Item Object** or the **Path Item Object** itself.

This means that where you used to write something like:
```swift
paths: [
  "/hello/world": OpenAPI.PathItem(description: "hi", ...)
]
```

You will now need to wrap it in an `Either` constructor like:
```swift
paths: [
  "/hello/world": .pathItem(OpenAPI.PathItem(description: "hi", ...))
]
```

There is also a convenience initializer for `Either` in this context which means that you can also write:
```swift
paths: [
  "/hello/world": .init(description: "hi", ...)
]
```

You may already have been using the `.init` shorthand to construct `OpenAPI.PathItem`s in which case your code does not need to change.

Accessing an entry in the `Document.paths` dictionary now requires digging into an `Either` that may be a **JSON Reference** or a **Path Item Object** -- this means that where you used to write something like:
```swift
let pathItem = document.paths["hello/world"]
```
You will now need to decide between the following:
```swift
// access the path item (ignoring the possibility that it could be a reference)
let pathItemObject = document.paths["hello/world"]?.pathItemValue

// access the reference directly (ignoring the possibility that it could be a path item object):
let pathItemReference = document.paths["hello/world"]?.reference

// look the path item up in the Components Object (OpenAPIKit module only because this requires OpenAPI 3.1.x):
let pathItem = document.paths["hello/world"].flatMap { document.components[$0] }

// switch on the Either and handle it differently depending on the result:
switch document.paths["hello/world"] {
  case .a(let reference):
    break
  case .b(let pathItem):
    break
  case nil:
    break
}
```

NOTE: The error you will get in places where you need to make the above adjustments will look like:
```
Cannot convert value of type 'OpenAPI.PathItem' to expected dictionary value type 'Either<JSONReference<OpenAPI.PathItem>, OpenAPI.PathItem>'
```

#### Example differences
The `OpenAPI.Example` type's `value` property has become optional so you will now need to handle a `nil` case or use optional chaining in places where you switch-on or otherwise access that property.

#### DereferencedOperation differences
The `DereferencedOperation` type's `callbacks` property is now an `OpenAPI.DereferencedCallbacksMap` instead of an `OpenAPI.CallbacksMap`.

#### DereferencedResponse differences
The `DereferencedResponse` type's `links` property is now an `OrderedDictionary<String, OpenAPI.Link>` instead of an `OpenAPI.Link.Map`.

#### OrderedDictionary proliferation
More `Dictionary` types have been changed to `OrderedDictionary` so that ordering is retained in more situations. This change won't impact most code, but because _some_ `Dictionary` methods are not supported by `OrderedDictionary`, there is a small chance of code breaking. See the following file changes if you need to know which properties switched from `Dictionary` to `OrderedDictionary`: https://github.com/mattpolzin/OpenAPIKit/pull/233/files

An additional location where `OrderedDictionary` replaced `Dictionary` is the `mapping` property of `Discriminator`.

#### Validations difference
The `Document` `validate()` method now throws errors related to warnings from parsing the OpenAPI Document by defualt. If you want to ignore or handle those warnings differently, use `validate(strict: false)`.

The `.operationsContainResponses` validation is now opt-in instead of applied by default when validating. If you still want to ensure documents have responses in all Operation objects, tack the `.operationsContainResponses` validation onto your validator, e.g.: `try document.validate(using: Validator().validating(.operationsContainResponses))`.

