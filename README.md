[![sswg:sandbox|94x20](https://img.shields.io/badge/sswg-sandbox-lightgrey.svg)](https://github.com/swift-server/sswg/blob/master/process/incubation.md#sandbox-level) [![Swift 5.1+](http://img.shields.io/badge/Swift-5.1/5.2-blue.svg)](https://swift.org)

[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) ![Tests](https://github.com/mattpolzin/OpenAPIKit/workflows/Tests/badge.svg)

# OpenAPIKit <!-- omit in toc -->

A library containing Swift types that encode to- and decode from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md) Documents and their components.

- [Usage](#usage)
	- [Decoding OpenAPI Documents](#decoding-openapi-documents)
		- [Decoding Errors](#decoding-errors)
	- [Encoding OpenAPI Documents](#encoding-openapi-documents)
	- [Validating OpenAPI Documents](#validating-openapi-documents)
	- [A note on dictionary ordering](#a-note-on-dictionary-ordering)
	- [OpenAPI Document structure](#openapi-document-structure)
		- [Document Root](#document-root)
		- [Routes](#routes)
		- [Endpoints](#endpoints)
		- [Request/Response Bodies](#requestresponse-bodies)
		- [Schemas](#schemas)
			- [Generating Schemas from Swift Types](#generating-schemas-from-swift-types)
		- [JSON References](#json-references)
		- [Security Requirements](#security-requirements)
		- [Specification Extensions](#specification-extensions)
	- [Dereferencing & Resolving](#dereferencing--resolving)
- [Curated Integrations](#curated-integrations)
	- [Generating OpenAPI Documents](#generating-openapi-documents)
	- [Semantic Diffing of OpenAPI Documents](#semantic-diffing-of-openapi-documents)
- [Notes](#notes)
- [Specification Coverage & Type Reference](#specification-coverage--type-reference)

## Usage

### Decoding OpenAPI Documents

You can decode a JSON OpenAPI document (i.e. using the `JSONDecoder` from **Foundation** library) or a YAML OpenAPI document (i.e. using the `YAMLDecoder` from the [**Yams**](https://github.com/jpsim/Yams) library) with the following code:
```swift
let decoder = ... // JSONDecoder() or YAMLDecoder()
let openAPIDoc = try decoder.decode(OpenAPI.Document, from: ...)
```

#### Decoding Errors
You can wrap any error you get back from a decoder in `OpenAPI.Error` to get a friendlier human-readable description from `localizedDescription`.

```swift
do {
  try decoder.decode(OpenAPI.Document, from: ...)
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

You can use this same validation system to dig arbitrarily deep into an OpenAPI Document and assert things that the OpenAPI Specification does not actually mandate. For more on validation, see the [Validation Documentation](./documentation/validation.md).

### A note on dictionary ordering
The **Foundation** library's `JSONEncoder` and `JSONDecoder` do not make any guarantees about the ordering of keyed containers. This means decoding a JSON OpenAPI Document and then encoding again might result in the document's various hashed structures being in a totally different order.

If retaining order is important for your use-case, I recommend the [**Yams**](https://github.com/jpsim/Yams) and [**FineJSON**](https://github.com/omochi/FineJSON) libraries for YAML and JSON respectively.

### OpenAPI Document structure
The types used by this library largely mirror the object definitions found in the [OpenAPI specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md)  version 3.0.2. The [Project Status](#project-status) lists each object defined by the spec and the name of the respective type in this library.

#### Document Root
At the root there is an `OpenAPI.Document`. In addition to some information that applies to the entire API, the document contains `OpenAPI.Components` (essentially a dictionary of reusable components that can be referenced with `JSONReferences`) and an `OpenAPI.PathItem.Map` (a dictionary of routes your API defines).

#### Routes
Each route is an entry in the document's `OpenAPI.PathItem.Map`. The keys of this dictionary are the paths for each route (i.e. `/widgets`). The values of this dictionary are `OpenAPI.PathItems` which define any combination of endpoints (i.e. `GET`, `POST`, `PATCH`, etc.) that the given route supports. In addition to accessing endpoints on a path item under the name of the method (`.get`, `.post`, etc.), you can get an array of pairs matching endpoint methods to operations with the `.endpoints` method on `PathItem`.

#### Endpoints
Each endpoint on a route is defined by an `OpenAPI.Operation`. Among other things, this operation can specify the parameters (path, query, header, etc.), request body, and response bodies/codes supported by the given endpoint.

#### Request/Response Bodies
Request and response bodies can be defined in great detail using OpenAPI's derivative of the JSON Schema specification. This library uses the `JSONSchema` type for such schema definitions.

#### Schemas
**Fundamental types** are specified as `JSONSchema.integer`, `JSONSchema.string`, `JSONSchema.boolean`, etc.

**Properties** are given as arguments to static constructors. By default, types are **non-nullable**, **required**, and **generic**.

A type can be made **optional** (i.e. it can be omitted) with `JSONSchema.integer(required: false)` or `JSONSchema.integer.optionalSchemaObject()`. A type can be made **nullable** with `JSONSchema.number(nullable: true)` or `JSONSchema.number.nullableSchemaObject()`.

A type's **format** can be further specified, for example `JSONSchema.number(format: .double)` or `JSONSchema.string(format: .dateTime)`.

You can specify a schema's **allowed values** (e.g. for an enumerated type) with `JSONSchema.string(allowedValues: "hello", "world")`.

Each type has its own additional set of properties that can be specified. For example, integers can have a **minimum value**: `JSONSchema.integer(minimum: (0, exclusive: true))` (where exclusive means the number must be greater than 0, not greater-than-or-equal-to 0).

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

##### Generating Schemas from Swift Types

Some schemas can be easily generated from Swift types. Many of the fundamental Swift types support schema representations out-of-box.

For example, the following are true
```swift
String.openAPISchema == JSONSchema.string

Bool.openAPISchema == JSONSchema.boolean

Double.openAPISchema == JSONSchema.number(format: .double)

Float.openAPISchema == JSONSchema.number(format: .float)
...
```

`Array` and `Optional` are supported out-of-box. For example, the following are true
```swift
[String].openAPISchema == .array(items: .string)

[Int].openAPISchema == .array(items: .integer)

Int32?.openAPISchema == .integer(format: .int32, required: false)

[String?].openAPISchema == .array(items: .string(required: false))
...
```

Additional schema generation support can be found in the [`mattpolzin/OpenAPIReflection`](https://github.com/mattpolzin/OpenAPIReflection) library.

You can conform your own types to `OpenAPISchemaType` to make it convenient to generate `JSONSchemas` from them.

#### JSON References
The `JSONReference` type allows you to work with OpenAPIDocuments that store some of their information in the shared Components Object dictionary or even external files. You cannot dereference documents (yet), but you can encode and decode references.

You can create an external reference with `JSONReference.external(URL)`. Internal references usually refer to an object in the Components Object dictionary and are constructed with `JSONReference.component(named:)`. If you need to refer to something in the current file but not in the Components Object, you can use `JSONReference.internal(path:)`.

You can check whether a given `JSONReference` exists in the Components Object with `document.components.contains()`. You can access a referenced object in the Components Object with `document.components[reference]`.

You can create references from the Components Object with `document.components.reference(named:ofType:)`. This method will throw an error if the given component does not exist in the ComponentsObject.

You can use `document.components.dereference()` to turn an `Either` containing either a reference or a component into an optional value of that component's type (having either pulled it out of the `Either` or looked it up in the Components Object).

For example,
```swift
let apiDoc: OpenAPI.Document = ...
let addBooksPath = apiDoc.paths["/cloudloading/addBook"]

let addBooksParameters: [OpenAPI.Parameter]? = addBooksPath?.parameters.compactMap(apiDoc.components.dereference)
```

Note that this looks a component up in the Components Object but it does not transform it into an entirely derefernced object in the same way as is described below in the [Dereferencing & Resolving](#dereferencing--resolving) section.

#### Security Requirements
In the OpenAPI specifcation, a security requirement (like can be found on the root Document or on Operations) is a dictionary where each key is the name of a security scheme found in the Components Object and each value is an array of applicable scopes (which is of course only a non-empty array when the security scheme type is one for which "scopes" are relevant).

OpenAPIKit defines the `SecurityRequirement` typealias as a dictionary with `JSONReference` keys; These references point to the Components Object and provide a slightly stronger contract than the String values required by the OpenAPI specification. Naturally, these are encoded to JSON/YAML as String values rather than JSON References to maintain compliance with the OpenAPI Specification.

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
In addition to using the `Components` type's `dereference()` method to look up a `JSONReference`, you can opt to work on an entirely dereferenced OpenAPI document with the `OpenAPI.Document` `locallyDereferenced()` method.

As the name implies, you can only derefence whole documents that are contained within one file (which is another way of saying that all references are "local"). Specifically, all references must be located within the document's Components Object.

Unlike what happens when you dereference an individual component using `Components` `dereference()` method, dereferencing a whole `OpenAPI.Document` will result in type-level changes that guarantee all references are removed. `OpenAPI.Document`'s `locallyDereferenced()` method returns a `DereferencedDocument` which exposes `DereferencedPathItem`s which have `DereferencedParameter`s and `DereferencedOperation`s and so on.

Anywhere that a type would have had either a reference or a component, the dereferenced variety will simply have the component. For example, `PathItem` has an array of parameters, each of which is `Either<JSONReference<Parameter>, Parameter>` whereas a `DereferencedPathItem` has an array of `DereferencedParameter`s. The dereferenced variant of each type exposes all the same properties. This can make for a much more convenient way to traverse a document because you don't need to check for or look up references anywhere the OpenAPI Specification allows them.

You can take things a step further and resolve the document. Calling `resolved()` on a `DereferencedDocument` will produce a canonical form of an `OpenAPI.Document`. The `ResolvedRoute`s and `ResolvedEndpoint`s that the `ResolvedDocument` exposes collect all relevant information from the whole document into themselves. For example, a `ResolvedEndpoint` knows what servers it can be used on, what path it is located at, and which parameters it supports (even if some of those parameters were defined in an `OpenAPI.Operation` and others were defined in the containing `OpenAPI.PathItem`).

If your end goal is to analyze the OpenAPI Document or generate something entirely new (like code) from it, the `ResolvedDocument` is by far more convenient to traverse and query than the original `OpenAPI.Document`. The downside is, there is not currently support for mutating the `ResolvedDocument` and then turning it back into an `OpenAPI.Document` to encode it.

## Curated Integrations
Following is a short list of integrations that might be immediately useful or just serve as examples of ways that OpenAPIKit can be used to harness the power of the OpenAPI specification.

If you have a library you would like to propose for this section, please create a pull request and explain a bit about your project.

### Generating OpenAPI Documents

[**VaporOpenAPI**](https://github.com/mattpolzin/VaporOpenAPI) / [VaporOpenAPIExample](https://github.com/mattpolzin/VaporOpenAPIExample) provide an example of generating OpenAPI from a Vapor application's routes.

[**JSONAPI+OpenAPI**](https://github.com/mattpolzin/jsonapi-openapi) is a library that generates OpenAPI schemas from JSON:API types. The library has some rudimentary and experimental support for going the other direction and generating Swift types that represent JSON:API resources described by OpenAPI documentation.

### Semantic Diffing of OpenAPI Documents

[**OpenAPIDiff**](https://github.com/mattpolzin/OpenAPIDiff) is a library and a CLI that implements semantic diffing; that is, rather than just comparing two OpenAPI documents line-by-line for textual differences, it parses the documents and describes the differences in the two OpenAPI ASTs.

## Notes
This library does *not* currently support file reading at all muchless following `$ref`s to other files and loading them in.

This library *is* opinionated about a few defaults when you use the Swift types, however encoding and decoding stays true to the spec. Some key things to note:

1. Within schemas, `required` is specified on the property rather than being specified on the parent object (encoding/decoding still follows the OpenAPI spec).
    * ex `JSONSchema.object(properties: [ "val": .string(required: true)])` is an "object" type with a required "string" type property.
2. Within schemas, `required` defaults to `true` on initialization (again, encoding/decoding still follows the OpenAPI spec).
    * ex. `JSONSchema.string` is a required "string" type.
    * ex. `JSONSchema.string(required: false)` is an optional "string" type.

See [**A note on dictionary ordering**](#a-note-on-dictionary-ordering) before deciding on an encoder/decoder to use with this library.

## Specification Coverage & Type Reference
For a full list of OpenAPI Specification types annotated with whether OpenAPIKit supports them and relevant translations to OpenAPIKit types, see the [Specification Coverage](./documentation/specification_coverage.md) documentation. For detailed information on the OpenAPIKit types, see the [full type documentation](https://github.com/mattpolzin/OpenAPIKit/wiki).
