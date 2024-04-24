//
//  Array+ExternallyDereferenceable.swift
//

import OpenAPIKitCore

extension Array where Element: ExternallyDereferenceable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components) {
        try await withThrowingTaskGroup(of: (Element, OpenAPI.Components).self) { group in
            for elem in self {
                group.addTask {
                    return try await elem.externallyDereferenced(with: loader)
                }
            }

            var newElems = Self()
            var newComponents = OpenAPI.Components()

            for try await (elem, components) in group {
                newElems.append(elem)
                try newComponents.merge(components)
            }
            return (newElems, newComponents)
        }
    }
}
