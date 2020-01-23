//
//  Server.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation

extension OpenAPI {
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
extension OpenAPI.Server: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
        case description
        case variables
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(URL.self, forKey: .url)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        variables = try container.decodeIfPresent(OrderedDictionary<String, Variable>.self, forKey: .variables) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(url, forKey: .url)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        if variables.count > 0 {
            try container.encode(variables, forKey: .variables)
        }
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
