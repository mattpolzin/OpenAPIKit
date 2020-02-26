//
//  OpenAPI.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation

/// The OpenAPI namespace
public enum OpenAPI {}

extension OpenAPI {
    public enum CodableError: Swift.Error, Equatable {
        case allCasesArrayNotCodable
        case exampleNotCodable
        case primitiveGuessFailed
        case exampleNotSupported(String)
    }

    public enum TypeError: Swift.Error {
        case invalidNode
        case unknownNodeType(Any.Type)
    }

    public enum DecodingError: Swift.Error, CustomDebugStringConvertible {
        case missingKeyword(underlyingError: String?, codingPath: [CodingKey])
        case unknown(codingPath: [CodingKey])

        public var debugDescription: String {
            switch self {
            case .missingKeyword(underlyingError: let err, codingPath: let path):
                return "When parsing Open API JSON, an expected keyword was missing. Carefully read your JSON keys to make sure all keys required by OpenAPI are spelled correctly. Underlying error: "
                    + (err ?? "") + ". PATH: \(path)"
            case .unknown(codingPath: let path):
                return "An unknown error has occurred. That sucks. PATH: \(path)"
            }
        }
    }

    public struct Error: Swift.Error {

        public let localizedDescription: String
        public let codingPath: [CodingKey]
        public let underlyingError: Swift.Error

        public init(from underlyingError: Swift.Error) {
            self.underlyingError = underlyingError
            if let openAPIError = underlyingError as? OpenAPIError {
                localizedDescription = openAPIError.localizedDescription
                codingPath = openAPIError.codingPath

            } else if let decodingError = underlyingError as? Swift.DecodingError {

                if let openAPIError = decodingError.underlyingError as? OpenAPIError {
                    localizedDescription = openAPIError.localizedDescription
                    codingPath = openAPIError.codingPath
                } else {
                    let wrappedError = DecodingErrorWrapper(decodingError: decodingError)
                    localizedDescription = wrappedError.localizedDescription
                    codingPath = wrappedError.codingPath
                }

            } else {
                localizedDescription = underlyingError.localizedDescription
                codingPath = []
            }
        }
    }
}
