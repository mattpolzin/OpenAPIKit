//
//  Header.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import Poly
import OrderedDictionary

extension OpenAPI {
    public struct Header: Equatable {
        public let description: String?
        public let required: Bool
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>

        public typealias Map = OrderedDictionary<String, Either<JSONReference<OpenAPI.Components, Header>, Header>>

        public typealias SchemaProperty = Either<JSONReference<OpenAPI.Components, JSONSchema>, JSONSchema>

        public init(schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(schema: JSONSchema,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(.init(schema))
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(.init(schemaReference))
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(content: OpenAPI.Content.Map,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(content)
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }
    }
}

// MARK: - Codable

extension OpenAPI.Header {
    private enum CodingKeys: String, CodingKey {
        case description
        case required
        case deprecated

        // the following are alternatives
        case content
        case schema
    }
}

extension OpenAPI.Header: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if required {
            try container.encode(required, forKey: .required)
        }

        switch schemaOrContent {
        case .a(let schema):
            try container.encode(schema, forKey: .schema)
        case .b(let contentMap):
            try container.encode(contentMap, forKey: .content)
        }

        try description.encodeIfNotNil(to: &container, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }
    }
}

extension OpenAPI.Header: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false

        let maybeContent = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content)

        let maybeSchema = try container.decodeIfPresent(SchemaProperty.self, forKey: .schema)

        switch (maybeContent, maybeSchema) {
        case (let content?, nil):
            schemaOrContent = .init(content)
        case (nil, let schema?):
            schemaOrContent = .init(schema)
        default:
            throw OpenAPI.DecodingError.unsatisfied(requirement: "A single path parameter must specify one but not both 'content' and 'schema'.", codingPath: decoder.codingPath)
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
    }
}
