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

    public struct Content: Codable, Equatable {
        public let schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>
        public let example: AnyCodable?
        //        public let examples:
        public let encoding: [String: Encoding]?

        public init(schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>,
                    example: AnyCodable? = nil,
                    encoding: [String: Encoding]? = nil) {
            self.schema = schema
            self.example = example
            self.encoding = encoding
        }
    }
}

extension OpenAPI.Content {
    public typealias Map = [OpenAPI.ContentType: OpenAPI.Content]
}

extension OpenAPI.Content {
    public struct Encoding: Codable, Equatable {
        public let contentType: String?
        public let headers: OpenAPI.Header.Map?
//        public let style: String?
//        public let explode: Bool (defaults for this need to be tied to style making style a good candidate for abstraction)
        public let allowReserved: Bool

        public init(contentType: String? = nil,
                    headers: OpenAPI.Header.Map? = nil,
                    allowReserved: Bool = false) {
            self.contentType = contentType
            self.headers = headers
            self.allowReserved = allowReserved
        }
    }
}
