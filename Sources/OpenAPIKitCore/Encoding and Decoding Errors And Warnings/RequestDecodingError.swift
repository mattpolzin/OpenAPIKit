//
//  RequestDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/28/20.
//

extension OpenAPI.Error.Decoding {
    public struct Request: OpenAPIError {
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
        }

        public init(context: Context, relativeCodingPath: [CodingKey]) {
            self.context = context
            self.relativeCodingPath = relativeCodingPath
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

    public var relativeCodingPathString: String {
        relativeCodingPath.stringValue
    }

    public static func relativePath(from path: [CodingKey]) -> [CodingKey] {
        guard let responsesIndex = path.firstIndex(where: { $0.stringValue == "requestBody" }) else {
            return path
        }
        return Array(path.dropFirst(responsesIndex.advanced(by: 1)))
    }

    public init(_ error: InconsistencyError) {
        context = .inconsistency(error)
        relativeCodingPath = Self.relativePath(from: error.codingPath)
    }

    public init(_ error: Swift.DecodingError) {
        context = .other(error)
        relativeCodingPath = Self.relativePath(from: error.codingPathWithoutSubject)
    }

    public init(_ eitherError: EitherDecodeNoTypesMatchedError) {
        if let eitherBranchToDigInto = Self.eitherBranchToDigInto(eitherError) {
            self = Self(unwrapping: eitherBranchToDigInto)
            return
        }

        context = .neither(eitherError)
        relativeCodingPath = Self.relativePath(from: eitherError.codingPath)
    }
}

extension OpenAPI.Error.Decoding.Request: DiggingError {
    public init(unwrapping error: Swift.DecodingError) {
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
