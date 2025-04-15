//
//  OpenAPI.swift
//
//
//  Created by Mathew Polzin on 6/22/19.
//

/// The OpenAPI namespace
public enum OpenAPI {}
extension OpenAPI {
    public struct Document: Equatable {
        public var openAPIVersion: Version
        public var info: Info
        public var servers: [Server]?
        public var paths: PathItem.Map
        public var webhooks: OrderedDictionary<String, Either<JSONReference<PathItem>, PathItem>>?
        public var components: Components?
        public var security: [SecurityRequirement]?
        public var tags: [Tag]?
        public var externalDocs: ExternalDocumentation?
        public var jsonSchemaDialect: URL?

        public init(
            openAPIVersion: Version = .v3_1_0,
            info: Info,
            servers: [Server]? = nil,
            paths: PathItem.Map,
            webhooks: OrderedDictionary<String, Either<JSONReference<PathItem>, PathItem>>? = nil,
            components: Components? = nil,
            security: [SecurityRequirement]? = nil,
            tags: [Tag]? = nil,
            externalDocs: ExternalDocumentation? = nil,
            jsonSchemaDialect: URL? = nil
        ) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.webhooks = webhooks
            self.components = components
            self.security = security
            self.tags = tags
            self.externalDocs = externalDocs
            self.jsonSchemaDialect = jsonSchemaDialect
        }

        private enum CodingKeys: String, CodingKey {
            case openAPIVersion = "openapi"
            case info
            case servers
            case paths
            case webhooks
            case components
            case security
            case tags
            case externalDocs
            case jsonSchemaDialect = "$schema"
        }
    }
}
