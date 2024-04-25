//
//  Optional+ExternallyDereferenceable.swift
//

import OpenAPIKitCore

extension Optional where Wrapped: ExternallyDereferenceable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) {
        guard let wrapped = self else { return (nil, .init(), []) }
        return try await wrapped.externallyDereferenced(with: loader)
    }
}
