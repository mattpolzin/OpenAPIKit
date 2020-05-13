//
//  Discriminator.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Disciminator Object"
    /// 
    /// See [OpenAPI Discriminator Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#discriminator-object).
    public struct Discriminator: Equatable {
        public let propertyName: String
        public let mapping: [String: String]?

        public init(propertyName: String,
                    mapping: [String: String]? = nil) {
            self.propertyName = propertyName
            self.mapping = mapping
        }
    }
}

// MARK: - Codable

extension OpenAPI.Discriminator: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(propertyName, forKey: .propertyName)
        try container.encodeIfPresent(mapping, forKey: .mapping)
    }
}

extension OpenAPI.Discriminator: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        propertyName = try container.decode(String.self, forKey: .propertyName)
        mapping = try container.decodeIfPresent([String: String].self, forKey: .mapping)
    }
}

extension OpenAPI.Discriminator {
    private enum CodingKeys: String, CodingKey {
        case propertyName
        case mapping
    }
}
