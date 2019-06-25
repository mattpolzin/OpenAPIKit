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
    }

    public enum TypeError: Swift.Error {
        case invalidNode
        case unknownNodeType(Any.Type)
    }

    public enum DecodingError: Swift.Error, CustomDebugStringConvertible {
        case missingKeyword(underlyingError: String?)

        public var debugDescription: String {
            switch self {
            case .missingKeyword(underlyingError: let err):
                return "When parsing Open API JSON, an expected keyword was missing. Carefully read your JSON keys to make sure all keys required by OpenAPI are spelled correctly. Underlying error: "
                    + (err ?? "")
            }
        }
    }
}
