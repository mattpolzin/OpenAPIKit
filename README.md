[![Build Status](https://app.bitrise.io/app/2f7379e33723d853/status.svg?token=Jx4X3su3oE59z_rJBRC_og&branch=master)](https://app.bitrise.io/app/2f7379e33723d853)

# OpenAPI

A library that encodes to and decodes from [OpenAPI](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.2.md) Documents.

This library *is* opinionated about a few defaults when you use the Swift types, however encoding and decoding stays true to the spec. Some key things to note:

1. Within schemas, `required` is specified on the property rather than being specified on the parent object (encoding/decoding still follows the OpenAPI spec).
    * ex `JSONSchemaObject.object(properties: [ "val": .string(required: true)])` is an "object" type with a required "string" type property.
2. Within schemas, `required` defaults to `true` on initialization (again, encoding/decoding still follows the OpenAPI spec).
    * ex. `JSONSchemaObject.string` is a required "string" type.
    * ex. `JSONSchemaObject.string(required: false)` is an optional "string" type.
