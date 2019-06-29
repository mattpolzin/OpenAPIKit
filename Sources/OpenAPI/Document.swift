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
        //    public let servers:
        public let paths: [PathComponents: PathItem]
        public let components: OpenAPI.Components
        //    public let security:
        //    public let tags:
        //    public let externalDocs:

        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    paths: [PathComponents: PathItem],
                    components: OpenAPI.Components) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.paths = paths
            self.components = components
        }

        public enum Version: String, Codable {
            case v3_0_0 = "3.0.0"
        }

        public struct Info: Codable {
            public let title: String
            public let description: String?
            public let termsOfService: URL?
            //        public let contact:
            //        public let license:
            public let version: String

            public init(title: String,
                        description: String? = nil,
                        termsOfService: URL? = nil,
                        version: String) {
                self.title = title
                self.description = description
                self.termsOfService = termsOfService
                self.version = version
            }
        }

        public struct PathComponents: RawRepresentable, Equatable, Hashable {
            public let components: [String]

            public init(_ components: [String]) {
                self.components = components
            }

            public init?(rawValue: String) {
                components = rawValue.split(separator: "/").map(String.init)
            }

            public var rawValue: String {
                return "/\(components.joined(separator: "/"))"
            }
        }
    }
}



// MARK: - Codable

extension OpenAPI.Document.PathComponents: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(rawValue)
    }
}

extension OpenAPI.Document.PathComponents: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let rawValue = try container.decode(String.self)

        components = rawValue.split(separator: "/").map(String.init)
    }
}

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

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            paths.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .paths)

        try container.encode(components, forKey: .components)
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)

        info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)

        // hacky workaround for Dictionary bug
        let pathsDict = try container.decode([String: OpenAPI.PathItem].self, forKey: .paths)
        paths = Dictionary(pathsDict.compactMap { pathString, pathItem in
            OpenAPI.Document.PathComponents(rawValue: pathString).map { ($0, pathItem) } },
                           uniquingKeysWith: { $1 })

        components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents
    }
}
