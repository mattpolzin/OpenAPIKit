//
//  Either+LocallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

// MARK: - LocallyDereferenceable
extension Either: LocallyDereferenceable where A: LocallyDereferenceable, B: LocallyDereferenceable, A.DereferencedSelf == B.DereferencedSelf {
    public func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> A.DereferencedSelf {
        switch self {
        case .a(let value):
            return try value._dereferenced(in: components, following: references)
        case .b(let value):
            return try value._dereferenced(in: components, following: references)
        }
    }

    public func externallyDereferenced<Context>(with loader: inout ExternalLoader<Context>) throws -> Self where Context : ExternalLoaderContext {
        switch self {
        case .a(let a):
           return .a(try a.externallyDereferenced(with: &loader))
        case .b(let b):
           return .b(try b.externallyDereferenced(with: &loader))
        }
    }
}
