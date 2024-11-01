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
    /// See [OpenAPI Tag Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#tag-object).
    public struct Tag: Equatable, CodableVendorExtendable {
        public let name: String
        public let description: String?
        public let externalDocs: ExternalDocumentation?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            name: String,
            description: String? = nil,
            externalDocs: ExternalDocumentation? = nil,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.description = description
            self.externalDocs = externalDocs
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Tag: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(name: stringLiteral)
    }
}

// MARK: - Describable

extension OpenAPI.Tag : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Tag {
        guard let description = description else { return self }
        return OpenAPI.Tag(
            name: name,
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

        description = try container.decodeIfPresent(String.self, forKey: .description)

        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Tag {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case description
        case externalDocs
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
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
