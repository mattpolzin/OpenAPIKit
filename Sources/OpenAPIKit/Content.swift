//
//  File.swift
//  
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation
import Poly

extension OpenAPI {
    public enum ContentType: String, Codable, Equatable, Hashable {
        case json = "application/json"
        case xml = "application/xml"
        case form = "application/x-www-form-urlencoded"
    }

    public struct Content: Codable, Equatable {
        public let schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>
        //        public let example:
        //        public let examples:
        //        public let encoding:

        public init(schema: Either<JSONReference<Components, JSONSchema>, JSONSchema>) {
            self.schema = schema
        }
    }
}

extension OpenAPI.Content {
    public typealias Map = [OpenAPI.ContentType: OpenAPI.Content]
}
