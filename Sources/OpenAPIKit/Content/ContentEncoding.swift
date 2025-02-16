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
    /// See [OpenAPI Encoding Object](https://spec.openapis.org/oas/v3.1.1.html#encoding-object).
    public struct Encoding: Equatable, Sendable {
        public typealias Style = OpenAPI.Parameter.SchemaContext.Style

        public let contentTypes: [OpenAPI.ContentType]
        public let headers: OpenAPI.Header.Map?
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool

        public init(
            contentTypes: [OpenAPI.ContentType] = [],
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            allowReserved: Bool = false
        ) {
            self.contentTypes = contentTypes
            self.headers = headers
            self.style = style
            self.explode = style.defaultExplode
            self.allowReserved = allowReserved
        }

        public init(
            contentTypes: [OpenAPI.ContentType] = [],
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            explode: Bool,
            allowReserved: Bool = false
        ) {
            self.contentTypes = contentTypes
            self.headers = headers
            self.style = style
            self.explode = explode
            self.allowReserved = allowReserved
        }

        public static let defaultStyle: Style = .default(for: .query)
    }
}

// MARK: - Codable
extension OpenAPI.Content.Encoding: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if contentTypes.count > 0 {
            let contentTypesString = contentTypes
                .map(\.rawValue)
                .joined(separator: ", ")
            try container.encode(contentTypesString, forKey: .contentType)
        }
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
    }
}

extension OpenAPI.Content.Encoding: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let contentTypesString = try container.decodeIfPresent(String.self, forKey: .contentType)
        if let contentTypesString {
            contentTypes = contentTypesString
                .split(separator: ",")
                .compactMap { string in
                    OpenAPI.ContentType.init(rawValue: string.trimmingCharacters(in: .whitespaces))
                }
        } else {
            contentTypes = []
        }

        headers = try container.decodeIfPresent(OpenAPI.Header.Map.self, forKey: .headers)

        let style: Style = try container.decodeIfPresent(Style.self, forKey: .style) ?? Self.defaultStyle
        self.style = style

        explode = try container.decodeIfPresent(Bool.self, forKey: .explode) ?? style.defaultExplode

        allowReserved = try container.decodeIfPresent(Bool.self, forKey: .allowReserved) ?? false
    }
}

extension OpenAPI.Content.Encoding {
    private enum CodingKeys: String, CodingKey {
        case contentType
        case headers
        case style
        case explode
        case allowReserved
    }
}

extension OpenAPI.Content.Encoding: Validatable {}
