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

### JSONSchema differences
The `reference` case has gained a `CoreContext` so switching on it will need to change as follows:

Before:
```swift
case .reference(let ref): ...
```

After:
```swift 
case .reference(let ref, let context): ...
```

### Migrating to the OpenAPIKit module
This section describes migrating to the module that supports OpenAPI 3.1.x documents.

### JSONReference differences
All occurrences of `JSONReference` outside of `JSONSchema` have been replaced by `OpenAPI.Reference`, a type that supports OpenAPI 3.1.x's ability to override summary and description.

Anywhere your code used to create a reference with `JSONReference.internal(.path(...))` you will now use `OpenAPI.Reference.internal(path: ...)` (and similarly for external references).

### JSONSchema differences
The `.reference` case has gained a `CoreContext` so switching on it will need to change as follows:

Before:
```swift
case .reference(let ref): ...
```

After:
```swift 
case .reference(let ref, let context): ...
```
