//
//  Optional+ExternallyDereferenceable.swift
//

import OpenAPIKitCore

extension Optional where Wrapped: ExternallyDereferenceable {

    public func externallyDereferenced<Context: ExternalLoaderContext>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) {
        guard let wrapped = self else { return (nil, .init()) }
        return try await wrapped.externallyDereferenced(with: loader)
    }
}
