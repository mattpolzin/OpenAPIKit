//
//  ResponseStatusCode.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

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
public struct ResponseStatusCode: RawRepresentable, Equatable, Hashable, HasWarnings {
    public typealias RawValue = String

    public let warnings: [Warning]

    public var value: Code

    internal init(value: Code) {
        self.value = value
        warnings = []
    }

    public static let `default`: Self = .init(value: .default)
    public static func range(_ range: Range) -> Self { .init(value: .range(range)) }
    public static func status(code: Int) -> Self { .init(value: .status(code: code)) }

    public enum Code: Equatable, Hashable {
        case `default`
        case range(Range)
        case status(code: Int)
    }

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
        switch value {
        case .default:
            return "default"

        case .range(let range):
            return range.rawValue

        case .status(code: let code):
            return String(code)
        }
    }

    public var isSuccess: Bool {
        switch value {
        case .range(.success), .status(code: 200..<300):
            return true
        case .range, .status, .default:
            return false
        }
    }

    public init?(rawValue: String) {
        if let val = Int(rawValue) {
            value = .status(code: val)
            warnings = []
        } else if rawValue == "default" {
            value = .default
            warnings = []
        } else if let range = Range(rawValue: rawValue.uppercased()) {
            value = .range(range)
            warnings = []
        } else if rawValue.contains("/"),
                  let first = (rawValue.split(separator: "/")).first,
                  let fallback = Self(rawValue: String(first)) {
            value = fallback.value
            warnings = [
                .message("Found non-compliant Status Code '\(rawValue)' but was able to parse as \(first)")
            ]
        } else {
            return nil
        }
    }
}

extension ResponseStatusCode: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.value = .status(code: value)
        warnings = []
    }
}
