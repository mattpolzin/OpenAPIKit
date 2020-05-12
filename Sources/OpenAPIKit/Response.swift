//
//  Response.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

extension OpenAPI {
    /// OpenAPI Spec "Response Object"
    ///
    /// See [OpenAPI Response Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#response-object).
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
    public typealias Map = OrderedDictionary<StatusCode, Either<JSONReference<OpenAPI.Response>, OpenAPI.Response>>
}

// MARK: - Status Code
extension OpenAPI.Response {
    /// An HTTP Status code or status code range.
    ///
    /// OpenAPI supports one of the following as a key in the [Responses Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#responses-object):
    /// - A `default` entry.
    /// - A specific status code.
    /// - A status code range.
    ///
    /// The `.default` case is used for a default entry.
    ///
    /// You can use integer literals to specify an exact status code.
    ///
    /// Status code ranges are named in the `StatusCode.Range` enum. For example, the "1XX" range (100-199) can be written as either `.range(.information)` or as `.range(.init(rawValue: "1XX"))`.
    public enum StatusCode: RawRepresentable, Equatable, Hashable {
        public typealias RawValue = String

        case `default`
        case range(Range)
        case status(code: Int)

        public enum Range: String {
            /// Status Code `100-199`
            case information = "1XX"
            /// Status Code `200-299`
            case success = "2XX"
            /// Status Code `300-399`
            case redirect = "3XX"
            /// Status Code `400-499`
            case clientError = "4XX"
            /// Status Code `500-599`
            case serverError = "5XX"
        }

        public var rawValue: String {
            switch self {
            case .default:
                return "default"

            case .range(let range):
                return range.rawValue

            case .status(code: let code):
                return String(code)
            }
        }

        public var isSuccess: Bool {
            switch self {
            case .range(.success), .status(code: 200..<300):
                return true
            case .range, .status, .default:
                return false
            }
        }

        public init?(rawValue: String) {
            if let val = Int(rawValue) {
                self = .status(code: val)

            } else if rawValue == OpenAPI.Response.StatusCode.default.rawValue {
                self = .default

            } else if let range = Range(rawValue: rawValue.uppercased()) {
                self = .range(range)

            } else if rawValue.contains("/"),
                let first = (rawValue.split(separator: "/")).first,
                let fallback = Self(rawValue: String(first)) {
                self = fallback
                print("WARNING: Found non-compliant Status Code '\(rawValue)' but was able to parse as \(first)")

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
extension Either where A == JSONReference<OpenAPI.Response>, B == OpenAPI.Response {

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
        } catch let error as EitherDecodeNoTypesMatchedError {

            throw OpenAPI.Error.Decoding.Response(error)
        } catch let error as DecodingError {

            throw OpenAPI.Error.Decoding.Response(error)
        }
    }
}

extension OpenAPI.Response.StatusCode: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(self.rawValue)
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
                details: "Expected the status code to be either an Int, a range like '1XX', or 'default' but found \(strVal) instead",
                codingPath: decoder.codingPath
            )
        }

        self = value
    }
}
