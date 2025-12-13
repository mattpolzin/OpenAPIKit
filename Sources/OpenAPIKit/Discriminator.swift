//
//  Discriminator.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Discriminator Object"
    ///
    /// See [OpenAPI Discriminator Object](https://spec.openapis.org/oas/v3.2.0.html#discriminator-object).
    public struct Discriminator: HasConditionalWarnings, Sendable {
        public let propertyName: String
        public let mapping: OrderedDictionary<String, String>?
        public let defaultMapping: String?

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        public init(propertyName: String,
                    mapping: OrderedDictionary<String, String>? = nil,
                    defaultMapping: String? = nil) {
            self.propertyName = propertyName
            self.mapping = mapping
            self.defaultMapping = defaultMapping

            self.conditionalWarnings = [
                nonNilVersionWarning(fieldName: "defaultMapping", value: defaultMapping, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }
    }
}

extension OpenAPI.Discriminator: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.propertyName == rhs.propertyName
        && lhs.mapping == rhs.mapping
        && lhs.defaultMapping == rhs.defaultMapping
    }
}

fileprivate func nonNilVersionWarning<Subject>(fieldName: String, value: Subject?, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
    value.map { _ in
        OpenAPI.Document.ConditionalWarnings.version(
            lessThan: minimumVersion,
            doesNotSupport: "The Discriminator \(fieldName) field"
        )
    }
}

// MARK: - Codable

extension OpenAPI.Discriminator: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(propertyName, forKey: .propertyName)
        try container.encodeIfPresent(mapping, forKey: .mapping)
        try container.encodeIfPresent(defaultMapping, forKey: .defaultMapping)
    }
}

extension OpenAPI.Discriminator: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        propertyName = try container.decode(String.self, forKey: .propertyName)
        mapping = try container.decodeIfPresent(OrderedDictionary<String, String>.self, forKey: .mapping)
        defaultMapping = try container.decodeIfPresent(String.self, forKey: .defaultMapping)

        conditionalWarnings = [
            nonNilVersionWarning(fieldName: "defaultMapping", value: defaultMapping, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }
}

extension OpenAPI.Discriminator {
    private enum CodingKeys: String, CodingKey {
        case propertyName
        case mapping
        case defaultMapping
    }
}

extension OpenAPI.Discriminator: Validatable {}
