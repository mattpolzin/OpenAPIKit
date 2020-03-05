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
    public enum EncodableError: Swift.Error, Equatable {
        case allCasesArrayNotCodable
        case exampleNotCodable
        case primitiveGuessFailed
        case exampleNotSupported(String)
    }

    public enum TypeError: Swift.Error, CustomDebugStringConvertible {
        case invalidNode
        case unknownNodeType(Any.Type)

        public var debugDescription: String {
            switch self {
            case .invalidNode:
                return "Invalid Node"
            case .unknownNodeType(let type):
                return "Could not determine OpenAPI node type of \(String(describing: type))"
            }
        }
    }

    public struct Error: Swift.Error {

        public let localizedDescription: String
        public let codingPath: [CodingKey]
        public let underlyingError: Swift.Error

        public var codingPathString: String { codingPath.stringValue }

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
