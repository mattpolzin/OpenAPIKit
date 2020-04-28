//
//  Document.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/13/19.
//

import Foundation

extension OpenAPI {
    /// The root of an OpenAPI 3.0 document.
    /// 
    /// See [OpenAPI Specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md).
    public struct Document: Equatable, CodableVendorExtendable {
        public var openAPIVersion: Version
        public var info: Info
        public var servers: [Server]
        public var paths: PathItem.Map
        public var components: Components
        public var security: [SecurityRequirement]
        public var tags: [Tag]?
        public var externalDocs: ExternalDocumentation?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(openAPIVersion: Version = .v3_0_0,
                    info: Info,
                    servers: [Server],
                    paths: PathItem.Map,
                    components: Components,
                    security: [SecurityRequirement] = [],
                    tags: [Tag]? = nil,
                    externalDocs: ExternalDocumentation? = nil,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.openAPIVersion = openAPIVersion
            self.info = info
            self.servers = servers
            self.paths = paths
            self.components = components
            self.security = security
            self.tags = tags
            self.externalDocs = externalDocs
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI {
    /// If the security scheme is of type "oauth2" or "openIdConnect",
    /// then the value is a list of scope names required for the execution.
    /// For other security scheme types, the array MUST be empty.
    ///
    /// OpenAPI Spec "Security Requirement Object"
    ///
    /// See [OpenAPI Security Requirement Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#security-requirement-object).
    public typealias SecurityRequirement = [JSONReference<SecurityScheme>: [String]]
}

extension OpenAPI.Document {
    public enum Version: String, Codable {
        case v3_0_0 = "3.0.0"
        case v3_0_1 = "3.0.1"
        case v3_0_2 = "3.0.2"
        case v3_0_3 = "3.0.3"
    }
}

// MARK: - Codable

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

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Document: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            openAPIVersion = try container.decode(OpenAPI.Document.Version.self, forKey: .openAPIVersion)

            info = try container.decode(OpenAPI.Document.Info.self, forKey: .info)

            servers = try container.decodeIfPresent([OpenAPI.Server].self, forKey: .servers) ?? []

            let components = try container.decodeIfPresent(OpenAPI.Components.self, forKey: .components) ?? .noComponents
            self.components = components

            let paths = try container.decode(OpenAPI.PathItem.Map.self, forKey: .paths)
            self.paths = paths
            try validateSecurityRequirements(in: paths, against: components)

            security = try decodeSecurityRequirements(from: container, forKey: .security, given: components) ?? []

            tags = try container.decodeIfPresent([OpenAPI.Tag].self, forKey: .tags)

            externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)

            vendorExtensions = try Self.extensions(from: decoder)

        } catch let error as OpenAPI.Error.Decoding.Path {

            throw OpenAPI.Error.Decoding.Document(error)
        } catch let error as InconsistencyError {

            throw OpenAPI.Error.Decoding.Document(error)
        } catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Document(error)
        }
    }
}

extension OpenAPI.Document {
    internal enum CodingKeys: ExtendableCodingKey {
        case openAPIVersion
        case info
        case servers
        case paths
        case components
        case security
        case tags
        case externalDocs
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .openAPIVersion,
                .info,
                .servers,
                .paths,
                .components,
                .security,
                .tags,
                .externalDocs
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "openapi":
                self = .openAPIVersion
            case "info":
                self = .info
            case "servers":
                self = .servers
            case "paths":
                self = .paths
            case "components":
                self = .components
            case "security":
                self = .security
            case "tags":
                self = .tags
            case "externalDocs":
                self = .externalDocs
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String {
            switch self {
            case .openAPIVersion:
                return "openapi"
            case .info:
                return "info"
            case .servers:
                return "servers"
            case .paths:
                return "paths"
            case .components:
                return "components"
            case .security:
                return "security"
            case .tags:
                return "tags"
            case .externalDocs:
                return "externalDocs"
            case .extended(let key):
                return key
            }
        }

        var intValue: Int? {
            return nil
        }
    }
}

internal func encodeSecurity<CodingKeys: CodingKey>(requirements security: [OpenAPI.SecurityRequirement], to container: inout KeyedEncodingContainer<CodingKeys>, forKey key: CodingKeys) throws {
    // A real mess here because we've got an Array of non-string-keyed
    // Dictionaries.
    var securityContainer = container.nestedUnkeyedContainer(forKey: key)
    for securityRequirement in security {
        let securityKeysAndValues = securityRequirement
            .compactMap { keyValue in keyValue.key.name.map { ($0, keyValue.value) } }
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
                    key: JSONReference<OpenAPI.SecurityScheme>.component(named: key),
                    value: value
                )
            }

            if let components = optionalComponents {
                // check each key for validity against components.
                let foundInComponents = { (ref: JSONReference<OpenAPI.SecurityScheme>) -> Bool in
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

internal func validateSecurityRequirements(in paths: OpenAPI.PathItem.Map, against components: OpenAPI.Components) throws {
    for (path, pathItem) in paths {
        for (verb, operation) in pathItem.endpoints {
            if let securityRequirements = operation.security {
                try validate(
                    securityRequirements: securityRequirements,
                    at: path,
                    for: verb,
                    against: components
                )
            }
        }
    }
}

internal func validate(securityRequirements: [OpenAPI.SecurityRequirement], at path: OpenAPI.Path, for verb: OpenAPI.HttpVerb, against components: OpenAPI.Components) throws {
    let securitySchemes = securityRequirements.flatMap { $0.keys }

    for securityScheme in securitySchemes {
        guard components[securityScheme] != nil else {
            let schemeKey = securityScheme.name ?? securityScheme.absoluteString
            let keys = [
                "paths",
                path.rawValue,
                verb.rawValue.lowercased(),
                "security",
                schemeKey
            ]
            .map(AnyCodingKey.init(stringValue:))

            throw InconsistencyError(
                subjectName: schemeKey,
                details: "Each key found in a Security Requirement dictionary must refer to a Security Scheme present in the Components dictionary",
                codingPath: keys
            )
        }
    }
}
