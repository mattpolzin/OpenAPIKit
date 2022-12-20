//
//  JSONSchemaSimpleContexts.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

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
