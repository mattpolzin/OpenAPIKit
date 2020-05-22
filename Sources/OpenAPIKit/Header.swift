//
//  Header.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 8/25/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Header Object"
    ///
    /// See [OpenAPI Header Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#header-object).
    public struct Header: Equatable, CodableVendorExtendable {
        public typealias SchemaContext = Parameter.SchemaContext

        public let description: String?
        public let required: Bool
        public let deprecated: Bool // default is false
        /// OpenAPI Spec "schema" or "content", which are mutually exclusive.
        public let schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public typealias Map = OrderedDictionary<String, Either<JSONReference<Header>, Header>>

        public init(
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
            description: String? = nil,
            required: Bool = false,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(
            schema: SchemaContext,
            description: String? = nil,
            required: Bool = false,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemaOrContent = .init(schema)
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(
            schema: JSONSchema,
            description: String? = nil,
            required: Bool = false,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemaOrContent = .init(SchemaContext(schema, style: .default(for: .header)))
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(
            schemaReference: JSONReference<JSONSchema>,
            description: String? = nil,
            required: Bool = false,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemaOrContent = .init(SchemaContext(schemaReference: schemaReference, style: .default(for: .header)))
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(
            content: OpenAPI.Content.Map,
            description: String? = nil,
            required: Bool = false,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schemaOrContent = .init(content)
            self.description = description
            self.required = required
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }
    }
}

// MARK: - Header Convenience
extension OpenAPI.Parameter.SchemaContext {
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

    public static func header(schemaReference: JSONReference<JSONSchema>,
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

    public static func header(schemaReference: JSONReference<JSONSchema>,
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
    internal enum CodingKeys: ExtendableCodingKey {
        case description
        case required
        case deprecated

        // the following are alternatives
        case content
        case schema

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .description,
                .required,
                .deprecated,
                .content,
                .schema
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "description":
                self = .description
            case "required":
                self = .required
            case "deprecated":
                self = .deprecated
            case "content":
                self = .content
            case "schema":
                self = .schema
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .description:
                return "description"
            case .required:
                return "required"
            case .deprecated:
                return "deprecated"
            case .content:
                return "content"
            case .schema:
                return "schema"
            case .extended(let key):
                return key
            }
        }
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

        try container.encodeIfPresent(description, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Header: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false

        let maybeContent = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content)

        let maybeSchema: SchemaContext?
        if container.contains(.schema) {
            maybeSchema = try SchemaContext(from: decoder, for: .header)
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

        vendorExtensions = try Self.extensions(from: decoder)
    }
}
