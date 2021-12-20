//
//  OpenAPIWarning.swift
//  
//
//  Created by Mathew Polzin on 12/19/21.
//

extension OpenAPI {
    public enum Warning {
        case underlyingError(OpenAPIError)
        case message(String)

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
}

extension OpenAPI.Warning: CustomStringConvertible {
    /// Description of error given in the structure:
    /// `subject` `context` `error`: `details`
    ///
    /// A subject, context, and error are all guaranteed.
    /// The details are only provided in certain contexts.
    public var localizedDescription: String {
        switch self {
        case .underlyingError(let err): return err.localizedDescription
        case .message(let msg): return msg
        }
    }

    public var description: String { localizedDescription }
}

public protocol HasWarnings {
    var warnings: [OpenAPI.Warning] { get }
}
