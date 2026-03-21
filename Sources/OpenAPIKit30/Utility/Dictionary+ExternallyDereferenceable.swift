//
//  Dictionary+ExternallyDereferenceable.swift
//  OpenAPI
//

import OpenAPIKitCore

extension Dictionary where Key: Sendable, Value: ExternallyDereferenceable & Sendable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) {
        var newDict = Self()
        var newComponents = OpenAPI.Components()
        var newMessages = [Loader.Message]()

        for (key, value) in self {
            let (newValue, components, messages) = try await value.externallyDereferenced(with: loader)
            newDict[key] = newValue
            try newComponents.merge(components)
            newMessages += messages
        }

        return (newDict, newComponents, newMessages)
    }
}
