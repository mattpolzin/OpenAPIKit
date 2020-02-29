//
//  Header.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import Poly
import OrderedDictionary
import AnyCodable

extension OpenAPI {
    public struct Header: Equatable {
        public typealias Schema = PathItem.Parameter.Schema

        public let description: String?
        public let required: Bool
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<Schema, OpenAPI.Content.Map>

        public typealias Map = OrderedDictionary<String, Either<JSONReference<OpenAPI.Components, Header>, Header>>

        public init(schemaOrContent: Either<Schema, OpenAPI.Content.Map>,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(schema: Schema,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(schema)
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(schema: JSONSchema,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(Schema(schema, style: .default(for: .header)))
            self.description = description
            self.required = required
            self.deprecated = deprecated
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    description: String? = nil,
                    required: Bool = false,
                    deprecated: Bool = false) {
            self.schemaOrContent = .init(Schema(schemaReference: schemaReference, style: .default(for: .header)))
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

// MARK: - Header Convenience
extension OpenAPI.PathItem.Parameter.Schema {
    public static func header(_ schema: JSONSchema,
                              allowReserved: Bool = false,
                              example: AnyCodable? = nil) -> Self {
        return .init(
            schema,
            style: .default(for: .header),
            allowReserved: allowReserved,
            example: example
        )
    }

    public static func header(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                              allowReserved: Bool = false,
                              example: AnyCodable? = nil) -> Self {
        return .init(
            schemaReference: schemaReference,
            style: .default(for: .header),
            allowReserved: allowReserved,
            example: example
        )
    }

    public static func header(_ schema: JSONSchema,
                              allowReserved: Bool = false,
                              examples: OpenAPI.Example.Map?) -> Self {
        return .init(
            schema,
            style: .default(for: .header),
            allowReserved: allowReserved,
            examples: examples
        )
    }

    public static func header(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                              allowReserved: Bool = false,
                              examples: OpenAPI.Example.Map?) -> Self {
        return .init(
            schemaReference: schemaReference,
            style: .default(for: .header),
            allowReserved: allowReserved,
            examples: examples
        )
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
            try schema.encode(to: encoder, for: .header)
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

        let maybeSchema: Schema?
        if container.contains(.schema) {
            maybeSchema = try Schema(from: decoder, for: .header)
        } else {
            maybeSchema = nil
        }

        switch (maybeContent, maybeSchema) {
        case (let content?, nil):
            schemaOrContent = .init(content)
        case (nil, let schema?):
            schemaOrContent = .init(schema)
        default:
            throw InconsistencyError(
                subjectName: "Header",
                details: "A single path parameter must specify one but not both `content` and `schema`",
                codingPath: decoder.codingPath
            )
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
    }
}
