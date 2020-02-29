//
//  Response.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import Poly
import OrderedDictionary

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
    public typealias Map = OrderedDictionary<StatusCode, Either<JSONReference<OpenAPI.Components, OpenAPI.Response>, OpenAPI.Response>>
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
extension Either where A == JSONReference<OpenAPI.Components, OpenAPI.Response>, B == OpenAPI.Response {

    public static func response(
        description: String,
        headers: OpenAPI.Header.Map? = nil,
        content: OpenAPI.Content.Map
    ) -> Self {
        return .b(
            .init(
                description: description,
                headers: headers,
                content: content
            )
        )
    }

    public static func response(reference: JSONReference<OpenAPI.Components, OpenAPI.Response>) -> Self {
        return .a(reference)
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
            try container.encode(content, forKey: .content)
        }
    }
}

extension OpenAPI.Response: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        do {
            description = try container.decode(String.self, forKey: .description)

            headers = try container.decodeIfPresent(OpenAPI.Header.Map.self, forKey: .headers)

            content = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content) ?? [:]

        } catch let error as InconsistencyError {
            throw OpenAPI.Error.Decoding.Response(error)
        } catch let error as PolyDecodeNoTypesMatchedError {
            throw OpenAPI.Error.Decoding.Response(error)
        } catch let error as DecodingError {
            throw OpenAPI.Error.Decoding.Response(error)
        }
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
        let strVal = try container.decode(String.self)
        let val = OpenAPI.Response.StatusCode(rawValue: strVal)

        guard let value = val else {
            throw InconsistencyError(
                subjectName: "status code",
                details: "Expected the status code to be either an Int or 'default' but found \(strVal) instead",
                codingPath: decoder.codingPath
            )
        }

        self = value
    }
}
