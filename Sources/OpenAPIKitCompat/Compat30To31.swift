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

private extension OpenAPIKit30.OpenAPI.Document {
    func to31() -> OpenAPI31.Document {
        let info = OpenAPI31.Document.Info(
            title: info.title, version: info.version
        )

        let servers = servers.map { $0.to31() }

        let paths = paths.mapValues { $0.to31() }

        return OpenAPI31.Document(
            info: info,
            servers: servers,
            paths: paths,
            components: components.to31()
        )
    }
}

private extension OpenAPIKit30.OpenAPI.Server {
    func to31() -> OpenAPI31.Server {

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

private extension OpenAPIKit30.OpenAPI.PathItem {
    func to31() -> OpenAPI31.PathItem {
        OpenAPI31.PathItem(
            summary: <#T##String?#>
        )
    }
}

private extension OpenAPIKit30.OpenAPI.SecurityScheme {
    func to31() -> OpenAPI31.SecurityScheme {
        OpenAPI31.SecurityScheme(
            type: <#T##OpenAPI.SecurityScheme.SecurityType#>
        )
    }
}

private extension OpenAPIKit30.JSONSchema {
    func to31() -> OpenAPIKit.JSONSchema {
        let schema: OpenAPIKit.JSONSchema.Schema

        switch value {
        case .boolean(let core):
            schema = .boolean(
                .init(
                    format: core.format,
                    required: core.required,
                    nullable: core.nullable,
                    permissions: core.permissions,
                    deprecated: core.deprecated,
                    title: core.title,
                    description: core.description,
                    discriminator: core.discriminator,
                    externalDocs: <#T##OpenAPI.ExternalDocumentation?#>
                )
            )
        case .number(_, _):
            <#code#>
        case .integer(_, _):
            <#code#>
        case .string(_, _):
            <#code#>
        case .object(_, _):
            <#code#>
        case .array(_, _):
            <#code#>
        case .all(of: let of, core: let core):
            <#code#>
        case .one(of: let of, core: let core):
            <#code#>
        case .any(of: let of, core: let core):
            <#code#>
        case .not(_, core: let core):
            <#code#>
        case .reference(_, _):
            <#code#>
        case .fragment(_):
            <#code#>
        }

        OpenAPIKit.JSONSchema(
            schema: schema
        )
    }
}

private extension OpenAPIKit30.OpenAPI.Components {
    func to31() -> OpenAPI31.Components {
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
            vendorExtensions: vendorExtensions.mapValues { $0.to31() }
        )
    }
}
