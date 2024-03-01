//
//  Example.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Example Object"
    ///
    /// See [OpenAPI Example Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#example-object).
    public struct Example: Equatable, CodableVendorExtendable {
        public let summary: String?
        public let description: String?

        /// Represents the OpenAPI `externalValue` as a URL _or_
        /// the OpenAPI `value` as `AnyCodable`.
        public let value: Either<URL, AnyCodable>?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public let vendorExtensions: [String: AnyCodable]

        public init(
            summary: String? = nil,
            description: String? = nil,
            value: Either<URL, AnyCodable>? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            self.value = value
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Example {
    public typealias Map = OrderedDictionary<String, Either<JSONReference<OpenAPI.Example>, OpenAPI.Example>>
}

// MARK: - Either Convenience
extension Either where A == JSONReference<OpenAPI.Example>, B == OpenAPI.Example {
    /// Construct an `Example`.
    public static func example(
        summary: String? = nil,
        description: String? = nil,
        value: Either<URL, AnyCodable>? = nil,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                summary: summary,
                description: description,
                value: value,
                vendorExtensions: vendorExtensions
            )
        )
    }
}

// MARK: - Codable
extension OpenAPI.Example: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(summary, forKey: .summary)
        try container.encodeIfPresent(description, forKey: .description)

        switch value {
        case .a(let url):
            try container.encode(url.absoluteURL, forKey: .externalValue)
        case .b(let example):
            try container.encode(example, forKey: .value)
        case nil:
            break
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Example: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        guard !(container.contains(.externalValue) && container.contains(.value)) else {
            throw InconsistencyError(
                subjectName: "example value",
                details: "Found both `value` and `externalValue` keys in an Example. You must specify one or the other.",
                codingPath: container.codingPath
            )
        }

        if let externalValue = try container.decodeURLAsStringIfPresent(forKey: .externalValue) {
            value = .a(externalValue)
        } else if let internalValue = try container.decodeIfPresent(AnyCodable.self, forKey: .value) {
            value = .b(internalValue)
        } else {
            value = nil
        }

        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Example {
    internal enum CodingKeys: ExtendableCodingKey {
        case summary
        case description
        case value
        case externalValue
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [.summary, .description, .value, .externalValue]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "summary":
                self = .summary
            case "description":
                self = .description
            case "value":
                self = .value
            case "externalValue":
                self = .externalValue
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .summary:
                return "summary"
            case .description:
                return "description"
            case .value:
                return "value"
            case .externalValue:
                return "externalValue"
            case .extended(let key):
                return key
            }
        }
    }
}

// MARK: - LocallyDereferenceable
extension OpenAPI.Example: LocallyDereferenceable {
    /// Examples do not contain any references but for convenience
    /// they can be "dereferenced" to themselves.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> OpenAPI.Example{
        var vendorExtensions = self.vendorExtensions
        if let name = name {
            vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        return .init(
            summary: self.summary,
            description: self.description,
            value: self.value,
            vendorExtensions: vendorExtensions
        )
    }
}

extension OpenAPI.Example: Validatable {}
