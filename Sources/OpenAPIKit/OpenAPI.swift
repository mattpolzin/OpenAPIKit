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
        case foundNeither(option1: String, option2: String, codingPath: [CodingKey], notOption1Because: Swift.Error?, notOption2Because: Swift.Error?)
        case unsatisfied(requirement: String, codingPath: [CodingKey])
        case unknown(codingPath: [CodingKey])

        public var debugDescription: String {
            switch self {
            case .missingKeyword(underlyingError: let err, codingPath: let path):
                return "When parsing Open API JSON, an expected keyword was missing. Carefully read your JSON keys to make sure all keys required by OpenAPI are spelled correctly. Underlying error: "
                    + (err ?? "") + ". PATH: \(path)"
            case .foundNeither(option1: let option1, option2: let option2, codingPath: let path, notOption1Because: let reason1, notOption2Because: let reason2):
                return "Found neither of two expected things. Expected either \(option1) or \(option2). \n\nPATH: \(path).\n\n Could not have been \(option1) because: \(String(describing:reason1)).\n\n Could not have been \(option2) because: \(String(describing:reason2))"
            case .unsatisfied(requirement: let requirement, codingPath: let path):
                return "Unsatisfied OpenAPI requirement: \(requirement). PATH: \(path)"
            case .unknown(codingPath: let path):
                return "An unknown error has occurred. That sucks. PATH: \(path)"
            }
        }
    }
}
