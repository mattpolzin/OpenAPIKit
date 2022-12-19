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
        let info = OpenAPI31.Document.Info(
            title: info.title, version: info.version
        )

        let servers = servers.map { $0.to31() }

        let paths = paths.mapValues { $0.to31() }

        let security = security.map { $0.to31() }

        let tags = tags?.map { $0.to31() }

        return OpenAPI31.Document(
            openAPIVersion: .v3_1_0,
            info: info,
            servers: servers,
            paths: paths,
            components: components.to31(),
            security: security,
            tags: tags,
            externalDocs: externalDocs?.to31(),
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.Server: To31 {
    fileprivate func to31() -> OpenAPI31.Server {

        let variables = variables.mapValues { variable in
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
            variables: variables,
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
        let examples = examples?.mapValues(eitherRefTo31)
        switch schema {
        case .a(let ref):
            if let examples {
                return OpenAPI31.Parameter.SchemaContext(
                    schemaReference: .init(ref.to31()),
                    style: style,
                    allowReserved: allowReserved,
                    examples: examples
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
            if let examples {
                return OpenAPI31.Parameter.SchemaContext(
                    schema.to31(),
                    style: style,
                    allowReserved: allowReserved,
                    examples: examples
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
        let examples = examples?.mapValues(eitherRefTo31)
        if let examples {
            return OpenAPI31.Content(
                schema: schema.map(eitherRefTo31),
                examples: examples,
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

extension OpenAPIKit30.OpenAPI.RuntimeExpression: To31 {
    fileprivate func to31() -> OpenAPI31.Run {
        
    }
}

extension OpenAPIKit30.OpenAPI.Link: To31 {
    fileprivate func to31() -> OpenAPI31.Link {
        return OpenAPI31.Link(
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

extension OpenAPIKit30.OpenAPI.Operation: To31 {
    fileprivate func to31() -> OpenAPI31.Operation {
        // TODO: finish filling out constructor with all optional arguments.
        OpenAPI31.Operation(
            tags: tags,
            summary: summary,
            description: description,
            externalDocs: externalDocs?.to31(),
            operationId: operationId,
            parameters: parameters.map(eitherRefTo31),
//            requestBody: eitherRefTo31(requestBody),
            responses: responses.mapValues(eitherRefTo31),
//            callbacks: callbacks.mapValues(eitherRefTo31),
            deprecated: deprecated,
//            security: ,
            servers: servers?.map { $0.to31() },
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPIKit30.OpenAPI.PathItem: To31 {
    fileprivate func to31() -> OpenAPI31.PathItem {
        let servers = servers?.map { $0.to31() }

        let parameters = parameters.map(eitherRefTo31)

        return OpenAPI31.PathItem(
            summary: summary,
            description: description,
            servers: servers,
            parameters: parameters,
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

private extension OpenAPIKit30.JSONReference {
    func to31<T>() -> OpenAPIKit.JSONReference<T> {
        switch self {
        case .internal(let ref):
            switch ref {
            case .component(name: let name):
                return .internal(.component(name: name))
            case .path(let path):
                return .internal(.path(.init(rawValue: path.rawValue)))
            }
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

extension OpenAPIKit30.JSONSchema: To31 {
    fileprivate func to31() -> OpenAPIKit.JSONSchema {
//        let schema: OpenAPIKit.JSONSchema.Schema

//        switch value {
//        case .boolean(let core):
//            schema = .boolean(
//                .init(
//                    format: core.format,
//                    required: core.required,
//                    nullable: core.nullable,
//                    permissions: core.permissions,
//                    deprecated: core.deprecated,
//                    title: core.title,
//                    description: core.description,
//                    discriminator: core.discriminator,
//                    externalDocs: <#T##OpenAPI.ExternalDocumentation?#>
//                )
//            )
//        case .number(_, _):
//            <#code#>
//        case .integer(_, _):
//            <#code#>
//        case .string(_, _):
//            <#code#>
//        case .object(_, _):
//            <#code#>
//        case .array(_, _):
//            <#code#>
//        case .all(of: let of, core: let core):
//            <#code#>
//        case .one(of: let of, core: let core):
//            <#code#>
//        case .any(of: let of, core: let core):
//            <#code#>
//        case .not(_, core: let core):
//            <#code#>
//        case .reference(_, _):
//            <#code#>
//        case .fragment(_):
//            <#code#>
//        }

        // TODO: finish filling out constructor, replacing the null schema.
        OpenAPIKit.JSONSchema(
            schema: .null // schema
        )
    }
}

extension OpenAPIKit30.OpenAPI.Components: To31 {
    fileprivate func to31() -> OpenAPI31.Components {
        // TODO: finish filling out constructor with all optional arguments.
        OpenAPI31.Components(
            schemas: schemas.mapValues { $0.to31() },
//            responses: responses.mapValues { $0.to31() },
            parameters: parameters.mapValues { $0.to31() },
            examples: examples.mapValues { $0.to31() },
//            requestBodies: requestBodies.mapValues { $0.to31() },
            headers: headers.mapValues { $0.to31() },
            securitySchemes: securitySchemes.mapValues { $0.to31() },
//            links: links.mapValues { $0.to31() },
//            callbacks: callbacks.mapValues { $0.to31() },
            vendorExtensions: vendorExtensions
        )
    }
}
