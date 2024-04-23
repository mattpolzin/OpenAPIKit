//
//  Dictionary+ExternallyDereferenceable.swift
//  OpenAPI
//

import OpenAPIKitCore

extension Dictionary where Value: ExternallyDereferenceable {

    public func externallyDereferenced<Context: ExternalLoader>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) {
        try await withThrowingTaskGroup(of: (Key, Value, OpenAPI.Components).self) { group in
          for (key, value) in self {
              group.addTask {
                  let (newRef, components) = try await value.externallyDereferenced(with: loader)
                  return (key, newRef, components)
              }
          }

          var newDict = Self()
          var newComponents = OpenAPI.Components()

          for try await (key, newRef, components) in group {
              newDict[key] = newRef
              try newComponents.merge(components)
          }
          return (newDict, newComponents)
        }
    }
}
