//
//  ExternalDoc.swift
//  
//
//  Created by Mathew Polzin on 11/2/19.
//

import Foundation

extension OpenAPI {
    public struct ExternalDoc: Equatable {
        public let description: String?
        public let url: URL

        public init(description: String? = nil,
                    url: URL) {
            self.description = description
            self.url = url
        }
    }
}

// MARK: - Codable

extension OpenAPI.ExternalDoc: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        try container.encode(url, forKey: .url)
    }
}

extension OpenAPI.ExternalDoc: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        url = try container.decode(URL.self, forKey: .url)
    }
}

extension OpenAPI.ExternalDoc {
    private enum CodingKeys: String, CodingKey {
        case description
        case url
    }
}
