//
//  OpenAPIDecodingErrors.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation

extension OpenAPI.Error {
    public enum Decoding {}
}

public enum ErrorCategory {
    case typeMismatch(expectedTypeName: String)
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
    var localizedDescription: String {
        let errorTypeString: String = {
            switch errorCategory {
            case .typeMismatch(expectedTypeName: let typeName):
                return " to be parsable as \(typeName) but it was not"
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
            case .typeMismatch:
                return "Expected `\(subjectName)` value"
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
