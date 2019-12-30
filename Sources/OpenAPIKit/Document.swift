//
//  Document.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/13/19.
//

import AnyCodable
import Foundation
import Poly
import Sampleable

extension OpenAPI {
    /// The root of an OpenAPI 3.0 document.
    public struct Document {
        public let openAPIVersion: Version
        public let info: Info
        public let servers: [Server]
        public let paths: PathItem.Map
        public let components: OpenAPI.Components
        //    public let security:
        public let tags: [Tag]?
        public let externalDocs: ExternalDoc?

        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    servers: [Server],
                    paths: PathItem.Map,
                    components: OpenAPI.Components,
                    tags: [Tag]? = nil,
                    externalDocs: ExternalDoc? = nil) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.components = components
            self.tags = tags
            self.externalDocs = externalDocs
        }

        // variadic servers
        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    servers: Server...,
                    paths: PathItem.Map,
                    components: OpenAPI.Components,
                    tags: [Tag]? = nil,
                    externalDocs: ExternalDoc? = nil) {
            self.init(
                openAPIVersion: openAPIVersion,
                info: info,
                servers: servers,
                paths: paths,
                components: components,
                tags: tags,
                externalDocs: externalDocs
            )
        }
    }
}

extension OpenAPI.Document {
    public enum Version: String, Codable {
        case v3_0_0 = "3.0.0"
        case v3_0_1 = "3.0.1"
        case v3_0_2 = "3.0.2"
    }
}

// MARK: - Codable

extension OpenAPI.Document {
    private enum CodingKeys: String, CodingKey {
        case openAPIVersion = "openapi"
        case info
        case servers
        case paths
        case components
        case security
        case tags
        case externalDocs
    }
}

extension OpenAPI.Document: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(openAPIVersion, forKey: .openAPIVersion)

        try container.encode(info, forKey: .info)

        if servers.count > 0 {
            try container.encode(servers, forKey: .servers)
        }

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            paths.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .paths)

        try container.encode(components, forKey: .components)

        if let encodableTags = tags {
            try container.encode(encodableTags, forKey: .tags)
        }

        try externalDocs.encodeIfNotNil(to: &container, forKey: .externalDocs)
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)

        info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)

        servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers) ?? []

        // hacky workaround for Dictionary bug
        let pathsDict = try container.decode([String: Either<JSONReference<OpenAPI.Components, OpenAPI.PathItem>, OpenAPI.PathItem>].self, forKey: .paths)
        paths = Dictionary(pathsDict.map { args in
            let (pathString, pathItem) = args

            return (OpenAPI.PathComponents(rawValue: pathString), pathItem)
        },
                           uniquingKeysWith: { $1 })

        components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents

        tags = try container.decodeIfPresent([OpenAPI.Tag].self, forKey: .tags)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)
    }
}
