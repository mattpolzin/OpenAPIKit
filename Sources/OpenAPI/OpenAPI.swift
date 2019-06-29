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
        case foundNeither(option1: String, option2: String)
        case unsatisfied(requirement: String)
        case unknown

        public var debugDescription: String {
            switch self {
            case .missingKeyword(underlyingError: let err):
                return "When parsing Open API JSON, an expected keyword was missing. Carefully read your JSON keys to make sure all keys required by OpenAPI are spelled correctly. Underlying error: "
                    + (err ?? "")
            case .foundNeither(option1: let option1, option2: let option2):
                return "Found neither of two expected things. Expected either \(option1) or \(option2)"
            case .unsatisfied(requirement: let requirement):
                return "Unsatisfied OpenAPI requirement: \(requirement)"
            case .unknown:
                return "An unknown error has occurred. That sucks."
            }
        }
    }
}
