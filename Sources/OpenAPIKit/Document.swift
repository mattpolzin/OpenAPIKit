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
    public struct Document: Equatable {
        public let openAPIVersion: Version
        public let info: Info
        public let servers: [Server]
        public let paths: PathItem.Map
        public let components: Components
        public let security: [SecurityRequirement]
        public let tags: [Tag]?
        public let externalDocs: ExternalDoc?

        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    servers: [Server],
                    paths: PathItem.Map,
                    components: Components,
                    security: [SecurityRequirement] = [],
                    tags: [Tag]? = nil,
                    externalDocs: ExternalDoc? = nil) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.components = components
            self.security = security
            self.tags = tags
            self.externalDocs = externalDocs
        }
    }
}

extension OpenAPI {
    public typealias SecurityRequirement = [JSONReference<Components, SecurityScheme>: [String]]
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

        if !servers.isEmpty {
            try container.encode(servers, forKey: .servers)
        }

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let pathsStringKeyedDict = Dictionary(
            paths.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(pathsStringKeyedDict, forKey: .paths)

        try container.encode(components, forKey: .components)

        // A real mess here because we've got an Array of non-string-keyed
        // Dictionaries.
        if !security.isEmpty {
            try encodeSecurity(requirements: security, to: &container, forKey: .security)
        }

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

        let components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents
        self.components = components

        // A real mess here because we've got an Array of non-string-keyed
        // Dictionaries.
        security = try decodeSecurityRequirements(from: container, forKey: .security, given: components) ?? []

        tags = try container.decodeIfPresent([OpenAPI.Tag].self, forKey: .tags)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)
    }
}

internal func encodeSecurity<CodingKeys: CodingKey>(requirements security: [OpenAPI.SecurityRequirement], to container: inout KeyedEncodingContainer<CodingKeys>, forKey key: CodingKeys) throws {
    // A real mess here because we've got an Array of non-string-keyed
    // Dictionaries.
    var securityContainer = container.nestedUnkeyedContainer(forKey: key)
    for securityRequirement in security {
        let securityKeysAndValues = securityRequirement
            .compactMap { keyValue in keyValue.key.selector.map { ($0, keyValue.value) } }
        let securityStringKeyedDict = Dictionary(
            securityKeysAndValues,
            uniquingKeysWith: { $1 }
        )
        try securityContainer.encode(securityStringKeyedDict)
    }
}

internal func decodeSecurityRequirements<CodingKeys: CodingKey>(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys, given optionalComponents: OpenAPI.Components?) throws -> [OpenAPI.SecurityRequirement]? {
    // A real mess here because we've got an Array of non-string-keyed
    // Dictionaries.
    if container.contains(key) {
        var securityContainer = try container.nestedUnkeyedContainer(forKey: key)

        var securityRequirements = [OpenAPI.SecurityRequirement]()
        while !securityContainer.isAtEnd {
            let securityStringKeyedDict = try securityContainer.decode([String: [String]].self)

            // convert to JSONReference keys
            let securityKeysAndValues = securityStringKeyedDict.map { (key, value) in
                (
                    key: JSONReference<OpenAPI.Components, OpenAPI.SecurityScheme>.internal(.node(\.securitySchemes, named: key)),
                    value: value
                )
            }

            if let components = optionalComponents {
                // check each key for validity against components.
                let foundInComponents = { (ref: JSONReference<OpenAPI.Components, OpenAPI.SecurityScheme>) -> Bool in
                    return (try? components.contains(ref)) ?? false
                }
                guard securityKeysAndValues.map({ $0.key }).allSatisfy(foundInComponents) else {
                    throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary.")
                }
            }

            securityRequirements.append(Dictionary(securityKeysAndValues, uniquingKeysWith: { $1 }))
        }

        return securityRequirements
    } else {
        return nil
    }
}
