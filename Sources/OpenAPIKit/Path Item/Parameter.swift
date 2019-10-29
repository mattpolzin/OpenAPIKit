//
//  Parameter.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly

extension OpenAPI.PathItem {
    public struct Parameter: Equatable {
        public let name: String
        public let parameterLocation: Location
        public let description: String?
        public let deprecated: Bool // default is false
        public let schemaOrContent: Either<SchemaProperty, OpenAPI.Content.Map>

        public typealias Array = [Either<Parameter, JSONReference<OpenAPI.Components, Parameter>>]

        public typealias SchemaProperty = Either<JSONReference<OpenAPI.Components, JSONSchema>, JSONSchema>

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

        public init(name: String,
                    parameterLocation: Location,
                    schema: JSONSchema,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(.init(schema))
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
            self.schemaOrContent = .init(.init(schemaReference))
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

        public var required: Bool {
            switch parameterLocation {
            case .query(required: let required, allowEmptyValue: _),
                 .header(required: let required),
                 .cookie(required: let required):
                return required
            case .path:
                return true
            }
        }
    }
}

extension OpenAPI.PathItem.Parameter {
    public enum Location: Equatable {
        case query(required: Bool, allowEmptyValue: Bool)
        case header(required: Bool)
        case path
        case cookie(required: Bool)

        public static func query(required: Bool) -> Location { return .query(required: required, allowEmptyValue: false) }

        public static func query(allowEmptyValue: Bool) -> Location { return .query(required: false, allowEmptyValue: allowEmptyValue) }

        public static var query: Location { return .query(required: false, allowEmptyValue: false) }

        public static var header: Location { return .header(required: false) }

        public static var cookie: Location { return .cookie(required: false) }

        public var isQuery: Bool {
            guard case .query = self else {
                return false
            }
            return true
        }

        public var isHeader: Bool {
            guard case .header = self else {
                return false
            }
            return true
        }

        public var isPath: Bool { return self == .path }

        public var isCookie: Bool {
            guard case .cookie = self else {
                return false
            }
            return true
        }
    }
}

// MARK: `Either` convenience methods
// OpenAPI.PathItem.Array.Element =>
extension Either where A == OpenAPI.PathItem.Parameter, B == JSONReference<OpenAPI.Components, OpenAPI.PathItem.Parameter> {
    public static func parameter(_ parameter: OpenAPI.PathItem.Parameter) -> Self {
        return .a(parameter)
    }

    public static func parameter(reference: JSONReference<OpenAPI.Components, OpenAPI.PathItem.Parameter>) -> Self {
        return .b(reference)
    }
}

// OpenAPI.PathItem.SchemaProperty =>
extension Either where A == OpenAPI.PathItem.Parameter.SchemaProperty, B == OpenAPI.Content.Map {
    public static func content(_ map: OpenAPI.Content.Map) -> Self {
        return .b(map)
    }

    public static func schema(_ schema: JSONSchema) -> Self {
        return .a(.b(schema))
    }

    public static func schema(reference: JSONReference<OpenAPI.Components, JSONSchema>) -> Self {
        return .a(.a(reference))
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
