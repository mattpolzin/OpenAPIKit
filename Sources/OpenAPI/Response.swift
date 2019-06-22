//
//  Response.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    public struct Response: Equatable {
        public let description: String
        //    public let headers:
        public let content: PathItem.PathProperties.Operation.ContentMap
        //    public let links:

        public init(description: String,
                    content: PathItem.PathProperties.Operation.ContentMap) {
            self.description = description
            self.content = content
        }

        public enum StatusCode: RawRepresentable, Equatable, Hashable {
            public typealias RawValue = String

            case `default`
            case status(code: Int)

            public var rawValue: String {
                switch self {
                case .default:
                    return "default"

                case .status(code: let code):
                    return String(code)
                }
            }

            public init?(rawValue: String) {
                if let val = Int(rawValue) {
                    self = .status(code: val)
                } else {
                    self = .default
                }
            }
        }
    }
}

// MARK: - Codable

extension OpenAPI.Response: Encodable {
    private enum CodingKeys: String, CodingKey {
        case description
        case headers
        case content
        case links
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(description, forKey: .description)

        // Hack to work around Dictionary encoding
        // itself as an array in this case:
        let stringKeyedDict = Dictionary(
            content.map { ($0.key.rawValue, $0.value) },
            uniquingKeysWith: { $1 }
        )
        try container.encode(stringKeyedDict, forKey: .content)
    }
}

extension OpenAPI.Response.StatusCode: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        let string: String
        switch self {
        case .`default`:
            string = "default"

        case .status(code: let code):
            string = String(code)
        }

        try container.encode(string)
    }
}
