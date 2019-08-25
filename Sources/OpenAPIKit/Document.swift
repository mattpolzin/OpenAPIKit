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
        //    public let tags:
        public let externalDocs: ExternalDoc?

        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    servers: [Server],
                    paths: PathItem.Map,
                    components: OpenAPI.Components,
                    externalDocs: ExternalDoc? = nil) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.components = components
            self.externalDocs = externalDocs
        }
    }
}

extension OpenAPI.Document {
    public enum Version: String, Codable {
        case v3_0_0 = "3.0.0"
        case v3_0_1 = "3.0.1"
        case v3_0_2 = "3.0.2"
    }

    public struct Info: Codable {
        public let title: String
        public let description: String?
        public let termsOfService: URL?
        public let contact: Contact?
        public let license: License?
        public let version: String

        public init(title: String,
                    description: String? = nil,
                    termsOfService: URL? = nil,
                    contact: Contact? = nil,
                    license: License? = nil,
                    version: String) {
            self.title = title
            self.description = description
            self.termsOfService = termsOfService
            self.contact = contact
            self.license = license
            self.version = version
        }

        public struct Contact: Codable {
            public let name: String?
            public let url: URL?
            public let email: String?

            public init(name: String? = nil,
                        url: URL? = nil,
                        email: String? = nil) {
                self.name = name
                self.url = url
                self.email = email
            }
        }

        public struct License: Codable {
            public let name: String
            public let url: URL?

            public init(name: String,
                        url: URL? = nil) {
                self.name = name
                self.url = url
            }
        }
    }
}

extension OpenAPI {

    public struct ExternalDoc: Codable, Equatable {
        public let description: String?
        public let url: URL

        public init(description: String? = nil,
                    url: URL) {
            self.description = description
            self.url = url
        }
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

        if externalDocs != nil {
            try container.encode(externalDocs, forKey: .externalDocs)
        }
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)

        info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)

        servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers) ?? []

        // hacky workaround for Dictionary bug
        let pathsDict = try container.decode([String: OpenAPI.PathItem].self, forKey: .paths)
        paths = Dictionary(pathsDict.compactMap { args in
            let (pathString, pathItem) = args

            return OpenAPI.PathComponents(rawValue: pathString)
                .map { ($0, pathItem) }
            },
                           uniquingKeysWith: { $1 })

        components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)
    }
}
