//
//  OAuthFlows.swift
//  
//
//  Created by Mathew Polzin on 1/23/20.
//

import Foundation

extension Shared {
    /// OpenAPI Spec "Oauth Flows Object"
    ///
    /// See [OpenAPI Oauth Flows Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#oauth-flows-object).
    public struct OAuthFlows: Equatable {
        public let implicit: Implicit?
        public let password: Password?
        public let clientCredentials: ClientCredentials?
        public let authorizationCode: AuthorizationCode?

        public init(
            implicit: Implicit? = nil,
            password: Password? = nil,
            clientCredentials: ClientCredentials? = nil,
            authorizationCode: AuthorizationCode? = nil
        ) {
            self.implicit = implicit
            self.password = password
            self.clientCredentials = clientCredentials
            self.authorizationCode = authorizationCode
        }
    }
}

extension Shared.OAuthFlows {
    public typealias Scope = String
    public typealias ScopeDescription = String

    public struct CommonFields: Equatable {
        public let refreshUrl: URL?
        public let scopes: OrderedDictionary<Scope, ScopeDescription>
    }

    @dynamicMemberLookup
    public struct Implicit: Equatable {
        private let common: CommonFields
        public let authorizationUrl: URL

        public init(authorizationUrl: URL, refreshUrl: URL? = nil, scopes: OrderedDictionary<Scope, ScopeDescription>) {
            self.authorizationUrl = authorizationUrl
            common = .init(refreshUrl: refreshUrl, scopes: scopes)
        }

        public subscript<T>(dynamicMember path: KeyPath<CommonFields, T>) -> T {
            return common[keyPath: path]
        }
    }

    @dynamicMemberLookup
    public struct Password: Equatable {
        private let common: CommonFields
        public let tokenUrl: URL

        public init(tokenUrl: URL, refreshUrl: URL? = nil, scopes: OrderedDictionary<Scope, ScopeDescription>) {
            self.tokenUrl = tokenUrl
            common = .init(refreshUrl: refreshUrl, scopes: scopes)
        }

        public subscript<T>(dynamicMember path: KeyPath<CommonFields, T>) -> T {
            return common[keyPath: path]
        }
    }

    @dynamicMemberLookup
    public struct ClientCredentials: Equatable {
        private let common: CommonFields
        public let tokenUrl: URL

        public init(tokenUrl: URL, refreshUrl: URL? = nil, scopes: OrderedDictionary<Scope, ScopeDescription>) {
            self.tokenUrl = tokenUrl
            common = .init(refreshUrl: refreshUrl, scopes: scopes)
        }

        public subscript<T>(dynamicMember path: KeyPath<CommonFields, T>) -> T {
            return common[keyPath: path]
        }
    }

    @dynamicMemberLookup
    public struct AuthorizationCode: Equatable {
        private let common: CommonFields
        public let authorizationUrl: URL
        public let tokenUrl: URL

        public init(authorizationUrl: URL, tokenUrl: URL, refreshUrl: URL? = nil, scopes: OrderedDictionary<Scope, ScopeDescription>) {
            self.authorizationUrl = authorizationUrl
            self.tokenUrl = tokenUrl
            common = .init(refreshUrl: refreshUrl, scopes: scopes)
        }

        public subscript<T>(dynamicMember path: KeyPath<CommonFields, T>) -> T {
            return common[keyPath: path]
        }
    }
}

// MARK: - Codable
extension Shared.OAuthFlows {
    private enum CodingKeys: String, CodingKey {
        case implicit
        case password
        case clientCredentials
        case authorizationCode
    }
}

extension Shared.OAuthFlows.CommonFields {
    private enum CodingKeys: String, CodingKey {
        case refreshUrl
        case scopes
    }
}

extension Shared.OAuthFlows.Implicit {
    private enum CodingKeys: String, CodingKey {
        case authorizationUrl
    }
}

extension Shared.OAuthFlows.Password {
    private enum CodingKeys: String, CodingKey {
        case tokenUrl
    }
}

extension Shared.OAuthFlows.ClientCredentials {
    private enum CodingKeys: String, CodingKey {
        case tokenUrl
    }
}

extension Shared.OAuthFlows.AuthorizationCode {
    private enum CodingKeys: String, CodingKey {
        case authorizationUrl
        case tokenUrl
    }
}

extension Shared.OAuthFlows: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(implicit, forKey: .implicit)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(clientCredentials, forKey: .clientCredentials)
        try container.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
    }
}

extension Shared.OAuthFlows: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        implicit = try container.decodeIfPresent(Shared.OAuthFlows.Implicit.self, forKey: .implicit)
        password = try container.decodeIfPresent(Shared.OAuthFlows.Password.self, forKey: .password)
        clientCredentials = try container.decodeIfPresent(Shared.OAuthFlows.ClientCredentials.self, forKey: .clientCredentials)
        authorizationCode = try container.decodeIfPresent(Shared.OAuthFlows.AuthorizationCode.self, forKey: .authorizationCode)
    }
}

extension Shared.OAuthFlows.CommonFields: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(refreshUrl?.absoluteString, forKey: .refreshUrl)
        try container.encode(scopes, forKey: .scopes)
    }
}

extension Shared.OAuthFlows.CommonFields: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        refreshUrl = try container.decodeURLAsStringIfPresent(forKey: .refreshUrl)
        scopes = try container.decode(OrderedDictionary<Shared.OAuthFlows.Scope, Shared.OAuthFlows.ScopeDescription>.self, forKey: .scopes)
    }
}

extension Shared.OAuthFlows.Implicit: Encodable {
    public func encode(to encoder: Encoder) throws {
        try common.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(authorizationUrl.absoluteString, forKey: .authorizationUrl)
    }
}

extension Shared.OAuthFlows.Implicit: Decodable {
    public init(from decoder: Decoder) throws {
        common = try Shared.OAuthFlows.CommonFields(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        authorizationUrl = try container.decodeURLAsString(forKey: .authorizationUrl)
    }
}

extension Shared.OAuthFlows.Password: Encodable {
    public func encode(to encoder: Encoder) throws {
        try common.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tokenUrl.absoluteString, forKey: .tokenUrl)
    }
}

extension Shared.OAuthFlows.Password: Decodable {
    public init(from decoder: Decoder) throws {
        common = try Shared.OAuthFlows.CommonFields(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        tokenUrl = try container.decodeURLAsString(forKey: .tokenUrl)
    }
}

extension Shared.OAuthFlows.ClientCredentials: Encodable {
    public func encode(to encoder: Encoder) throws {
        try common.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tokenUrl.absoluteString, forKey: .tokenUrl)
    }
}

extension Shared.OAuthFlows.ClientCredentials: Decodable {
    public init(from decoder: Decoder) throws {
        common = try Shared.OAuthFlows.CommonFields(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        tokenUrl = try container.decodeURLAsString(forKey: .tokenUrl)
    }
}

extension Shared.OAuthFlows.AuthorizationCode: Encodable {
    public func encode(to encoder: Encoder) throws {
        try common.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tokenUrl.absoluteString, forKey: .tokenUrl)
        try container.encode(authorizationUrl.absoluteString, forKey: .authorizationUrl)
    }
}

extension Shared.OAuthFlows.AuthorizationCode: Decodable {
    public init(from decoder: Decoder) throws {
        common = try Shared.OAuthFlows.CommonFields(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        tokenUrl = try container.decodeURLAsString(forKey: .tokenUrl)
        authorizationUrl = try container.decodeURLAsString(forKey: .authorizationUrl)
    }
}

extension Shared.OAuthFlows: Validatable {}
extension Shared.OAuthFlows.Implicit: Validatable {}
extension Shared.OAuthFlows.Password: Validatable {}
extension Shared.OAuthFlows.ClientCredentials: Validatable {}
extension Shared.OAuthFlows.AuthorizationCode: Validatable {}
