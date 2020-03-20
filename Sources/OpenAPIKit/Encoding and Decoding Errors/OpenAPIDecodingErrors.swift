//
//  OpenAPIDecodingErrors.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation

extension OpenAPI.Error {
    // Just creating a namespace
    public enum Decoding {}
}

public enum ErrorCategory {
    case typeMismatch(expectedTypeName: String)
    case typeMismatch2(possibleTypeName1: String, possibleTypeName2: String, details: String)
    case missing(KeyValue)
    case dataCorrupted(underlying: Swift.Error?)
    case inconsistency(details: String)

    public enum KeyValue {
        case key
        case value
    }
}

public protocol OpenAPIError: Swift.Error {
    var subjectName: String { get }
    var contextString: String { get }
    var errorCategory: ErrorCategory { get }
    var codingPath: [CodingKey] { get }
}

public extension OpenAPIError {
    /// Description of error given in the structure:
    /// `subject` `context` `error`: `details`
    ///
    /// A subject, context, and error are all guaranteed.
    /// The details are only provided in certain contexts.
    var localizedDescription: String {
        let subjectString: String = {
            switch errorCategory {
            case .missing(let keyOrValue):
                switch keyOrValue {
                case .key:
                    return "Expected to find `\(subjectName)` key"
                case .value:
                    return "Expected `\(subjectName)` value"
                }
            case .typeMismatch(expectedTypeName: _):
                if subjectName == "[unknown object]" {
                    return "Expected value"
                } else {
                    return "Expected `\(subjectName)` value"
                }
            case .typeMismatch2(possibleTypeName1: let type1, possibleTypeName2: let type2, details: _):
                return "Found neither a \(type1) nor a \(type2)"
            case .dataCorrupted:
                return "Could not parse `\(subjectName)`"
            case .inconsistency(details: _):
                return "Inconsistency encountered when parsing `\(subjectName)`"
            }
        }()

        let contextString = self.contextString.isEmpty ? "" : " \(self.contextString)"

        let errorTypeString: String = {
            switch errorCategory {
            case .typeMismatch(expectedTypeName: let typeName):
                return " to be parsable as \(typeName) but it was not"
            case .typeMismatch2(possibleTypeName1: _, possibleTypeName2: _, details: let details):
                return ". \(details)"
            case .missing(let keyOrValue):
                switch keyOrValue {
                case .key:
                    return " but it is missing"
                case .value:
                    return " to be non-null but it is null"
                }
            case .dataCorrupted(underlying: let error):
                return error.map { ":\n\n" + $0.localizedDescription } ?? ""
            case .inconsistency(details: let details):
                return ": \(details)"
            }
        }()

        return "\(subjectString)\(contextString)\(errorTypeString)."
    }
}

internal extension Swift.Array where Element == CodingKey {
    var stringValue: String {
        return self.map { key in
            if let intValue = key.intValue {
                return "[\(intValue)]"
            }
            let strValue = key.stringValue
            if strValue.contains("/") {
                return "['\(strValue)']"
            }
            return ".\(strValue)"
        }.joined()
    }

    /// Get a relative coding path. Given a shorter other coding path, this will
    /// return the part of this coding path not overlapping with the given path.
    ///
    /// Given:
    ///
    ///     self = ["a", "b", "c"]
    ///     other = ["a", "b"]
    ///
    /// The result will be:
    ///
    ///     ["c"]
    ///
    func relative(to other: [CodingKey]) -> [CodingKey] {
        Array(
            self
                .enumerated()
                .drop { (offset, codingKey) in
                    other.lazy.enumerated().contains { $0.0 == offset && $0.1.stringValue == codingKey.stringValue }
            }.map { $0.1 }
        )
    }
}
