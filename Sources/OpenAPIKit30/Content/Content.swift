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
    /// See [OpenAPI Media Type Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#media-type-object).
    public struct Content: Equatable, CodableVendorExtendable {
        public var schema: Either<JSONReference<JSONSchema>, JSONSchema>?
        public var example: AnyCodable?
        public var examples: Example.Map?
        public var encoding: OrderedDictionary<String, Encoding>?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a single example.
        public init(
            schema: Either<JSONReference<JSONSchema>, JSONSchema>?,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.example = example
            self.examples = nil
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }

        /// Create `Content` with a reference to a schema and optionally
        /// provide a single example.
        public init(
            schemaReference: JSONReference<JSONSchema>,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .init(schemaReference)
            self.example = example
            self.examples = nil
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }

        /// Create `Content` with a schema and optionally provide a single
        /// example.
        public init(
            schema: JSONSchema,
            example: AnyCodable? = nil,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .init(schema)
            self.example = example
            self.examples = nil
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }

        /// Create `Content` with a schema, a reference to a schema, or no
        /// schema at all and optionally provide a map of examples.
        public init(
            schema: Either<JSONReference<JSONSchema>, JSONSchema>?,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = schema
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }

        /// Create `Content` with a reference to a schema and optionally
        /// provide a map of examples.
        public init(
            schemaReference: JSONReference<JSONSchema>,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .init(schemaReference)
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }

        /// Create `Content` with a schema and optionally provide a map
        /// of examples.
        public init(
            schema: JSONSchema,
            examples: Example.Map?,
            encoding: OrderedDictionary<String, Encoding>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.schema = .init(schema)
            self.examples = examples
            self.example = examples.flatMap(Self.firstExample(from:))
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }
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
            .compactMap { $0.value.exampleValue?.value.codableValue }
            .first
    }

    /// Pulls the first example found in the example dictionary
    /// given.
    internal static func firstExample(from exampleDict: OrderedDictionary<String, OpenAPI.Example>) -> AnyCodable? {
        return exampleDict
        .lazy
        .compactMap { $0.value.value.codableValue }
        .first
    }
}

// MARK: - Codable

extension OpenAPI.Content: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(schema, forKey: .schema)

        // only encode `examples` if non-nil,
        // otherwise encode `example` if non-nil
        if examples != nil {
            try container.encode(examples, forKey: .examples)
        } else if example != nil {
            try container.encode(example, forKey: .example)
        }

        try container.encodeIfPresent(encoding, forKey: .encoding)

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Content: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard !(container.contains(.examples) && container.contains(.example)) else {
            throw InconsistencyError(
                subjectName: "Example and Examples",
                details: "Only one of `example` and `examples` is allowed in the Media Type Object (`OpenAPI.Content`).",
                codingPath: container.codingPath
            )
        }

        schema = try container.decodeIfPresent(Either<JSONReference<JSONSchema>, JSONSchema>.self, forKey: .schema)

        encoding = try container.decodeIfPresent(OrderedDictionary<String, Encoding>.self, forKey: .encoding)

        if container.contains(.example) {
            example = try container.decode(AnyCodable.self, forKey: .example)
            examples = nil
        } else {
            let examplesMap = try container.decodeIfPresent(OpenAPI.Example.Map.self, forKey: .examples)
            examples = examplesMap
            example = examplesMap.flatMap(Self.firstExample(from:))
        }

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Content {
    internal enum CodingKeys: ExtendableCodingKey {
        case schema
        case example  // `example` and `examples` are mutually exclusive
        case examples // `example` and `examples` are mutually exclusive
        case encoding
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [.schema, .example, .examples, .encoding]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "schema":
                self = .schema
            case "example":
                self = .example
            case "examples":
                self = .examples
            case "encoding":
                self = .encoding
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .schema:
                return "schema"
            case .example:
                return "example"
            case .examples:
                return "examples"
            case .encoding:
                return "encoding"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Content: Validatable {}
