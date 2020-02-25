//
//  File.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import Poly

extension OpenAPI.Error.Decoding {
    public struct Path: OpenAPIError {
        public let path: OpenAPI.PathComponents
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case endpoint(Operation)
            case generic(Swift.DecodingError)
            case neither(PolyDecodeNoTypesMatchedError)
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
        case .neither(let polyError):
            return polyError.subjectName
        }
    }

    public var contextString: String {
        let relativeCodingPath = relativeCodingPathString.isEmpty
            ? ""
            : "in \(relativeCodingPathString) "
        switch context {
        case .endpoint(let endpointError):
            return "\(relativeCodingPath)for the **\(endpointError.contextString)** endpoint under `\(path.rawValue)`"
        case .generic, .neither:
            return "\(relativeCodingPath)under the `\(path.rawValue)` path"
        }
    }

    public var errorCategory: ErrorCategory {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.errorCategory
        case .generic(let decodingError):
            return decodingError.errorCategory
        case .neither(let polyError):
            return polyError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.codingPath
        case .generic(let decodingError):
            return decodingError.codingPath
        case .neither(let polyError):
            return polyError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.relativeCodingPathString
        case .generic, .neither:
            return relativeCodingPath.stringValue
        }
    }
}
