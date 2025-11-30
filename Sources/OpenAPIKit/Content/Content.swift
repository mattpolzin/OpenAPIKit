//
//  Content.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 7/4/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Media Type Object"
    /// 
    /// See [OpenAPI Media Type Object](https://spec.openapis.org/oas/v3.1.1.html#media-type-object).
    public struct Content: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        /// A schema describing the complete content of the request, response,
        /// parameter, or header.
        public var schema: JSONSchema?

        /// A schema describing each item within a sequential media type.
        public var itemSchema: JSONSchema?

        public var example: AnyCodable?
        public var examples: Example.Map?

        /// Provide either a map of encodings or some combination of prefix-
        /// and item- positional encodings.
        ///
        /// If the OpenAPI Document specifies the 'encoding' key (a map)
        /// then this property will be set to its first case. If the OpenAPI
        /// Document specifies either or both of the 'prefixEncoding' and
        /// 'itemEncoding' keys, this property will be set to its second case.
        ///
        /// You can access the encoding map (OAS 'encoding' property) as the `Content`
        /// type's `encodingMap` as well.
        ///
        /// You can access the positional encoding (OAS 'prefixEncoding' and
        /// `itemEncoding` properties) as the `Content` type's `prefixEncoding`
        /// and `itemEncoding` properties.
        public var encoding: Either<OrderedDictionary<String, Encoding>, PositionalEncoding>?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        /// The encoding of this `Content` (Media Type Object) if it is a map
        /// from property names to encoding information.
        ///
        /// This property gets modified as part of the `encoding` property.
        ///
        /// See also the `prefixEncoding` and `itemEncoding` properties.
        public var encodingMap: OrderedDictionary<String, Encoding>? { encoding?.a }

        /// The positional prefix-encoding for this `Content` (Media Type
        /// Object) if set.
        ///
        /// This property gets modified as part of the `encoding` property.
        ///
        /// See also the `itemEncoding` and `encodingMap` properties.
        public var prefixEncoding: [Encoding]? { encoding?.b?.prefixEncoding }

        /// The positional item-encoding for this `Content` (Media Type
        /// Object) if set.
        ///
        /// This property gets modified as part of the `encoding` property.
        ///
        /// See also the `prefixEncoding` and `encodingMap` properties.
        public var itemEncoding: Encoding? { encoding?.b?.itemEncoding }

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a single example.
        public init(
            schema: JSONSchema?,
            itemSchema: JSONSchema? = nil,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.itemSchema = itemSchema
            self.example = example
            self.examples = nil
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a single example.
        public init(
            schema: JSONSchema?,
            itemSchema: JSONSchema? = nil,
            example: AnyCodable? = nil,
            prefixEncoding: [Encoding] = [],
            itemEncoding: Encoding? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.itemSchema = itemSchema
            self.example = example
            self.examples = nil
            if itemEncoding != nil || prefixEncoding != [] {
                self.encoding = .b(.init(prefixEncoding: prefixEncoding, itemEncoding: itemEncoding))
            } else {
                self.encoding = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: prefixEncoding, itemEncoding: itemEncoding)
        }

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a single example.
        public init(
            itemSchema: JSONSchema?,
            example: AnyCodable? = nil,
            prefixEncoding: [Encoding] = [],
            itemEncoding: Encoding? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = nil
            self.itemSchema = itemSchema
            self.example = example
            self.examples = nil
            if itemEncoding != nil || prefixEncoding != [] {
                self.encoding = .b(.init(prefixEncoding: prefixEncoding, itemEncoding: itemEncoding))
            } else {
                self.encoding = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: prefixEncoding, itemEncoding: itemEncoding)
        }

        /// Create `Content` with a reference to a schema and optionally
        /// provide a single example.
        public init(
            schemaReference: OpenAPI.Reference<JSONSchema>,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .reference(schemaReference.jsonReference, description: schemaReference.description)
            self.example = example
            self.examples = nil
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema and optionally provide a single
        /// example.
        public init(
            schema: JSONSchema,
            itemSchema: JSONSchema? = nil,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.itemSchema = itemSchema
            self.example = example
            self.examples = nil
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a map of examples.
        public init(
            schema: Either<OpenAPI.Reference<JSONSchema>, JSONSchema>?,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            switch schema {
            case .none:
                self.schema = nil

            case .some(.a(let reference)):
                self.schema = .reference(reference.jsonReference)

            case .some(.b(let schemaValue)):
                self.schema = schemaValue
            }
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a reference to a schema and optionally
        /// provide a map of examples.
        public init(
            schemaReference: OpenAPI.Reference<JSONSchema>,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .reference(schemaReference.jsonReference)
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema and optionally provide a map
        /// of examples.
        public init(
            schema: JSONSchema,
            itemSchema: JSONSchema? = nil,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.itemSchema = itemSchema
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema and optionally provide a map
        /// of examples.
        public init(
            itemSchema: JSONSchema?,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = nil
            self.itemSchema = itemSchema
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding.map(Either.a)
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: nil, itemEncoding: nil)
        }

        /// Create `Content` with a schema and optionally provide a map
        /// of examples.
        public init(
            itemSchema: JSONSchema? = nil,
            examples: Example.Map?,
            prefixEncoding: [Encoding] = [],
            itemEncoding: Encoding? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = nil
            self.itemSchema = itemSchema
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            if itemEncoding != nil || prefixEncoding != [] {
                self.encoding = .b(.init(prefixEncoding: prefixEncoding, itemEncoding: itemEncoding))
            } else {
                self.encoding = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: prefixEncoding, itemEncoding: itemEncoding)
        }
    }
}

extension OpenAPI.Content: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.schema == rhs.schema
        && lhs.itemSchema == rhs.itemSchema
        && lhs.example == rhs.example
        && lhs.examples == rhs.examples
        && lhs.encoding == rhs.encoding
        && lhs.vendorExtensions == rhs.vendorExtensions
    }
}


extension OpenAPI.Content {
    fileprivate static func conditionalWarnings(itemSchema: JSONSchema?, prefixEncoding: [Encoding]?, itemEncoding: Encoding?) -> [(any Condition, OpenAPI.Warning)] {
        let itemSchemaWarning: (any Condition, OpenAPI.Warning)? =
            itemSchema.map { _ in
                OpenAPI.Document.ConditionalWarnings.version(lessThan: .v3_2_0, doesNotSupport: "The Media Type Object itemSchema property")
            }
        let prefixEncodingWarning : (any Condition, OpenAPI.Warning)? =
            prefixEncoding.flatMap { prefixEncoding in
                if prefixEncoding == [] {
                    nil
                } else {
                    OpenAPI.Document.ConditionalWarnings.version(lessThan: .v3_2_0, doesNotSupport: "The Media Type Object prefixEncoding property")
                }
            }

        let itemEncodingWarning : (any Condition, OpenAPI.Warning)? =
            itemEncoding.map { _ in
                OpenAPI.Document.ConditionalWarnings.version(lessThan: .v3_2_0, doesNotSupport: "The Media Type Object itemEncoding property")
            }

        return [
            itemSchemaWarning,
            prefixEncodingWarning,
            itemEncodingWarning
        ].compactMap { $0 }
    }
}

extension OpenAPI.Content {
    public typealias Map = OrderedDictionary<OpenAPI.ContentType, OpenAPI.Content>
}

extension OpenAPI.Content {
    /// Pulls the first (inlined, not referenced) example found
    /// in the example dictionary given.
    ///
    /// Operates on a dictionary with values that may be either
    /// an Example or a reference to and example.
    internal static func firstExample(from exampleDict: OpenAPI.Example.Map) -> AnyCodable? {
        return exampleDict
            .lazy
            .compactMap { $0.value.exampleValue?.value?.codableValue }
            .first
    }

    /// Pulls the first example found in the example dictionary
    /// given.
    internal static func firstExample(from exampleDict: OrderedDictionary<String, OpenAPI.Example>) -> AnyCodable? {
        return exampleDict
        .lazy
        .compactMap { $0.value.value?.codableValue }
        .first
    }
}

// MARK: - Codable

extension OpenAPI.Content: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(schema, forKey: .schema)
        try container.encodeIfPresent(itemSchema, forKey: .itemSchema)

        // only encode `examples` if non-nil,
        // otherwise encode `example` if non-nil
        if examples != nil {
            try container.encode(examples, forKey: .examples)
        } else if example != nil {
            try container.encode(example, forKey: .example)
        }

        if let encoding {
            switch encoding {
            case .a(let encoding):
                try container.encode(encoding, forKey: .encoding)

            case .b(let positionalEncoding):
                if !positionalEncoding.prefixEncoding.isEmpty {
                    try container.encode(positionalEncoding.prefixEncoding, forKey: .prefixEncoding)
                }
                try container.encodeIfPresent(positionalEncoding.itemEncoding, forKey: .itemEncoding)
            }
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Content: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard !(container.contains(.examples) && container.contains(.example)) else {
            throw GenericError(
                subjectName: "Example and Examples",
                details: "Only one of `example` and `examples` is allowed in the Media Type Object (`OpenAPI.Content`).",
                codingPath: container.codingPath
            )
        }

        guard !(container.contains(.encoding) && (container.contains(.prefixEncoding) || container.contains(.itemEncoding))) else {
            throw GenericError(
                subjectName: "Encoding and Positional Encoding",
                details: "If `prefixEncoding` or `itemEncoding` are specified then `encoding` is not allowed in the Media Type Object (`OpenAPI.Content`).",
                codingPath: container.codingPath
            )
        }

        schema = try container.decodeIfPresent(JSONSchema.self, forKey: .schema)
        itemSchema = try container.decodeIfPresent(JSONSchema.self, forKey: .itemSchema)

        var maybePrefixEncoding: [Encoding]? = nil
        var maybeItemEncoding: Encoding? = nil
        if container.contains(.encoding) {
            encoding = .a(try container.decode(OrderedDictionary<String, Encoding>.self, forKey: .encoding))
        } else if container.contains(.prefixEncoding) || container.contains(.itemEncoding) {
            let prefixEncoding = try container.decodeIfPresent([Encoding].self, forKey: .prefixEncoding) ?? []
            let itemEncoding = try container.decodeIfPresent(Encoding.self, forKey: .itemEncoding)

            maybePrefixEncoding = prefixEncoding
            maybeItemEncoding = itemEncoding

            encoding = .b(.init(prefixEncoding: prefixEncoding, itemEncoding: itemEncoding))
        } else {
            encoding = nil
        }

        if container.contains(.example) {
            example = try container.decode(AnyCodable.self, forKey: .example)
            examples = nil
        } else {
            let examplesMap = try container.decodeIfPresent(OpenAPI.Example.Map.self, forKey: .examples)
            examples = examplesMap
            example = examplesMap.flatMap(Self.firstExample(from:))
        }

        vendorExtensions = try Self.extensions(from: decoder)

        conditionalWarnings = Self.conditionalWarnings(itemSchema: itemSchema, prefixEncoding: maybePrefixEncoding, itemEncoding: maybeItemEncoding)
    }
}

extension OpenAPI.Content {
    internal enum CodingKeys: ExtendableCodingKey {
        case schema
        case itemSchema
        case example  // `example` and `examples` are mutually exclusive
        case examples // `example` and `examples` are mutually exclusive
        case encoding
        case itemEncoding
        case prefixEncoding
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .schema,
                .itemSchema,
                .example,
                .examples,
                .encoding,
                .itemEncoding,
                .prefixEncoding
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "schema":
                self = .schema
            case "itemSchema":
                self = .itemSchema
            case "example":
                self = .example
            case "examples":
                self = .examples
            case "encoding":
                self = .encoding
            case "itemEncoding":
                self = .itemEncoding
            case "prefixEncoding":
                self = .prefixEncoding
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .schema:
                return "schema"
            case .itemSchema:
                return "itemSchema"
            case .example:
                return "example"
            case .examples:
                return "examples"
            case .encoding:
                return "encoding"
            case .itemEncoding:
                return "itemEncoding"
            case .prefixEncoding:
                return "prefixEncoding"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Content: Validatable {}
