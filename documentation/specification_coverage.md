
## Specification Coverage <!-- omit in toc -->
The list below is organized like the [OpenAPI Specification 3.1.x](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md) reference. Types that have OpenAPIKit representations are checked off. Types that have different names in OpenAPIKit than they do in the specification have their OpenAPIKit names in parenthesis.

For more information on the OpenAPIKit types, see the [full type documentation](https://github.com/mattpolzin/OpenAPIKit/wiki).

### Table of Contents <!-- omit in toc -->
- [OpenAPI Object (`OpenAPI.Document`)](#openapi-object-openapidocument)
- [Info Object (`OpenAPI.Document.Info`)](#info-object-openapidocumentinfo)
- [Contact Object (`OpenAPI.Document.Info.Contact`)](#contact-object-openapidocumentinfocontact)
- [License Object (`OpenAPI.Document.Info.License`)](#license-object-openapidocumentinfolicense)
- [Server Object (`OpenAPI.Server`)](#server-object-openapiserver)
- [Server Variable Object (`OpenAPI.Server.Variable`)](#server-variable-object-openapiservervariable)
- [Components Object (`OpenAPI.Components`)](#components-object-openapicomponents)
- [Paths Object (`OpenAPI.PathItem.Map`)](#paths-object-openapipathitemmap)
- [Path Item Object (`OpenAPI.PathItem`)](#path-item-object-openapipathitem)
- [Operation Object (`OpenAPI.Operation`)](#operation-object-openapioperation)
- [External Document Object (`OpenAPI.ExternalDocumentation`)](#external-document-object-openapiexternaldocumentation)
- [Parameter Object (`OpenAPI.Parameter`)](#parameter-object-openapiparameter)
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
- [Reference Object (`OpenAPI.Reference`)](#reference-object-openapireference)
- [Schema Object (`JSONSchema`)](#schema-object-jsonschema)
- [Discriminator Object (`OpenAPI.Discriminator`)](#discriminator-object-openapidiscriminator)
- [XML Object (`OpenAPI.XML`)](#xml-object-openapixml)
- [Security Scheme Object (`OpenAPI.SecurityScheme`)](#security-scheme-object-openapisecurityscheme)
- [OAuth Flows Object (`OpenAPI.OauthFlows`)](#oauth-flows-object-openapioauthflows)
- [OAuth Flow Object (`OpenAPI.OauthFlows.*`)](#oauth-flow-object-openapioauthflows)
- [Security Requirement Object (`OpenAPI.Document.SecurityRequirement`)](#security-requirement-object-openapidocumentsecurityrequirement)

### OpenAPI Object (`OpenAPI.Document`)
- [x] openapi (`openAPIVersion`)
- [x] info
- [ ] jsonSchemaDialect
- [x] servers
- [x] paths
- [x] webhooks
- [x] components
- [x] security
- [x] tags
- [x] externalDocs
- [x] specification extensions (`vendorExtensions`)

### Info Object (`OpenAPI.Document.Info`)
- [x] title
- [x] summary
- [x] description
- [x] termsOfService
- [x] contact
- [x] license
- [x] version
- [x] specification extensions (`vendorExtensions`)

### Contact Object (`OpenAPI.Document.Info.Contact`)
- [x] name
- [x] url
- [x] email
- [x] specification extensions (`vendorExtensions`)

### License Object (`OpenAPI.Document.Info.License`)
- [x] name
- [x] identifier (`Identifier` `spdx` case)
- [x] url (`Identifier` `url` case)
- [x] specification extensions (`vendorExtensions`)

### Server Object (`OpenAPI.Server`)
- [x] url
- [x] description
- [x] variables
- [x] specification extensions (`vendorExtensions`)

### Server Variable Object (`OpenAPI.Server.Variable`)
- [x] enum
- [x] default
- [x] description
- [x] specification extensions (`vendorExtensions`)

### Components Object (`OpenAPI.Components`)
- [x] schemas
- [x] responses
- [x] parameters
- [x] examples
- [x] requestBodies
- [x] headers
- [x] securitySchemes
- [x] links
- [x] callbacks
- [x] pathItems
- [x] specification extensions (`vendorExtensions`)

### Paths Object (`OpenAPI.PathItem.Map`)
- [x] *dictionary*
- ~[ ] specification extensions~ (not a planned addition)

### Path Item Object (`OpenAPI.PathItem`)
- [x] $ref
- [x] summary
- [x] description
- [x] get
- [x] put
- [x] post
- [x] delete
- [x] options
- [x] head
- [x] patch
- [x] trace
- [x] servers
- [x] parameters
- [x] specification extensions (`vendorExtensions`)

### Operation Object (`OpenAPI.Operation`)
- [x] tags
- [x] summary
- [x] description
- [x] externalDocs
- [x] operationId
- [x] parameters
- [x] requestBody
- [x] responses
- [x] callbacks
- [x] deprecated
- [x] security
- [x] servers
- [x] specification extensions (`vendorExtensions`)

### External Document Object (`OpenAPI.ExternalDocumentation`)
- [x] description
- [x] url
- [x] specification extensions (`vendorExtensions`)

### Parameter Object (`OpenAPI.Parameter`)
- [x] name
- [x] in (`context`)
- [x] description
- [x] required (part of `context`)
- [x] deprecated
- [x] allowEmptyValue (part of `context`)
- [x] schema (`schemaOrContent`)
    - [x] style
    - [x] explode
    - [x] allowReserved
    - [x] example
    - [x] examples
- [x] content (`schemaOrContent`)
- [x] specification extensions (`vendorExtensions`)

### Request Body Object (`OpenAPI.Request`)
- [x] description
- [x] content
- [x] required
- [x] specification extensions (`vendorExtensions`)

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
- [x] default (`Response.StatusCode.Code` `.default` case)
- [x] *dictionary*
- ~[ ] specification extensions~ (not a planned addition)

### Response Object (`OpenAPI.Response`)
- [x] description
- [x] headers
- [x] content
- [x] links
- [x] specification extensions (`vendorExtensions`)

### Callback Object
- [x] *{expression}*
- [ ] specification extensions

### Example Object (`OpenAPI.Example`)
- [x] summary
- [x] description
- [x] value
- [x] externalValue (part of `value`)
- [x] specification extensions (`vendorExtensions`)

### Link Object
- [x] operationRef (`operation` URL value)
- [x] operationId (`operation` String value)
- [x] parameters
- [x] requestBody
- [x] description
- [x] server
- [x] specification extensions (`vendorExtensions`)

### Header Object (`OpenAPI.Header`)
- [x] description
- [x] required
- [x] deprecated
- [x] schema (`schemaOrContent`)
    - [x] style
    - [x] explode
    - [x] allowReserved
    - [x] example
    - [x] examples
- [x] content (`schemaOrContent`)
- [x] specification extensions (`vendorExtensions`)

### Tag Object (`OpenAPI.Tag`)
- [x] name
- [x] description
- [x] externalDocs
- [x] specification extensions (`vendorExtensions`)

### Reference Object (`OpenAPI.Reference`)
- [x] summary
- [x] description
- [x] $ref
    - [x] local (same file) reference (`internal` case)
        - [x] encode
        - [x] decode
        - [x] dereference
    - [x] remote (different file) reference (`external` case)
        - [x] encode
        - [x] decode
        - [ ] dereference

### Schema Object (`JSONSchema`)
- [x] Mostly complete support for JSON Schema inherited keywords (select ones enumerated below)
- [x] discriminator
- [x] readOnly (`permissions` `.readOnly` case)
- [x] writeOnly (`permissions` `.writeOnly` case)
- [ ] xml
- [x] externalDocs
- [x] example
- [x] deprecated
- [x] specification extensions (`vendorExtensions`)

### Discriminator Object (`OpenAPI.Discriminator`)
- [x] propertyName
- [x] mapping
- [ ] specification extensions

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
- [x] specification extensions (`vendorExtensions`)

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
