//
//  Request.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Request Body Object"
    ///
    /// See [OpenAPI Request Body Object](https://spec.openapis.org/oas/v3.0.4.html#request-body-object).
    public struct Request: Equatable, CodableVendorExtendable, Sendable {
        public var description: String?
        public var content: Content.Map
        public var required: Bool

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            description: String? = nil,
            content: Content.Map,
            required: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.description = description
            self.content = content
            self.required = required
            self.vendorExtensions = vendorExtensions
        }
    }
}

// MARK: - Codable

extension OpenAPI.Request {
    internal enum CodingKeys: ExtendableCodingKey {
        case description
        case content
        case required
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .description,
                .content,
                .required
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "description":
                self = .description
            case "content":
                self = .content
            case "required":
                self = .required
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .description:
                return "description"
            case .content:
                return "content"
            case .required:
                return "required"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Request: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(content, forKey: .content)

        if required {
            try container.encode(required, forKey: .required)
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Request: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            description = try container.decodeIfPresent(String.self, forKey: .description)
            content = try container.decode(OpenAPI.Content.Map.self, forKey: .content)
            required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false

            vendorExtensions = try Self.extensions(from: decoder)
        } catch let error as InconsistencyError {

            throw OpenAPI.Error.Decoding.Request(error)
        } catch let error as Swift.DecodingError {

            throw OpenAPI.Error.Decoding.Request(error)
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Request(error)
        }
    }
}

extension OpenAPI.Request: Validatable {}
