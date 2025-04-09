//
//  ContentEncoding.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore

extension OpenAPI.Content {
    /// OpenAPI Spec "Encoding Object"
    /// 
    /// See [OpenAPI Encoding Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#encoding-object).
    public struct Encoding: Equatable, CodableVendorExtendable {
        public typealias Style = OpenAPI.Parameter.SchemaContext.Style

        public let contentType: OpenAPI.ContentType?
        public let headers: OpenAPI.Header.Map?
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public init(
            contentType: OpenAPI.ContentType? = nil,
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            allowReserved: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.contentType = contentType
            self.headers = headers
            self.style = style
            self.explode = style.defaultExplode
            self.allowReserved = allowReserved
            self.vendorExtensions = vendorExtensions
        }

        public init(
            contentType: OpenAPI.ContentType? = nil,
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            explode: Bool,
            allowReserved: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.contentType = contentType
            self.headers = headers
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
            self.vendorExtensions = vendorExtensions
        }

        public static let defaultStyle: Style = .default(for: .query)
    }
}

// MARK: - Codable
extension OpenAPI.Content.Encoding: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(contentType, forKey: .contentType)
        try container.encodeIfPresent(headers, forKey: .headers)

        if style != Self.defaultStyle {
            try container.encode(style, forKey: .style)
        }

        if explode != style.defaultExplode {
            try container.encode(explode, forKey: .explode)
        }

        if allowReserved != false {
            try container.encode(allowReserved, forKey: .allowReserved)
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.Content.Encoding: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        contentType = try container.decodeIfPresent(OpenAPI.ContentType.self, forKey: .contentType)

        headers = try container.decodeIfPresent(OpenAPI.Header.Map.self, forKey: .headers)

        let style: Style = try container.decodeIfPresent(Style.self, forKey: .style) ?? Self.defaultStyle
        self.style = style

        explode = try container.decodeIfPresent(Bool.self, forKey: .explode) ?? style.defaultExplode

        allowReserved = try container.decodeIfPresent(Bool.self, forKey: .allowReserved) ?? false

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Content.Encoding {
    internal enum CodingKeys: ExtendableCodingKey {
        case contentType
        case headers
        case style
        case explode
        case allowReserved
        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [.contentType, .headers, .style, .explode, .allowReserved]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "contentType":
                self = .contentType
            case "headers":
                self = .headers
            case "style":
                self = .style
            case "explode":
                self = .explode
            case "allowReserved":
                self = .allowReserved
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        var stringValue: String {
            switch self {
            case .contentType:
                return "contentType"
            case .headers:
                return "headers"
            case .style:
                return "style"
            case .explode:
                return "explode"
            case .allowReserved:
                return "allowReserved"
            case .extended(let key):
                return key
            }
        }
    }
}

extension OpenAPI.Content.Encoding: Validatable {}
