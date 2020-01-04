//
//  Response.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly

extension OpenAPI {
    public struct Response: Equatable {
        public let description: String
        public let headers: Header.Map?
        public let content: Content.Map
        //    public let links:

        public init(description: String,
                    headers: Header.Map? = nil,
                    content: Content.Map) {
            self.description = description
            self.headers = headers
            self.content = content
        }
    }
}

extension OpenAPI.Response {
    public typealias Map = [StatusCode: Either<OpenAPI.Response, JSONReference<OpenAPI.Components, OpenAPI.Response>>]
}

// MARK: - Status Code
extension OpenAPI.Response {
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

            } else if rawValue == OpenAPI.Response.StatusCode.default.rawValue {
                self = .default

            } else {
                return nil
            }
        }
    }
}

extension OpenAPI.Response.StatusCode: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .status(code: value)
    }
}

// MARK: `Either` convenience methods
extension Either where A == OpenAPI.Response, B == JSONReference<OpenAPI.Components, OpenAPI.Response> {

    public static func response(
        description: String,
        headers: OpenAPI.Header.Map? = nil,
        content: OpenAPI.Content.Map
    ) -> Self {
        return .a(
            .init(
                description: description,
                headers: headers,
                content: content
            )
        )
    }

    public static func response(reference: JSONReference<OpenAPI.Components, OpenAPI.Response>) -> Self {
        return .b(reference)
    }
}

// MARK: - Codable

extension OpenAPI.Response {
    private enum CodingKeys: String, CodingKey {
        case description
        case headers
        case content
        //        case links
    }
}

extension OpenAPI.Response: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(description, forKey: .description)

        try headers.encodeIfNotNil(to: &container, forKey: .headers)

        if content.count > 0 {
            // Hack to work around Dictionary encoding
            // itself as an array in this case:
            let stringKeyedDict = Dictionary(
                content.map { ($0.key.rawValue, $0.value) },
                uniquingKeysWith: { $1 }
            )
            try container.encode(stringKeyedDict, forKey: .content)
        }
    }
}

extension OpenAPI.Response: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        description = try container.decode(String.self, forKey: .description)

        headers = try container.decodeIfPresent(OpenAPI.Header.Map.self, forKey: .headers)

        // hacky workaround for Dictionary decoding bug
        let maybeContentDict = try container.decodeIfPresent([String: OpenAPI.Content].self, forKey: .content)
        content = maybeContentDict.map { contentDict in
            Dictionary(contentDict.compactMap { contentTypeString, content in
                OpenAPI.ContentType(rawValue: contentTypeString).map { ($0, content) } },
                       uniquingKeysWith: { $1 })
        } ?? [:]
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

extension OpenAPI.Response.StatusCode: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let val = OpenAPI.Response.StatusCode(rawValue: try container.decode(String.self))

        guard let value = val else {
            throw OpenAPI.DecodingError.unknown(codingPath: decoder.codingPath)
        }

        self = value
    }
}
