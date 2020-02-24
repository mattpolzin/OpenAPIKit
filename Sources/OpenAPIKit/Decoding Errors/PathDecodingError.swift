//
//  File.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation

extension OpenAPI.Error.Decoding {
    public struct Path: OpenAPIError {
        public let path: OpenAPI.PathComponents
        public let context: Context
        public let codingPath: [CodingKey]

        public enum Context {
            case endpoint(Operation)
            case generic(Swift.DecodingError)
        }
    }
}

extension OpenAPI.Error.Decoding.Path {
    public var subjectName: String {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.subjectName
        case .generic(let decodingError):
            return decodingError.subjectName
        }
    }

    public var contextString: String {
        let relativeCodingPath = relativeCodingPathString.isEmpty
            ? ""
            : "in \(relativeCodingPathString) "
        switch context {
        case .endpoint(let endpointError):
            return "\(relativeCodingPath)for the **\(endpointError.contextString)** endpoint under `\(path.rawValue)`"
        case .generic:
            return "\(relativeCodingPath)under the `\(path.rawValue)` path"
        }
    }

    public var errorCategory: ErrorCategory {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.errorCategory
        case .generic(let decodingError):
            return decodingError.errorCategory
        }
    }

    internal var relativeCodingPathString: String {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.relativeCodingPathString
        case .generic(let decodingError):
            return decodingError.relativeCodingPathString
        }
    }
}
