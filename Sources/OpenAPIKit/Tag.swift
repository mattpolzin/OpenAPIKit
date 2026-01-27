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
    /// See [OpenAPI Tag Object](https://spec.openapis.org/oas/v3.2.0.html#tag-object).
    public struct Tag: HasConditionalWarnings, CodableVendorExtendable, Sendable {
        public let name: String
        /// Summary of the tag. Available for OAS 3.2.0 and greater.
        public let summary: String?
        public let description: String?
        public let externalDocs: ExternalDocumentation?
        /// The tag this tag is nested under.
        public let parent: String?
        /// A machine-readable string to categorize what sort of tag this is.
        /// Any string value can be used, but some common options are provided
        /// on OpenAPIKit's `Tag.Kind` type as static properties and more can
        /// be found in the public registry:
        /// https://spec.openapis.org/registry/tag-kind
        public let kind: Kind?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        /// Warnings that apply conditionally depending on the OpenAPI Document
        /// the Tag belongs to.
        ///
        /// Check these with the `applicableConditionalWarnings(for:)` method.
        public let conditionalWarnings: [(any Condition, Warning)]

        public init(
            name: String,
            summary: String? = nil,
            description: String? = nil,
            externalDocs: ExternalDocumentation? = nil,
            parent: String? = nil,
            kind: Kind? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.summary = summary
            self.description = description
            self.externalDocs = externalDocs
            self.parent = parent
            self.kind = kind
            self.vendorExtensions = vendorExtensions

            self.conditionalWarnings = [
                // If summary is non-nil, the document must be OAS version 3.2.0 or greater
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "summary", value: summary, minimumVersion: .v3_2_0),
                // If parent is non-nil, the document must be OAS version 3.2.0 or greater
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "parent", value: parent, minimumVersion: .v3_2_0),
                // If kind is non-nil, the document must be OAS version 3.2.0 or greater
                OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "kind", value: kind, minimumVersion: .v3_2_0)
            ].compactMap { $0 }
        }
    }
}

extension OpenAPI.Tag {
    public struct Kind : ExpressibleByStringLiteral, Codable, Equatable, Sendable {
        public let rawValue: String

        public init(stringLiteral: String) {
            self.rawValue = stringLiteral
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.rawValue = try container.decode(String.self)
        }

      public func encode(to encoder: Encoder) throws {
          var container = encoder.singleValueContainer()

          try container.encode(rawValue)
      }
    }
}

extension OpenAPI.Tag.Kind {
    /// See https://spec.openapis.org/registry/tag-kind/audience.html
    public static let audience: OpenAPI.Tag.Kind = "audience"
    /// See https://spec.openapis.org/registry/tag-kind/badge.html
    public static let badge: OpenAPI.Tag.Kind = "badge"
    /// See https://spec.openapis.org/registry/tag-kind/nav.html
    public static let nav: OpenAPI.Tag.Kind = "nav"
}

extension OpenAPI.Tag: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name == rhs.name
          && lhs.summary == rhs.summary
          && lhs.description == rhs.description
          && lhs.externalDocs == rhs.externalDocs
          && lhs.parent == rhs.parent
          && lhs.kind == rhs.kind
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
            parent: parent,
            kind: kind,
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
            parent: parent,
            kind: kind,
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

        try container.encodeIfPresent(parent, forKey: .parent)

        try container.encodeIfPresent(kind, forKey: .kind)

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

        parent = try container.decodeIfPresent(String.self, forKey: .parent)

        kind = try container.decodeIfPresent(Kind.self, forKey: .kind)

        vendorExtensions = try Self.extensions(from: decoder)

        conditionalWarnings = [
            // If summary is non-nil, the document must be OAS version 3.2.0 or greater
            OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "summary", value: summary, minimumVersion: .v3_2_0),
            // If parent is non-nil, the document must be OAS version 3.2.0 or greater
            OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "parent", value: parent, minimumVersion: .v3_2_0),
            // If kind is non-nil, the document must be OAS version 3.2.0 or greater
            OASWarnings.Doc.nonNilVersionWarning(objectName: "Tag", fieldName: "kind", value: kind, minimumVersion: .v3_2_0)
        ].compactMap { $0 }
    }
}

extension OpenAPI.Tag {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case summary
        case description
        case externalDocs
        case parent
        case kind
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
                .summary,
                .description,
                .externalDocs,
                .parent,
                .kind
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
            case "parent":
                self = .parent
            case "kind":
                self = .kind
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
            case .parent:
                return "parent"
            case .kind:
                return "kind"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Tag: Validatable {}
