//
//  JSONSchemaContext.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

// MARK: - Core Context

/// A schema context stores information about a schema.
/// All schemas can have the contextual information in
/// this protocol.
public protocol JSONSchemaContext {
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
    /// See [OpenAPI Discriminator Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#discriminator-object).
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

    /// Get an example, if specified. If unspecified, returns `nil`.
    var example: AnyCodable? { get }

    /// `true` if this schema can only be read from and is therefore
    /// unsupported for request data.
    var readOnly: Bool { get }

    /// `true` if this schema can only be written to and is therefore
    /// unavailable in response data.
    var writeOnly: Bool { get }

    /// `true` if this schema is deprecated, `false` otherwise.
    var deprecated: Bool { get }
}

extension JSONSchema {
    /// The context that applies to all schemas.
    public struct CoreContext<Format: OpenAPIFormat>: JSONSchemaContext, Equatable {
        public let format: Format
        public let required: Bool // default true
        let _nullable: Bool? // default false

        let _permissions: Permissions? // default `.readWrite`
        let _deprecated: Bool? // default false

        public let title: String?
        public let description: String?
        public let externalDocs: OpenAPI.ExternalDocumentation?

        public let discriminator: OpenAPI.Discriminator?

        // NOTE: "const" is supported by the newest JSON Schema spec but not
        // yet by OpenAPI. Instead, will use "enum" with one possible value for now.
//        public let constantValue: Format.SwiftType?

        public let allowedValues: [AnyCodable]?
        public let defaultValue: AnyCodable?

        public let example: AnyCodable?

        public var nullable: Bool { _nullable ?? false }
        public var permissions: Permissions { _permissions ?? .readWrite}
        public var deprecated: Bool { _deprecated ?? false }

        public var formatString: String? { format.rawValue }

        public var readOnly: Bool { permissions == .readOnly }
        public var writeOnly: Bool { permissions == .writeOnly }

        public var isEmpty: Bool {
            return format == .unspecified
                && _nullable == nil
                && description == nil
                && discriminator == nil
                && title == nil
                && _deprecated == nil
                && externalDocs == nil
                && allowedValues == nil
                && defaultValue == nil
                && example == nil
                && _permissions == nil
        }

        public init(
            format: Format = .unspecified,
            required: Bool = true,
            nullable: Bool? = nil,
            permissions: Permissions? = nil,
            deprecated: Bool? = nil,
            title: String? = nil,
            description: String? = nil,
            discriminator: OpenAPI.Discriminator? = nil,
            externalDocs: OpenAPI.ExternalDocumentation? = nil,
            allowedValues: [AnyCodable]? = nil,
            defaultValue: AnyCodable? = nil,
            example: AnyCodable? = nil
        ) {
            self.format = format
            self.required = required
            self._nullable = nullable
            self._permissions = permissions
            self._deprecated = deprecated
            self.title = title
            self.description = description
            self.discriminator = discriminator
            self.externalDocs = externalDocs
            self.allowedValues = allowedValues
            self.defaultValue = defaultValue
            self.example = example
        }

        public init(
            format: Format = .unspecified,
            required: Bool = true,
            nullable: Bool? = nil,
            permissions: Permissions? = nil,
            deprecated: Bool? = nil,
            title: String? = nil,
            description: String? = nil,
            discriminator: OpenAPI.Discriminator? = nil,
            externalDocs: OpenAPI.ExternalDocumentation? = nil,
            allowedValues: [AnyCodable]? = nil,
            defaultValue: AnyCodable? = nil,
            example: String
        ) {
            self.format = format
            self.required = required
            self._nullable = nullable
            self._permissions = permissions
            self._deprecated = deprecated
            self.title = title
            self.description = description
            self.discriminator = discriminator
            self.externalDocs = externalDocs
            self.allowedValues = allowedValues
            self.defaultValue = defaultValue
            self.example = AnyCodable(example)
        }

        public enum Permissions: String, Codable {
            case readOnly
            case writeOnly
            case readWrite

            public init<Format: OpenAPIFormat>(
                _ permissions: CoreContext<Format>.Permissions
            ) {
                switch permissions {
                case .readOnly:
                    self = .readOnly
                case .writeOnly:
                    self = .writeOnly
                case .readWrite:
                    self = .readWrite
                }
            }
        }
    }
}

// MARK: - Transformations

extension JSONSchema.CoreContext {
    /// Return the optional version of this Context
    public func optionalContext() -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: false,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// Return the required version of this context
    public func requiredContext() -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: true,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
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
            example: example
        )
    }

    /// Return this context with the given list of possible values
    public func with(allowedValues: [AnyCodable]) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// Return this context with the given default value.
    public func with(defaultValue: AnyCodable) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// Return this context with the given example
    public func with(example: AnyCodable) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// Return this context with the given discriminator
    public func with(discriminator: OpenAPI.Discriminator) -> JSONSchema.CoreContext<Format> {
        return .init(
            format: format,
            required: required,
            nullable: _nullable,
            permissions: _permissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
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
    public struct NumericContext: Equatable {
        public struct Bound: Equatable {
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
    public struct IntegerContext: Equatable {
        public struct Bound: Equatable {
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

    /// The context that only applies to `.string` schemas.
    public struct StringContext: Equatable {
        public let maxLength: Int?
        let _minLength: Int?

        public var minLength: Int {
            return _minLength ?? 0
        }

        /// Regular expression
        public let pattern: String?

        public init(
            maxLength: Int? = nil,
            minLength: Int? = nil,
            pattern: String? = nil
        ) {
            self.maxLength = maxLength
            self._minLength = minLength
            self.pattern = pattern
        }
    }

    /// The context that only applies to `.array` schemas.
    public struct ArrayContext: Equatable {
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
    public struct ObjectContext: Equatable {
        /// The maximum number of properties the object
        /// is allowed to have.
        public let maxProperties: Int?
        let _minProperties: Int?
        public let properties: [String: JSONSchema]

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
            return Array(properties.filter { (_, schemaObject) in
                schemaObject.required
            }.keys).sorted()
        }

        /// The properties of this object that are optional.
        ///
        /// - Note: An object's optional properties array
        ///     is determined by looking at its properties'
        ///     required Bool.
        public var optionalProperties: [String] {
            return Array(properties.filter { (_, schemaObject) in
                !schemaObject.required
            }.keys).sorted()
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
            properties: [String: JSONSchema],
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
}

// MARK: - Codable

extension JSONSchema {
    // not nested because Context is a generic type
    internal enum ContextCodingKeys: String, CodingKey {
        case type
        case format
        case title
        case description
        case discriminator
        case externalDocs
        case allowedValues = "enum"
        case defaultValue = "default"
        case nullable
        case example
        case readOnly
        case writeOnly
        case deprecated
//      case constantValue = "const"
    }
}

extension JSONSchema.CoreContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)

        if Format.self != JSONTypeFormat.AnyFormat.self {
            try container.encode(format.jsonType, forKey: .type)
        }

        if format != Format.unspecified {
            try container.encode(format, forKey: .format)
        }

        try container.encodeIfPresent(allowedValues, forKey: .allowedValues)
        try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(discriminator, forKey: .discriminator)
        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
        try container.encodeIfPresent(example, forKey: .example)

        // nullable is false if omitted
        if nullable {
            try container.encode(nullable, forKey: .nullable)
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
}

extension JSONSchema.CoreContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchema.ContextCodingKeys.self)

        format = try container.decodeIfPresent(Format.self, forKey: .format) ?? .unspecified

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
            allowedValues = try container.decodeIfPresent([String].self, forKey: .allowedValues)?.map(AnyCodable.init)
        } else {
            allowedValues = try container.decodeIfPresent([AnyCodable].self, forKey: .allowedValues)
        }
        defaultValue = try container.decodeIfPresent(AnyCodable.self, forKey: .defaultValue)
        _nullable = try container.decodeIfPresent(Bool.self, forKey: .nullable)

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
        example = try container.decodeIfPresent(AnyCodable.self, forKey: .example)
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
            try container.encode(max.value, forKey: .maximum)
            if max.exclusive {
                try container.encode(true, forKey: .exclusiveMaximum)
            }
        }

        if let min =  minimum {
            try container.encode(min.value, forKey: .minimum)
            if min.exclusive {
                try container.encode(true, forKey: .exclusiveMinimum)
            }
        }
    }
}

extension JSONSchema.NumericContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        multipleOf = try container.decodeIfPresent(Double.self, forKey: .multipleOf)

        let exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum) ?? Bound.defaultExclusion
        let exclusiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMinimum) ?? Bound.defaultExclusion

        maximum = (try container.decodeIfPresent(Double.self, forKey: .maximum))
            .map { Bound(value: $0, exclusive: exclusiveMaximum) }
        minimum = (try container.decodeIfPresent(Double.self, forKey: .minimum))
            .map { Bound(value: $0, exclusive: exclusiveMinimum) }
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
            try container.encode(max.value, forKey: .maximum)
            if max.exclusive {
                try container.encode(true, forKey: .exclusiveMaximum)
            }
        }

        if let min =  minimum {
            try container.encode(min.value, forKey: .minimum)
            if min.exclusive {
                try container.encode(true, forKey: .exclusiveMinimum)
            }
        }
    }
}

extension JSONSchema.IntegerContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        multipleOf = try container.decodeIfPresent(Int.self, forKey: .multipleOf)

        let exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum) ?? false
        let exclusiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMinimum) ?? false

        // the following acrobatics thanks to some libraries (namely Yams) not
        // being willing to decode floating point representations of whole numbers
        // as integer values.
        let maximumAttempt = try container.decodeIfPresent(Double.self, forKey: .maximum)
        let minimumAttempt = try container.decodeIfPresent(Double.self, forKey: .minimum)

        maximum = try maximumAttempt.map { floatMax in
            guard let integer = Int(exactly: floatMax) else {
                throw InconsistencyError(
                    subjectName: "maximum",
                    details: "Expected an Integer literal but found a floating point value",
                    codingPath: decoder.codingPath
                )
            }
            return integer
        }.map { Bound(value: $0, exclusive: exclusiveMaximum) }

        minimum = try minimumAttempt.map { floatMin in
            guard let integer = Int(exactly: floatMin) else {
                throw InconsistencyError(
                    subjectName: "minimum",
                    details: "Expected an Integer literal but found a floating point value",
                    codingPath: decoder.codingPath
                )
            }
            return integer
        }.map { Bound(value: $0, exclusive: exclusiveMinimum) }
    }
}

extension JSONSchema.StringContext {
    internal enum CodingKeys: String, CodingKey {
        case maxLength
        case minLength
        case pattern
    }
}

extension JSONSchema.StringContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(_minLength, forKey: .minLength)
        try container.encodeIfPresent(pattern, forKey: .pattern)
    }
}

extension JSONSchema.StringContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        _minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
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

        let decodedProperties = try container.decodeIfPresent([String: JSONSchema].self, forKey: .properties) ?? [:]
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
        _ properties: [String: JSONSchema],
        takingRequirementsFrom required: [String]
    ) -> [String: JSONSchema] {
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
                properties[propertyName] = .fragment(.init(required: true))
            }

        return properties
    }
}
