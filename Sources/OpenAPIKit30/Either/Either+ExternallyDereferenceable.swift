//
//  Either+ExternallyDereferenceable.swift
//  
//
//  Created by Mathew Polzin on 2/28/21.
//

import OpenAPIKitCore

// MARK: - ExternallyDereferenceable
extension Either: ExternallyDereferenceable where A: ExternallyDereferenceable, B: ExternallyDereferenceable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        switch self {
        case .a(let a):
           let (newA, components, messages) = try await a.externallyDereferenced(with: loader)
           return (.a(newA), components, messages)
        case .b(let b):
           let (newB, components, messages) = try await b.externallyDereferenced(with: loader)
           return (.b(newB), components, messages)
        }
    }
}
