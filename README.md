[![MIT license](http://img.shields.io/badge/license-MIT-lightgrey.svg)](http://opensource.org/licenses/MIT) [![Swift 5.0](http://img.shields.io/badge/Swift-5.0-blue.svg)](https://swift.org) [![Build Status](https://app.bitrise.io/app/2f7379e33723d853/status.svg?token=Jx4X3su3oE59z_rJBRC_og&branch=master)](https://app.bitrise.io/app/2f7379e33723d853)

# OpenAPIKit

A library containing Swift types that encode to- and decode from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md) Documents and their components.

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
- [ ] tags
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
- [ ] variables

### Server Variable Object
- [ ] enum
- [ ] default
- [ ] description

### Components Object (`OpenAPI.Components`)
- [x] schemas
- [ ] responses
- [x] parameters
- [ ] examples
- [ ] requestBodies
- [ ] headers
- [ ] securitySchemes
- [ ] links
- [ ] callbacks

### Paths Object (`OpenAPI.PathItem.Map`)
- [x] *dictionary*

### Path Item Object (`OpenAPI.PathItem`)
- [x] $ref (`reference` case)
- [x] summary (`operations` case)
- [x] description (`operations` case)
- [x] get (`operations` case)
- [x] put (`operations` case)
- [x] post (`operations` case)
- [x] delete (`operations` case)
- [x] options (`operations` case)
- [x] head (`operations` case)
- [x] patch (`operations` case)
- [x] trace (`operations` case)
- [x] servers (`operations` case)
- [x] parameters (`operations` case)

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
    - [ ] style
    - [ ] explode
    - [ ] allowReserved
    - [ ] example
    - [ ] examples

#### Style Values
- [ ] matrix
- [ ] label
- [ ] form
- [ ] simple
- [ ] spaceDelimited
- [ ] pipeDelimited
- [ ] deepObject

### Request Body Object (`OpenAPI.Request`)
- [x] description
- [x] content
- [x] required

### Media Type Object (`OpenAPI.Content`)
- [x] schema
- [ ] example
- [ ] examples
- [ ] encoding

### Encoding Object
- [ ] contentType
- [ ] headers
- [ ] style
- [ ] explode
- [ ] allowReserved

### Responses Object (`OpenAPI.Response.Map`)
- [x] *dictionary*

### Response Object (`OpenAPI.Response`)
- [x] description
- [ ] headers
- [x] content
- [ ] links

### Callback Object
- [ ] *{expression}*

### Example Object
- [ ] summary
- [ ] description
- [ ] value
- [ ] externalValue

### Link Object
- [ ] operationRef
- [ ] operationId
- [ ] parameters
- [ ] requestBody
- [ ] description
- [ ] server

### Header Object
- [ ] description
- [ ] required
- [ ] deprecated
- [ ] allowEmptyValue
- [ ] content
- [ ] schema
    - [ ] style
    - [ ] explode
    - [ ] allowReserved
    - [ ] example
    - [ ] examples

### Tag Object
- [ ] name
- [ ] description
- [ ] externalDocs

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
- [ ] externalDocs
- [x] example
- [ ] deprecated

### Discriminator Object
- [ ] propertyName
- [ ] mapping

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
