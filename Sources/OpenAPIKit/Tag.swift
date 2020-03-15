//
//  Tag.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation

extension OpenAPI {
    public struct Tag: Equatable {
        public let name: String
        public let description: String?
        public let externalDocs: ExternalDocumentation?

        public init(name: String,
                    description: String? = nil,
                    externalDocs: ExternalDocumentation? = nil) {
            self.name = name
            self.description = description
            self.externalDocs = externalDocs
        }
    }
}

extension OpenAPI.Tag: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(name: stringLiteral)
    }
}

// MARK: - Codable

extension OpenAPI.Tag: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        try externalDocs.encodeIfNotNil(to: &container, forKey: .externalDocs)
    }
}

extension OpenAPI.Tag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)
    }
}

extension OpenAPI.Tag {
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case externalDocs
    }
}
