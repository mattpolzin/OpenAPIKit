//
//  OpenAPIErrors.swift
//  JSONAPIOpenAPI
//
//  Created by Mathew Polzin on 7/26/19.
//

import Foundation

public enum OpenAPICodableError: Swift.Error, Equatable {
    case allCasesArrayNotCodable
    case exampleNotCodable
    case primitiveGuessFailed
}

public enum OpenAPITypeError: Swift.Error {
    case invalidNode
    case unknownNodeType(Any.Type)
}
