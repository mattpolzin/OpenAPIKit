//
//  Request.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

public struct OpenAPIRequest: Equatable {
    public let description: String?
    public let content: OpenAPIPathItem.PathProperties.Operation.ContentMap
    public let required: Bool

    public init(description: String? = nil,
                content: OpenAPIPathItem.PathProperties.Operation.ContentMap,
                required: Bool = true) {
        self.description = description
        self.content = content
        self.required = required
    }
}

// MARK: - Codable

extension OpenAPIRequest: Encodable {
    private enum CodingKeys: String, CodingKey {
        case description
        case content
        case required
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if description != nil {
            try container.encode(description, forKey: .description)
        }

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            content.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .content)

        try container.encode(required, forKey: .required)
    }
}
