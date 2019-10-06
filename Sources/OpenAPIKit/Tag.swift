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
    }
}
