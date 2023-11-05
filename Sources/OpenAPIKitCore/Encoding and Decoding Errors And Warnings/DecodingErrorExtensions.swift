//
//  DecodingErrorExtensions.swift
//  
//
//  Created by Mathew Polzin on 2/26/20.
//

public extension Swift.DecodingError {
    var subjectName: String {
        let name: String? = {
            switch self {
            case .keyNotFound(let key, _):
                return "\(key.stringValue)"
            case .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context):
                return context.codingPath.last?.stringValue
            @unknown default:
                return nil
            }
        }()

        return name ?? "[unknown object]"
    }

    var codingPathWithoutSubject: [CodingKey] {
        switch self {
        case .keyNotFound(_, let context):
            return context.codingPath
        case .typeMismatch(_, let ctx), .valueNotFound(_, let ctx), .dataCorrupted(let ctx):
            return ctx.codingPath.count > 0 ? ctx.codingPath.dropLast() : []
        @unknown default:
            return []
        }
    }

    var codingPath: [CodingKey] {
        switch self {
        case .keyNotFound(_, let context), .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context):
            return context.codingPath
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
        case .dataCorrupted(let context):
            return .inconsistency(details: context.debugDescription)
        @unknown default:
            return .dataCorrupted(underlying: underlyingError)
        }
    }

    var underlyingError: Swift.Error? {
        switch self {
        case .typeMismatch(_, let context), .valueNotFound(_, let context), .keyNotFound(_, let context), .dataCorrupted(let context):
            return context.underlyingError
        @unknown default:
            return nil
        }
    }

    func replacingPath(with codingPath: [CodingKey]) -> Self {
        switch self {
        case .typeMismatch(let type, let context):
            return .typeMismatch(type, context.replacingPath(with: codingPath))
        case .valueNotFound(let type, let context):
            return .valueNotFound(type, context.replacingPath(with: codingPath))
        case .keyNotFound(let key, let context):
            return .keyNotFound(key, context.replacingPath(with: codingPath))
        case .dataCorrupted(let context):
            return .dataCorrupted(context.replacingPath(with: codingPath))
        @unknown default:
            return .dataCorrupted(.init(codingPath: codingPath, debugDescription: "unknown error"))
        }
    }
}

public extension Swift.DecodingError.Context {
    func replacingPath(with codingPath: [CodingKey]) -> Self {
        return Swift.DecodingError.Context(
            codingPath: codingPath,
            debugDescription: debugDescription,
            underlyingError: underlyingError
        )
    }
}

internal struct DecodingErrorWrapper: OpenAPIError {
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
