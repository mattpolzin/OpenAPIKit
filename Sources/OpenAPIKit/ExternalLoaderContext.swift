//
//  ExternalLoaderContext.swift
//  
//
//  Created by Mathew Polzin on 7/30/2023.
//

import OpenAPIKitCore
import Foundation

/// An `ExternalLoaderContext` enables `OpenAPIKit` to load external references 
/// without knowing the details of what decoder is being used or how new internal 
/// references should be named.
public protocol ExternalLoaderContext {
    /// External references are loaded into this Components Object. This allows for
    /// loading external references into a single Document but also retaining the
    /// identity of those refernces; that is, if three parts of a Document refer to 
    /// the same external reference, the external object will be loaded into this 
    /// Components Object and the three locations will still refer to the same 
    /// object (these are now internal references).
    var components: OpenAPI.Components { get set }

    /// Load the given URL and decode it as type T. 
    static func load<T>(_: URL) throws -> T where T: Decodable

    /// Determine the next Component Key (where to store something in the 
    /// Components Object) for a new object of the given type that was loaded
    /// at the given external URL.
    mutating func nextComponentKey<T>(type: T.Type, at: URL) -> OpenAPI.ComponentKey
}

extension ExternalLoaderContext {
    mutating func store<T>(type: T.Type, from url: URL) throws -> OpenAPI.Reference<T> where T: ComponentDictionaryLocatable & Equatable & Decodable & LocallyDereferenceable {
        let key = nextComponentKey(type: type, at: url)
        let value: T = try Self.load(url)
        components[keyPath: T.openAPIComponentsKeyPath][key] = try value.externallyDereferenced(in: &self)
        return try components.reference(named: key.rawValue, ofType: T.self)
    }
}
