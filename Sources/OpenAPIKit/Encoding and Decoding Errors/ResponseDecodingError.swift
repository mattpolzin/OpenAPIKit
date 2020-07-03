//
//  ResponseDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/28/20.
//

extension OpenAPI.Error.Decoding {
    public struct Response: OpenAPIError {
        public let statusCode: OpenAPI.Response.StatusCode
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
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
        case .neither(let eitherError):
            return eitherError.subjectName
        }
    }

    public var contextString: String { statusCode.rawValue }

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

    internal init(_ eitherError: EitherDecodeNoTypesMatchedError) {
        if let eitherBranchToDigInto = Self.eitherBranchToDigInto(eitherError) {
            self = Self(unwrapping: eitherBranchToDigInto)
            return
        }

        var codingPath = Self.relativePath(from: eitherError.codingPath)
        let code = codingPath.removeFirst().stringValue.lowercased()

        // this part of the coding path is structurally guaranteed to be a status code.
        statusCode = OpenAPI.Response.StatusCode(rawValue: code)!
        context = .neither(eitherError)
        relativeCodingPath = Array(codingPath)
    }
}

extension OpenAPI.Error.Decoding.Response: DiggingError {
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
}
