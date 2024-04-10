//
//  Either+ExternallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

// MARK: - ExternallyDereferenceable
extension Either: ExternallyDereferenceable where A: ExternallyDereferenceable, B: ExternallyDereferenceable {

    public func externallyDereferenced<Context: ExternalLoaderContext>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) { 
        switch self {
        case .a(let a):
           let (newA, components) = try await a.externallyDereferenced(with: loader)
           return (.a(newA), components)
        case .b(let b):
           let (newB, components) = try await b.externallyDereferenced(with: loader)
           return (.b(newB), components)
        }
    }
}
