//
//  OAuthFlows.swift
//  
//
//  Created by Mathew Polzin on 1/23/20.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Oauth Flows Object"
    ///
    /// See [OpenAPI Oauth Flows Object](https://spec.openapis.org/oas/v3.0.4.html#oauth-flows-object).
    public struct OAuthFlows: Equatable, Sendable {
        public let implicit: Implicit?
        public let password: Password?
        public let clientCredentials: ClientCredentials?
        public let authorizationCode: AuthorizationCode?
        public let deviceAuthorization: DeviceAuthorization?

        public init(
            implicit: Implicit? = nil,
            password: Password? = nil,
            clientCredentials: ClientCredentials? = nil,
            authorizationCode: AuthorizationCode? = nil,
            deviceAuthorization: DeviceAuthorization? = nil
        ) {
            self.implicit = implicit
            self.password = password
            self.clientCredentials = clientCredentials
            self.authorizationCode = authorizationCode
            self.deviceAuthorization = deviceAuthorization
        }
    }
}

extension OpenAPI.OAuthFlows {
    @dynamicMemberLookup
    public struct DeviceAuthorization: Equatable, Sendable {
        private let common: CommonFields
        public let deviceAuthorizationUrl: URL
        public let tokenUrl: URL

        public init(deviceAuthorizationUrl: URL, tokenUrl: URL, refreshUrl: URL? = nil, scopes: OrderedDictionary<Scope, ScopeDescription>) {
            self.deviceAuthorizationUrl = deviceAuthorizationUrl
            self.tokenUrl = tokenUrl
            common = .init(refreshUrl: refreshUrl, scopes: scopes)
        }

        public subscript<T>(dynamicMember path: KeyPath<CommonFields, T>) -> T {
            return common[keyPath: path]
        }
    }
}

// MARK: - Codable
extension OpenAPI.OAuthFlows {
    private enum CodingKeys: String, CodingKey {
        case implicit
        case password
        case clientCredentials
        case authorizationCode
        case deviceAuthorization
    }
}

extension OpenAPI.OAuthFlows.DeviceAuthorization {
    private enum CodingKeys: String, CodingKey {
        case deviceAuthorizationUrl
        case tokenUrl
    }
}

extension OpenAPI.OAuthFlows: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(implicit, forKey: .implicit)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(clientCredentials, forKey: .clientCredentials)
        try container.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
        try container.encodeIfPresent(deviceAuthorization, forKey: .deviceAuthorization)
    }
}

extension OpenAPI.OAuthFlows: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        implicit = try container.decodeIfPresent(OpenAPI.OAuthFlows.Implicit.self, forKey: .implicit)
        password = try container.decodeIfPresent(OpenAPI.OAuthFlows.Password.self, forKey: .password)
        clientCredentials = try container.decodeIfPresent(OpenAPI.OAuthFlows.ClientCredentials.self, forKey: .clientCredentials)
        authorizationCode = try container.decodeIfPresent(OpenAPI.OAuthFlows.AuthorizationCode.self, forKey: .authorizationCode)
        deviceAuthorization = try container.decodeIfPresent(OpenAPI.OAuthFlows.DeviceAuthorization.self, forKey: .deviceAuthorization)
    }
}

extension OpenAPI.OAuthFlows.DeviceAuthorization: Encodable {
    public func encode(to encoder: Encoder) throws {
        try common.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(tokenUrl.absoluteString, forKey: .tokenUrl)
        try container.encode(deviceAuthorizationUrl.absoluteString, forKey: .deviceAuthorizationUrl)
    }
}

extension OpenAPI.OAuthFlows.DeviceAuthorization: Decodable {
    public init(from decoder: Decoder) throws {
        common = try OpenAPI.OAuthFlows.CommonFields(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        tokenUrl = try container.decodeURLAsString(forKey: .tokenUrl)
        deviceAuthorizationUrl = try container.decodeURLAsString(forKey: .deviceAuthorizationUrl)
    }
}

extension OpenAPI.OAuthFlows: Validatable {}
extension OpenAPI.OAuthFlows.DeviceAuthorization: Validatable {}
// The following conformances are found in Core
// extension Shared.OAuthFlows.Implicit: Validatable {}
// extension Shared.OAuthFlows.Password: Validatable {}
// extension Shared.OAuthFlows.ClientCredentials: Validatable {}
// extension Shared.OAuthFlows.AuthorizationCode: Validatable {}
