//
//  RequestDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/28/20.
//

import Foundation
import Poly

extension OpenAPI.Error.Decoding {
    public struct Request: OpenAPIError {
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case inconsistency(InconsistencyError)
            case generic(Swift.DecodingError)
            case neither(PolyDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Request {
    public var subjectName: String {
        switch context {
        case .inconsistency(let error):
            return error.subjectName
        case .generic(let decodingError):
            return decodingError.subjectName
        case .neither(let polyError):
            return polyError.subjectName
        }
    }

    public var contextString: String { "" }

    public var errorCategory: ErrorCategory {
        switch context {
        case .inconsistency(let error):
            return .inconsistency(details: error.details)
        case .generic(let decodingError):
            return decodingError.errorCategory
        case .neither(let polyError):
            return polyError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .inconsistency(let error):
            return error.codingPath
        case .generic(let decodingError):
            return decodingError.codingPath
        case .neither(let polyError):
            return polyError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        relativeCodingPath.stringValue
    }

    internal static func relativePath(from path: [CodingKey]) -> [CodingKey] {
        guard let responsesIdx = path.firstIndex(where: { $0.stringValue == "requestBody" }) else {
            return path
        }
        return Array(path.dropFirst(responsesIdx.advanced(by: 1)))
    }

    internal init(_ error: InconsistencyError) {
        context = .inconsistency(error)
        relativeCodingPath = Self.relativePath(from: error.codingPath)
    }

    internal init(_ error: Swift.DecodingError) {
        context = .generic(error)
        relativeCodingPath = Self.relativePath(from: error.codingPathWithoutSubject)
    }

    internal init(unwrapping error: Swift.DecodingError) {
        if let decodingError = error.underlyingError as? Swift.DecodingError {
            self = Self(unwrapping: decodingError)
        } else if let inconsistencyError = error.underlyingError as? InconsistencyError {
            self = Self(inconsistencyError)
        } else if let polyError = error.underlyingError as? PolyDecodeNoTypesMatchedError {
            self = Self(polyError)
        } else {
            self = Self(error)
        }
    }

    internal init(_ polyError: PolyDecodeNoTypesMatchedError) {
        if polyError.individualTypeFailures.count == 2 {
            if polyError.individualTypeFailures[0].typeString == "$ref" && polyError.individualTypeFailures[1].codingPath(relativeTo: polyError.codingPath).count > 1 {
                self = Self(unwrapping: polyError.individualTypeFailures[1].error)
                return
            } else if polyError.individualTypeFailures[1].typeString == "$ref" && polyError.individualTypeFailures[0].codingPath(relativeTo: polyError.codingPath).count > 1 {
                self = Self(unwrapping: polyError.individualTypeFailures[0].error)
                return
            }
        }
        context = .neither(polyError)
        relativeCodingPath = Self.relativePath(from: polyError.codingPath)
    }
}

