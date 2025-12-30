//
//  SecurityScheme.swift
//  
//
//  Created by Mathew Polzin on 12/30/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Security Scheme Object"
    ///
    /// See [OpenAPI Security Scheme Object](https://spec.openapis.org/oas/v3.2.0.html#security-scheme-object).
    public struct SecurityScheme: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        public var type: SecurityType
        public var description: String?
        /// Indication of if the security scheme is deprecated. Defaults to
        /// `false` and OpenAPIKit only encodes this property if it is set to
        /// `true`.
        public var deprecated: Bool

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]
        
        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        public init(
            type: SecurityType,
            description: String? = nil,
            vendorExtensions: [String: AnyCodable] = [:],
            deprecated: Bool = false
        ) {
            self.type = type
            self.description = description
            self.vendorExtensions = vendorExtensions
            self.deprecated = deprecated

            self.conditionalWarnings = [
                OASWarnings.Doc.nonNilVersionWarning(objectName: "SecurityScheme", fieldName: "oauth2MetadataUrl", value: type.oauth2MetadataUrl, minimumVersion: .v3_2_0),
                notFalseVersionWarning(fieldName: "deprecated", value: deprecated, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }

        public static func apiKey(name: String, location: Location, description: String? = nil, deprecated: Bool = false) -> SecurityScheme {
            return .init(type: .apiKey(name: name, location: location), description: description, deprecated: deprecated)
        }

        public static func http(scheme: String, bearerFormat: String? = nil, description: String? = nil, deprecated: Bool = false) -> SecurityScheme {
            return .init(type: .http(scheme: scheme, bearerFormat: bearerFormat), description: description, deprecated: deprecated)
        }

        public static func oauth2(flows: OAuthFlows, metadataUrl: URL? = nil, description: String? = nil, deprecated: Bool = false) -> SecurityScheme {
            return .init(type: .oauth2(flows: flows, metadataUrl: metadataUrl), description: description, deprecated: deprecated)
        }

        public static func openIdConnect(url: URL, description: String? = nil, deprecated: Bool = false) -> SecurityScheme {
            return .init(type: .openIdConnect(openIdConnectUrl: url), description: description, deprecated: deprecated)
        }

        public static func mutualTLS(description: String? = nil, deprecated: Bool = false) -> SecurityScheme {
            return .init(type: .mutualTLS, description: description, deprecated: deprecated)
        }

        public enum SecurityType: Equatable, Sendable {
            case apiKey(name: String, location: Location)
            case http(scheme: String, bearerFormat: String?)
            case oauth2(flows: OAuthFlows, metadataUrl: URL?)
            case openIdConnect(openIdConnectUrl: URL)
            case mutualTLS
        }
    }
}

extension OpenAPI.SecurityScheme: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type
        && lhs.description == rhs.description
        && lhs.deprecated == rhs.deprecated
        && lhs.vendorExtensions == rhs.vendorExtensions
    }
}

fileprivate func notFalseVersionWarning(fieldName: String, value: Bool, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
    guard value else { return nil }

    return OpenAPI.Document.ConditionalWarnings.version(
        lessThan: minimumVersion,
        doesNotSupport: "The Security Scheme \(fieldName) field"
    )
}

extension OpenAPI.SecurityScheme.SecurityType {
    public enum Name: String, Codable {
        case apiKey
        case http
        case oauth2
        case openIdConnect
        case mutualTLS
    }

    public var name: Name {
        switch self {
        case .apiKey:
            return .apiKey
        case .http:
            return .http
        case .oauth2:
            return .oauth2
        case .openIdConnect:
            return .openIdConnect
        case .mutualTLS:
            return .mutualTLS
        }
    }

    public var oauth2MetadataUrl: URL? {
      guard case let .oauth2(_, metadataUrl: metadataUrl) = self else { return nil }

      return metadataUrl
    }
}

// MARK: - Describable

extension OpenAPI.SecurityScheme : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.SecurityScheme {
        guard let description = description else { return self }
        var scheme = self
        scheme.description = description
        return scheme
    }
}

// MARK: - Codable
extension OpenAPI.SecurityScheme: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(description, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        switch type {
        case .apiKey(name: let name, location: let location):
            try container.encode(SecurityType.Name.apiKey, forKey: .type)
            try container.encode(name, forKey: .name)
            try container.encode(location, forKey: .location)
        case .http(scheme: let scheme, bearerFormat: let bearerFormat):
            try container.encode(SecurityType.Name.http, forKey: .type)
            try container.encode(scheme, forKey: .scheme)
            try container.encodeIfPresent(bearerFormat, forKey: .bearerFormat)
        case .openIdConnect(openIdConnectUrl: let url):
            try container.encode(SecurityType.Name.openIdConnect, forKey: .type)
            try container.encode(url.absoluteString, forKey: .openIdConnectUrl)
        case .oauth2(flows: let flows, metadataUrl: let url):
            try container.encode(SecurityType.Name.oauth2, forKey: .type)
            try container.encode(flows, forKey: .flows)
            try container.encodeIfPresent(url?.absoluteString, forKey: .oauth2MetadataUrl)
        case .mutualTLS:
            try container.encode(SecurityType.Name.mutualTLS, forKey: .type)
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.SecurityScheme: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false

        let typeName = try container.decode(SecurityType.Name.self, forKey: .type)

        switch typeName {
        case .apiKey:
            let (name, location) = try Self.decodeAPIKey(from: container)
            type = .apiKey(
                name: name,
                location: location
            )
        case .http:
            let (scheme, bearerFormat) = try Self.decodeHTTP(from: container)
            type = .http(
                scheme: scheme,
                bearerFormat: bearerFormat
            )
        case .oauth2:
            type = .oauth2(
                flows: try container.decode(OpenAPI.OAuthFlows.self, forKey: .flows),
                metadataUrl: try container.decodeURLAsStringIfPresent(forKey: .oauth2MetadataUrl)
            )
        case .openIdConnect:
            type = .openIdConnect(
                openIdConnectUrl: try container.decodeURLAsString(forKey: .openIdConnectUrl)
            )
        case .mutualTLS:
            type = .mutualTLS
        }

        vendorExtensions = try Self.extensions(from: decoder)

        self.conditionalWarnings = [
            OASWarnings.Doc.nonNilVersionWarning(objectName: "SecurityScheme", fieldName: "oauth2MetadataUrl", value: type.oauth2MetadataUrl, minimumVersion: .v3_2_0),
            notFalseVersionWarning(fieldName: "deprecated", value: deprecated, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }

    internal static func decodeAPIKey(from container: KeyedDecodingContainer<OpenAPI.SecurityScheme.CodingKeys>) throws -> (name: String, location: Location) {
        return try (
            name: container.decode(String.self, forKey: .name),
            location: container.decode(Location.self, forKey: .location)
        )
    }

    internal static func decodeHTTP(from container: KeyedDecodingContainer<OpenAPI.SecurityScheme.CodingKeys>) throws -> (scheme: String, bearerFormat: String?) {
        return try (
            scheme: container.decode(String.self, forKey: .scheme),
            bearerFormat: container.decodeIfPresent(String.self, forKey: .bearerFormat)
        )
    }
}

extension OpenAPI.SecurityScheme {
    internal enum CodingKeys: ExtendableCodingKey {
        case type
        case description
        case deprecated
        case name
        case location
        case scheme
        case bearerFormat
        case flows
        case openIdConnectUrl
        case oauth2MetadataUrl
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .type,
                .description,
                .deprecated,
                .name,
                .location,
                .scheme,
                .bearerFormat,
                .flows,
                .openIdConnectUrl,
                .oauth2MetadataUrl
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "type":
                self = .type
            case "description":
                self = .description
            case "deprecated":
                self = .deprecated
            case "name":
                self = .name
            case "in":
                self = .location
            case "scheme":
                self = .scheme
            case "bearerFormat":
                self = .bearerFormat
            case "flows":
                self = .flows
            case "openIdConnectUrl":
                self = .openIdConnectUrl
            case "oauth2MetadataUrl":
                self = .oauth2MetadataUrl
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .type:
                return "type"
            case .description:
                return "description"
            case .deprecated:
                return "deprecated"
            case .name:
                return "name"
            case .location:
                return "in"
            case .scheme:
                return "scheme"
            case .bearerFormat:
                return "bearerFormat"
            case .flows:
                return "flows"
            case .openIdConnectUrl:
                return "openIdConnectUrl"
            case .oauth2MetadataUrl:
                return "oauth2MetadataUrl"
            case .extended(let key):
                return key
            }
        }
    }
}

// MARK: - LocallyDereferenceable
extension OpenAPI.SecurityScheme: LocallyDereferenceable {
    /// Security Schemes do not contain any references but for convenience
    /// they can be "dereferenced" to themselves.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> OpenAPI.SecurityScheme {
        var ret = self
        if let name {
            ret.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }
        return ret
    }
}

extension OpenAPI.SecurityScheme: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        return (self, .init(), [])
    }
}

extension OpenAPI.SecurityScheme: Validatable {}
