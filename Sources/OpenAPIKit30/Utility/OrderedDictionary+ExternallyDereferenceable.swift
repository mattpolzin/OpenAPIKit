//
//  OrderedDictionary+ExternallyDereferenceable.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 08/05/2023.
//

import OpenAPIKitCore

extension OrderedDictionary where Value: ExternallyDereferenceable {

    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components) {
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
