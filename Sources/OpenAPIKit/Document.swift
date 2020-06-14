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
    ///
    /// An OpenAPI Document can say a _lot_ about the API it describes.
    /// A read-through of the specification is highly recommended because
    /// OpenAPIKit stays intentionally close to the naming and structure
    /// layed out by the Specification -- it goes without saying that the encoded
    /// JSON or YAML produced by OpenAPIKit conforms to the specification
    /// exactly.
    public struct Document: Equatable, CodableVendorExtendable {
        /// OpenAPI Spec "openapi" field.
        ///
        /// OpenAPIKit only explicitly supports versions that can be found in
        /// the `Version` enum. Other versions may or may not be decodable
        /// by OpenAPIKit to a certain extent.
        public var openAPIVersion: Version

        /// Information about the API described by this OpenAPI Document.
        ///
        /// Licensing, Terms of Service, contact information, API version (the
        /// version of the API this document describes, not the OpenAPI
        /// Specification version), etc.
        public var info: Info

        /// An array of Server Objects, which provide connectivity information
        /// to a target server.
        ///
        /// If the servers property is not provided, or is an
        /// empty array, the default value is a Server Object with a url value of
        /// "/".
        public var servers: [Server]

        /// All routes supported by this API. This property maps the path of each
        /// route (`OpenAPI.Path`) to the documentation for that route
        /// (`OpenAPI.PathItem`).
        public var paths: PathItem.Map

        /// Storage for components that need to be referenced elsewhere in the
        /// OpenAPI Document using `JSONReferences`.
        ///
        /// Storing components here can be in the interest of being explicit about
        /// the fact that the components are always the same (such as an
        /// "Unauthorized" `Response` definition used on all endpoints) or it might
        /// just be practical to put things here and reference them elsewhere to
        /// cut down on the overall size of the document.
        ///
        /// If your document is defined in Swift then this is a less beneficial way to
        /// share definitions than to just use the same Swift value multiple times, but
        /// you still might want to consider using the Components Object for its impact
        /// on the JSON/YAML structure of your document once encoded.
        public var components: Components

        /// A declaration of which security mechanisms can be used across the API.
        ///
        /// The list of values includes alternative security requirement objects that can
        /// be used. Only one of the security requirement objects need to be satisfied
        /// to authorize a request. Individual operations can override this definition.
        ///
        /// To make security optional, an empty security requirement can be included
        /// in the array.
        ///
        /// - Important: The OpenAPI Specification defines Security Requirement
        ///     Object keys as being `String` values corresponding to entries in
        ///     the Components Object.
        ///
        ///     OpenAPIKit has a type capable of representing that: The `JSONReference`.
        ///     For that reason, OpenAPIKit defines keys in security requirement objects as
        ///     explicit references to entries in the Components Object instead of `String`
        ///     values.
        public var security: [SecurityRequirement]

        /// A list of tags used by the specification with additional metadata.
        ///
        /// The order of the tags can be used to reflect on their order by the parsing tools.
        /// Not all tags that are used by Operation Objects must be declared at the document
        /// level.
        ///
        /// - Important: Each tag name in the list MUST be unique.
        public var tags: [Tag]?

        /// Additional external documentation.
        public var externalDocs: ExternalDocumentation?

        /// Retrieve an array of all Operation Ids defined by
        /// this API. These Ids are guaranteed to be unique by
        /// the OpenAPI Specification.
        ///
        /// See [Operation Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#operation-object) in the specifcation.
        ///
        public var allOperationIds: [String] {
            return paths.values
                .flatMap { $0.endpoints }
                .compactMap { $0.operation.operationId }
        }

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            openAPIVersion: Version = .v3_0_0,
            info: Info,
            servers: [Server],
            paths: PathItem.Map,
            components: Components,
            security: [SecurityRequirement] = [],
            tags: [Tag]? = nil,
            externalDocs: ExternalDocumentation? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
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

extension OpenAPI.Document {
    /// A `Route` is the combination of a path (where the route lives)
    /// and a path item (the definition of the route).
    public struct Route: Equatable {
        public let path: OpenAPI.Path
        public let pathItem: OpenAPI.PathItem

        public init(
            path: OpenAPI.Path,
            pathItem: OpenAPI.PathItem
        ) {
            self.path = path
            self.pathItem = pathItem
        }
    }

    /// Get all routes for this document.
    ///
    /// - Returns: An Array of `Routes` with the path
    ///     and the definition of the route.
    public var routes: [Route] {
        return paths.map { (path, pathItem) in .init(path: path, pathItem: pathItem) }
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
    /// The OpenAPI Specification version.
    ///
    /// OpenAPIKit only explicitly supports versions that can be found in
    /// this enum. Other versions may or may not be decodable by
    /// OpenAPIKit to a certain extent.
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

        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)

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
        for endpoint in pathItem.endpoints {
            if let securityRequirements = endpoint.operation.security {
                try validate(
                    securityRequirements: securityRequirements,
                    at: path,
                    for: endpoint.method,
                    against: components
                )
            }
        }
    }
}

internal func validate(securityRequirements: [OpenAPI.SecurityRequirement], at path: OpenAPI.Path, for verb: OpenAPI.HttpMethod, against components: OpenAPI.Components) throws {
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
