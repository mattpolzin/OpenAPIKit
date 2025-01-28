//
//  JSONSchemaContext.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

// MARK: - Core Context

/// A schema context stores information about a schema.
/// All schemas can have the contextual information in
/// this protocol.
public protocol JSONSchemaContext: Sendable {
    /// The format of the schema as a string value.
    ///
    /// This can be set even when a schema type has
    /// not be specified. If a type has been specified,
    /// a type-safe format can be used and retrieved
    /// via the `jsonTypeFormat` property.
    var formatString: String? { get }

    /// `true` if values for this schema are required, `false` if they
    /// are optional (and can therefore be omitted from request/response data).
    ///
    /// - Important: Required/optional are distinct from the concept of nullability.
    ///
    ///     **Nullability:** Whether or not a value can be  `null`.
    ///
    ///     **Optionality:** Whether or not a key/value can be entirely
    ///         omitted from request/response data.
    var required: Bool { get }

    /// `true` if values for this schema can be `null`.
    ///
    /// - Important: This is distinct from the concept of optionality.
    ///
    ///     **Nullability:** Whether or not a value can be  `null`.
    ///
    ///     **Optionality:** Whether or not a key/value can be entirely
    ///         omitted from request/response data.
    var nullable: Bool { get }

    /// Get the title, if specified. If unspecified, returns `nil`.
    var title: String? { get }

    /// Get the description, if specified. If unspecified, returns `nil`.
    var description: String? { get }

    /// An object used to discriminate upon the options for a child object's
    /// schema in a polymorphic context.
    ///
    /// Discriminators are only applicable when used in conjunction with
    /// `allOf`, `anyOf`, or `oneOf`.
    ///
    /// Still, they need to be supported on the
    /// `JSONSchema.Context` (which is not used with those three special
    /// schema types) because the specification states that a discriminator can
    /// be placed on a parent object (one level up from an `allOf`, `anyOf`,
    /// or `oneOf`) as a way to reduce redundancy.
    ///
    /// See [OpenAPI Discriminator Object](https://spec.openapis.org/oas/v3.1.1.html#discriminator-object).
    var discriminator: OpenAPI.Discriminator? { get }

    /// Get the external docs, if specified. If unspecified, returns `nil`.
    var externalDocs: OpenAPI.ExternalDocumentation? { get }

    /// The OpenAPI spec calls this "enum"
    ///
    /// If not specified, it is assumed that any
    /// value of the given format is allowed.
    /// NOTE: I would like the array of allowed
    /// values to have the type `Format.SwiftType`
    /// but this is not tractable because I also
    /// want to be able to automatically turn any
    /// Swift type that will get _encoded as
    /// something compatible with_ `Format.SwiftType`
    /// into an allowed value.
    var allowedValues: [AnyCodable]? { get }

    /// The OpenAPI spec calls this "default"
    ///
    /// If specified, this value indicates the value the
    /// property will take on if no value is explicitly given
    /// by the client.
    /// NOTE: I would like the default value to have
    /// the type `Format.SwiftType` but this is not
    /// tractable because I also want to be able to
    /// automatically turn any Swift type that will get
    /// _encoded as something compatible with_
    /// `Format.SwiftType` into a default.
    var defaultValue: AnyCodable? { get }

    /// Get examples of values fitting the schema.
    var examples: [AnyCodable] { get }

    /// A schema is "inferred" if it was not actually parsed as a JSON Schema but rather
    /// inferred to exist based on surroundings.
    ///
    /// The only currently known case of this is when we parse a `requried` entry in an
    /// object and that object has no property with the same name as the requirement.
    /// We _infer_ that there is a property by that name (even if only when combined with
    /// another schema elsewhere via e.g. `allOf`). This inferred schema has no properties
    /// except for being required; it can be differentiated from a schema that was explicitly
    /// given in the parsed JSON Schema to have no properties via this internal `_inferred`
    /// boolean.
    ///
    /// This is a non-breaking way to tracking such properties, but a breaking change in the
    /// future might very well represent this more elegantly. For example, maybe a requirement
    /// without a property definition is not a .fragment schema but rather a new case in that
    /// enum.
    var inferred: Bool { get }

    /// `true` if this schema can only be read from and is therefore
    /// unsupported for request data.
    var readOnly: Bool { get }

    /// `true` if this schema can only be written to and is therefore
    /// unavailable in response data.
    var writeOnly: Bool { get }

    /// `true` if this schema is deprecated, `false` otherwise.
    var deprecated: Bool { get }

    /// An anchor, if the schema defines one.
    /// See [Defining location-independent identifiers](https://json-schema.org/draft/2020-12/json-schema-core#name-defining-location-independe)
    var anchor: String? { get }

    /// A dynamic anchor, if the schema defines one.
    /// See [Dynamic References with "$dynamicRef"](https://json-schema.org/draft/2020-12/json-schema-core#name-dynamic-references-with-dyn)
    var dynamicAnchor: String? { get }

    /// Vendor Extensions (a.k.a. Specification Extensions) for the schema
    var vendorExtensions: [String: AnyCodable] { get }
}

extension JSONSchema {
    /// The context that applies to all schemas.
    public struct CoreContext<Format: OpenAPIFormat>: JSONSchemaContext, HasWarnings {
        public let warnings: [OpenAPI.Warning]

        public let format: Format
        public let required: Bool // default true
        public let nullable: Bool // default false

        let _permissions: Permissions? // default `.readWrite`
        let _deprecated: Bool? // default false

        public let title: String?
        public let description: String?
        public let externalDocs: OpenAPI.ExternalDocumentation?

        public let discriminator: OpenAPI.Discriminator?

        public let allowedValues: [AnyCodable]?
        public let defaultValue: AnyCodable?

        /// One or more examples of values fitting the schema. Note that OpenAPI 3.1 supports
        /// both `examples` (via the JSON Schema specification) and also `example` which
        /// comes from OpenAPI 3.0 and is now deprecated. Because the latter is deprecated,
        /// `example` in an OpenAPI document will be parsed as a single-element `examples`
        /// property of a schema. It will be encoded as `examples` (so there is no way to output
        /// the deprecated `example` property from OpenAPIKit).
        ///
        /// An empty examples array is omitted from encoding.
        public let examples: [AnyCodable]

        /// An anchor, if the schema defines one.
        public let anchor: String?

        /// A dynamic anchor, if the schema defines one.
        public let dynamicAnchor: String?

        /// A list of schema-local definitions.
        public let defs: OrderedDictionary<String, JSONSchema>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String : AnyCodable]

        /// A schema is "inferred" if it was not actually parsed as a JSON Schema but rather
        /// inferred to exist based on surroundings.
        ///
        /// The only currently known case of this is when we parse a `requried` entry in an
        /// object and that object has no property with the same name as the requirement.
        /// We _infer_ that there is a property by that name (even if only when combined with
        /// another schema elsewhere via e.g. `allOf`). This inferred schema has no properties
        /// except for being required; it can be differentiated from a schema that was explicitly
        /// given in the parsed JSON Schema to have no properties via this internal `_inferred`
        /// boolean.
        ///
        /// This is a non-breaking way to tracking such properties, but a breaking change in the
        /// future might very well represent this more elegantly. For example, maybe a requirement
        /// without a property definition is not a .fragment schema but rather a new case in that
        /// enum.
        public let inferred: Bool

        public var permissions: Permissions { _permissions ?? .readWrite}
        public var deprecated: Bool { _deprecated ?? false }

        public var formatString: String? { format.rawValue }

        public var readOnly: Bool { permissions == .readOnly }
        public var writeOnly: Bool { permissions == .writeOnly }

        public var isEmpty: Bool {
            return format == .unspecified
                && description == nil
                && discriminator == nil
                && title == nil
                && _deprecated == nil
                && externalDocs == nil
                && allowedValues == nil
                && defaultValue == nil
                && examples.isEmpty
                && _permissions == nil
        }

        /// Create a schema core context.
        ///
        /// NOTE that the `_inferred` parameter has semantics specific to
        ///      decoding schemas and you almost certaintly do not want
        ///      to set it unless you are carrying forward the `inferred`
        ///      property of another core context.
        public init(
            format: Format = .unspecified,
            required: Bool = true,
            nullable: Bool = false,
            permissions: Permissions? = nil,
            deprecated: Bool? = nil,
            title: String? = nil,
            description: String? = nil,
            discriminator: OpenAPI.Discriminator? = nil,
            externalDocs: OpenAPI.ExternalDocumentation? = nil,
            allowedValues: [AnyCodable]? = nil,
            defaultValue: AnyCodable? = nil,
            examples: [AnyCodable] = [],
            anchor: String? = nil,
            dynamicAnchor: String? = nil,
            defs: OrderedDictionary<String, JSONSchema> = [:],
            vendorExtensions: [String: AnyCodable] = [:],
            _inferred: Bool = false
        ) {
            self.warnings = []
            self.format = format
            self.required = required
            self.nullable = nullable
            self._permissions = permissions
            self._deprecated = deprecated
            self.title = title
            self.description = description
            self.discriminator = discriminator
            self.externalDocs = externalDocs
            self.allowedValues = allowedValues
            self.defaultValue = defaultValue
            self.examples = examples
            self.anchor = anchor
            self.dynamicAnchor = dynamicAnchor
            self.defs = defs
            self.vendorExtensions = vendorExtensions
            self.inferred = _inferred
        }

        public init(
            format: Format = .unspecified,
            required: Bool = true,
            nullable: Bool = false,
            permissions: Permissions? = nil,
            deprecated: Bool? = nil,
            title: String? = nil,
            description: String? = nil,
            discriminator: OpenAPI.Discriminator? = nil,
            externalDocs: OpenAPI.ExternalDocumentation? = nil,
            allowedValues: [AnyCodable]? = nil,
            defaultValue: AnyCodable? = nil,
            examples: [String],
            anchor: String? = nil,
            dynamicAnchor: String? = nil,
            defs: OrderedDictionary<String, JSONSchema> = [:],
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.warnings = []
            self.format = format
            self.required = required
            self.nullable = nullable
            self._permissions = permissions
            self._deprecated = deprecated
            self.title = title
            self.description = description
            self.discriminator = discriminator
            self.externalDocs = externalDocs
            self.allowedValues = allowedValues
            self.defaultValue = defaultValue
            self.examples = examples.map(AnyCodable.init)
            self.anchor = anchor
            self.dynamicAnchor = dynamicAnchor
            self.defs = defs
            self.vendorExtensions = vendorExtensions
            self.inferred = false
        }
    }
}

extension JSONSchema.CoreContext: Equatable {
    public static func == (lhs: JSONSchema.CoreContext<Format>, rhs: JSONSchema.CoreContext<Format>) -> Bool {
      // Split the conditionals up for the sake of the Swift 5.4 compiler.
      let step1 = lhs.format == rhs.format
          && lhs.required == rhs.required
          && lhs.nullable == rhs.nullable
          && lhs._permissions == rhs._permissions
          && lhs._deprecated == rhs._deprecated
          && lhs.title == rhs.title
          && lhs.description == rhs.description
          && lhs.externalDocs == rhs.externalDocs
          && lhs.discriminator == rhs.discriminator

      return step1 
          && lhs.allowedValues == rhs.allowedValues
          && lhs.defaultValue == rhs.defaultValue
          && lhs.examples == rhs.examples
          && lhs.anchor == rhs.anchor
          && lhs.dynamicAnchor == rhs.dynamicAnchor
          && lhs.defs == rhs.defs
          && lhs.vendorExtensions == rhs.vendorExtensions
          && lhs.inferred == rhs.inferred
    }
}

// MARK: - Transformations

extension JSONSchema.CoreContext {
    /// Return the optional version of this Context
    public func optionalContext() -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: false,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return the required version of this context
    public func requiredContext() -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: true,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return the nullable version of this context
    public func nullableContext() -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: true,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given list of possible values
    public func with(allowedValues: [AnyCodable]) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given default value.
    public func with(defaultValue: AnyCodable) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given example
    public func with(example: AnyCodable) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: [example],
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given examples
    public func with(examples: [AnyCodable]) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given discriminator
    public func with(discriminator: OpenAPI.Discriminator) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given description
    public func with(description: String) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }

    /// Return this context with the given description
    public func with(vendorExtensions: [String: AnyCodable]) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples,
            anchor: anchor,
            dynamicAnchor: dynamicAnchor,
            defs: defs,
            vendorExtensions: vendorExtensions,
            _inferred: inferred
        )
    }
}

// MARK: - Specific Contexts

extension JSONSchema {
    /// The context that only applies to `.number` schemas.
    ///
    /// - Note: Although integers are numbers, `integer`
    /// schemas have their own context type. An
    /// `IntegerContext` _can_ be asked for the
    /// `NumericContext` that would describe it via its
    /// `numericContext` property.
    public struct NumericContext: Equatable, Sendable {
        public struct Bound: Equatable, Sendable {
            public let value: Double
            public let exclusive: Bool

            internal static let defaultExclusion: Bool = false
        }

        /// A numeric instance is valid only if division by this keyword's value results in an integer. Defaults to nil.
        public let multipleOf: Double?

        public let maximum: Bound?
        public let minimum: Bound?

        public init(
            multipleOf: Double? = nil,
            maximum: (Double, exclusive: Bool)? = nil,
            minimum: (Double, exclusive: Bool)? = nil
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum.map { Bound(value: $0.0, exclusive: $0.exclusive) }
            self.minimum = minimum.map { Bound(value: $0.0, exclusive: $0.exclusive) }
        }

        internal init(
            multipleOf: Double?,
            maximum: Bound?,
            minimum: Bound?
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum
            self.minimum = minimum
        }
    }

    /// The context that only applies to `.integer` schemas.
    public struct IntegerContext: Equatable, Sendable {
        public struct Bound: Equatable, Sendable {
            public let value: Int
            public let exclusive: Bool

            internal static let defaultExclusion: Bool = false
        }

        /// A numeric instance is valid only if division by this keyword's value results in an integer. Defaults to nil.
        public let multipleOf: Int?

        public let maximum: Bound?
        public let minimum: Bound?

        public init(
            multipleOf: Int? = nil,
            maximum: (Int, exclusive: Bool)? = nil,
            minimum: (Int, exclusive: Bool)? = nil
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum.map { Bound(value: $0.0, exclusive: $0.exclusive) }
            self.minimum = minimum.map { Bound(value: $0.0, exclusive: $0.exclusive) }
        }

        /// Create an `IntegerContext` from the given `NumericContext`.
        ///
        /// This will only succeed if all properties of the `NumericContext` are
        /// integers.
        public init?(from numericContext: NumericContext) {
            let multipleOf: Int?
            if let numericMultipleOf = numericContext.multipleOf {
                guard let intMultipleOf = Int(exactly: numericMultipleOf) else {
                    return nil
                }
                multipleOf = intMultipleOf
            } else {
                multipleOf = nil
            }

            let maximum: Bound?
            if let numericMax = numericContext.maximum {
                guard let intMaxValue = Int(exactly: numericMax.value) else {
                    return nil
                }
                maximum = Bound(value: intMaxValue, exclusive: numericMax.exclusive)
            } else {
                maximum = nil
            }

            let minimum: Bound?
            if let numericMin = numericContext.minimum {
                guard let intMinValue = Int(exactly: numericMin.value) else {
                    return nil
                }
                minimum = Bound(value: intMinValue, exclusive: numericMin.exclusive)
            } else {
                minimum = nil
            }

            self.multipleOf = multipleOf
            self.maximum = maximum
            self.minimum = minimum
        }

        internal init(
            multipleOf: Int?,
            maximum: Bound?,
            minimum: Bound?
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum
            self.minimum = minimum
        }

        /// Get the `NumericContext` that describes this
        /// `IntegerContext`.
        public var numericContext: NumericContext {
            return .init(
                multipleOf: multipleOf.map(Double.init),
                maximum: maximum.map { (Double($0.value), exclusive: $0.exclusive) },
                minimum: minimum.map { (Double($0.value), exclusive: $0.exclusive) }
            )
        }
    }

    /// The context that only applies to `.array` schemas.
    public struct ArrayContext: Equatable, Sendable {
        /// A JSON Type Node that describes
        /// the type of each element in the array.
        public let items: JSONSchema?

        /// Maximum number of items in array.
        public let maxItems: Int?

        let _minItems: Int?
        /// Minimum number of items in array.
        /// Defaults to 0.
        public var minItems: Int { _minItems ?? 0 }

        let _uniqueItems: Bool?
        /// Setting to true indicates all
        /// elements of the array are expected
        /// to be unique. Defaults to false.
        public var uniqueItems: Bool { _uniqueItems ?? false }

        public init(
            items: JSONSchema? = nil,
            maxItems: Int? = nil,
            minItems: Int? = nil,
            uniqueItems: Bool? = nil
        ) {
            self.items = items
            self.maxItems = maxItems
            self._minItems = minItems
            self._uniqueItems = uniqueItems
        }
    }

    /// The context that only applies to `.object` schemas.
    public struct ObjectContext: Equatable, Sendable {
        /// The maximum number of properties the object
        /// is allowed to have.
        public let maxProperties: Int?
        let _minProperties: Int?
        public let properties: OrderedDictionary<String, JSONSchema>

        /// Either a boolean or a schema defining or allowing
        /// additional properties on this object.
        ///
        /// A value of `false` means that only properties listed
        /// in the `properties` dictionary may be defined on
        /// this object.
        ///
        /// A value of `true` means that properties
        /// not named in the `properties` dictionary are
        /// allowed.
        ///
        /// A `JSONSchema` value means that additional
        /// properties not listed in the `properties` dictionary
        /// are allowed but must match the given schema.
        ///
        /// A `nil` value is treated like a `true` value but
        /// allows you to omit the property from encoding.
        public let additionalProperties: Either<Bool, JSONSchema>?

        /// The properties of this object that are required.
        ///
        /// - Note: An object's required properties array
        ///     is determined by looking at its properties'
        ///     required Bool.
        public var requiredProperties: [String] {
            properties.filter { _, schema in schema.required }.map { $0.key }
        }

        /// The properties of this object that are optional.
        ///
        /// - Note: An object's optional properties array
        ///     is determined by looking at its properties'
        ///     required Bool.
        public var optionalProperties: [String] {
            properties.filter { _, schema in !schema.required }.map { $0.key }
        }

        /// The minimum number of properties allowed.
        ///
        /// This might constradict a value explicitly specified on initialization
        /// or when decoding if the number of required properties is greater
        /// than the explicitly set minimum.
        public var minProperties: Int {
            return max(_minProperties ?? 0, requiredProperties.count)
        }

        public init(
            properties: OrderedDictionary<String, JSONSchema>,
            additionalProperties: Either<Bool, JSONSchema>? = nil,
            maxProperties: Int? = nil,
            minProperties: Int? = nil
        ) {
            self.properties = properties
            self.additionalProperties = additionalProperties
            self.maxProperties = maxProperties
            self._minProperties = minProperties
        }
    }

    /// The context that only applies to `.string` schemas.
    public struct StringContext: Equatable, Sendable {
        public let maxLength: Int?
        let _minLength: Int?

        public let contentMediaType: OpenAPI.ContentType?
        public let contentEncoding: OpenAPI.ContentEncoding?

        public var minLength: Int {
            return _minLength ?? 0
        }

        /// Regular expression
        public let pattern: String?

        public init(
            maxLength: Int? = nil,
            minLength: Int? = nil,
            pattern: String? = nil,
            contentMediaType: OpenAPI.ContentType? = nil,
            contentEncoding: OpenAPI.ContentEncoding? = nil
        ) {
            self.maxLength = maxLength
            self._minLength = minLength
            self.pattern = pattern
            self.contentMediaType = contentMediaType
            self.contentEncoding = contentEncoding
        }

        // we make the following a static function so it doesn't muddy the namespace while auto-completing on a value.
        public static func _minLength(_ context: StringContext) -> Int? {
            return context._minLength
        }
    }
}

extension OpenAPI {
    /// An encoding, as specified in RFC 2045, part 6.1 and RFC 4648.
    public enum ContentEncoding: String, Codable, Sendable {
        case _7bit = "7bit"
        case _8bit = "8bit"
        case binary
        case quoted_printable = "quoted-printable"
        case base16
        case base32
        case base64
    }
}

// MARK: - Codable

extension JSONSchema {
    // not nested because Context is a generic type
    internal enum ContextCodingKeys: String, CodingKey {
        case type
        case nullable
        case format
        case title
        case description
        case discriminator
        case externalDocs
        case allowedValues = "enum"
        case const
        case defaultValue = "default"
        case example // deprecated in favor of examples
        case examples
        case anchor = "$anchor"
        case dynamicAnchor = "$dynamicAnchor"
        case defs = "$defs"
        case readOnly
        case writeOnly
        case deprecated
    }
}

extension JSONSchema.CoreContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)

        // encode zero or more values to the 'type' field
        try encodeTypes(to: &container)

        if format != Format.unspecified {
            try container.encode(format, forKey: .format)
        }

        if (allowedValues?.count == 1) {
            try container.encode(allowedValues?.first, forKey: .const)
        } else {
            try container.encodeIfPresent(allowedValues, forKey: .allowedValues)
        }
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(discriminator, forKey: .discriminator)
        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
        if !examples.isEmpty {
            try container.encode(examples, forKey: .examples)
        }
        try container.encodeIfPresent(anchor, forKey: .anchor)
        try container.encodeIfPresent(dynamicAnchor, forKey: .dynamicAnchor)
        if !defs.isEmpty {
            try container.encode(defs, forKey: .defs)
        }

        // deprecated is false if omitted
        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        // permissions are readWrite if omitted
        switch permissions {
        case .readOnly:
            try container.encode(true, forKey: .readOnly)
        case .writeOnly:
            try container.encode(true, forKey: .writeOnly)
        case .readWrite:
            break
        }
    }

    /// Encode value(s) to the `type` field.
    ///
    /// If this JSONSchema represents any type of thing, no `type` property
    /// is encoded. If this JSONSchema represents one type of thing, a single
    /// string is encoded to the `type` property. If this JSONSchema represents
    /// multiple types of things (like both `null` (i.e. it is nullable) and some other
    /// type, an array of strings is encoded to the `type` property.
    private func encodeTypes(to container: inout KeyedEncodingContainer<JSONSchema.ContextCodingKeys>) throws {
        let types: [String] = [
            Format.self == JSONTypeFormat.AnyFormat.self ? nil : format.jsonType.rawValue,
            nullable ? JSONType.null.rawValue : nil
        ].compactMap { $0 }

        if types.count > 1 {
            try container.encode(types, forKey: .type)
        } else if let type = types.first {
            try container.encode(type, forKey: .type)
        }
    }
}

extension JSONSchema.CoreContext: Decodable {
    public init(from decoder: Decoder) throws {
        var warnings: [OpenAPI.Warning] = []

        let container = try decoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)

        format = try container.decodeIfPresent(Format.self, forKey: .format) ?? .unspecified

        let (nullable, nullableWarnings) = try Self.decodeNullable(from: container)
        self.nullable = nullable
        warnings += nullableWarnings

        // default to `true` at decoding site.
        // It is the responsibility of decoders farther upstream
        // to mark this as _not_ required if needed using
        // `.optionalContext()`.
        required = true

        title = try container.decodeIfPresent(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        discriminator = try container.decodeIfPresent(OpenAPI.Discriminator.self, forKey: .discriminator)
        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)
        if Format.self == JSONTypeFormat.StringFormat.self {
            if nullable {
                allowedValues = try Self.decodeAllowedValuesOrConst(String?.self, inContainer: container)?.map(AnyCodable.init)
            } else {
                allowedValues = try Self.decodeAllowedValuesOrConst(String.self, inContainer: container)?.map(AnyCodable.init)
            }
        } else {
            allowedValues = try Self.decodeAllowedValuesOrConst(AnyCodable.self, inContainer: container)
        }
        defaultValue = try container.decodeIfPresent(AnyCodable.self, forKey: .defaultValue)

        let readOnly = try container.decodeIfPresent(Bool.self, forKey: .readOnly)
        let writeOnly = try container.decodeIfPresent(Bool.self, forKey: .writeOnly)

        if readOnly == nil && writeOnly == nil {
            _permissions = nil
        } else {
            let inferredReadOnly = readOnly ?? false
            let inferredWriteOnly = writeOnly ?? false

            switch (inferredReadOnly, inferredWriteOnly) {
            case (false, false):
                _permissions = .readWrite
            case (false, true):
                _permissions = .writeOnly
            case (true, false):
                _permissions = .readOnly
            case (true, true):
                throw InconsistencyError(
                    subjectName: "JSONSchema",
                    details: "Either `readOnly` or `writeOnly` can be true but not both",
                    codingPath: decoder.codingPath
                )
            }
        }

        _deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated)
        if container.contains(.example) {
            examples = [try container.decode(AnyCodable.self, forKey: .example)]
        } else {
            examples = try container.decodeIfPresent([AnyCodable].self, forKey: .examples) ?? []
        }
        anchor = try container.decodeIfPresent(String.self, forKey: .anchor)
        dynamicAnchor = try container.decodeIfPresent(String.self, forKey: .dynamicAnchor)
        defs = try container.decodeIfPresent(OrderedDictionary<String, JSONSchema>.self, forKey: .defs) ?? [:]
        // vendor extensions get decoded by the JSONSchema because although vendor extensions
        // apply to all schemas (core context) they are more accurately in the context of the
        // full JSON Schema.
        vendorExtensions = [:]
        inferred = false

        self.warnings = warnings
    }

    /// Support both `enum` and `const` when decoding allowed values for the schema.
    private static func decodeAllowedValuesOrConst<To: Decodable>(_ type: To.Type, inContainer container: KeyedDecodingContainer<JSONSchema.ContextCodingKeys>) throws -> [To]? {
        if let manyValues = try container.decodeIfPresent([To].self, forKey: .allowedValues) {
            return manyValues
        }
        if let oneValue = try container.decodeIfPresent(To.self, forKey: .const) {
            return [oneValue]
        }
        return nil
    }

    /// Decode whether or not this is a nullable JSONSchema.
    private static func decodeNullable(from container: KeyedDecodingContainer<JSONSchema.ContextCodingKeys>) throws -> (Bool, [OpenAPI.Warning]) {
        let nullable: Bool
        var warnings: [OpenAPI.Warning] = []

        if let _nullable = try? container.decodeIfPresent(Bool.self, forKey: .nullable) {
            nullable = _nullable
            warnings.append(
                .underlyingError(
                      InconsistencyError(
                          subjectName: "OpenAPI Schema",
                          details: "Found 'nullable' property. This property is not supported by OpenAPI v3.1.x. OpenAPIKit has translated it into 'type: [\"null\", ...]'.",
                          codingPath: container.codingPath
                      )
                  )
            )
            
        }
        else if let types = try? container.decodeIfPresent([JSONType].self, forKey: .type) {
            nullable = types.contains(JSONType.null)
        }
        else if let type = try? container.decodeIfPresent(JSONType.self, forKey: .type) {
            nullable = type == JSONType.null
        } else {
          nullable = false
        }
        return (nullable, warnings)
    }
}

extension JSONSchema.NumericContext {
    internal enum CodingKeys: String, CodingKey {
        case multipleOf
        case maximum
        case exclusiveMaximum
        case minimum
        case exclusiveMinimum
    }
}

extension JSONSchema.NumericContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(multipleOf, forKey: .multipleOf)

        if let max = maximum {
            if max.exclusive {
                try container.encode(max.value, forKey: .exclusiveMaximum)
            } else {
                try container.encode(max.value, forKey: .maximum)
            }
        }

        if let min =  minimum {
            if min.exclusive {
                try container.encode(min.value, forKey: .exclusiveMinimum)
            } else {
                try container.encode(min.value, forKey: .minimum)
            }
        }
    }
}

extension JSONSchema.NumericContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        multipleOf = try container.decodeIfPresent(Double.self, forKey: .multipleOf)

        if let exclusiveMaximum = try container.decodeIfPresent(Double.self, forKey: .exclusiveMaximum) {
            maximum = Bound(value: exclusiveMaximum, exclusive: true)
        } else {
            maximum = try container.decodeIfPresent(Double.self, forKey: .maximum)
                .map { Bound(value: $0, exclusive: false) }
        }

        if let exclusiveMinimum = try container.decodeIfPresent(Double.self, forKey: .exclusiveMinimum) {
            minimum = Bound(value: exclusiveMinimum, exclusive: true)
        } else {
            minimum = (try container.decodeIfPresent(Double.self, forKey: .minimum))
                .map { Bound(value: $0, exclusive: false) }
        }
    }
}

extension JSONSchema.IntegerContext {
    internal enum CodingKeys: String, CodingKey {
        case multipleOf
        case maximum
        case exclusiveMaximum
        case minimum
        case exclusiveMinimum
    }
}

extension JSONSchema.IntegerContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(multipleOf, forKey: .multipleOf)

        if let max = maximum {
            if max.exclusive {
                try container.encode(max.value, forKey: .exclusiveMaximum)
            } else {
                try container.encode(max.value, forKey: .maximum)
            }
        }

        if let min =  minimum {
            if min.exclusive {
                try container.encode(min.value, forKey: .exclusiveMinimum)
            } else {
                try container.encode(min.value, forKey: .minimum)
            }
        }
    }
}

extension JSONSchema.IntegerContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        multipleOf = try container.decodeIfPresent(Int.self, forKey: .multipleOf)

            // the following acrobatics thanks to some libraries (namely Yams) not
            // being willing to decode floating point representations of whole numbers
            // as integer values.
        let exclusiveIntegerMaximumAttempt = try? container.decodeIfPresent(Int.self, forKey: .exclusiveMaximum)
        let exclusiveIntegerMinimumAttempt = try? container.decodeIfPresent(Int.self, forKey: .exclusiveMinimum)
        let exclusiveDoubleMaximumAttempt = try container.decodeIfPresent(Double.self, forKey: .exclusiveMaximum)
        let exclusiveDoubleMinimumAttempt = try container.decodeIfPresent(Double.self, forKey: .exclusiveMinimum)

        let maximumIntegerAttempt = try? container.decodeIfPresent(Int.self, forKey: .maximum)
        let minimumIntegerAttempt = try? container.decodeIfPresent(Int.self, forKey: .minimum)
        let maximumDoubleAttempt = try container.decodeIfPresent(Double.self, forKey: .maximum)
        let minimumDoubleAttempt = try container.decodeIfPresent(Double.self, forKey: .minimum)

        func boundFrom(integer intAttempt: Int?, double doubleAttempt: Double?, max: Bool, exclusive: Bool) throws -> Bound? {
            let value = try intAttempt
                ?? doubleAttempt.map { floatVal in
                guard let integer = Int(exactly: floatVal) else {
                    throw InconsistencyError(
                        subjectName: max ? "maximum" : "minimum",
                        details: "Expected an Integer literal but found a floating point value (\(String(describing: floatVal)))",
                        codingPath: decoder.codingPath,
                        pathIncludesSubject: false
                    )
                }
                return integer
            }
            return value.map { Bound(value: $0, exclusive: exclusive) }
        }

        maximum = try boundFrom(integer: exclusiveIntegerMaximumAttempt, double: exclusiveDoubleMaximumAttempt, max: true, exclusive: true)
        ?? boundFrom(integer: maximumIntegerAttempt, double: maximumDoubleAttempt, max: true, exclusive: false)

        minimum = try boundFrom(integer: exclusiveIntegerMinimumAttempt, double: exclusiveDoubleMinimumAttempt, max: false, exclusive: true)
        ?? boundFrom(integer: minimumIntegerAttempt, double: minimumDoubleAttempt, max: false, exclusive: false)
    }
}

extension JSONSchema.ArrayContext {
    internal enum CodingKeys: String, CodingKey {
        case items
        case maxItems
        case minItems
        case uniqueItems
    }
}

extension JSONSchema.ArrayContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(maxItems, forKey: .maxItems)
        try container.encodeIfPresent(_minItems, forKey: .minItems)
        try container.encodeIfPresent(_uniqueItems, forKey: .uniqueItems)
    }
}

extension JSONSchema.ArrayContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        items = try container.decodeIfPresent(JSONSchema.self, forKey: .items)
        maxItems = try container.decodeIfPresent(Int.self, forKey: .maxItems)
        _minItems = try container.decodeIfPresent(Int.self, forKey: .minItems)
        _uniqueItems = try container.decodeIfPresent(Bool.self, forKey: .uniqueItems)
    }
}

extension JSONSchema.ObjectContext {
    internal enum CodingKeys: String, CodingKey {
        case maxProperties
        case minProperties
        case properties
        case additionalProperties
        case required
    }
}

extension JSONSchema.ObjectContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(maxProperties, forKey: .maxProperties)

        if properties.count > 0 {
            try container.encode(properties, forKey: .properties)
        }

        try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)

        if !requiredProperties.isEmpty {
            try container.encode(requiredProperties, forKey: .required)
        }

        try container.encodeIfPresent(_minProperties, forKey: .minProperties)
    }
}

extension JSONSchema.ObjectContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        maxProperties = try container.decodeIfPresent(Int.self, forKey: .maxProperties)
        _minProperties = try container.decodeIfPresent(Int.self, forKey: .minProperties)
        additionalProperties = try container.decodeIfPresent(Either<Bool, JSONSchema>.self, forKey: .additionalProperties)

        let requiredArray = try container.decodeIfPresent([String].self, forKey: .required) ?? []

        let decodedProperties = try container.decodeIfPresent(OrderedDictionary<String, JSONSchema>.self, forKey: .properties) ?? [:]
        properties = Self.properties(decodedProperties, takingRequirementsFrom: requiredArray)
    }

    /// Make any property not in the given "required" array optional.
    ///
    /// All schemas are assumed required until a parent object schema
    /// omits the property containing the schema from its required array.
    ///
    /// This allows OpenAPIKit to store the concept of "requried" on each
    /// schema instead of on the parenting object and to consider root
    /// schemas (those not living in another object's properties dictionary)
    /// to be required.
    ///
    /// - Parameters:
    ///     - properties: The properties before resolving optionality.
    ///     - required: The array of names of properties that should be required.
    internal static func properties(
        _ properties: OrderedDictionary<String, JSONSchema>,
        takingRequirementsFrom required: [String]
    ) -> OrderedDictionary<String, JSONSchema> {
        var properties = properties

        // mark any optional properties as optional.
        properties
            .filter { !required.contains($0.key) }
            .forEach { (propertyName, property) in
                properties[propertyName] = property.optionalSchemaObject()
            }

        // add any required properties not in the properties dict to
        // the properties dict as fragments.
        required
            .filter { !properties.keys.contains($0) }
            .forEach { propertyName in
                properties[propertyName] = .fragment(.init(required: true, _inferred: true))
            }

        return properties
    }
}

extension JSONSchema.StringContext {
    public enum CodingKeys: String, CodingKey {
        case maxLength
        case minLength
        case pattern
        case contentMediaType
        case contentEncoding
    }
}

extension JSONSchema.StringContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(_minLength, forKey: .minLength)
        try container.encodeIfPresent(pattern, forKey: .pattern)
        try container.encodeIfPresent(contentMediaType, forKey: .contentMediaType)
        try container.encodeIfPresent(contentEncoding, forKey: .contentEncoding)
    }
}

extension JSONSchema.StringContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        _minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        contentMediaType = try container.decodeIfPresent(OpenAPI.ContentType.self, forKey: .contentMediaType)
        contentEncoding = try container.decodeIfPresent(OpenAPI.ContentEncoding.self, forKey: .contentEncoding)
    }
}
