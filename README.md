[![sswg:sandbox|94x20](https://img.shields.io/badge/sswg-sandbox-lightgrey.svg)](https://github.com/swift-server/sswg/blob/master/process/incubation.md#sandbox-level) [![Swift 5.1+](http://img.shields.io/badge/Swift-5.1+-blue.svg)](https://swift.org)

[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) ![Tests](https://github.com/mattpolzin/OpenAPIKit/workflows/Tests/badge.svg)

# OpenAPIKit <!-- omit in toc -->

A library containing Swift types that encode to- and decode from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md) Documents and their components.

- [Usage](#usage)
  - [Decoding OpenAPI Documents](#decoding-openapi-documents)
    - [Decoding Errors](#decoding-errors)
  - [Encoding OpenAPI Documents](#encoding-openapi-documents)
  - [Validating OpenAPI Documents](#validating-openapi-documents)
  - [Supporting OpenAPI 3.0.x Documents](#supporting-openapi-3-documents)
  - [A note on dictionary ordering](#a-note-on-dictionary-ordering)
  - [OpenAPI Document structure](#openapi-document-structure)
    - [Document Root](#document-root)
    - [Routes](#routes)
    - [Endpoints](#endpoints)
    - [Request/Response Bodies](#requestresponse-bodies)
    - [Schemas](#schemas)
    - [JSON References](#json-references)
    - [Security Requirements](#security-requirements)
    - [Specification Extensions](#specification-extensions)
  - [Dereferencing & Resolving](#dereferencing--resolving)
- [Curated Integrations](#curated-integrations)
  - [Declarative OpenAPI Documents](#declarative-openapi-documents)
  - [Generating OpenAPI Documents](#generating-openapi-documents)
  - [Semantic Diffing of OpenAPI Documents](#semantic-diffing-of-openapi-documents)
- [Notes](#notes)
- [Contributing](#contributing)
- [Security](#security)
- [Specification Coverage & Type Reference](#specification-coverage--type-reference)

## Usage

### Migration
#### 1.x to 2.x
If you are migrating from OpenAPIKit 1.x to OpenAPIKit 2.x, check out the [v2 migration guide](./documentation/v2_migration_guide.md).

#### 2.x to 3.0.0
If you are migrating from OpenAPIKit 2.x to OpenAPIKit 3.x, check out the [v3 migration guide](./documentation/v3_migration_guide.md).

You will need to start being explicit about which of the two new modules you want to use in your project: `OpenAPIKit` (now supports OpenAPI spec v3.1) and/or `OpenAPIKit30` (continues to support OpenAPI spec v3.0 like the previous versions of OpenAPIKit did).

In package manifests, dependencies will be one of:
```
// v3.0 of spec:
dependencies: [.product(name: "OpenAPIKit30", package: "OpenAPIKit")]

// v3.1 of spec:
dependencies: [.product(name: "OpenAPIKit", package: "OpenAPIKit")]
```

Your imports need to be specific as well:
```swift
// v3.0 of spec:
import OpenAPIKit30

// v3.1 of spec:
import OpenAPIKit
```

It is recommended that you build your project against the `OpenAPIKit` module and only use `OpenAPIKit30` to support reading OpenAPI 3.0.x documents in and then [converting them](#supporting-openapi-3.0.x-documents) to OpenAPI 3.1.x documents. The situation not supported yet by this strategy is where you need to write out an OpenAPI 3.0.x document (as opposed to 3.1.x). That is a planned feature but it has not yet been implemented. If your use-case benefits from reading in an OpenAPI 3.0.x document and also writing out an OpenAPI 3.0.x document then you can operate entirely against the `OpenAPIKit30` module.

### Decoding OpenAPI Documents

You can decode a JSON OpenAPI document (i.e. using the `JSONDecoder` from **Foundation** library) or a YAML OpenAPI document (i.e. using the `YAMLDecoder` from the [**Yams**](https://github.com/jpsim/Yams) library) with the following code:
```swift
let decoder = ... // JSONDecoder() or YAMLDecoder()
let openAPIDoc = try decoder.decode(OpenAPI.Document.self, from: ...)
```

#### Decoding Errors
You can wrap any error you get back from a decoder in `OpenAPI.Error` to get a friendlier human-readable description from `localizedDescription`.

```swift
do {
  try decoder.decode(OpenAPI.Document.self, from: ...)
} catch let error {
  print(OpenAPI.Error(from: error).localizedDescription)  
}
```

### Encoding OpenAPI Documents

You can encode a JSON OpenAPI document (i.e. using the `JSONEncoder` from the **Foundation** library) or a YAML OpenAPI document (i.e. using the `YAMLEncoder` from the [**Yams**](https://github.com/jpsim/Yams) library) with the following code:
```swift
let openAPIDoc = ...
let encoder = ... // JSONEncoder() or YAMLEncoder()
let encodedOpenAPIDoc = try encoder.encode(openAPIDoc)
```

### Validating OpenAPI Documents
Thanks to Swift's type system, the vast majority of the OpenAPI Specification is represented by the types of OpenAPIKit -- you cannot create bad OpenAPI docuements in the first place and decoding a document will fail with generally useful errors.

That being said, there are a small number of additional checks that you can perform to really put any concerns to bed.

```swift
let openAPIDoc = ...
// perform additional validations on the document:
try openAPIDoc.validate()
```

You can use this same validation system to dig arbitrarily deep into an OpenAPI Document and assert things that the OpenAPI Specification does not actually mandate. For more on validation, see the [OpenAPIKit Validation Documentation](./documentation/validation.md).

### Supporting OpenAPI 3.0.x Documents
If you need to operate on OpenAPI 3.0.x documents and only 3.0.x documents, you can use the `OpenAPIKit30` module throughout your code.

However, if you need to operate on both OpenAPI 3.0.x and 3.1.x documents, the recommendation is to use the OpenAPIKit compatibility layer to read in a 3.0.x document and convert it to a 3.1.x document so that you can use just the one set of Swift types throughout most of your program. An example of that follows.

In this example, only one file in the whole project needs to import `OpenAPIKit30` or `OpenAPIKitCompat`. Every other file would just import `OpenAPIKit` and work with the document in the 3.1.x format.

#### Converting from 3.0.x to 3.1.x
```swift
// import OpenAPIKit30 for OpenAPI 3.0 document support
import OpenAPIKit30
// import OpenAPIKit for OpenAPI 3.1 document support
import OpenAPIKit
// import OpenAPIKitCompat to convert between the versions
import OpenAPIKitCompat

// if most of your project just works with OpenAPI v3.1, most files only need to import OpenAPIKit.
// Only in the file where you are supporting converting from OpenAPI v3.0 to v3.1 do you need the
// other two imports.

// we can support either version by attempting to parse an old version and then a new version if the old version fails
let oldDoc: OpenAPIKit30.OpenAPI.Document?
let newDoc: OpenAPIKit.OpenAPI.Document

oldDoc = try? JSONDecoder().decode(OpenAPI.Document.self, from: someFileData)

newDoc = oldDoc?.convert(to: .v3_1_0) ??
  (try! JSONDecoder().decode(OpenAPI.Document.self, from: someFileData))
// ^ Here we simply fall-back to 3.1.x if loading as 3.0.x failed. You could do a more
//   graceful job of this by determining up front which version to attempt to load or by 
//   holding onto errors for each decode attempt so you can tell the user why the document 
//   failed to decode as neither 3.0.x nor 3.1.x if it fails in both cases.
```

### A note on dictionary ordering
The **Foundation** library's `JSONEncoder` and `JSONDecoder` do not make any guarantees about the ordering of keyed containers. This means decoding a JSON OpenAPI Document and then encoding again might result in the document's various hashed structures being in a different order.

If retaining order is important for your use-case, I recommend the [**Yams**](https://github.com/jpsim/Yams) and [**FineJSON**](https://github.com/omochi/FineJSON) libraries for YAML and JSON respectively. Also keep in mind that JSON is entirely valid YAML and therefore you will likely get good results from Yams decoding of JSON as well (it just won't _encode_ as valid JSON). 

The Foundation JSON encoding and decoding will be the most stable and battle-tested option with Yams as a pretty well established and stable option as well. FineJSON is lesser used (to my knowledge) but I have had success with it in the past.

### OpenAPI Document structure
The types used by this library largely mirror the object definitions found in the [OpenAPI specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md) version 3.0.3. The [Project Status](#project-status) lists each object defined by the spec and the name of the respective type in this library.

#### Document Root
At the root there is an `OpenAPI.Document`. In addition to some information that applies to the entire API, the document contains `OpenAPI.Components` (essentially a dictionary of reusable components that can be referenced with `JSONReferences` and `OpenAPI.References`) and an `OpenAPI.PathItem.Map` (a dictionary of routes your API defines).

#### Routes
Each route is an entry in the document's `OpenAPI.PathItem.Map`. The keys of this dictionary are the paths for each route (i.e. `/widgets`). The values of this dictionary are `OpenAPI.PathItems` which define any combination of endpoints (i.e. `GET`, `POST`, `PATCH`, etc.) that the given route supports. In addition to accessing endpoints on a path item under the name of the method (`.get`, `.post`, etc.), you can get an array of pairs matching endpoint methods to operations with the `.endpoints` method on `PathItem`.

#### Endpoints
Each endpoint on a route is defined by an `OpenAPI.Operation`. Among other things, this operation can specify the parameters (path, query, header, etc.), request body, and response bodies/codes supported by the given endpoint.

#### Request/Response Bodies
Request and response bodies can be defined in great detail using OpenAPI's derivative of the JSON Schema specification. This library uses the `JSONSchema` type for such schema definitions.

#### Schemas
**Fundamental types** are specified as `JSONSchema.integer`, `JSONSchema.string`, `JSONSchema.boolean`, etc.

**Schema attributes** are given as arguments to static constructors. By default, schemas are **non-nullable**, **required**, and **generic**. The below examples are not comprehensive and you can pass any number of the optional attributes to the static constructors as arguments.

A schema can be made **optional** (i.e. it can be omitted) with `JSONSchema.integer(required: false)` or an existing schema can be asked for an `optionalSchemaObject()`. 

A schema can be made **nullable** with `JSONSchema.number(nullable: true)` or an existing schema can be asked for a `nullableSchemaObject()`.

Nullability highlights an important decision OpenAPIKit makes. The JSON Schema specification that dictates how OpenAPI v3.1 documents _encode_ nullability states that a nullable property is encoded as having the `null` type in addition to whatever other type(s) it has. So in OpenAPIKit you set `nullability` as a property of a schema, but when encoded/decoded it will represent the inclusion of absence of `null` in the list of `type`s of the schema.

Some types of schemas can be further specialized with a **format**. For example, `JSONSchema.number(format: .double)` or `JSONSchema.string(format: .dateTime)`.

You can specify a schema's **allowed values** (e.g. for an enumerated type) with `JSONSchema.string(allowedValues: "hello", "world")`.

Each type of schema has its own additional set of properties that can be specified. For example, integers can have a **minimum value**: `JSONSchema.integer(minimum: (0, exclusive: true))`. `exclusive: true` in this context means the number must be strictly greater than 0 whereas `exclusive: false` means the number must be greater-than or equal-to 0.

Compound objects can be built with `JSONSchema.array`, `JSONSchema.object`, `JSONSchema.all(of:)`, etc.

For example, perhaps a person is represented by the schema:
```swift
JSONSchema.object(
  title: "Person",
  properties: [
    "first_name": .string(minLength: 2),
    "last_name": .string(nullable: true),
    "age": .integer,
    "favorite_color": .string(allowedValues: "red", "green", "blue")
  ]
)
```

Take a look at the [OpenAPIKit Schema Object](./documentation/schema_object.md) documentation for more information.

#### OpenAPI References
The `OpenAPI.Reference` type represents the OpenAPI specification's reference support that is essentially just JSON Reference specification compliant but with the ability to override summaries and descriptions at the reference site where appropriate.

For details on the underlying reference support, see the next section on the `JSONReference` type.

#### JSON References
The `JSONReference` type allows you to work with OpenAPIDocuments that store some of their information in the shared Components Object dictionary or even external files. Only documents where all references point to the Components Object can be dereferenced currently, but you can encode and decode all references.

You can create an external reference with `JSONReference.external(URL)`. Internal references usually refer to an object in the Components Object dictionary and are constructed with `JSONReference.component(named:)`. If you need to refer to something in the current file but not in the Components Object, you can use `JSONReference.internal(path:)`.

You can check whether a given `JSONReference` exists in the Components Object with `document.components.contains()`. You can access a referenced object in the Components Object with `document.components[reference]`.

You can create references from the Components Object with `document.components.reference(named:ofType:)`. This method will throw an error if the given component does not exist in the ComponentsObject.

You can use `document.components.lookup()` or the `Components` type's `subscript` to turn an `Either` containing either a reference or a component into an optional value of that component's type (having either pulled it out of the `Either` or looked it up in the Components Object). The `lookup()` method throws when it can't find an item whereas `subscript` returns `nil`.

For example,
```swift
let apiDoc: OpenAPI.Document = ...
let addBooksPath = apiDoc.paths["/cloudloading/addBook"]

let addBooksParameters: [OpenAPI.Parameter]? = addBooksPath?.parameters.compactMap { apiDoc.components[$0] }
```

Note that this looks a component up in the Components Object but it does not transform it into an entirely derefernced object in the same way as is described below in the [Dereferencing & Resolving](#dereferencing--resolving) section.

#### Security Requirements
In the OpenAPI specifcation, a security requirement (like can be found on the root Document or on Operations) is a dictionary where each key is the name of a security scheme found in the Components Object and each value is an array of applicable scopes (which is of course only a non-empty array when the security scheme type is one for which "scopes" are relevant).

OpenAPIKit defines the `SecurityRequirement` typealias as a dictionary with `JSONReference` keys; These references point to the Components Object and provide a slightly stronger contract than the String values required by the OpenAPI specification. Naturally, these are encoded to JSON/YAML as String values rather than JSON References to maintain compliance with the OpenAPI Specification.

To give an example, let's say you want to describe OAuth 2.0 authentication via the implicit flow. First, define a Security Scheme:
```swift
let oauthScheme = OpenAPI.SecurityScheme.oauth2(
    flows: .init(
        implicit: .init(
            authorizationUrl: URL(string: "https://my-api.com/oauth2/auth")!,
            scopes: ["read:widget": "read widget"]
        )
    )
)
```

Next, store it in your OpenAPI document's Components Object (which likely has other entries but we'll only specify the security schemes for this example):
```swift
let components = OpenAPI.Components(
    securitySchemes: ["implicit-oauth": oauthScheme]
)
```

Finally, your OpenAPI Document should use the Components Object we just created and also reference the OAuth implicit scheme via an internal JSON reference:
```swift
let document = OpenAPI.Document(
    info: .init(title: "API", version: "1.0"),
    servers: [],
    paths: [:],
    components: components,
    security: [[.component( named: "implicit-oauth"): ["read:widget"]]]
)
```

If your API supports multiple alternative authentication strategies (only one of which needs to be used), you might have additional entries in your Document's Security array:
```swift
let document = OpenAPI.Document(
    info: .init(title: "API", version: "1.0"),
    servers: [],
    paths: [:],
    components: components,
    security: [
        [.component( named: "implicit-oauth"): ["read:widget"]],
        [.component( named: "auth-code-oauth"): ["read:widget"]]
    ]
)
```

#### Specification Extensions
Many OpenAPIKit types support [Specification Extensions](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#specification-extensions). As described in the OpenAPI Specification, these extensions must be objects that are keyed with the prefix "x-". For example, a property named "specialProperty" on the root OpenAPI Object (`OpenAPI.Document`) is invalid but the property "x-specialProperty" is a valid specification extension.

You can get or set specification extensions via the `vendorExtensions` property on any object that supports this feature. The keys are `Strings` beginning with the aforementioned "x-" prefix and the values are `AnyCodable`. If you set an extension without using the "x-" prefix, the prefix will be added upon encoding.

`AnyCodable` can be constructed from literals or explicitly. The following are all valid.

```swift
var document = OpenAPI.Document(...)

document.vendorExtensions["x-specialProperty1"] = true
document.vendorExtensions["x-specialProperty2"] = "hello world"
document.vendorExtensions["x-specialProperty3"] = ["hello", "world"]
document.vendorExtensions["x-specialProperty4"] = ["hello": "world"]
document.vendorExtensions["x-specialProperty5"] = AnyCodable("hello world")
```

### Dereferencing & Resolving
In addition to looking something up in the `Components` object, you can entirely derefererence many OpenAPIKit types. A dereferenced type has had all of its references looked up (and all of its properties' references, all the way down).

You use a value's `dereferenced(in:)` method to fully dereference it.

You can even dereference the whole document with the `OpenAPI.Document` `locallyDereferenced()` method. As the name implies, you can only derefence whole documents that are contained within one file (which is another way of saying that all references are "local"). Specifically, all references must be located within the document's Components Object.

Unlike what happens when you lookup an individual component using the `lookup()` method on `Components`, dereferencing a whole `OpenAPI.Document` will result in type-level changes that guarantee all references are removed. `OpenAPI.Document`'s `locallyDereferenced()` method returns a `DereferencedDocument` which exposes `DereferencedPathItem`s which have `DereferencedParameter`s and `DereferencedOperation`s and so on.

Anywhere that a type would have had either a reference or a component, the dereferenced variety will simply have the component. For example, `PathItem` has an array of parameters, each of which is `Either<OpenAPI.Reference<Parameter>, Parameter>` whereas a `DereferencedPathItem` has an array of `DereferencedParameter`s. The dereferenced variant of each type exposes all the same properties and you can get at the underlying `OpenAPI` type via an `underlying{TypeName}` property. This can make for a much more convenient way to traverse a document because you don't need to check for or look up references anywhere the OpenAPI Specification allows them.

For all dereferenced types except for `JSONSchema`, dereferencing will store a new vendor extension on the dereferenced value to keep track of the Component Object name the value used to be referenced at. This vendor extension is a string value with the `x-component-name` key.

You can take things a step further and resolve the document. Calling `resolved()` on a `DereferencedDocument` will produce a canonical form of an `OpenAPI.Document`. The `ResolvedRoute`s and `ResolvedEndpoint`s that the `ResolvedDocument` exposes collect all relevant information from the whole document into themselves. For example, a `ResolvedEndpoint` knows what servers it can be used on, what path it is located at, and which parameters it supports (even if some of those parameters were defined in an `OpenAPI.Operation` and others were defined in the containing `OpenAPI.PathItem`).

If your end goal is to analyze the OpenAPI Document or generate something entirely new (like code) from it, the `ResolvedDocument` is by far more convenient to traverse and query than the original `OpenAPI.Document`. The downside is, there is not currently support for mutating the `ResolvedDocument` and then turning it back into an `OpenAPI.Document` to encode it.

```swift
let document: OpenAPI.Document = ...

let resolvedDocument = try document
    .locallyDereferenced()
    .resolved()

for endpoint in resolvedDocument.endpoints {
    // The description found on the PathItem containing the Operation defining this endpoint:
    let routeDescription = endpoint.routeDescription

    // The description found directly on the Operation defining this endpoint:
    let endpointDescription = endpoint.endpointDescription

    // The path, which in the OpenAPI.Document is the key of the dictionary containing
    // the PathItem under which the Operation for this endpoint lives:
    let path = endpoint.path

    // The method, which in the OpenAPI.Document is the way you access the Operation for
    // this endpoint on the PathItem (GET, PATCH, etc.):
    let httpMethod = endpoint.method

    // All parameters defined for the Operation _or_ the PathItem containing it:
    let parameters = endpoint.parameters

    // Per the specification, this is 
    // 1. the list of servers defined on the Operation if one is given.
    // 2. the list of servers defined on the PathItem if one is given _and_ 
    //	no list was found on the Operation.
    // 3. the list of servers defined on the Document if no list was found on
    //	the Operation _or_ the PathItem.
    let servers = endpoint.servers

    // and many more properties...
}
```

## Curated Integrations
Following is a short list of integrations that might be immediately useful or just serve as examples of ways that OpenAPIKit can be used to harness the power of the OpenAPI specification.

If you have a library you would like to propose for this section, please create a pull request and explain a bit about your project.

### Declarative OpenAPI Documents

The [**Swift Package Registry API Docs**](https://github.com/mattt/swift-package-registry-oas) define the OpenAPI documentation for the Swift Package Registry standard using declarative Swift code and OpenAPIKit. This project also provides a useful example of producing a user-friendly ReDoc web interface to the OpenAPI documentation after encoding it as YAML.

### Generating OpenAPI Documents

[**VaporOpenAPI**](https://github.com/mattpolzin/VaporOpenAPI) / [VaporOpenAPIExample](https://github.com/mattpolzin/VaporOpenAPIExample) provide an example of generating OpenAPI from a Vapor application's routes.

[**JSONAPI+OpenAPI**](https://github.com/mattpolzin/jsonapi-openapi) is a library that generates OpenAPI schemas from JSON:API types. The library has some rudimentary and experimental support for going the other direction and generating Swift types that represent JSON:API resources described by OpenAPI documentation.

### Semantic Diffing of OpenAPI Documents

[**OpenAPIDiff**](https://github.com/mattpolzin/OpenAPIDiff) is a library and a CLI that implements semantic diffing; that is, rather than just comparing two OpenAPI documents line-by-line for textual differences, it parses the documents and describes the differences in the two OpenAPI ASTs.

## Notes
This library does *not* currently support file reading at all muchless following `$ref`s to other files and loading them in. You must read OpenAPI documentation into `Data` or `String` (depending on the decoder you want to use) and all references must be internal to the same file to be resolved.

This library *is* opinionated about a few defaults when you use the Swift types, however encoding and decoding stays true to the spec. Some key things to note:

1. Within schemas, `required` is specified on the property rather than being specified on the parent object (encoding/decoding still follows the OpenAPI spec).
    * ex `JSONSchema.object(properties: [ "val": .string(required: true)])` is an "object" type with a required "string" type property.
2. Within schemas, `required` defaults to `true` on initialization (again, encoding/decoding still follows the OpenAPI spec).
    * ex. `JSONSchema.string` is a required "string" type.
    * ex. `JSONSchema.string(required: false)` is an optional "string" type.

See [**A note on dictionary ordering**](#a-note-on-dictionary-ordering) before deciding on an encoder/decoder to use with this library.

## Contributing
Contributions to OpenAPIKit are welcome and appreciated! The project is mostly maintained by one person which means additional contributors have a huge impact on how much gets done how quickly.

Please see the [Contribution Guidelines](./CONTRIBUTING.md) for a few brief notes on contributing the the project.

## Security
The OpenAPIKit project takes code security seriously. As part of the Swift Server Workground incubation program, this project follows a shared set of standards around receiving, reporting, and reacting to security vulnerabilies.

Please see [Security](./SECURITY.md) for information on how to report vulnerabilities to the OpenAPIKit project and what to expect after you do.

**Please do not report security vulnerabilities via GitHub issues.**

## Specification Coverage & Type Reference
For a full list of OpenAPI Specification types annotated with whether OpenAPIKit supports them and relevant translations to OpenAPIKit types, see the [Specification Coverage](./documentation/specification_coverage.md) documentation. For detailed information on the OpenAPIKit types, see the [full type documentation](https://github.com/mattpolzin/OpenAPIKit/wiki).
