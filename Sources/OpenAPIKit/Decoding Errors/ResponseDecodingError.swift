//
//  ResponseDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/28/20.
//

import Foundation
import Poly

extension OpenAPI.Error.Decoding {
    public struct Response: OpenAPIError {
        public let statusCode: OpenAPI.Response.StatusCode
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(PolyDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Response {
    public var subjectName: String {
        switch context {
        case .inconsistency(let error):
            return error.subjectName
        case .other(let decodingError):
            return decodingError.subjectName
        case .neither(let polyError):
            return polyError.subjectName
        }
    }

    public var contextString: String { statusCode.rawValue }

    public var errorCategory: ErrorCategory {
        switch context {
        case .inconsistency(let error):
            return .inconsistency(details: error.details)
        case .other(let decodingError):
            return decodingError.errorCategory
        case .neither(let polyError):
            return polyError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .inconsistency(let error):
            return error.codingPath
        case .other(let decodingError):
            return decodingError.codingPath
        case .neither(let polyError):
            return polyError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        relativeCodingPath.stringValue
    }

    internal static func relativePath(from path: [CodingKey]) -> [CodingKey] {
        guard let responsesIndex = path.firstIndex(where: { $0.stringValue == "responses" }) else {
            return path
        }
        return Array(path.dropFirst(responsesIndex.advanced(by: 1)))
    }

    internal init(_ error: InconsistencyError) {
        var codingPath = Self.relativePath(from: error.codingPath)
        let code = codingPath.removeFirst().stringValue.lowercased()

        // this part of the coding path is structurally guaranteed to be a status code.
        statusCode = OpenAPI.Response.StatusCode(rawValue: code)!
        context = .inconsistency(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: Swift.DecodingError) {
        var codingPath = Self.relativePath(from: error.codingPathWithoutSubject)
        let code = codingPath.removeFirst().stringValue.lowercased()

        // this part of the coding path is structurally guaranteed to be a status code.
        statusCode = OpenAPI.Response.StatusCode(rawValue: code)!
        context = .other(error)
        relativeCodingPath = Array(codingPath)
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
            let firstFailureIsReference = polyError.individualTypeFailures[0].typeString == "$ref"
            let secondFailureIsReference = polyError.individualTypeFailures[1].typeString == "$ref"

            let firstFailureIsDeeper = polyError.individualTypeFailures[0].codingPath(relativeTo: polyError.codingPath).count > 1
            let secondFailureIsDeeper = polyError.individualTypeFailures[1].codingPath(relativeTo: polyError.codingPath).count > 1

            if firstFailureIsReference && secondFailureIsDeeper {
                self = Self(unwrapping: polyError.individualTypeFailures[1].error)
                return
            } else if secondFailureIsReference && firstFailureIsDeeper {
                self = Self(unwrapping: polyError.individualTypeFailures[0].error)
                return
            }
        }

        var codingPath = Self.relativePath(from: polyError.codingPath)
        let code = codingPath.removeFirst().stringValue.lowercased()

        // this part of the coding path is structurally guaranteed to be a status code.
        statusCode = OpenAPI.Response.StatusCode(rawValue: code)!
        context = .neither(polyError)
        relativeCodingPath = Array(codingPath)
    }
}
