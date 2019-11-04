//
//  Header.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation
import Poly

extension OpenAPI {
    public struct Header: Equatable {
        public let description: String?
        public let required: Bool
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>

        public typealias Map = [String: Either<Header, JSONReference<OpenAPI.Components, Header>>]

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
            // Hack to work around Dictionary encoding
            // itself as an array in this case:
            let stringKeyedDict = Dictionary(
                contentMap.map { ($0.key.rawValue, $0.value) },
                uniquingKeysWith: { $1 }
            )
            try container.encode(stringKeyedDict, forKey: .content)
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

        // hacky workaround for Dictionary decoding bug
        let maybeContentDict = try container.decodeIfPresent([String: OpenAPI.Content].self, forKey: .content)
        let maybeContent = maybeContentDict.map { contentDict in
            Dictionary(contentDict.compactMap { contentTypeString, content in
                OpenAPI.ContentType(rawValue: contentTypeString).map { ($0, content) } },
                       uniquingKeysWith: { $1 })
        }

        let maybeSchema = try container.decodeIfPresent(SchemaProperty.self, forKey: .schema)

        switch (maybeContent, maybeSchema) {
        case (let content?, _):
            schemaOrContent = .init(content)
        case (_, let schema?):
            schemaOrContent = .init(schema)
        default:
            throw OpenAPI.DecodingError.unsatisfied(requirement: "A single path parameter must specify one but not both 'content' and 'schema'.", codingPath: decoder.codingPath)
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false
    }
}
