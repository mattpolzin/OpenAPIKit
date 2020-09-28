//
//  ContentEncoding.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI.Content {
    /// OpenAPI Spec "Encoding Object"
    /// 
    /// See [OpenAPI Encoding Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#encoding-object).
    public struct Encoding: Equatable {
        public typealias Style = OpenAPI.Parameter.SchemaContext.Style

        public let contentType: OpenAPI.ContentType?
        public let headers: OpenAPI.Header.Map?
        public let style: Style
        public let explode: Bool
        public let allowReserved: Bool

        public init(
            contentType: OpenAPI.ContentType? = nil,
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            allowReserved: Bool = false
        ) {
            self.contentType = contentType
            self.headers = headers
            self.style = style
            self.explode = style.defaultExplode
            self.allowReserved = allowReserved
        }

        public init(
            contentType: OpenAPI.ContentType? = nil,
            headers: OpenAPI.Header.Map? = nil,
            style: Style = Self.defaultStyle,
            explode: Bool,
            allowReserved: Bool = false
        ) {
            self.contentType = contentType
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
