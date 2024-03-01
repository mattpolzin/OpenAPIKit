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

        var codingPath = eitherError.codingPath.dropFirst()
        let route = OpenAPI.Path(rawValue: codingPath.removeFirst().stringValue)

        path = route
        context = .neither(eitherError)
        relativeCodingPath = Array(codingPath)
    }
}
