//
//  OpenAPIDecodingErrors.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import Poly

extension OpenAPI.Error {
    public enum Decoding {}
}

public enum ErrorCategory {
    case typeMismatch(expectedTypeName: String)
    case typeMismatch2(possibleTypeName1: String, possibleTypeName2: String, details: String)
    case missing(KeyValue)
    case dataCorrupted
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
        let errorTypeString: String = {
            switch errorCategory {
            case .typeMismatch(expectedTypeName: let typeName):
                return " to be parsable as \(typeName) but it was not"
            case .typeMismatch2(possibleTypeName1: _, possibleTypeName2: _, details: let details):
                return " but found neither: \(details)"
            case .missing(let kv):
                switch kv {
                case .key:
                    return " but it is missing"
                case .value:
                    return " to be non-null but it is null"
                }
            case .dataCorrupted:
                return ""
            case .inconsistency(details: let details):
                return ": \(details)"
            }
        }()

        let subjectString: String = {
            switch errorCategory {
            case .missing(let kv):
                switch kv {
                case .key:
                    return "Expected to find `\(subjectName)` key"
                case .value:
                    return "Expected `\(subjectName)` value"
                }
            case .typeMismatch(expectedTypeName: _):
                return "Expected `\(subjectName)` value"
            case .typeMismatch2(possibleTypeName1: let t1, possibleTypeName2: let t2, details: _):
                return "Expected to find either a \(t1) or a \(t2)"
            case .dataCorrupted:
                return "Could not parse `\(subjectName)`"
            case .inconsistency(details: _):
                return "Inconsistency encountered when parsing `\(subjectName)`"
            }
        }()

        return "\(subjectString) \(contextString)\(errorTypeString)."
    }
}

internal extension Swift.Array where Element == CodingKey {
    var stringValue: String {
        return self.map { key in
            if let intVal = key.intValue {
                return "[\(intVal)]"
            }
            return ".\(key.stringValue)"
        }.joined()
    }
}

internal struct OpenAPIDecodingError: OpenAPIError {
    let decodingError: Swift.DecodingError

    var subjectName: String { decodingError.subjectName }

    var contextString: String {
        let relativeCodingPathString = decodingError.relativeCodingPathString

        return relativeCodingPathString.isEmpty
            ? ""
            : "in \(relativeCodingPathString)"
    }

    var errorCategory: ErrorCategory { decodingError.errorCategory }

    var codingPath: [CodingKey] { decodingError.codingPath }
}

internal extension Swift.DecodingError {
    var subjectName: String {
        let name: String? = {
            switch self {
            case .keyNotFound(let key, _):
                return "\(key.stringValue)"
            case .typeMismatch(_, let ctx), .valueNotFound(_, let ctx), .dataCorrupted(let ctx):
                return ctx.codingPath.last?.stringValue
            @unknown default:
                return nil
            }
        }()

        return name ?? "[unknown object]"
    }

    var codingPathWithoutSubject: [CodingKey] {
        switch self {
        case .keyNotFound(_, let ctx):
            return ctx.codingPath
        case .typeMismatch(_, let ctx), .valueNotFound(_, let ctx), .dataCorrupted(let ctx):
            return ctx.codingPath.count > 0 ? ctx.codingPath.dropLast() : []
        @unknown default:
            return []
        }
    }

    var codingPath: [CodingKey] {
        switch self {
        case .keyNotFound(_, let ctx), .typeMismatch(_, let ctx), .valueNotFound(_, let ctx), .dataCorrupted(let ctx):
            return ctx.codingPath
        @unknown default:
            return []
        }
    }

    var relativeCodingPathString: String {
        return codingPathWithoutSubject.stringValue
    }

    var errorCategory: ErrorCategory {
        switch self {
        case .typeMismatch(let type, _):
            return .typeMismatch(expectedTypeName: String(describing: type))
        case .valueNotFound:
            return .missing(.value)
        case .keyNotFound:
            return .missing(.key)
        case .dataCorrupted:
            return .dataCorrupted
        @unknown default:
            return .dataCorrupted
        }
    }

    var underlyingError: Swift.Error? {
        switch self {
        case .typeMismatch(_, let ctx), .valueNotFound(_, let ctx), .keyNotFound(_, let ctx), .dataCorrupted(let ctx):
            return ctx.underlyingError
        @unknown default:
            return nil
        }
    }

    func replacingPath(with codingPath: [CodingKey]) -> Self {
        switch self {
        case .typeMismatch(let type, let ctx):
            return .typeMismatch(type, ctx.replacingPath(with: codingPath))
        case .valueNotFound(let type, let ctx):
            return .valueNotFound(type, ctx.replacingPath(with: codingPath))
        case .keyNotFound(let key, let ctx):
            return .keyNotFound(key, ctx.replacingPath(with: codingPath))
        case .dataCorrupted(let ctx):
            return .dataCorrupted(ctx.replacingPath(with: codingPath))
        @unknown default:
            return .dataCorrupted(.init(codingPath: codingPath, debugDescription: "unknown error"))
        }
    }
}

internal extension PolyDecodeNoTypesMatchedError {
    var subjectName: String {
        return codingPath.last?.stringValue ?? "[unknown object]"
    }

    var codingPathWithoutSubject: [CodingKey] {
        return codingPath.count > 0 ? codingPath.dropLast() : []
    }

    var relativeCodingPathString: String {
        return codingPathWithoutSubject.stringValue
    }

    var errorCategory: ErrorCategory {
        guard let f1 = individualTypeFailures.first, let f2 = individualTypeFailures.dropFirst().first else {
            return .dataCorrupted
        }
        func typeString(_ t: Any.Type) -> String {
            if (t as? Reference.Type) != nil {
                return "$ref"
            }
            return String(describing: t)
        }
        return .typeMismatch2(
            possibleTypeName1: typeString(f1.type),
            possibleTypeName2: typeString(f2.type),
            details: "\n\n" + individualTypeFailures.map {
                let type = $0.type
                let error = OpenAPIDecodingError(decodingError:  $0.error).localizedDescription
                return "\(String(describing: type)) could not be decoded because:\n\(error)"
            }.joined(separator: "\n\n")
        )
    }
}

internal extension Swift.DecodingError.Context {
    func replacingPath(with codingPath: [CodingKey]) -> Self {
        return Swift.DecodingError.Context(
            codingPath: codingPath,
            debugDescription: debugDescription,
            underlyingError: underlyingError
        )
    }
}

internal struct InconsistencyError: Swift.Error {
    let subjectName: String
    let details: String
    let codingPath: [CodingKey]

    var localizedDescription: String { details }
}
