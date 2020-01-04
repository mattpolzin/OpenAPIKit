//
//  Parameter.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly
import AnyCodable

extension OpenAPI.PathItem {
    public struct Parameter: Equatable {
        public let name: String
        public let parameterLocation: Location
        public let description: String?
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<Schema, OpenAPI.Content.Map>

        public typealias Array = [Either<Parameter, JSONReference<OpenAPI.Components, Parameter>>]

        public init(name: String,
                    parameterLocation: Location,
                    schemaOrContent: Either<Schema, OpenAPI.Content.Map>,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schema: Schema,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(schema)
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schema: JSONSchema,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(Schema(schema, style: .default(for: parameterLocation)))
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(Schema(schemaReference: schemaReference, style: .default(for: parameterLocation)))
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    content: OpenAPI.Content.Map,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(content)
            self.description = description
            self.deprecated = deprecated
        }

        public var required: Bool { parameterLocation.required }
    }
}

// MARK: `Either` convenience methods
// OpenAPI.PathItem.Array.Element =>
extension Either where A == OpenAPI.PathItem.Parameter, B == JSONReference<OpenAPI.Components, OpenAPI.PathItem.Parameter> {
    public static func parameter(_ parameter: OpenAPI.PathItem.Parameter) -> Self {
        return .a(parameter)
    }

    public static func parameter(
        name: String,
        parameterLocation: OpenAPI.PathItem.Parameter.Location,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false
    ) -> Self {
        return .a(
            .init(
                name: name,
                parameterLocation: parameterLocation,
                schema: schema,
                description: description,
                deprecated: deprecated
            )
        )
    }

    public static func parameter(
        name: String,
        parameterLocation: OpenAPI.PathItem.Parameter.Location,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false
    ) -> Self {
        return .a(
            .init(
                name: name,
                parameterLocation: parameterLocation,
                content: content,
                description: description,
                deprecated: deprecated
            )
        )
    }

    public static func parameter(reference: JSONReference<OpenAPI.Components, OpenAPI.PathItem.Parameter>) -> Self {
        return .b(reference)
    }
}

// OpenAPI.PathItem.SchemaProperty =>
extension Either where A == OpenAPI.PathItem.Parameter.Schema, B == OpenAPI.Content.Map {
    public static func content(_ map: OpenAPI.Content.Map) -> Self {
        return .b(map)
    }

    public static func schema(_ schema: OpenAPI.PathItem.Parameter.Schema) -> Self {
        return .a(schema)
    }
}

// MARK: - Codable

extension OpenAPI.PathItem.Parameter {
    private enum CodingKeys: String, CodingKey {
        case name
        case parameterLocation = "in"
        case description
        case required
        case deprecated
        case allowEmptyValue

        // the following are alternatives
        case content
        case schema
    }

    private enum LocationString: String, Codable {
        case query
        case header
        case path
        case cookie
    }
}

extension OpenAPI.PathItem.Parameter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool
        let location: LocationString
        switch parameterLocation {
        case .query(required: let req, allowEmptyValue: let allowEmptyValue):
            required = req
            location = .query

            if allowEmptyValue {
                try container.encode(allowEmptyValue, forKey: .allowEmptyValue)
            }
        case .header(required: let req):
            required = req
            location = .header
        case .path:
            required = true
            location = .path
        case .cookie(required: let req):
            required = req
            location = .cookie
        }
        try container.encode(location, forKey: .parameterLocation)

        if required {
            try container.encode(required, forKey: .required)
        }

        switch schemaOrContent {
        case .a(let schema):
            try schema.encode(to: encoder, for: parameterLocation)
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

extension OpenAPI.PathItem.Parameter: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        let location = try container.decode(LocationString.self, forKey: .parameterLocation)

        switch location {
        case .query:
            let allowEmptyValue = try container.decodeIfPresent(Bool.self, forKey: .allowEmptyValue) ?? false
            parameterLocation = .query(required: required, allowEmptyValue: allowEmptyValue)
        case .header:
            parameterLocation = .header(required: required)
        case .path:
            if !required {
                throw OpenAPI.DecodingError.unsatisfied(requirement: "positional path parameters must be explicitly set to required.", codingPath: decoder.codingPath)
            }
            parameterLocation = .path
        case .cookie:
            parameterLocation = .cookie(required: required)
        }

        // hacky workaround for Dictionary decoding bug
        let maybeContentDict = try container.decodeIfPresent([String: OpenAPI.Content].self, forKey: .content)
        let maybeContent = maybeContentDict.map { contentDict in
            Dictionary(contentDict.compactMap { contentTypeString, content in
                OpenAPI.ContentType(rawValue: contentTypeString).map { ($0, content) } },
                       uniquingKeysWith: { $1 })
        }

        let maybeSchema: Schema?
        if container.contains(.schema) {
            maybeSchema = try Schema(from: decoder, for: parameterLocation)
        } else {
            maybeSchema = nil
        }

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
