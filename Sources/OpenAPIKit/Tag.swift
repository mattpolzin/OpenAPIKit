//
//  Tag.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation

extension OpenAPI {
    public struct Tag: Equatable, Codable {
        public let name: String
        public let description: String?
        public let externalDocs: ExternalDoc?

        public init(name: String,
                    description: String? = nil,
                    externalDocs: ExternalDoc? = nil) {
            self.name = name
            self.description = description
            self.externalDocs = externalDocs
        }
    }
}
