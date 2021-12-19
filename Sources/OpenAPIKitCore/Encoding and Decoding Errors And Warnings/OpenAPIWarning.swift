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
    }
}
