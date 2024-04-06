//
//  Either+ExternallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

// MARK: - ExternallyDereferenceable
extension Either: ExternallyDereferenceable where B: ExternallyDereferenceable {
    public func externallyDereferenced<Context>(with loader: inout ExternalLoader<Context>) async throws -> Self where Context : ExternalLoaderContext {
        switch self {
        case .a(let a):
           return .a(a)
        case .b(let b):
           return .b(try await b.externallyDereferenced(with: &loader))
        }
    }
}
