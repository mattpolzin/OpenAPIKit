//
//  File.swift
//  
//
//  Created by Mathew Polzin on 10/6/19.
//

import Foundation

extension OpenAPI {
    public struct Discriminator: Equatable, Codable {
        public let propertyName: String
        public let mapping: [String: String]?

        public init(propertyName: String,
                    mapping: [String: String]? = nil) {
            self.propertyName = propertyName
            self.mapping = mapping
        }
    }
}
