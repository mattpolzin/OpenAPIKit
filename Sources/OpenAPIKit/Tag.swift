//
//  Tag.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Tag Object"
    ///
    /// See [OpenAPI Tag Object](https://spec.openapis.org/oas/v3.1.1.html#tag-object).
    public struct Tag: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        public let name: String
        /// Summary of the tag. Available for OAS 3.2.0 and greater.
        public let summary: String?
        public let description: String?
        public let externalDocs: ExternalDocumentation?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public let conditionalWarnings: [(any Condition, Warning)]

        public init(
            name: String,
            summary: String? = nil,
            description: String? = nil,
            externalDocs: ExternalDocumentation? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.summary = summary
            self.description = description
            self.externalDocs = externalDocs
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = [
                // If summary is non-nil, the document must be OAS version 3.2.0 or greater
                nonNilVersionWarning(fieldName: "summary", value: summary, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }
    }
}

fileprivate func nonNilVersionWarning<Subject>(fieldName: String, value: Subject?, minimumVersion: OpenAPI.Document.Version) -> (any Condition, OpenAPI.Warning)? {
    value.map { _ in
        OpenAPI.Document.ConditionalWarnings.version(
            lessThan: minimumVersion,
            doesNotSupport: "The Tag \(fieldName) field"
        )
    }
}

extension OpenAPI.Tag: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
          && lhs.summary == rhs.summary
          && lhs.description == rhs.description
          && lhs.externalDocs == rhs.externalDocs
          && lhs.vendorExtensions == rhs.vendorExtensions
    }
}

extension OpenAPI.Tag: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(name: stringLiteral)
    }
}

// MARK: - Describable & Summarizable

extension OpenAPI.Tag : OpenAPISummarizable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Tag {
        guard let description = description else { return self }
        return OpenAPI.Tag(
            name: name,
            summary: summary,
            description: description,
            externalDocs: externalDocs,
            vendorExtensions: vendorExtensions
        )
    }

    public func overriddenNonNil(summary: String?) -> OpenAPI.Tag {
        guard let summary = summary else { return self }
        return OpenAPI.Tag(
            name: name,
            summary: summary,
            description: description,
            externalDocs: externalDocs,
            vendorExtensions: vendorExtensions
        )
    }
}

// MARK: - Codable

extension OpenAPI.Tag: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        try container.encodeIfPresent(summary, forKey: .summary)

        try container.encodeIfPresent(description, forKey: .description)

        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Tag: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        summary = try container.decodeIfPresent(String.self, forKey: .summary)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)

        vendorExtensions = try Self.extensions(from: decoder)

        conditionalWarnings = [
            // If summary is non-nil, the document must be OAS version 3.2.0 or greater
            nonNilVersionWarning(fieldName: "summary", value: summary, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }
}

extension OpenAPI.Tag {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case summary
        case description
        case externalDocs
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
                .summary,
                .description,
                .externalDocs
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "name":
                self = .name
            case "summary":
                self = .summary
            case "description":
                self = .description
            case "externalDocs":
                self = .externalDocs
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .name:
                return "name"
            case .summary:
                return "summary"
            case .description:
                return "description"
            case .externalDocs:
                return "externalDocs"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Tag: Validatable {}
