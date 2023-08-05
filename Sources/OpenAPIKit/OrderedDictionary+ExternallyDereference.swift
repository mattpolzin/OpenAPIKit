//
//  OrderedDictionary+ExternallyDereference.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 08/05/2023.
//

import OpenAPIKitCore

extension OrderedDictionary where Value: LocallyDereferenceable {
    internal func externallyDereferenced<Context>(with loader: inout ExternalLoader<Context>) throws -> Self where Context: ExternalLoaderContext {
        var newDict = Self()
        for (key, value) in self {
            let newRef = try value.externallyDereferenced(with: &loader)
            newDict[key] = newRef
        }
        return newDict
    }
}
