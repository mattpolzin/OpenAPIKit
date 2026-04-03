//
//  Array+ExternallyDereferenceable.swift
//

import OpenAPIKitCore

extension Array where Element: ExternallyDereferenceable & Sendable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) {
        var newElements = Self()
        newElements.reserveCapacity(count)
        var newComponents = OpenAPI.Components()
        var newMessages = [Loader.Message]()

        for element in self {
            let (newElement, components, messages) = try await element.externallyDereferenced(with: loader)
            newElements.append(newElement)
            try newComponents.merge(components)
            newMessages += messages
        }

        return (newElements, newComponents, newMessages)
    }
}
