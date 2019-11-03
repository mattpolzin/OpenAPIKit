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

extension OpenAPI.PathItem.Parameter {
    public struct Schema: Equatable {
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool //defaults to false
        public let schema: Either<JSONReference<OpenAPI.Components, JSONSchema>, JSONSchema>

        public let example: AnyCodable?
        public let examples: OpenAPI.Example.Map?

        public init(_ schema: JSONSchema,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.example = example
            self.examples = nil
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.example = example
            self.examples = nil

            self.explode = style.defaultExplode
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.example = example
            self.examples = nil
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    style: Style,
                    allowReserved: Bool = false,
                    example: AnyCodable? = nil) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.example = example
            self.examples = nil

            self.explode = style.defaultExplode
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
        }

        public init(_ schema: JSONSchema,
                    style: Style,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schema)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))

            self.explode = style.defaultExplode
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    style: Style,
                    explode: Bool,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
        }

        public init(schemaReference: JSONReference<OpenAPI.Components, JSONSchema>,
                    style: Style,
                    allowReserved: Bool = false,
                    examples: OpenAPI.Example.Map?) {
            self.style = style
            self.allowReserved = allowReserved
            self.schema = .init(schemaReference)
            self.examples = examples
            self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))

            self.explode = style.defaultExplode
        }

        public enum Style: String, CaseIterable, Codable {
            case form
            case simple
            case matrix
            case label
            case spaceDelimited
            case pipeDelimited
            case deepObject

            public static func `default`(for location: OpenAPI.PathItem.Parameter.Location) -> Self {
                switch location {
                case .query:
                    return .form
                case .cookie:
                    return .form
                case .path:
                    return .simple
                case .header:
                    return .simple
                }
            }

            internal var defaultExplode: Bool {
                switch self {
                case .form:
                    return true
                default:
                    return false
                }
            }
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

extension OpenAPI.PathItem.Parameter.Schema {
    private enum CodingKeys: String, CodingKey {
        case style
        case explode
        case allowReserved
        case schema

        // the following two are alternatives
        case example
        case examples
    }
}

extension OpenAPI.PathItem.Parameter.Schema {
    public func encode(to encoder: Encoder, for location: OpenAPI.PathItem.Parameter.Location) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if style != Style.default(for: location) {
            try container.encode(style, forKey: .style)
        }

        if explode != style.defaultExplode {
            try container.encode(explode, forKey: .explode)
        }

        if allowReserved != false {
            try container.encode(allowReserved, forKey: .allowReserved)
        }

        try container.encode(schema, forKey: .schema)

        if examples != nil {
            try container.encode(examples, forKey: .examples)
        } else if example != nil {
            try container.encode(example, forKey: .example)
        }
    }
}

extension OpenAPI.PathItem.Parameter.Schema {
    public init(from decoder: Decoder, for location: OpenAPI.PathItem.Parameter.Location) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schema = try container.decode(Either<JSONReference<OpenAPI.Components, JSONSchema>, JSONSchema>.self, forKey: .schema)

        let style = try container.decodeIfPresent(Style.self, forKey: .style) ?? Style.default(for: location)
        self.style = style

        explode = try container.decodeIfPresent(Bool.self, forKey: .explode) ?? style.defaultExplode

        allowReserved = try container.decodeIfPresent(Bool.self, forKey: .allowReserved) ?? false

        if container.contains(.example) {
            example = try container.decode(AnyCodable.self, forKey: .example)
            examples = nil
        } else {
            let examplesMap = try container.decodeIfPresent(OpenAPI.Example.Map.self, forKey: .examples)
            examples = examplesMap
            example = examplesMap.flatMap(OpenAPI.Content.firstExample(from:))
        }
    }
}
