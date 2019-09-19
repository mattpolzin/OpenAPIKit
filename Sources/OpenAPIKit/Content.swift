//
//  Content.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly
import AnyCodable

extension OpenAPI {
    public enum ContentType: String, Codable, Equatable, Hashable {
        case json = "application/json"
        case xml = "application/xml"
        case form = "application/x-www-form-urlencoded"
    }

    public struct Content: Equatable {
        public let schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>
        public let example: AnyCodable?
        //        public let examples:
        public let encoding: [String: Encoding]?

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public let vendorExtensions: [String: AnyCodable]

        public init(schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>,
                    example: AnyCodable? = nil,
                    encoding: [String: Encoding]? = nil,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.schema = schema
            self.example = example
            self.encoding = encoding
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Content {
    public typealias Map = [OpenAPI.ContentType: OpenAPI.Content]
}

extension OpenAPI.Content {
    public struct Encoding: Codable, Equatable {
        public let contentType: OpenAPI.ContentType?
        public let headers: OpenAPI.Header.Map?
//        public let style: String?
//        public let explode: Bool (defaults for this need to be tied to style making style a good candidate for abstraction)
        public let allowReserved: Bool

        public init(contentType: OpenAPI.ContentType? = nil,
                    headers: OpenAPI.Header.Map? = nil,
                    allowReserved: Bool = false) {
            self.contentType = contentType
            self.headers = headers
            self.allowReserved = allowReserved
        }
    }
}

// MARK: - Codable

extension OpenAPI.Content: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(schema, forKey: .schema)

        if example != nil {
            try container.encode(example, forKey: .example)
        }

        if encoding != nil {
            try container.encode(encoding, forKey: .encoding)
        }

        if vendorExtensions != [:] {
            for (key, value) in vendorExtensions {
                let xKey = key.starts(with: "x-") ? key : "x-\(key)"
                try container.encode(value, forKey: .extended(xKey))
            }
        }
    }
}

extension OpenAPI.Content: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        schema = try container.decode(Either<JSONReference<OpenAPI.Components, JSONSchema>, JSONSchema>.self, forKey: .schema)
        example = try container.decodeIfPresent(AnyCodable.self, forKey: .example)
        encoding = try container.decodeIfPresent([String: Encoding].self, forKey: .encoding)

        let decodedAny = (try AnyCodable(from: decoder)).value as? [String: Any]

        vendorExtensions = decodedAny?.filter {
            guard let key = CodingKeys(stringValue: $0.key) else { return false }

            return !CodingKeys.allBuiltinCases.contains(key)
        }.mapValues(AnyCodable.init) ?? [:]
    }
}

extension OpenAPI.Content {
    private enum CodingKeys: CodingKey, Equatable {
        case schema
        case example
        case encoding
        case extended(String)

        init?(stringValue: String) {
            switch stringValue {
            case "schema":
                self = .schema
            case "example":
                self = .example
            case "encoding":
                self = .encoding
            default:
                self = .extended(stringValue)
            }
        }

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String {
            switch self {
            case .schema:
                return "schema"
            case .example:
                return "example"
            case .encoding:
                return "encoding"
            case .extended(let key):
                return key
            }
        }

        var intValue: Int? {
            return nil
        }

        static var allBuiltinCases: [CodingKeys] {
            return [.schema, .example, .encoding]
        }
    }
}
