//
//  Parameter.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly

extension OpenAPI.PathItem.Properties {
    public struct Parameter: Equatable {
        public let name: String
        public let parameterLocation: Location
        public let description: String?
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>
        // TODO: serialization rules
        /*
         Serialization Rules
         */

        public typealias Array = [Either<Parameter, JSONReference<OpenAPI.Components, Parameter>>]

        public typealias SchemaProperty = Either<JSONReference<OpenAPI.Components, JSONSchemaObject>, JSONSchemaObject>

        public init(name: String,
                    parameterLocation: Location,
                    schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.deprecated = deprecated
        }
    }
}

extension OpenAPI.PathItem.Properties.Parameter {
    public enum Location: Equatable {
        case query(required: Bool?)
        case header(required: Bool?)
        case path
        case cookie(required: Bool?)
    }
}

// MARK: - Codable

extension OpenAPI.PathItem.Properties.Parameter {
    private enum CodingKeys: String, CodingKey {
        case name
        case parameterLocation = "in"
        case description
        case required
        case deprecated

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

extension OpenAPI.PathItem.Properties.Parameter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool?
        let location: LocationString
        switch parameterLocation {
        case .query(required: let req):
            required = req
            location = .query
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

        try container.encode(required, forKey: .required)

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

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }
    }
}

extension OpenAPI.PathItem.Properties.Parameter: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        let location = try container.decode(LocationString.self, forKey: .parameterLocation)

        switch location {
        case .query:
            parameterLocation = .query(required: required)
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
