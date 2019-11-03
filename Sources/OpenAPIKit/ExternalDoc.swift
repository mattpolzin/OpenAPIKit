//
//  ExternalDoc.swift
//  
//
//  Created by Mathew Polzin on 11/2/19.
//

import Foundation

extension OpenAPI {
    public struct ExternalDoc: Codable, Equatable {
        public let description: String?
        public let url: URL

        public init(description: String? = nil,
                    url: URL) {
            self.description = description
            self.url = url
        }
    }
}
