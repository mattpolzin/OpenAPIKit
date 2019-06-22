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
}
