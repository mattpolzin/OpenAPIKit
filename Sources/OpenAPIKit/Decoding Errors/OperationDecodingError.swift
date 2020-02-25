//
//  File.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation

extension OpenAPI.Error.Decoding {
    public struct Operation: OpenAPIError {
        public let endpoint: OpenAPI.HttpVerb
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case generic(Swift.DecodingError)
        }
    }
}

extension OpenAPI.Error.Decoding.Operation {
    public var subjectName: String {
        switch context {
        case .generic(let decodingError):
            return decodingError.subjectName
        }
    }

    public var contextString: String { endpoint.rawValue }

    public var errorCategory: ErrorCategory {
        switch context {
        case .generic(let decodingError):
            return decodingError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .generic(let decodingError):
            return decodingError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        relativeCodingPath.stringValue
    }
}
