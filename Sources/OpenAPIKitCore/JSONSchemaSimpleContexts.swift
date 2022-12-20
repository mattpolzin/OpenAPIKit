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

        public static let _defaultExclusion: Bool = false

        internal init(value: Double, exclusive: Bool) {
            self.value = value
            self.exclusive = exclusive
        }

        public static func _init(value: Double, exclusive: Bool) -> Bound {
            .init(value: value, exclusive: exclusive)
        }
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

        public static let _defaultExclusion: Bool = false

        internal init(value: Int, exclusive: Bool) {
            self.value = value
            self.exclusive = exclusive
        }

        public static func _init(value: Int, exclusive: Bool) -> Bound {
            .init(value: value, exclusive: exclusive)
        }
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
