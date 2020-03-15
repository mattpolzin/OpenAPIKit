//
//  Server.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import OrderedDictionary

extension OpenAPI {
    /// OpenAPI Spec "Server Object"
    ///
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#server-object
    public struct Server: Equatable {
        public let url: URL
        public let description: String?
        public let variables: OrderedDictionary<String, Variable>

        public init(url: URL,
                    description: String? = nil,
                    variables: OrderedDictionary<String, Variable> = [:]) {
            self.url = url
            self.description = description
            self.variables = variables
        }
    }
}

extension OpenAPI.Server {
    /// OpenAPI Spec "Server Variable Object"
    ///
    /// https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#server-variable-object
    public struct Variable: Equatable {
        public let `enum`: [String]
        public let `default`: String
        public let description: String?

        public init(enum: [String] = [],
                    default: String,
                    description: String? = nil) {
            self.enum = `enum`
            self.default = `default`
            self.description = description
        }
    }
}

// MARK: - Codable
extension OpenAPI.Server: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(URL.self, forKey: .url)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        variables = try container.decodeIfPresent(OrderedDictionary<String, Variable>.self, forKey: .variables) ?? [:]
    }
}

extension OpenAPI.Server: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(url, forKey: .url)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        if variables.count > 0 {
            try container.encode(variables, forKey: .variables)
        }
    }
}

extension OpenAPI.Server {
    private enum CodingKeys: String, CodingKey {
        case url
        case description
        case variables
    }
}

extension OpenAPI.Server.Variable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(`enum`, forKey: .enum)

        try container.encode(`default`, forKey: .default)

        try description.encodeIfNotNil(to: &container, forKey: .description)
    }
}

extension OpenAPI.Server.Variable: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        `enum` = try container.decode([String].self, forKey: .enum)

        `default` = try container.decode(String.self, forKey: .default)

        description = try container.decodeIfPresent(String.self, forKey: .description)
    }
}

extension OpenAPI.Server.Variable {
    private enum CodingKeys: String, CodingKey {
        case `enum`
        case `default`
        case description
    }
}
