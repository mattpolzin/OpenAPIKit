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

// MARK: - Codable
extension OpenAPI.OAuthFlows {
    private enum CodingKeys: String, CodingKey {
        case implicit
        case password
        case clientCredentials
        case authorizationCode
    }
}

extension OpenAPI.OAuthFlows: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(implicit, forKey: .implicit)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(clientCredentials, forKey: .clientCredentials)
        try container.encodeIfPresent(authorizationCode, forKey: .authorizationCode)
    }
}

extension OpenAPI.OAuthFlows: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        implicit = try container.decodeIfPresent(OpenAPI.OAuthFlows.Implicit.self, forKey: .implicit)
        password = try container.decodeIfPresent(OpenAPI.OAuthFlows.Password.self, forKey: .password)
        clientCredentials = try container.decodeIfPresent(OpenAPI.OAuthFlows.ClientCredentials.self, forKey: .clientCredentials)
        authorizationCode = try container.decodeIfPresent(OpenAPI.OAuthFlows.AuthorizationCode.self, forKey: .authorizationCode)
    }
}

extension OpenAPI.OAuthFlows: Validatable {}
