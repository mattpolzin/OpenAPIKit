//
//  PathDecodingError.swift
//  
//
//  Created by Mathew Polzin on 2/23/20.
//

import OpenAPIKitCore

extension OpenAPI.Error.Decoding {
    public struct Path: OpenAPIError {
        public let path: OpenAPI.Path
        public let context: Context
        internal let relativeCodingPath: [CodingKey]

        public enum Context {
            case endpoint(Operation)
            case inconsistency(InconsistencyError)
            case other(Swift.DecodingError)
            case neither(EitherDecodeNoTypesMatchedError)
        }
    }
}

extension OpenAPI.Error.Decoding.Path {
    public var subjectName: String {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.subjectName
        case .inconsistency(let inconsistencyError):
            return inconsistencyError.subjectName
        case .other(let decodingError):
            return decodingError.subjectName
        case .neither(let eitherError):
            return eitherError.subjectName
        }
    }

    public var contextString: String {
        let relativeCodingPath = relativeCodingPathString.isEmpty
            ? ""
            : "in \(relativeCodingPathString) "

        switch context {
        case .endpoint(let endpointError):
            switch endpointError.context {
            case .response(let responseError):
                let responseContext = responseError.statusCode.rawValue == "default"
                    ? "default"
                    : "status code '\(responseError.statusCode.rawValue)'"

                return "\(relativeCodingPath)for the \(responseContext) response of the **\(endpointError.endpoint.rawValue)** endpoint under `\(path.rawValue)`"
            case .request:
                return "\(relativeCodingPath)for the request body of the **\(endpointError.endpoint.rawValue)** endpoint under `\(path.rawValue)`"
            case .other, .inconsistency, .neither:
                return "\(relativeCodingPath)for the **\(endpointError.endpoint.rawValue)** endpoint under `\(path.rawValue)`"
            }
        case .other, .neither, .inconsistency:
            return "\(relativeCodingPath)under the `\(path.rawValue)` path"
        }
    }

    public var errorCategory: ErrorCategory {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.errorCategory
        case .inconsistency(let inconsistencyError):
            return inconsistencyError.errorCategory
        case .other(let decodingError):
            return decodingError.errorCategory
        case .neither(let eitherError):
            return eitherError.errorCategory
        }
    }

    public var codingPath: [CodingKey] {
        switch context {
        case .endpoint(let endpointError):
            return endpointError.codingPath
        case .inconsistency(let inconsistencyError):
            return inconsistencyError.codingPath
        case .other(let decodingError):
            return decodingError.codingPath
        case .neither(let eitherError):
            return eitherError.codingPath
        }
    }

    internal var relativeCodingPathString: String {
        switch context {
        case .endpoint(let endpointError):
            switch endpointError.context {
            case .response(let responseError):
                return responseError.relativeCodingPathString
            case .request(let requestError):
                return requestError.relativeCodingPathString
            case .other, .inconsistency, .neither:
                return endpointError.relativeCodingPathString
            }
        case .other, .inconsistency, .neither:
            return relativeCodingPath.stringValue
        }
    }

    internal init(_ error: DecodingError) {
        var codingPath = error.codingPathWithoutSubject.dropFirst()
        let route = OpenAPI.Path(rawValue: codingPath.removeFirst().stringValue)

        path = route
        context = .other(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: OpenAPI.Error.Decoding.Operation) {
        var codingPath = error.codingPath.dropFirst()
        let route = OpenAPI.Path(rawValue: codingPath.removeFirst().stringValue)

        path = route
        context = .endpoint(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ error: InconsistencyError) {
        var codingPath = error.codingPath.dropFirst()
        let route = OpenAPI.Path(rawValue: codingPath.removeFirst().stringValue)

        path = route
        context = .inconsistency(error)
        relativeCodingPath = Array(codingPath)
    }

    internal init(_ eitherError: EitherDecodeNoTypesMatchedError) {
        // *IMPORTANT*
        // -----------
        // In theory the following commented-out code is desirable but in practice it never
        // results in useful output because `eitherBranchToDigInto` checks for things that
        // never occur on `PathItem`'s only `Either` type (the array of `Parameter`s). Because
        // `Parameter` is such a simple type, it is never worth "digging" into more deeply.
        //
        // I intend to leave this code here commented out to be a guide if it the future the
        // `PathItem` type does gain deeper `Either` properties because in that case the code
        // below can simply be uncommented instead of needing to wrap my head around the situation
        // from scratch.

//        if let eitherBranchToDigInto = Self.eitherBranchToDigInto(eitherError) {
//            self = Self(unwrapping: eitherBranchToDigInto)
//            return
//        }

        var codingPath = eitherError.codingPath.dropFirst()
        let route = OpenAPI.Path(rawValue: codingPath.removeFirst().stringValue)

        path = route
        context = .neither(eitherError)
        relativeCodingPath = Array(codingPath)
    }
}

// *IMPORTANT*
// -----------
// See the note above in the `init(_ eitherError:)` initializer to understand why I want to
// leave the following commented out code intact.

//extension OpenAPI.Error.Decoding.Path: DiggingError {
//    public init(unwrapping error: Swift.DecodingError) {
//        if let decodingError = error.underlyingError as? Swift.DecodingError {
//            self = Self(unwrapping: decodingError)
//        } else if let inconsistencyError = error.underlyingError as? InconsistencyError {
//            self = Self(inconsistencyError)
//        } else if let eitherError = error.underlyingError as? EitherDecodeNoTypesMatchedError {
//            self = Self(eitherError)
//        } else {
//            self = Self(error)
//        }
//    }
//}
