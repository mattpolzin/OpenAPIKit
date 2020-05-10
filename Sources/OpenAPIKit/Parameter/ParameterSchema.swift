//
//  ParameterSchema.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI.Parameter {
    /// OpenAPI Spec "Parameter Object" schema and style configuration.
    ///
    /// See [OpenAPI Parameter Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#parameter-object)
    /// and [OpenAPI Style Values](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#style-values).
    public struct SchemaContext: Equatable {
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool //defaults to false
        public let schema: Either<JSONReference<JSONSchema>, JSONSchema>

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

        public init(schemaReference: JSONReference<JSONSchema>,
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

        public init(schemaReference: JSONReference<JSONSchema>,
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

        public init(schemaReference: JSONReference<JSONSchema>,
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

        public init(schemaReference: JSONReference<JSONSchema>,
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

    }
}

extension OpenAPI.Parameter.SchemaContext {
    public enum Style: String, CaseIterable, Codable {
        case form
        case simple
        case matrix
        case label
        case spaceDelimited
        case pipeDelimited
        case deepObject

        /// Get the default `Style` for the given location
        /// per the OpenAPI Specification.
        ///
        /// See the `style` fixed field under
        /// [OpenAPI Parameter Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#parameter-object).
        public static func `default`(for location: OpenAPI.Parameter.Context) -> Self {
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

// MARK: - Codable
extension OpenAPI.Parameter.SchemaContext {
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

extension OpenAPI.Parameter.SchemaContext {
    public func encode(to encoder: Encoder, for location: OpenAPI.Parameter.Context) throws {
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

extension OpenAPI.Parameter.SchemaContext {
    public init(from decoder: Decoder, for location: OpenAPI.Parameter.Context) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schema = try container.decode(Either<JSONReference<JSONSchema>, JSONSchema>.self, forKey: .schema)

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
