//
//  Either+Map.swift
//  
//
//  Created by Mathew Polzin on 12/19/22.
//

import OpenAPIKitCore

extension Either {
    internal func mapFirst<T>(_ transform: (A) -> T) -> Either<T,B> {
        switch self {
        case .a(let a):
            return .a(transform(a))
        case .b(let b):
            return .b(b)
        }
    }

    internal func mapSecond<T>(_ transform: (B) -> T) -> Either<A,T> {
        switch self {
        case .a(let a):
            return .a(a)
        case .b(let b):
            return .b(transform(b))
        }
    }
}
