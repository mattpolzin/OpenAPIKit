//
//  DocumentDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import OpenAPIKitCore

extension OpenAPI.Error.Decoding {
    public struct Document: OpenAPIError {
        public let context: Context
        public let codingPath: [CodingKey]

        public enum Context: Sendable {
            case path(Path)
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Document {
    public var subjectName: String {
        switch context {
        case .path(let pathError):
            return pathError.subjectName

        case .other(let decodingError):
            return decodingError.subjectName

        case .inconsistency(let error):
            return error.subjectName

        case .neither(let eitherError):
            return eitherError.subjectName
        }
    }

    public var contextString: String {
        switch context {
        case .path(let pathError):
            return pathError.contextString
        case .other, .inconsistency, .neither:
            return relativeCodingPathString.isEmpty
                ? "in the root Document object"
                : "in Document\(relativeCodingPathString)"
        }
    }

    public var errorCategory: ErrorCategory {
        switch context {
        case .path(let pathError):
            return pathError.errorCategory
        case .other(let error):
            return error.errorCategory
        case .inconsistency(let error):
            return .inconsistency(details: error.details)
        case .neither(let eitherError):
            return eitherError.errorCategory
        }
    }

    internal var relativeCodingPathString: String {
        switch context {
        case .other(let decodingError):
            return decodingError.relativeCodingPathString
        case .inconsistency(let error):
            return error.codingPath.isEmpty ? ""
                : error.pathIncludesSubject ? error.codingPath.dropLast().stringValue
                  : error.codingPath.stringValue
        case .path(let pathError):
            return pathError.relativeCodingPathString
        case .neither(let eitherError):
            return eitherError.codingPath.stringValue
        }
    }

    internal init(_ error: DecodingError) {
        context = .other(error)
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

    internal init(_ eitherError: EitherDecodeNoTypesMatchedError) {
        if let eitherBranchToDigInto = Self.eitherBranchToDigInto(eitherError) {
            self = Self(unwrapping: eitherBranchToDigInto)
            return
        }

        context = .neither(eitherError)
        codingPath = eitherError.codingPath
    }
}

extension OpenAPI.Error.Decoding.Document: DiggingError {
    public init(unwrapping error: Swift.DecodingError) {
        if let decodingError = error.underlyingError as? Swift.DecodingError {
            self = Self(unwrapping: decodingError)
        } else if let inconsistencyError = error.underlyingError as? InconsistencyError {
            self = Self(inconsistencyError)
        } else if let pathError = error.underlyingError as? OpenAPI.Error.Decoding.Path {
            self = Self(pathError)
        } else if let eitherError = error.underlyingError as? EitherDecodeNoTypesMatchedError {
            self = Self(eitherError)
        } else {
            self = Self(error)
        }
    }
}
