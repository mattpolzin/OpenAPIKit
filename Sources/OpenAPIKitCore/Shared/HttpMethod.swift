//
//  HttpMethod.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension Shared {
    /// Represents the HTTP methods supported by the
    /// OpenAPI Specification.
    ///
    /// See [OpenAPI Path Item Object](https://spec.openapis.org/oas/v3.2.0.html#path-item-object)
    /// because the supported HTTP methods are enumerated as properties on that
    /// object.
    public enum BuiltinHttpMethod: String, CaseIterable, Sendable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case trace = "TRACE"
        case query = "QUERY"
    }

    /// Represents an HTTP method.
    ///
    /// See [OpenAPI Path Item Object](https://spec.openapis.org/oas/v3.2.0.html#path-item-object).
    /// 
    /// Methods are split into builtin methods (those representable as
    /// properties on a Path Item Object) and other methods (those that can be
    /// added to the `additionalOperations` of a Path Item Object).
    ///
    /// `HttpMethod` is `ExpressibleByStringLiteral` so you can write a
    /// non-builtin method like "LINK" as:
    /// `let linkMethod : OpenAPI.HttpMethod = "LINK"`
    public enum HttpMethod: ExpressibleByStringLiteral, RawRepresentable, Equatable, Hashable, Codable, Sendable {
        case builtin(BuiltinHttpMethod)
        case other(String)

        public static let get = Self.builtin(.get)
        public static let post = Self.builtin(.post)
        public static let patch = Self.builtin(.patch)
        public static let put = Self.builtin(.put)
        public static let delete = Self.builtin(.delete)
        public static let head = Self.builtin(.head)
        public static let options = Self.builtin(.options)
        public static let trace = Self.builtin(.trace)
        public static let query = Self.builtin(.query)

        public var rawValue: String {
            switch self {
                case .builtin(let builtin): builtin.rawValue
                case .other(let other): other
            }
        }

        public init?(rawValue: String) {
            if let builtin = BuiltinHttpMethod.init(rawValue: rawValue) {
                self = .builtin(builtin)
                return
            }

            let uppercasedValue = rawValue.uppercased()
            if Self.additionalKnownUppercaseMethods.contains(uppercasedValue) && rawValue != uppercasedValue {
                return nil
            }

            // we accept that we do not know the correct capitalization for all
            // possible method names and fall back to whatever the user has
            // entered.
            self = .other(rawValue)
        }

        public init(stringLiteral value: String) {
            if let valid = Self.init(rawValue: value) {
                self = valid
                return
            }
            // we accept that a value may be invalid if it has been hard coded
            // as a literal because there is no compile-time evaluation and so
            // no way to prevent this without sacrificing code cleanliness.
            self = .other(value)
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()

            let attemptedMethod = try container.decode(String.self)

            if let value = Self.init(rawValue: attemptedMethod) {
                self = value
                return
            }

            throw GenericError(subjectName: "HTTP Method", details: "Failed to decode an HTTP method from \(attemptedMethod). This method name must be an uppercased string", codingPath: decoder.codingPath)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()

            try container.encode(self.rawValue)
        }

        internal static let additionalKnownUppercaseMethods = [
            "LINK",
            "CONNECT"
        ]
    }
}

extension Shared.HttpMethod: StringConvertibleHintProvider {
    public static func problem(with proposedString: String) -> String? {
        let uppercasedValue = proposedString.uppercased()
        if Self.additionalKnownUppercaseMethods.contains(uppercasedValue) && proposedString != uppercasedValue {
            return "'\(proposedString)' must be uppercased"
        }

        return nil
    }
}
