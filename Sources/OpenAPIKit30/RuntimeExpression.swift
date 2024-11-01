//
//  RuntimeExpression.swift
//  
//
//  Created by Mathew Polzin on 11/1/20.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Runtime Expression"
    ///
    /// See [OpenAPI Runtime Expression[(https://spec.openapis.org/oas/v3.0.4.html#runtime-expressions).
    ///
    public enum RuntimeExpression: RawRepresentable, Equatable {
        case url
        case method
        case statusCode
        case request(Source)
        case response(Source)

        public var rawValue: String {
            switch self {
            case .url:
                return "$url"
            case .method:
                return "$method"
            case .statusCode:
                return "$statusCode"
            case .request(let source):
                return "$request.\(source.rawValue)"
            case .response(let source):
                return "$response.\(source.rawValue)"
            }
        }

        public init?(rawValue: String) {
            // URL
            if rawValue == "$url" {
                self = .url
                return
            }

            // METHOD
            if rawValue == "$method" {
                self = .method
                return
            }

            // STATUS CODE
            if rawValue == "$statusCode" {
                self = .statusCode
                return
            }

            // REQUEST
            if rawValue.starts(with: "$request.") {
                guard let source = Source(rawValue.dropFirst(9)) else {
                    return nil
                }
                self = .request(source)
                return
            }

            // RESPONSE
            if rawValue.starts(with: "$response.") {
                guard let source = Source(rawValue.dropFirst(10)) else {
                    return nil
                }
                self = .response(source)
                return
            }

            return nil
        }

        public enum Source: RawRepresentable, Equatable {
            /// A reference to one of the header parameters.
            case header(name: String)
            /// A reference to one of the query parameters.
            case query(name: String)
            /// A reference to one of the path parameters.
            case path(name: String)
            /// A JSON Pointer to part of the requset or response body.
            ///
            /// You can leave the reference as `nil` to just refer to the body
            /// as a whole.
            case body(JSONReference<JSONSchema>.InternalReference?)

            public var rawValue: String {
                switch self {
                case .header(name: let name):
                    return "header.\(name)"
                case .query(name: let name):
                    return "query.\(name)"
                case .path(name: let name):
                    return "path.\(name)"
                case .body(let reference):
                    let referenceString = reference.map { $0.rawValue } ?? ""
                    return "body\(referenceString)"
                }
            }

            public init?(rawValue: String) {
                self.init(rawValue)
            }

            internal init?<S: StringProtocol>(_ rawValue: S) {
                // HEADER
                if rawValue.starts(with: "header.") {
                    self = .header(name: String(rawValue.dropFirst(7)))
                    return
                }

                // QUERY
                if rawValue.starts(with: "query.") {
                    self = .query(name: String(rawValue.dropFirst(6)))
                    return
                }

                // PATH
                if rawValue.starts(with: "path.") {
                    self = .path(name: String(rawValue.dropFirst(5)))
                    return
                }

                // BODY
                if rawValue.starts(with: "body") {
                    let bodyReference = rawValue.dropFirst(4)
                    if bodyReference.isEmpty {
                        self = .body(nil)
                        return
                    }
                    self = .body(Self.parseBodyReference(String(bodyReference)))
                    return
                }

                return nil
            }

            internal static func parseBodyReference(_ input: String) -> JSONReference<JSONSchema>.InternalReference? {
                return JSONReference<JSONSchema>.InternalReference(rawValue: input)
            }
        }
    }
}

// MARK: - Codable

extension OpenAPI.RuntimeExpression: Encodable {
    // uses raw representation
}

extension OpenAPI.RuntimeExpression: Decodable {
    // uses raw representation
}
