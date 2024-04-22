//
//  Array+ExternallyDereferenceable.swift
//

import OpenAPIKitCore

extension Array where Element: ExternallyDereferenceable {

    public func externallyDereferenced<Context: ExternalLoader>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) {
        try await withThrowingTaskGroup(of: (Int, (Element, OpenAPI.Components)).self) { group in
            for (idx, elem) in zip(self.indices, self) {
                group.addTask {
                    return try await (idx, elem.externallyDereferenced(with: loader))
                }
            }

            var newElems = Array<(Int, Element)>()
            var newComponents = OpenAPI.Components()

            for try await (idx, (elem, components)) in group {
                newElems.append((idx, elem))
                try newComponents.merge(components)
            }
            // things may come in out of order because of concurrency
            // so we reorder after completing all entries.
            newElems.sort { left, right in left.0 < right.0 }
            return (newElems.map { $0.1 }, newComponents)
        }
    }
}
