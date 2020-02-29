//
//  File.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation

extension OpenAPI.Error.Decoding {
    public struct Document: OpenAPIError {
        public let context: Context
        public let codingPath: [CodingKey]

        public enum Context {
            case path(Path)
            case inconsistency(InconsistencyError)
            case generic(Swift.DecodingError)
        }
    }
}

extension OpenAPI.Error.Decoding.Document {
    public var subjectName: String {
        switch context {
        case .path(let pathError):
            return pathError.subjectName

        case .generic(let decodingError):
            return decodingError.subjectName

        case .inconsistency(let error):
            return error.subjectName
        }
    }

    public var contextString: String {
        switch context {
        case .path(let pathError):
            return pathError.contextString
        case .generic, .inconsistency:
            return relativeCodingPathString.isEmpty
                ? "in the root Document object"
                : "in Document\(relativeCodingPathString)"
        }
    }

    public var errorCategory: ErrorCategory {
        switch context {
        case .path(let pathError):
            return pathError.errorCategory
        case .generic(let error):
            return error.errorCategory
        case .inconsistency(let error):
            return .inconsistency(details: error.details)
        }
    }

    internal var relativeCodingPathString: String {
        switch context {
        case .generic(let decodingError):
            return decodingError.relativeCodingPathString
        case .inconsistency:
            return ""
        case .path(let pathError):
            return pathError.relativeCodingPathString
        }
    }

    internal init(_ error: DecodingError) {
        context = .generic(error)
        codingPath = error.codingPath
    }

    internal init(_ error: InconsistencyError) {
        context = .inconsistency(error)
        codingPath = error.codingPath
    }

    internal init(_ error: OpenAPI.Error.Decoding.Path) {
        context = .path(error)
        codingPath = error.codingPath
    }
}
