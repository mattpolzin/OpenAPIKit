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
    /// See [OpenAPI Example Object](https://spec.openapis.org/oas/v3.2.0.html#example-object).
    public struct Example: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        public let summary: String?
        public let description: String?

        /// Stores the OpenAPI `dataValue`, `serializedValue`, `externalValue`,
        /// and `value` fields.
        public let value: OpenAPI.Example.Value?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public let conditionalWarnings: [(any Condition, OpenAPI.Warning)]

        public var dataValue: AnyCodable? { value?.dataValue }
        public var serializedValue: String? { value?.serializedValue }
        public var externalValue: URL? { value?.externalValue }

        public var legacyValue: AnyCodable? { value?.legacyValue }
        public var dataOrLegacyValue: AnyCodable? { value?.value }

        @available(*, deprecated, message: "This initializer populates the deprecated 'value' field, use init(summary:description:dataValue:serializedValue:vendorExtensions:) or init(summary:description:dataValue:externalValue:vendorExtensions:) instead.")
        public init(
            summary: String? = nil,
            description: String? = nil,
            value: Either<URL, AnyCodable>?,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            switch value {
            case .a(let url): self.value = .value(data: nil, serialized: .b(url))
            case .b(let value): self.value = .legacy(value)
            case nil: self.value = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = self.value?.conditionalWarnings ?? []
        }

        public init(
            summary: String? = nil,
            description: String? = nil,
            legacyValue: Either<URL, AnyCodable>?,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            switch legacyValue {
            case .a(let url): self.value = .value(data: nil, serialized: .b(url))
            case .b(let value): self.value = .legacy(value)
            case nil: self.value = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = self.value?.conditionalWarnings ?? []
        }

        public init(
            summary: String? = nil,
            description: String? = nil,
            value: Value?,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            self.value = value
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = self.value?.conditionalWarnings ?? []
        }

        public init(
            summary: String? = nil,
            description: String? = nil,
            dataValue: AnyCodable? = nil,
            serializedValue: String? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            if dataValue != nil || serializedValue != nil {
                self.value = .value(data: dataValue, serialized: serializedValue.map(Either.a))
            } else {
                self.value = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = self.value?.conditionalWarnings ?? []
        }

        public init(
            summary: String? = nil,
            description: String? = nil,
            dataValue: AnyCodable? = nil,
            externalValue: URL?,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.summary = summary
            self.description = description
            if dataValue != nil || externalValue != nil {
                self.value = .value(data: dataValue, serialized: externalValue.map(Either.b))
            } else {
                self.value = nil
            }
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = self.value?.conditionalWarnings ?? []
        }
    }
}

extension OpenAPI.Example: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.summary == rhs.summary
        && lhs.description == rhs.description
        && lhs.value == rhs.value
        && lhs.vendorExtensions == rhs.vendorExtensions
    }
}

extension OpenAPI.Example {
    public typealias Map = OrderedDictionary<String, Either<OpenAPI.Reference<OpenAPI.Example>, OpenAPI.Example>>
}

extension OpenAPI.Example.Value {
    fileprivate var conditionalWarnings: [(any Condition, OpenAPI.Warning)] {
        [
            nonNilVersionWarning(fieldName: "dataValue", value: dataValue, minimumVersion: .v3_2_0),
            nonNilVersionWarning(fieldName: "serializedValue", value: serializedValue, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }
}

fileprivate func nonNilVersionWarning<Subject>(fieldName: String, value: Subject?, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
    value.map { _ in
        OpenAPI.Document.ConditionalWarnings.version(
            lessThan: minimumVersion,
            doesNotSupport: "The Example Object \(fieldName) field"
        )
    }
}

// MARK: - Either Convenience
extension Either where A == OpenAPI.Reference<OpenAPI.Example>, B == OpenAPI.Example {
        @available(*, deprecated, message: "This function populates the deprecated 'value' field, use .value(summary:description:dataValue:serializedValue:vendorExtensions:) or .value(summary:description:dataValue:externalValue:vendorExtensions:) instead.")
    public static func example(
        summary: String? = nil,
        description: String? = nil,
        value: Either<URL, AnyCodable>?,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                summary: summary,
                description: description,
                legacyValue: value,
                vendorExtensions: vendorExtensions
            )
        )
    }

    public static func example(
        summary: String? = nil,
        description: String? = nil,
        dataValue: AnyCodable? = nil,
        serializedValue: String? = nil,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                summary: summary,
                description: description,
                dataValue: dataValue,
                serializedValue: serializedValue,
                vendorExtensions: vendorExtensions
            )
        )
    }

    public static func example(
        summary: String? = nil,
        description: String? = nil,
        dataValue: AnyCodable? = nil,
        externalValue: URL?,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                summary: summary,
                description: description,
                dataValue: dataValue,
                externalValue: externalValue,
                vendorExtensions: vendorExtensions
            )
        )
    }
}

// MARK: - Describable & Summarizable

extension OpenAPI.Example : OpenAPISummarizable {
    public func overriddenNonNil(summary: String?) -> OpenAPI.Example {
        guard let summary = summary else { return self }
        return OpenAPI.Example(
            summary: summary,
            description: description,
            value: value,
            vendorExtensions: vendorExtensions
        )
    }

    public func overriddenNonNil(description: String?) -> OpenAPI.Example {
        guard let description = description else { return self }
        return OpenAPI.Example(
            summary: summary,
            description: description,
            value: value,
            vendorExtensions: vendorExtensions
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
        case .legacy(let value):
            try container.encode(value, forKey: .value)
        case .value(data: let dataValue, serialized: let serialized):
            try container.encodeIfPresent(dataValue, forKey: .dataValue)
            switch serialized {
            case .a(let serializedValue):
                try container.encode(serializedValue, forKey: .serializedValue)
            case .b(let externalValue):
                try container.encode(externalValue.absoluteURL, forKey: .externalValue)
            case nil:
                break
            }
        case nil:
            break;
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Example: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try container.decodeIfPresent(AnyCodable.self, forKey: .value) {
            guard !(container.contains(.externalValue) || container.contains(.dataValue) || container.contains(.serializedValue)) else {
                throw GenericError(
                    subjectName: "example value",
                    details: "Found both `value` and one of `externalValue`, `dataValue`, or `serializedValue` keys in an Example. `value` cannot be used with these other keys.",
                    codingPath: container.codingPath
                )
            }

            self.value = .legacy(value)
        } else {

            let dataValue = try container.decodeIfPresent(AnyCodable.self, forKey: .dataValue)
            if let externalValue = try container.decodeURLAsStringIfPresent(forKey: .externalValue) {
                guard !(container.contains(.serializedValue)) else {
                    throw GenericError(
                        subjectName: "example value",
                        details: "Found both `externalValue` and `serializedValue` keys in an Example. These fields are mutually exclusive.",
                        codingPath: container.codingPath
                    )
                }

                self.value = .value(data: dataValue, serialized: .b(externalValue))
            } else if let serializedValue = try container.decodeIfPresent(String.self, forKey: .serializedValue) {
                self.value = .value(data: dataValue, serialized: .a(serializedValue))
            } else {
                self.value = dataValue.map { .value(data: $0, serialized: nil) }
            }
        }

        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        vendorExtensions = try Self.extensions(from: decoder)

        conditionalWarnings = self.value?.conditionalWarnings ?? []
    }
}

extension OpenAPI.Example {
    internal enum CodingKeys: ExtendableCodingKey {
        case summary
        case description
        case dataValue
        case serializedValue
        case value
        case externalValue
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .summary,
                .description,
                .dataValue,
                .serializedValue,
                .value,
                .externalValue
            ]
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
            case "dataValue":
                self = .dataValue
            case "serializedValue":
                self = .serializedValue
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
            case .dataValue:
                return "dataValue"
            case .serializedValue:
                return "serializedValue"
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
        if let name {
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

extension OpenAPI.Example: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        return (self, .init(), [])
    }
}

extension OpenAPI.Example: Validatable {}
