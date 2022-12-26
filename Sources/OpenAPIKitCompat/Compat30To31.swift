//
//  Compat30To31.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//

import OpenAPIKit
import OpenAPIKit30

private typealias OpenAPI31 = OpenAPIKit.OpenAPI
private typealias OpenAPI30 = OpenAPIKit30.OpenAPI

public extension OpenAPIKit30.OpenAPI.Document {
    func `convert`(to version: OpenAPIKit.OpenAPI.Document.Version) -> OpenAPIKit.OpenAPI.Document {
        switch version {
        case .v3_1_0:
            return self.to31()
        }
    }
}

private protocol To31 {
    associatedtype Destination
    func to31() -> Destination
}

extension OpenAPIKit30.OpenAPI.Document: To31 {
    fileprivate func to31() -> OpenAPI31.Document {
        OpenAPI31.Document(
            openAPIVersion: .v3_1_0,
            info: info.to31(),
            servers: servers.map { $0.to31() },
            paths: paths.mapValues { $0.to31() },
            components: components.to31(),
            security: security.map { $0.to31() },
            tags: tags?.map { $0.to31() },
            externalDocs: externalDocs?.to31(),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Document.Info: To31 {
    fileprivate func to31() -> OpenAPI31.Document.Info {
        OpenAPI31.Document.Info(
            title: title,
            description: description,
            termsOfService: termsOfService,
            contact: contact?.to31(),
            license: license?.to31(),
            version: version,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Document.Info.License: To31 {
    fileprivate func to31() -> OpenAPI31.Document.Info.License {
        OpenAPI31.Document.Info.License(
            name: name,
            url: url,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Document.Info.Contact: To31 {
    fileprivate func to31() -> OpenAPI31.Document.Info.Contact {
        OpenAPI31.Document.Info.Contact(
            name: name,
            url: url,
            email: email,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Server: To31 {
    fileprivate func to31() -> OpenAPI31.Server {

        let newVariables = variables.mapValues { variable in
            OpenAPI31.Server.Variable(
                enum: variable.enum,
                default: variable.default,
                description: variable.description,
                vendorExtensions: variable.vendorExtensions
            )
        }

        return OpenAPI31.Server(
            urlTemplate: urlTemplate,
            description: description,
            variables: newVariables,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Header: To31 {
    fileprivate func to31() -> OpenAPI31.Header {
        let newSchemaOrContent: Either<OpenAPI31.Parameter.SchemaContext, OpenAPI31.Content.Map>
        switch schemaOrContent {
        case .a(let context):
            newSchemaOrContent = .a(context.to31())
        case .b(let contentMap):
            newSchemaOrContent = .b(contentMap.mapValues { $0.to31() })
        }

        return OpenAPI31.Header(
            schemaOrContent: newSchemaOrContent,
            description: description,
            required: `required`,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Parameter.Context: To31 {
    fileprivate func to31() -> OpenAPI31.Parameter.Context {
        switch self {
        case .query(required: let required, allowEmptyValue: let allowEmptyValue):
            return .query(required: required, allowEmptyValue: allowEmptyValue)
        case .header(required: let required):
            return .header(required: required)
        case .path:
            return .path
        case .cookie(required: let required):
            return .cookie(required: required)
        }
    }
}

extension OpenAPIKit30.OpenAPI.Example: To31 {
    fileprivate func to31() -> OpenAPI31.Example {
        OpenAPI31.Example(
            summary: summary,
            description: description,
            value: value,
            vendorExtensions: vendorExtensions
        )
    }
}

extension Either: To31 where A: To31, B: To31 {
    fileprivate func to31() -> Either<A.Destination, B.Destination> {
        switch self {
        case .a(let a):
            return .a(a.to31())
        case .b(let b):
            return .b(b.to31())
        }
    }
}

fileprivate func eitherRefTo31<T, U>(_ either: Either<OpenAPIKit30.JSONReference<T>, T>) -> Either<OpenAPI31.Reference<U>, U> where T: To31, T.Destination == U {
    switch either {
        case .a(let a):
            return .a(.init(a.to31()))
        case .b(let b):
            return .b(b.to31())
    }
}

extension OpenAPIKit30.OpenAPI.Parameter.SchemaContext: To31 {
    fileprivate func to31() -> OpenAPI31.Parameter.SchemaContext {
        let newExamples = examples?.mapValues(eitherRefTo31)
        switch schema {
        case .a(let ref):
            if let newExamples = newExamples {
                return OpenAPI31.Parameter.SchemaContext(
                    schemaReference: .init(ref.to31()),
                    style: style,
                    allowReserved: allowReserved,
                    examples: newExamples
                )
            } else {
                return OpenAPI31.Parameter.SchemaContext(
                    schemaReference: .init(ref.to31()),
                    style: style,
                    allowReserved: allowReserved,
                    example: example
                )
            }
        case .b(let schema):
            if let newExamples = newExamples {
                return OpenAPI31.Parameter.SchemaContext(
                    schema.to31(),
                    style: style,
                    allowReserved: allowReserved,
                    examples: newExamples
                )
            } else {
                return OpenAPI31.Parameter.SchemaContext(
                    schema.to31(),
                    style: style,
                    allowReserved: allowReserved,
                    example: example
                )
            }
        }
    }
}

extension OpenAPIKit30.OpenAPI.Content.Encoding: To31 {
    fileprivate func to31() -> OpenAPI31.Content.Encoding {
        OpenAPI31.Content.Encoding(
            contentType: contentType,
            headers: headers?.mapValues(eitherRefTo31),
            style: style,
            explode: explode,
            allowReserved: allowReserved
        )
    }
}

extension OpenAPIKit30.OpenAPI.Content: To31 {
    fileprivate func to31() -> OpenAPI31.Content {
        if let newExamples = examples?.mapValues(eitherRefTo31) {
            return OpenAPI31.Content(
                schema: schema.map(eitherRefTo31),
                examples: newExamples,
                encoding: encoding?.mapValues { $0.to31() },
                vendorExtensions: vendorExtensions
            )
        } else {
            return OpenAPI31.Content(
                schema: schema.map(eitherRefTo31),
                example: example,
                encoding: encoding?.mapValues { $0.to31() },
                vendorExtensions: vendorExtensions
            )
        }
    }
}

extension OpenAPIKit30.OpenAPI.Parameter: To31 {
    fileprivate func to31() -> OpenAPI31.Parameter {
        let newSchemaOrContent: Either<OpenAPI31.Parameter.SchemaContext, OpenAPI31.Content.Map>
        switch schemaOrContent {
        case .a(let context):
            newSchemaOrContent = .a(context.to31())
        case .b(let contentMap):
            newSchemaOrContent = .b(contentMap.mapValues { $0.to31() })
        }

        return OpenAPI31.Parameter(
            name: name,
            context: context.to31(),
            schemaOrContent: newSchemaOrContent,
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.RuntimeExpression.Source: To31 {
    fileprivate func to31() -> OpenAPI31.RuntimeExpression.Source {
        switch self {
        case .header(name: let name):
            return .header(name: name)
        case .query(name: let name):
            return .query(name: name)
        case .path(name: let name):
            return .path(name: name)
        case .body(let ref):
            return .body(ref?.to31())
        }
    }
}

extension OpenAPIKit30.OpenAPI.RuntimeExpression: To31 {
    fileprivate func to31() -> OpenAPI31.RuntimeExpression {
        switch self {
        case .url:
            return .url
        case .method:
            return .method
        case .statusCode:
            return .statusCode
        case .request(let source):
            return .request(source.to31())
        case .response(let source):
            return .response(source.to31())
        }
    }
}

extension OpenAPIKit30.OpenAPI.Link: To31 {
    fileprivate func to31() -> OpenAPI31.Link {
        OpenAPI31.Link(
            operation: operation,
            parameters: parameters.mapValues { parameter in parameter.mapFirst { $0.to31() }},
            requestBody: requestBody?.mapFirst { $0.to31() },
            description: description,
            server: server?.to31(),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Response: To31 {
    fileprivate func to31() -> OpenAPI31.Response {
        OpenAPI31.Response(
            description: description,
            headers: headers?.mapValues(eitherRefTo31),
            content: content.mapValues { $0.to31() },
            links: links.mapValues(eitherRefTo31),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Request: To31 {
    fileprivate func to31() -> OpenAPI31.Request {
        OpenAPI31.Request(
            description: description,
            content: content.mapValues { $0.to31() },
            required: `required`,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Callbacks: To31 {
    fileprivate func to31() -> OpenAPI31.Callbacks {
        self.mapValues { (pathItem: OpenAPI30.PathItem) in
            .b(pathItem.to31())
        }
    }
}

extension OpenAPIKit30.OpenAPI.Operation: To31 {
    fileprivate func to31() -> OpenAPI31.Operation {
        if let newRequestBody = requestBody {
            return OpenAPI31.Operation(
                tags: tags,
                summary: summary,
                description: description,
                externalDocs: externalDocs?.to31(),
                operationId: operationId,
                parameters: parameters.map(eitherRefTo31),
                requestBody: eitherRefTo31(newRequestBody),
                responses: responses.mapValues(eitherRefTo31),
                callbacks: callbacks.mapValues(eitherRefTo31),
                deprecated: deprecated,
                security: security?.map { $0.to31() },
                servers: servers?.map { $0.to31() },
                vendorExtensions: vendorExtensions
            )
        } else {
            return OpenAPI31.Operation(
                tags: tags,
                summary: summary,
                description: description,
                externalDocs: externalDocs?.to31(),
                operationId: operationId,
                parameters: parameters.map(eitherRefTo31),
                responses: responses.mapValues(eitherRefTo31),
                callbacks: callbacks.mapValues(eitherRefTo31),
                deprecated: deprecated,
                security: security?.map { $0.to31() },
                servers: servers?.map { $0.to31() },
                vendorExtensions: vendorExtensions
            )
        }
    }
}

extension OpenAPIKit30.OpenAPI.PathItem: To31 {
    fileprivate func to31() -> OpenAPI31.PathItem {
        OpenAPI31.PathItem(
            summary: summary,
            description: description,
            servers: servers?.map { $0.to31() },
            parameters: parameters.map(eitherRefTo31),
            get: `get`?.to31(),
            put: put?.to31(),
            post: post?.to31(),
            delete: delete?.to31(),
            options: options?.to31(),
            head: head?.to31(),
            patch: patch?.to31(),
            trace: trace?.to31(),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.SecurityRequirement: To31 {
    fileprivate func to31() -> OpenAPI31.SecurityRequirement {
        var result = [OpenAPIKit.JSONReference<OpenAPI31.SecurityScheme>: [String]]()
        for (key, value) in self {
            result[key.to31()] = value
        }
        return result
    }
}

private extension OpenAPIKit30.JSONReference.InternalReference {
    func to31<T>() -> OpenAPIKit.JSONReference<T>.InternalReference {
        switch self {
        case .component(name: let name):
            return .component(name: name)
        case .path(let path):
            return .path(.init(rawValue: path.rawValue))
        }
    }
}

private extension OpenAPIKit30.JSONReference {
    func to31<T>() -> OpenAPIKit.JSONReference<T> {
        switch self {
        case .internal(let ref):
            return .internal(ref.to31())
        case .external(let url):
            return OpenAPIKit.JSONReference.external(url)
        }
    }
}

extension OpenAPIKit30.OpenAPI.Tag: To31 {
    fileprivate func to31() -> OpenAPI31.Tag {
        OpenAPI31.Tag(
            name: name,
            description: description,
            externalDocs: externalDocs?.to31(),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.ExternalDocumentation: To31 {
    fileprivate func to31() -> OpenAPI31.ExternalDocumentation {
        OpenAPI31.ExternalDocumentation(
            description: description,
            url: url,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.SecurityScheme.SecurityType: To31 {
    fileprivate func to31() -> OpenAPI31.SecurityScheme.SecurityType {
        switch self {
        case .apiKey(name: let name, location: let location):
            return .apiKey(name: name, location: location)
        case .http(scheme: let scheme, bearerFormat: let bearerFormat):
            return .http(scheme: scheme, bearerFormat: bearerFormat)
        case .oauth2(flows: let flows):
            return .oauth2(flows: flows)
        case .openIdConnect(openIdConnectUrl: let openIdConnectUrl):
            return .openIdConnect(openIdConnectUrl: openIdConnectUrl)
        }
    }
}

extension OpenAPIKit30.OpenAPI.SecurityScheme: To31 {
    fileprivate func to31() -> OpenAPI31.SecurityScheme {
        OpenAPI31.SecurityScheme(
            type: type.to31(),
            description: description,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.JSONTypeFormat: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONTypeFormat {
        switch self {
        case .boolean(let f):
            return .boolean(f)
        case .object(let f):
            return .object(f)
        case .array(let f):
            return .array(f)
        case .number(let f):
            return .number(f)
        case .integer(let f):
            return .integer(f)
        case .string(let f):
            return .string(f)
        }
    }
}

extension OpenAPIKit30.JSONSchema.CoreContext: To31 where Format: OpenAPIKit.OpenAPIFormat {
    fileprivate func to31() -> OpenAPIKit.JSONSchema.CoreContext<Format> {
        OpenAPIKit.JSONSchema.CoreContext<Format>(
            format: format,
            required: `required`,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs?.to31(),
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: [example].compactMap { $0 }
        )
    }
}

extension OpenAPIKit30.JSONSchema.NumericContext: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema.NumericContext {
        OpenAPIKit.JSONSchema.NumericContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.value, $0.exclusive) },
            minimum: minimum.map { ($0.value, $0.exclusive) }
        )
    }
}

extension OpenAPIKit30.JSONSchema.IntegerContext: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema.IntegerContext {
        OpenAPIKit.JSONSchema.IntegerContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.value, $0.exclusive) },
            minimum: minimum.map { ($0.value, $0.exclusive) }
        )
    }
}

extension OpenAPIKit30.JSONSchema.ArrayContext: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema.ArrayContext {
        OpenAPIKit.JSONSchema.ArrayContext(
            items: items.map { $0.to31() },
            maxItems: maxItems,
            minItems: minItems,
            uniqueItems: uniqueItems
        )
    }
}

extension OpenAPIKit30.JSONSchema.ObjectContext: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema.ObjectContext {
        OpenAPIKit.JSONSchema.ObjectContext(
            properties: properties.mapValues { $0.to31() },
            additionalProperties: additionalProperties?.mapSecond { $0.to31() },
            maxProperties: maxProperties,
            minProperties: minProperties
        )
    }
}

extension OpenAPIKit30.JSONSchema: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema {
        let schema: OpenAPIKit.JSONSchema.Schema

        switch value {
        case .boolean(let core):
            schema = .boolean(core.to31())
        case .number(let core, let numeric):
            schema = .number(core.to31(), numeric.to31())
        case .integer(let core, let integral):
            schema = .integer(core.to31(), integral.to31())
        case .string(let core, let stringy):
            schema = .string(core.to31(), stringy)
        case .object(let core, let objective):
            schema = .object(core.to31(), objective.to31())
        case .array(let core, let listy):
            schema = .array(core.to31(), listy.to31())
        case .all(of: let of, core: let core):
            schema = .all(of: of.map { $0.to31() }, core: core.to31())
        case .one(of: let of, core: let core):
            schema = .one(of: of.map { $0.to31() }, core: core.to31())
        case .any(of: let of, core: let core):
            schema = .any(of: of.map { $0.to31() }, core: core.to31())
        case .not(let not, core: let core):
            schema = .not(not.to31(), core: core.to31())
        case .reference(let ref, let context):
            schema = .reference(ref.to31(), context)
        case .fragment(let core):
            schema = .fragment(core.to31())
        }

        return OpenAPIKit.JSONSchema(
            schema: schema
        )
    }
}

extension OpenAPIKit30.OpenAPI.Components: To31 {
    fileprivate func to31() -> OpenAPI31.Components {
        OpenAPI31.Components(
            schemas: schemas.mapValues { $0.to31() },
            responses: responses.mapValues { $0.to31() },
            parameters: parameters.mapValues { $0.to31() },
            examples: examples.mapValues { $0.to31() },
            requestBodies: requestBodies.mapValues { $0.to31() },
            headers: headers.mapValues { $0.to31() },
            securitySchemes: securitySchemes.mapValues { $0.to31() },
            links: links.mapValues { $0.to31() },
            callbacks: callbacks.mapValues { $0.to31() },
            vendorExtensions: vendorExtensions
        )
    }
}
