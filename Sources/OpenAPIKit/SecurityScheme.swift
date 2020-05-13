//
//  SecurityScheme.swift
//  
//
//  Created by Mathew Polzin on 12/30/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Security Scheme Object"
    ///
    /// See [OpenAPI Security Scheme Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#security-scheme-object).
    public struct SecurityScheme: Equatable {
        public let type: SecurityType
        public let description: String?

        public init(type: SecurityType,
                    description: String? = nil) {
            self.type = type
            self.description = description
        }

        public static func apiKey(name: String, location: Location, description: String? = nil) -> SecurityScheme {
            return .init(type: .apiKey(name: name, location: location), description: description)
        }

        public static func http(scheme: String, bearerFormat: String? = nil, description: String? = nil) -> SecurityScheme {
            return .init(type: .http(scheme: scheme, bearerFormat: bearerFormat), description: description)
        }

        public static func oauth2(flows: OAuthFlows, description: String? = nil) -> SecurityScheme {
            return .init(type: .oauth2(flows: flows), description: description)
        }

        public static func openIdConnect(url: URL, description: String? = nil) -> SecurityScheme {
            return .init(type: .openIdConnect(openIdConnectUrl: url), description: description)
        }

        public enum SecurityType: Equatable {
            case apiKey(name: String, location: Location)
            case http(scheme: String, bearerFormat: String?)
            case oauth2(flows: OAuthFlows)
            case openIdConnect(openIdConnectUrl: URL)
        }

        public enum Location: String, Codable, Equatable {
            case query
            case header
            case cookie
        }
    }
}

extension OpenAPI.SecurityScheme.SecurityType {
    public enum Name: String, Codable {
        case apiKey
        case http
        case oauth2
        case openIdConnect
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
        }
    }
}

// MARK: - Codable
extension OpenAPI.SecurityScheme: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(description, forKey: .description)

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
            try container.encode(url, forKey: .openIdConnectUrl)
        case .oauth2(flows: let flows):
            try container.encode(SecurityType.Name.oauth2, forKey: .type)
            try container.encode(flows, forKey: .flows)
        }
    }
}

extension OpenAPI.SecurityScheme: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decodeIfPresent(String.self, forKey: .description)

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
                flows: try container.decode(OpenAPI.OAuthFlows.self, forKey: .flows)
            )
        case .openIdConnect:
            type = .openIdConnect(
                openIdConnectUrl: try container.decode(URL.self, forKey: .openIdConnectUrl)
            )
        }
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
    internal enum CodingKeys: String, CodingKey {
        case type
        case description
        case name
        case location = "in"
        case scheme
        case bearerFormat
        case flows
        case openIdConnectUrl
    }
}
