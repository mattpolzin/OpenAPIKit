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
        public var openAPIVersion: Version
        public var info: Info
        public var servers: [Server]
        public var paths: PathItem.Map
        public var components: Components
        public var security: [SecurityRequirement]
        public var tags: [Tag]?
        public var externalDocs: ExternalDoc?

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
    /// If the security scheme is of type "oauth2" or "openIdConnect",
    /// then the value is a list of scope names required for the execution.
    /// For other security scheme types, the array MUST be empty.
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

        try container.encode(paths, forKey: .paths)

        if !components.isEmpty {
            try container.encode(components, forKey: .components)
        }

        // A real mess here because we've got an Array of non-string-keyed
        // Dictionaries.
        if !security.isEmpty {
            try encodeSecurity(requirements: security, to: &container, forKey: .security)
        }

        try tags.encodeIfNotNil(to: &container, forKey: .tags)

        try externalDocs.encodeIfNotNil(to: &container, forKey: .externalDocs)
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)

            info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)

            servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers) ?? []

            paths = try container.decode(OpenAPI.PathItem.Map.self, forKey: .paths)

            let components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents
            self.components = components

            // A real mess here because we've got an Array of non-string-keyed
            // Dictionaries.
            security = try decodeSecurityRequirements(from: container, forKey: .security, given: components) ?? []

            tags = try container.decodeIfPresent([OpenAPI.Tag].self, forKey: .tags)

            externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDoc.self, forKey: .externalDocs)
        } catch let error as OpenAPI.Error.Decoding.Path {
            throw OpenAPI.Error.Decoding.Document(
                context: .path(error),
                codingPath: error.codingPath
            )
        } catch let error as InconsistencyError {
            throw OpenAPI.Error.Decoding.Document(
                context: .inconsistency(subjectName: error.subjectName, details: error.details),
                codingPath: error.codingPath
            )
        } catch let error as DecodingError {
            throw OpenAPI.Error.Decoding.Document(
                context: .generic(error),
                codingPath: error.codingPath
            )
        }
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
                    throw InconsistencyError(
                        subjectName: key.stringValue,
                        details: "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary",
                        codingPath: container.codingPath + [key]
                    )
                }
            }

            securityRequirements.append(Dictionary(securityKeysAndValues, uniquingKeysWith: { $1 }))
        }

        return securityRequirements
    }

    return nil
}
