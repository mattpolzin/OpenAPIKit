//
//  RequestDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/28/20.
//

import Foundation

extension OpenAPI.Error.Decoding {
    public struct Request: OpenAPIError {
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Request {
    public var subjectName: String {
        switch context {
        case .inconsistency(let error):
            return error.subjectName
        case .other(let decodingError):
            return decodingError.subjectName
        case .neither(let eitherError):
            return eitherError.subjectName
        }
    }

    public var contextString: String { "" }

    public var errorCategory: ErrorCategory {
        switch context {
        case .inconsistency(let error):
            return .inconsistency(details: error.details)
        case .other(let decodingError):
            return decodingError.errorCategory
        case .neither(let eitherError):
            return eitherError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .inconsistency(let error):
            return error.codingPath
        case .other(let decodingError):
            return decodingError.codingPath
        case .neither(let eitherError):
            return eitherError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        relativeCodingPath.stringValue
    }

    internal static func relativePath(from path: [CodingKey]) -> [CodingKey] {
        guard let responsesIndex = path.firstIndex(where: { $0.stringValue == "requestBody" }) else {
            return path
        }
        return Array(path.dropFirst(responsesIndex.advanced(by: 1)))
    }

    internal init(_ error: InconsistencyError) {
        context = .inconsistency(error)
        relativeCodingPath = Self.relativePath(from: error.codingPath)
    }

    internal init(_ error: Swift.DecodingError) {
        context = .other(error)
        relativeCodingPath = Self.relativePath(from: error.codingPathWithoutSubject)
    }

    internal init(unwrapping error: Swift.DecodingError) {
        if let decodingError = error.underlyingError as? Swift.DecodingError {
            self = Self(unwrapping: decodingError)
        } else if let inconsistencyError = error.underlyingError as? InconsistencyError {
            self = Self(inconsistencyError)
        } else if let eitherError = error.underlyingError as? EitherDecodeNoTypesMatchedError {
            self = Self(eitherError)
        } else {
            self = Self(error)
        }
    }

    internal init(_ eitherError: EitherDecodeNoTypesMatchedError) {
        if eitherError.individualTypeFailures.count == 2 {
            let firstFailureIsReference = eitherError.individualTypeFailures[0].typeString == "$ref"
            let secondFailureIsReference = eitherError.individualTypeFailures[1].typeString == "$ref"

            let firstFailureIsDeeper = eitherError.individualTypeFailures[0].codingPath(relativeTo: eitherError.codingPath).count > 1
            let secondFailureIsDeeper = eitherError.individualTypeFailures[1].codingPath(relativeTo: eitherError.codingPath).count > 1

            if firstFailureIsReference && secondFailureIsDeeper {
                self = Self(unwrapping: eitherError.individualTypeFailures[1].error)
                return
            } else if secondFailureIsReference && firstFailureIsDeeper {
                self = Self(unwrapping: eitherError.individualTypeFailures[0].error)
                return
            }
        }
        context = .neither(eitherError)
        relativeCodingPath = Self.relativePath(from: eitherError.codingPath)
    }
}

