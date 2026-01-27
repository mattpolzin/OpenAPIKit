//
//  OpenAPIWarning.swift
//  
//
//  Created by Mathew Polzin on 12/19/21.
//

public enum Warning: Swift.Error {
    case underlyingError(OpenAPIError)
    case message(String)

    public var underlyingError: OpenAPIError? {
        switch self {
        case .underlyingError(let error): return error
        case .message: return nil
        }
    }

    public var subjectName: String? {
        switch self {
        case .underlyingError(let err): return err.subjectName
        default: return nil
        }
    }

    public var contextString: String? {
        switch self {
        case .underlyingError(let err): return err.contextString
        default: return nil
        }
    }

    public var errorCategory: ErrorCategory? {
        switch self {
        case .underlyingError(let err): return err.errorCategory
        default: return nil
        }
    }

    public var codingPath: [CodingKey]? {
        switch self {
        case .underlyingError(let err): return err.codingPath
        default: return nil
        }
    }

    /// Get a human readable string value of the coding path.
    public var codingPathString : String? {
        return codingPath?.stringValue
    }
}

extension Warning: CustomStringConvertible {
    /// Description of warning.
    public var localizedDescription: String {
        switch self {
        case .underlyingError(let err):
            return err.localizedDescription
        case .message(let msg):
            return msg
        }
    }

    public var description: String { localizedDescription }
}

public protocol HasWarnings {
    /// Warnings generated while decoding an OpenAPI type.
    var warnings: [Warning] { get }
}
