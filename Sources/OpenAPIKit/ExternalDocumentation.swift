//
//  ExternalDocumentation.swift
//  
//
//  Created by Mathew Polzin on 11/2/19.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {
    /// OpenAPI Spec "External Documentation Object"
    /// 
    /// See [OpenAPI External Documentation Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#external-documentation-object).
    public struct ExternalDocumentation: Equatable, CodableVendorExtendable {
        public var description: String?
        public var url: URL

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            description: String? = nil,
            url: URL,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.description = description
            self.url = url
            self.vendorExtensions = vendorExtensions
        }
    }
}

// MARK: - Describable

extension OpenAPI.ExternalDocumentation : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.ExternalDocumentation {
        guard let description = description else { return self }
        return OpenAPI.ExternalDocumentation(
            description: description,
            url: url,
            vendorExtensions: vendorExtensions
        )
    }
}

// MARK: - Codable

extension OpenAPI.ExternalDocumentation: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(url.absoluteString, forKey: .url)

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.ExternalDocumentation: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decodeIfPresent(String.self, forKey: .description)
        url = try container.decodeURLAsString(forKey: .url)

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.ExternalDocumentation {
    internal enum CodingKeys: ExtendableCodingKey {
        case description
        case url
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .description,
                .url
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "description":
                self = .description
            case "url":
                self = .url
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .description:
                return "description"
            case .url:
                return "url"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.ExternalDocumentation: Validatable {}
