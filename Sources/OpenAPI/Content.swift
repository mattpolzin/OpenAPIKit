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
    }

    public struct Content: Codable, Equatable {
        public let schema: Either<JSONSchemaObject, JSONReference<Components, JSONSchemaObject>>
        //        public let example:
        //        public let examples:
        //        public let encoding:

        public init(schema: Either<JSONSchemaObject, JSONReference<Components, JSONSchemaObject>>) {
            self.schema = schema
        }
    }
}

extension OpenAPI.Content {
    public typealias Map = [OpenAPI.ContentType: Self]
}
