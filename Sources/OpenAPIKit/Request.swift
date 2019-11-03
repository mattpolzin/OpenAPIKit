//
//  Request.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    public struct Request: Equatable {
        public let description: String?
        public let content: Content.Map
        public let required: Bool

        public init(description: String? = nil,
                    content: Content.Map,
                    required: Bool = false) {
            self.description = description
            self.content = content
            self.required = required
        }
    }
}

// MARK: - Codable

extension OpenAPI.Request: Encodable {
    private enum CodingKeys: String, CodingKey {
        case description
        case content
        case required
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try description.encodeIfNotNil(to: &container, forKey: .description)

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            content.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .content)

        if required {
            try container.encode(required, forKey: .required)
        }
    }
}

extension OpenAPI.Request: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decodeIfPresent(String.self, forKey: .description)

        // hacky workaround for Dictionary decoding bug
        let contentDict = try container.decode([String: OpenAPI.Content].self, forKey: .content)
        content = Dictionary(contentDict.compactMap { contentTypeString, content in
            OpenAPI.ContentType(rawValue: contentTypeString).map { ($0, content) } },
                             uniquingKeysWith: { $1 })

        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
    }
}
