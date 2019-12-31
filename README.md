[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) [![Swift 5.1](http://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org) [![Build Status](https://app.bitrise.io/app/2f7379e33723d853/status.svg?token=Jx4X3su3oE59z_rJBRC_og&branch=master)](https://app.bitrise.io/app/2f7379e33723d853)

# OpenAPIKit

A library containing Swift types that encode to- and decode from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md) Documents and their components.

<!-- TOC depthFrom:2 depthTo:3 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Usage](#usage)
	- [Decoding OpenAPI Documents](#decoding-openapi-documents)
	- [Encoding OpenAPI Documents](#encoding-openapi-documents)
	- [Generating OpenAPI Documents](#generating-openapi-documents)
	- [OpenAPI Document structure](#openapi-document-structure)
- [Notes](#notes)
- [Project Status](#project-status)
	- [OpenAPI Object (`OpenAPI.Document`)](#openapi-object-openapidocument)
	- [Info Object (`OpenAPI.Document.Info`)](#info-object-openapidocumentinfo)
	- [Contact Object (`OpenAPI.Document.Info.Contact`)](#contact-object-openapidocumentinfocontact)
	- [License Object (`OpenAPI.Document.Info.License`)](#license-object-openapidocumentinfolicense)
	- [Server Object (`OpenAPI.Server`)](#server-object-openapiserver)
	- [Server Variable Object (`OpenAPI.Server.Variable`)](#server-variable-object-openapiservervariable)
	- [Components Object (`OpenAPI.Components`)](#components-object-openapicomponents)
	- [Paths Object (`OpenAPI.PathItem.Map`)](#paths-object-openapipathitemmap)
	- [Path Item Object (`OpenAPI.PathItem`)](#path-item-object-openapipathitem)
	- [Operation Object (`OpenAPI.PathItem.Operation`)](#operation-object-openapipathitemoperation)
	- [External Document Object (`OpenAPI.ExternalDoc`)](#external-document-object-openapiexternaldoc)
	- [Parameter Object (`OpenAPI.PathItem.Parameter`)](#parameter-object-openapipathitemparameter)
	- [Request Body Object (`OpenAPI.Request`)](#request-body-object-openapirequest)
	- [Media Type Object (`OpenAPI.Content`)](#media-type-object-openapicontent)
	- [Encoding Object (`OpenAPI.Content.Encoding`)](#encoding-object-openapicontentencoding)
	- [Responses Object (`OpenAPI.Response.Map`)](#responses-object-openapiresponsemap)
	- [Response Object (`OpenAPI.Response`)](#response-object-openapiresponse)
	- [Callback Object](#callback-object)
	- [Example Object (`OpenAPI.Example`)](#example-object-openapiexample)
	- [Link Object](#link-object)
	- [Header Object (`OpenAPI.Header`)](#header-object-openapiheader)
	- [Tag Object (`OpenAPI.Tag`)](#tag-object-openapitag)
	- [Reference Object (`JSONReference`)](#reference-object-jsonreference)
	- [Schema Object (`JSONSchema`)](#schema-object-jsonschema)
	- [Discriminator Object (`OpenAPI.Discriminator`)](#discriminator-object-openapidiscriminator)
	- [XML Object](#xml-object)
	- [Security Scheme Object](#security-scheme-object)
	- [OAuth Flows Object](#oauth-flows-object)
	- [OAuth Flow Object](#oauth-flow-object)
	- [Security Requirement Object](#security-requirement-object)

<!-- /TOC -->

## Usage

### Decoding OpenAPI Documents

You can decode a JSON OpenAPI document (i.e. using the `JSONDecoder` from **Foundation** library) or a YAML OpenAPI document (i.e. using the `YAMLDecoder` from the [**Yams**](https://github.com/jpsim/Yams) library) with the following code:
```swift
let decoder = ... // JSONDecoder() or YAMLDecoder()
let openAPIDoc = try decoder.decode(OpenAPI.Document, from: ...)
```

### Encoding OpenAPI Documents

You can encode a JSON OpenAPI document (i.e. using the `JSONEncoder` from the **Foundation** library) or a YAML OpenAPI document (i.e. using the `YAMLEncoder` from the [**Yams**](https://github.com/jpsim/Yams) library) with the following code:
```swift
let openAPIDoc = ...
let encoder = ... // JSONEncoder() or YAMLEncoder()
let encodedOpenAPIDoc = try encoder.encode(openAPIDoc)
```

### Generating OpenAPI Documents

See [**VaporOpenAPI**](https://github.com/mattpolzin/VaporOpenAPI) / [VaporOpenAPIExample](https://github.com/mattpolzin/VaporOpenAPIExample) for an example of generating OpenAPI from a Vapor application's routes.

See [**JSONAPI+OpenAPI**](https://github.com/mattpolzin/jsonapi-openapi) for an example of generating OpenAPI response schemas from JSON:API response documents.

### OpenAPI Document structure
The types used by this library largely mirror the object definitions found in the [OpenAPI specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md)  version 3.0.2. The [Project Status](#project-status) lists each object defined by the spec and the name of the respective type in this library.

#### Document Root
At the root there is an `OpenAPI.Document`. In addition to some information that applies to the entire API, the document contains `OpenAPI.Components` (essentially a dictionary of reusable components that can be referenced with `JSONReferences`) and an `OpenAPI.PathItem.Map` (a dictionary of routes your API defines).

#### Routes
Each route is an entry in the document's `OpenAPI.PathItem.Map`. The keys of this dictionary are the paths for each route (i.e. `/widgets`). The values of this dictionary are `OpenAPI.PathItems` which define any combination of endpoints (i.e. `GET`, `POST`, `PATCH`, etc.) that the given route supports.

#### Endpoints
Each endpoint on a route is defined by an `OpenAPI.PathItem.Operation`. Among other things, this operation can specify the parameters (path, query, header, etc.), request body, and response bodies/codes supported by the given endpoint.

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

##### Generating Schemas

Some schemas can be easily generated from Swift types. Many of the fundamental Swift types support schema representations out-of-box.

For example, the following are true
```swift
String.openAPINode() == JSONSchema.string

Bool.openAPINode() == JSONSchema.boolean

Double.openAPINode() == JSONSchema.number(format: .double)

Float.openAPINode() == JSONSchema.number(format: .float)
...
```

`Array` and `Optional` are supported out-of-box. For example, the following are true
```swift
[String].openAPINode() == .array(items: .string)

[Int].openAPINode() == .array(items: .integer)

Int32?.openAPINode() == .integer(format: .int32, required: false)

[String?].openAPINode() == .array(items: .string(required: false))
...
```

###### AnyCodable

A subset of supported Swift types require a `JSONEncoder` either to make an educated guess at the `JSONSchema` for the type or in order to turn arbitrary types into `AnyCodable` for use as schema examples or allowed values.

Swift enums produce schemas with **allowed values** specified as long as they conform to `CaseIterable`, `Encodable`, and `AnyJSONCaseIterable` (the last of which is free given the former two).
```swift
enum CodableEnum: String, CaseIterable, AnyJSONCaseIterable, Codable {
    case one
    case two
}

let schema = CodableEnum.genericOpenAPINode(using: JSONEncoder())
// ^ equivalent, although not equatable, to:
let sameSchema = JSONSchema.string(
  allowedValues: "one", "two"
)
```

Swift structs produce a best-guess schema as long as they conform to `Sampleable` and `Encodable`
```swift
struct Nested: Encodable, Sampleable {
  let string: String
  let array: [Int]

  // `Sampleable` just enables mirroring, although you could use it to produce
  // OpenAPI examples as well.
  static let sample: Self = .init(
    string: "",
    array: []
  )
}

let schema = Nested.genericOpenAPINode(using: JSONEncoder())
// ^ equivalent and indeed equatable to:
let sameSchema = JSONSchema.object(
  properties: [
    "string": .string,
    "array": .array(items: .integer)
  ]
)
```

## Notes
This library does *not* currently support file reading at all muchless following `$ref`s to other files and loading them in.

This library *is* opinionated about a few defaults when you use the Swift types, however encoding and decoding stays true to the spec. Some key things to note:

1. Within schemas, `required` is specified on the property rather than being specified on the parent object (encoding/decoding still follows the OpenAPI spec).
    * ex `JSONSchema.object(properties: [ "val": .string(required: true)])` is an "object" type with a required "string" type property.
2. Within schemas, `required` defaults to `true` on initialization (again, encoding/decoding still follows the OpenAPI spec).
    * ex. `JSONSchema.string` is a required "string" type.
    * ex. `JSONSchema.string(required: false)` is an optional "string" type.

## Project Status

### OpenAPI Object (`OpenAPI.Document`)
- [x] openapi (`openAPIVersion`)
- [x] info
- [x] servers
- [x] paths
- [x] components
- [ ] security
- [x] tags
- [x] externalDocs

### Info Object (`OpenAPI.Document.Info`)
- [x] title
- [x] description
- [x] termsOfService
- [x] contact
- [x] license
- [x] version

### Contact Object (`OpenAPI.Document.Info.Contact`)
- [x] name
- [x] url
- [x] email

### License Object (`OpenAPI.Document.Info.License`)
- [x] name
- [x] url

### Server Object (`OpenAPI.Server`)
- [x] url
- [x] description
- [x] variables

### Server Variable Object (`OpenAPI.Server.Variable`)
- [x] enum
- [x] default
- [x] description

### Components Object (`OpenAPI.Components`)
- [x] schemas
- [x] responses
- [x] parameters
- [x] examples
- [x] requestBodies
- [x] headers
- [ ] securitySchemes
- [ ] links
- [ ] callbacks

### Paths Object (`OpenAPI.PathItem.Map`)
- [x] *dictionary*

### Path Item Object (`OpenAPI.PathItem`)
- [x] $ref (`reference` case)
- [x] summary (`operations` case)
- [x] description (`operations` case)
- [x] servers (`operations` case)
- [x] parameters (`operations` case)
- [x] get (`operations` case)
- [x] put (`operations` case)
- [x] post (`operations` case)
- [x] delete (`operations` case)
- [x] options (`operations` case)
- [x] head (`operations` case)
- [x] patch (`operations` case)
- [x] trace (`operations` case)

### Operation Object (`OpenAPI.PathItem.Operation`)
- [x] tags
- [x] summary
- [x] description
- [x] externalDocs
- [x] operationId
- [x] parameters
- [x] requestBody
- [x] responses
- [ ] callbacks
- [x] deprecated
- [ ] security
- [x] servers

### External Document Object (`OpenAPI.ExternalDoc`)
- [x] description
- [x] url

### Parameter Object (`OpenAPI.PathItem.Parameter`)
- [x] name
- [x] in (`parameterLocation`)
- [x] description
- [x] required (part of `parameterLocation`)
- [x] deprecated
- [x] allowEmptyValue (part of `parameterLocation`)
- [x] content (`schemaOrContent`)
- [x] schema (`schemaOrContent`)
    - [x] style
    - [x] explode
    - [x] allowReserved
    - [x] example
    - [x] examples

### Request Body Object (`OpenAPI.Request`)
- [x] description
- [x] content
- [x] required

### Media Type Object (`OpenAPI.Content`)
- [x] schema
- [x] example
- [x] examples
- [x] encoding
- [x] specification extensions (`vendorExtensions`)

### Encoding Object (`OpenAPI.Content.Encoding`)
- [x] contentType
- [x] headers
- [x] style
- [x] explode
- [x] allowReserved

### Responses Object (`OpenAPI.Response.Map`)
- [x] *dictionary*

### Response Object (`OpenAPI.Response`)
- [x] description
- [x] headers
- [x] content
- [ ] links

### Callback Object
- [ ] *{expression}*

### Example Object (`OpenAPI.Example`)
- [x] summary
- [x] description
- [x] value
- [x] externalValue (part of `value`)
- [x] specification extensions (`vendorExtensions`)

### Link Object
- [ ] operationRef
- [ ] operationId
- [ ] parameters
- [ ] requestBody
- [ ] description
- [ ] server

### Header Object (`OpenAPI.Header`)
- [x] description
- [x] required
- [x] deprecated
- [x] content
- [x] schema
    - [ ] style
    - [ ] explode
    - [ ] allowReserved
    - [ ] example
    - [ ] examples

### Tag Object (`OpenAPI.Tag`)
- [x] name
- [x] description
- [x] externalDocs

### Reference Object (`JSONReference`)
- [x] $ref
    - [x] local (same file) reference (`node` case)
        - [x] encode
        - [ ] decode
        - [ ] dereference
    - [x] remote (different file) reference (`file` case)
        - [x] encode
        - [x] decode
        - [ ] dereference

### Schema Object (`JSONSchema`)
- [x] Mostly complete support for JSON Schema inherited keywords
- [ ] Specification Extensions
- [x] nullable
- [ ] discriminator
- [ ] readOnly
- [ ] writeOnly
- [ ] xml
- [x] externalDocs
- [x] example
- [ ] deprecated

### Discriminator Object (`OpenAPI.Discriminator`)
- [x] propertyName
- [x] mapping

### XML Object
- [ ] name
- [ ] namespace
- [ ] prefix
- [ ] attribute
- [ ] wrapped

### Security Scheme Object
- [ ] type
- [ ] description
- [ ] name
- [ ] in
- [ ] scheme
- [ ] bearerFormat
- [ ] flows
- [ ] openIdConnectUrl

### OAuth Flows Object
- [ ] implicit
- [ ] password
- [ ] clientCredentials
- [ ] authorizationCode

### OAuth Flow Object
- [ ] authorizationUrl
- [ ] tokenUrl
- [ ] refreshUrl
- [ ] scopes

### Security Requirement Object
- [ ] *{name}*
