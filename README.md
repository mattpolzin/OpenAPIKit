[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) [![Swift 5.1](http://img.shields.io/badge/Swift-5.1-blue.svg)](https://swift.org) [![Build Status](https://app.bitrise.io/app/2f7379e33723d853/status.svg?token=Jx4X3su3oE59z_rJBRC_og&branch=master)](https://app.bitrise.io/app/2f7379e33723d853)

# OpenAPIKit

A library containing Swift types that encode to- and decode from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md) Documents and their components.

- [Usage](#usage)
	- [Decoding OpenAPI Documents](#decoding-openapi-documents)
		- [Decoding Errors](#decoding-errors)
	- [Encoding OpenAPI Documents](#encoding-openapi-documents)
	- [A note on dictionary ordering](#a-note-on-dictionary-ordering)
	- [Generating OpenAPI Documents](#generating-openapi-documents)
	- [OpenAPI Document structure](#openapi-document-structure)
		- [Document Root](#document-root)
		- [Routes](#routes)
		- [Endpoints](#endpoints)
		- [Request/Response Bodies](#requestresponse-bodies)
		- [Schemas](#schemas)
			- [Generating Schemas from Swift Types](#generating-schemas-from-swift-types)
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
	- [XML Object (`OpenAPI.XML`)](#xml-object-openapixml)
	- [Security Scheme Object (`OpenAPI.SecurityScheme`)](#security-scheme-object-openapisecurityscheme)
	- [OAuth Flows Object (`OpenAPI.OauthFlows`)](#oauth-flows-object-openapioauthflows)
	- [OAuth Flow Object (`OpenAPI.OauthFlows.*`)](#oauth-flow-object-openapioauthflows)
	- [Security Requirement Object (`OpenAPI.Document.SecurityRequirement`)](#security-requirement-object-openapidocumentsecurityrequirement)

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
  try decoder.docode(OpenAPI.Document, from: ...)
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

### A note on dictionary ordering
The **Foundation** library's `JSONEncoder` and `JSONDecoder` do not make any guarantees about the ordering of keyed containers. This means decoding a JSON OpenAPI Document and then encoding again might result in the document's various hashed structures being in a totally different order.

If retaining order is important for your use-case, I recommend the [**Yams**](https://github.com/jpsim/Yams) and [**FineJSON**](https://github.com/omochi/FineJSON) libraries for YAML and JSON respectively.

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

##### Generating Schemas from Swift Types

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

Additional schema generation support can be found in the [`mattpolzin/OpenAPIReflection`](https://github.com/mattpolzin/OpenAPIReflection) library.

#### JSON References
The `JSONReference` type allows you to work with OpenAPIDocuments that store some of their information in the shared Components Object dictionary or even external files. You cannot dereference documents (yet), but you can encode and decode references.

You can create an external reference with `JSONReference.external(URL)`. Internal references usually refer to an object in the Components Object dictionary and are constructed with `JSONReference.component(named:)`. If you need to refer to something in the current file but not in the Components Object, you can use `JSONReference.internal(path:)`.

You can check whether a given `JSONReference` exists in the Components Object with `document.components.contains()`. You can access a referenced object in the Components Object with `document.components[reference]`.

You can create references from the Components Object with `document.components.reference(named:ofType:)`. This method will throw an error if the given component does not exist in the ComponentsObject.

## Notes
This library does *not* currently support file reading at all muchless following `$ref`s to other files and loading them in.

This library *is* opinionated about a few defaults when you use the Swift types, however encoding and decoding stays true to the spec. Some key things to note:

1. Within schemas, `required` is specified on the property rather than being specified on the parent object (encoding/decoding still follows the OpenAPI spec).
    * ex `JSONSchema.object(properties: [ "val": .string(required: true)])` is an "object" type with a required "string" type property.
2. Within schemas, `required` defaults to `true` on initialization (again, encoding/decoding still follows the OpenAPI spec).
    * ex. `JSONSchema.string` is a required "string" type.
    * ex. `JSONSchema.string(required: false)` is an optional "string" type.

See [**A note on dictionary ordering**](#a-note-on-dictionary-ordering) before deciding on an encoder/decoder to use with this library.

## Project Status

### OpenAPI Object (`OpenAPI.Document`)
- [x] openapi (`openAPIVersion`)
- [x] info
- [x] servers
- [x] paths
- [x] components
- [x] security
- [x] tags
- [x] externalDocs
- [ ] specification extensions

### Info Object (`OpenAPI.Document.Info`)
- [x] title
- [x] description
- [x] termsOfService
- [x] contact
- [x] license
- [x] version
- [ ] specification extensions

### Contact Object (`OpenAPI.Document.Info.Contact`)
- [x] name
- [x] url
- [x] email
- [ ] specification extensions

### License Object (`OpenAPI.Document.Info.License`)
- [x] name
- [x] url
- [ ] specification extensions

### Server Object (`OpenAPI.Server`)
- [x] url
- [x] description
- [x] variables
- [ ] specification extensions

### Server Variable Object (`OpenAPI.Server.Variable`)
- [x] enum
- [x] default
- [x] description
- [ ] specification extensions

### Components Object (`OpenAPI.Components`)
- [x] schemas
- [x] responses
- [x] parameters
- [x] examples
- [x] requestBodies
- [x] headers
- [x] securitySchemes
- [ ] links
- [ ] callbacks
- [ ] specification extensions

### Paths Object (`OpenAPI.PathItem.Map`)
- [x] *dictionary*
- ~[ ] specification extensions~ (not a planned addition)

### Path Item Object (`OpenAPI.PathItem`)
- [x] summary
- [x] description
- [x] servers
- [x] parameters
- [x] get
- [x] put
- [x] post
- [x] delete
- [x] options
- [x] head
- [x] patch
- [x] trace
- [ ] specification extensions

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
- [x] security
- [x] servers
- [ ] specification extensions

### External Document Object (`OpenAPI.ExternalDoc`)
- [x] description
- [x] url
- [ ] specification extensions

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
- [ ] specification extensions

### Request Body Object (`OpenAPI.Request`)
- [x] description
- [x] content
- [x] required
- [ ] specification extensions

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
- [ ] specification extensions

### Responses Object (`OpenAPI.Response.Map`)
- [x] *dictionary*
- ~[ ] specification extensions~ (not a planned addition)

### Response Object (`OpenAPI.Response`)
- [x] description
- [x] headers
- [x] content
- [ ] links
- [ ] specification extensions

### Callback Object
- [ ] *{expression}*
- [ ] specification extensions

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
- [ ] specification extensions

### Header Object (`OpenAPI.Header`)
- [x] description
- [x] required
- [x] deprecated
- [x] content
- [x] schema
    - [x] style
    - [x] explode
    - [x] allowReserved
    - [x] example
    - [x] examples
- [ ] specification extensions

### Tag Object (`OpenAPI.Tag`)
- [x] name
- [x] description
- [x] externalDocs
- [ ] specification extensions

### Reference Object (`JSONReference`)
- [x] $ref
    - [x] local (same file) reference (`internal` case)
        - [x] encode
        - [x] decode
        - [ ] dereference
    - [x] remote (different file) reference (`external` case)
        - [x] encode
        - [x] decode
        - [ ] dereference

### Schema Object (`JSONSchema`)
- [x] Mostly complete support for JSON Schema inherited keywords
- [x] nullable
- [ ] discriminator
- [x] readOnly (`permissions` `.readOnly` case)
- [x] writeOnly (`permissions` `.writeOnly` case)
- [ ] xml
- [x] externalDocs
- [x] example
- [x] deprecated
- [ ] specification extensions

### Discriminator Object (`OpenAPI.Discriminator`)
- [x] propertyName
- [x] mapping

### XML Object (`OpenAPI.XML`)
- [x] name
- [x] namespace
- [x] prefix
- [x] attribute
- [x] wrapped
- [ ] specification extensions

### Security Scheme Object (`OpenAPI.SecurityScheme`)
- [x] type
- [x] description
- [x] name (`SecurityType` `.apiKey` case)
- [x] in (`location` in `SecurityType` `.apiKey` case)
- [x] scheme (`SecurityType` `.http` case)
- [x] bearerFormat (`SecurityType` `.http` case)
- [x] flows (`SecurityType` `.oauth2` case)
- [x] openIdConnectUrl (`SecurityType` `.openIdConnect` case)
- [ ] specification extensions

### OAuth Flows Object (`OpenAPI.OauthFlows`)
- [x] implicit
- [x] password
- [x] clientCredentials
- [x] authorizationCode
- [ ] specification extensions

### OAuth Flow Object (`OpenAPI.OauthFlows.*`)
- `OpenAPI.OauthFlows.Implicit`
- `OpenAPI.OauthFlows.Password`
- `OpenAPI.OauthFlows.ClientCredentials`
- `OpenAPI.OauthFlows.AuthorizationCode`
- [x] authorizationUrl
- [x] tokenUrl
- [x] refreshUrl
- [x] scopes
- [ ] specification extensions

### Security Requirement Object (`OpenAPI.Document.SecurityRequirement`)
- [x] *{name}* (using `JSONReferences` instead of a stringy API)
