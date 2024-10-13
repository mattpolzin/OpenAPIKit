//
//  Dictionary+ExternallyDereferenceable.swift
//  OpenAPI
//

import OpenAPIKitCore

extension Dictionary where Value: ExternallyDereferenceable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) {
        try await withThrowingTaskGroup(of: (Key, Value, OpenAPI.Components, [Loader.Message]).self) { group in
          for (key, value) in self {
              group.addTask {
                  let (newRef, components, messages) = try await value.externallyDereferenced(with: loader)
                  return (key, newRef, components, messages)
              }
          }

          var newDict = Self()
          var newComponents = OpenAPI.Components()
          var newMessages = [Loader.Message]()

          for try await (key, newRef, components, messages) in group {
              newDict[key] = newRef
              try newComponents.merge(components)
              newMessages += messages
          }
          return (newDict, newComponents, newMessages)
        }
    }
}
