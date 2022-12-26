//
//  OpenAPIDecodingErrors.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

extension Error {
    // Just creating a namespace
    public enum Decoding {}
}

public enum ErrorCategory {
    /// The type with the given name was expected but not found.
    case typeMismatch(expectedTypeName: String)
    /// One of two possible types were expected but neither was found.
    case typeMismatch2(possibleTypeName1: String, possibleTypeName2: String, details: String)
    /// Either a key or value was missing.
    case missing(KeyValue)
    /// There was a data corruption issue (a bit of a catchall for errors not categorized otherwise).
    case dataCorrupted(underlying: Swift.Error?)
    /// Something inconsistent or disallowed according the OpenAPI Specification was found.
    case inconsistency(details: String)

    public enum KeyValue {
        case key
        case value
    }
}

public protocol OpenAPIError: Swift.Error, CustomStringConvertible {
    /// The subject of the error (i.e. the thing being worked with
    ///     when the error occurred).
    ///
    /// In the error description "Expected to find `title`
    ///     key in Document.info but it is missing." the **subject** is
    ///     "title".
    var subjectName: String { get }
    /// The context of the error (i.e. where in the document the error
    ///     occurred).
    ///
    /// In the error description "Expected to find `title`
    ///     key in Document.info but it is missing." the **context** is
    ///     "Document.info".
    var contextString: String { get }
    /// The category of error that occurred.
    ///
    /// The category can also carry a bit of contextual information that
    /// is only relevant for the given category.
    ///
    /// In the error description "Expected to find `title`
    ///     key in Document.info but it is missing." the **category** is
    ///     `.missing(.key)`.
    var errorCategory: ErrorCategory { get }
    /// The complete coding path for where the error occurred.
    ///
    /// This will often overlap with the `contextString` but there is not
    /// a 1-1 relationship between the two. This is the same concept of
    /// "codingPath" as is used elsewhere for the Swift `Codable` featureset.
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

    var description: String { localizedDescription }
}

public extension Swift.Array where Element == CodingKey {
    var stringValue: String {
        return self.map { key in
            if let intValue = key.intValue {
                return "[\(intValue)]"
            }
            let stringValue = key.stringValue
            if stringValue.contains("/") {
                return "['\(stringValue)']"
            }
            return ".\(stringValue)"
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
