//
//  OpenAPIErrors.swift
//  JSONAPIOpenAPI
//
//  Created by Mathew Polzin on 7/26/19.
//

import Foundation

public enum OpenAPICodableError: String, Swift.Error, Equatable {
    case allCasesArrayNotCodable
    case exampleNotCodable
    case primitiveGuessFailed
}

public enum OpenAPITypeError: Swift.Error, CustomDebugStringConvertible {
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
