//
//  JSONSchemaSimpleContexts.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

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

    public static func _init(
        multipleOf: Double?,
        maximum: Bound?,
        minimum: Bound?
    ) -> NumericContext { .init(multipleOf: multipleOf, maximum: maximum, minimum: minimum) }
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

    public static func _init(
        multipleOf: Int?,
        maximum: Bound?,
        minimum: Bound?
    ) -> IntegerContext { .init(multipleOf: multipleOf, maximum: maximum, minimum: minimum) }

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

    // we make the following a static function so it doesn't muddy the namespace while auto-completing on a value.
    public static func _minLength(_ context: StringContext) -> Int? {
        return context._minLength
    }
}


/// The context that only applies to `.reference` schemas.
public struct ReferenceContext: Equatable {
    public let required: Bool

    public init(required: Bool = true) {
        self.required = required
    }

    public func requiredContext() -> ReferenceContext {
        return .init(required: true)
    }

    public func optionalContext() -> ReferenceContext {
        return .init(required: false)
    }
}

extension NumericContext {
    public enum CodingKeys: String, CodingKey {
        case multipleOf
        case maximum
        case exclusiveMaximum
        case minimum
        case exclusiveMinimum
    }
}

extension NumericContext: Encodable {
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

extension NumericContext: Decodable {
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

extension IntegerContext {
    public enum CodingKeys: String, CodingKey {
        case multipleOf
        case maximum
        case exclusiveMaximum
        case minimum
        case exclusiveMinimum
    }
}

extension IntegerContext: Encodable {
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

extension IntegerContext: Decodable {
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

extension StringContext {
    public enum CodingKeys: String, CodingKey {
        case maxLength
        case minLength
        case pattern
    }
}

extension StringContext: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(maxLength, forKey: .maxLength)
        try container.encodeIfPresent(_minLength, forKey: .minLength)
        try container.encodeIfPresent(pattern, forKey: .pattern)
    }
}

extension StringContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        _minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
    }
}
