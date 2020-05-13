//
//  Server.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Server Object"
    ///
    /// See [OpenAPI Server Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#server-object).
    public struct Server: Equatable, CodableVendorExtendable {
        public let url: URL
        public let description: String?
        public let variables: OrderedDictionary<String, Variable>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(url: URL,
                    description: String? = nil,
                    variables: OrderedDictionary<String, Variable> = [:],
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.url = url
            self.description = description
            self.variables = variables
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Server {
    /// OpenAPI Spec "Server Variable Object"
    ///
    /// See [OpenAPI Server Variable Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#server-variable-object).
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

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Server: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(url, forKey: .url)

        try container.encodeIfPresent(description, forKey: .description)

        if variables.count > 0 {
            try container.encode(variables, forKey: .variables)
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Server {
    internal enum CodingKeys: ExtendableCodingKey {
        case url
        case description
        case variables

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .url,
                .description,
                .variables
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "url":
                self = .url
            case "description":
                self = .description
            case "variables":
                self = .variables
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String {
            switch self {
            case .url:
                return "url"
            case .description:
                return "description"
            case .variables:
                return "variables"
            case .extended(let key):
                return key
            }
        }

        var intValue: Int? {
            return nil
        }
    }
}

extension OpenAPI.Server.Variable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(`enum`, forKey: .enum)

        try container.encode(`default`, forKey: .default)

        try container.encodeIfPresent(description, forKey: .description)
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
