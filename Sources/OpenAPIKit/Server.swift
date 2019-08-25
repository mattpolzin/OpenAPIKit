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
        public let variables: [String: Variable]

        public init(url: URL,
                    description: String? = nil,
                    variables: [String: Variable] = [:]) {
            self.url = url
            self.description = description
            self.variables = variables
        }
    }
}

extension OpenAPI.Server {
    public struct Variable: Codable, Equatable {
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
        variables = try container.decodeIfPresent([String: Variable].self, forKey: .variables) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(url, forKey: .url)

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        if variables.count > 0 {
            try container.encode(variables, forKey: .variables)
        }
    }
}
