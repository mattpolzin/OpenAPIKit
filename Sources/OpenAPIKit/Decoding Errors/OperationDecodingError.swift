//
//  OperationDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import Foundation
import Poly

extension OpenAPI.Error.Decoding {
    public struct Operation: OpenAPIError {
        public let endpoint: OpenAPI.HttpVerb
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case request(Request)
            case response(Response)
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Operation {
    public var subjectName: String {
        switch context {
        case .request(let error):
            return error.subjectName
        case .response(let error):
            return error.subjectName
        case .inconsistency(let error):
            return error.subjectName
        case .other(let decodingError):
            return decodingError.subjectName
        case .neither(let polyError):
            return polyError.subjectName
        }
    }

    public var contextString: String { "" }

    public var errorCategory: ErrorCategory {
        switch context {
        case .request(let error):
            return error.errorCategory
        case .response(let error):
            return error.errorCategory
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
        case .request(let error):
            return error.codingPath
        case .response(let error):
            return error.codingPath
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

    internal init(_ error: OpenAPI.Error.Decoding.Request) {
        var codingPath = error.codingPath.dropFirst(2)
        // this part of the coding path is structurally guaranteed to be an HTTP verb.
        let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

        endpoint = verb
        context = .request(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: OpenAPI.Error.Decoding.Response) {
        var codingPath = error.codingPath.dropFirst(2)
        // this part of the coding path is structurally guaranteed to be an HTTP verb.
        let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

        endpoint = verb
        context = .response(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: InconsistencyError) {
        var codingPath = error.codingPath.dropFirst(2)
        // this part of the coding path is structurally guaranteed to be an HTTP verb.
        let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

        endpoint = verb
        context = .inconsistency(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: Swift.DecodingError) {
        var codingPath = error.codingPathWithoutSubject.dropFirst(2)
        // this part of the coding path is structurally guaranteed to be an HTTP verb.
        let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

        endpoint = verb
        context = .other(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(unwrapping error: Swift.DecodingError) {
        if let decodingError = error.underlyingError as? Swift.DecodingError {
            self = Self(unwrapping: decodingError)
        } else if let responseError = error.underlyingError as? OpenAPI.Error.Decoding.Request {
            self = Self(responseError)
        } else if let responseError = error.underlyingError as? OpenAPI.Error.Decoding.Response {
            self = Self(responseError)
        } else if let inconsistencyError = error.underlyingError as? InconsistencyError {
            self = Self(inconsistencyError)
        } else if let polyError = error.underlyingError as? EitherDecodeNoTypesMatchedError {
            self = Self(polyError)
        } else {
            self = Self(error)
        }
    }

    internal init(_ polyError: EitherDecodeNoTypesMatchedError) {
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

        var codingPath = polyError.codingPath.dropFirst(2)
        // this part of the coding path is structurally guaranteed to be an HTTP verb.
        let verb = OpenAPI.HttpVerb(rawValue: codingPath.removeFirst().stringValue.uppercased())!

        endpoint = verb
        context = .neither(polyError)
        relativeCodingPath = Array(codingPath)
    }
}
