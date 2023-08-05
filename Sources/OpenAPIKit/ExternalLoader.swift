//
//  ExternalLoader.swift
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
    /// Load the given URL and decode it as Type `T`. All Types `T` are `Decodable`, so
    /// the only real responsibility of a `load` function is to locate and load the given
    /// `URL` and pass its `Data` or `String` (depending on the decoder) to an appropriate
    /// `Decoder` for the given file type.
    static func load<T>(_: URL) throws -> T where T: Decodable

    /// Determine the next Component Key (where to store something in the 
    /// Components Object) for a new object of the given type that was loaded
    /// at the given external URL.
    ///
    /// - Important: Ideally, this function returns distinct keys for all different objects
    ///    but the same key for all equal objects. In practice, this probably means that any
    ///    time the same type and URL pair are passed in the same `ComponentKey` should be 
    ///    returned.
    mutating func nextComponentKey<T>(type: T.Type, at: URL, given components: OpenAPI.Components) throws -> OpenAPI.ComponentKey
}

public struct ExternalLoader<Context: ExternalLoaderContext> {
    public init(components: OpenAPI.Components, context: Context) {
        self.components = components
        self.context = context
    }

    /// External references are loaded into this Components Object. This allows for
    /// loading external references into a single Document but also retaining the
    /// identity of those refernces; that is, if three parts of a Document refer to 
    /// the same external reference, the external object will be loaded into this 
    /// Components Object and the three locations will still refer to the same 
    /// object (these are now internal references).
    ///
    /// In the most common use-cases, the starting place for this `components` property
    /// should be the existing `Components` for some OpenAPI `Document`. This allows local 
    /// references to be followed while external references are loaded.
    public internal(set) var components: OpenAPI.Components

    internal var context: Context

    internal mutating func store<T>(type: T.Type, from url: URL) throws -> OpenAPI.Reference<T> where T: ComponentDictionaryLocatable & Equatable & Decodable & LocallyDereferenceable {
        let key = try context.nextComponentKey(type: type, at: url, given: components)
        let value: T = try Context.load(url)
        components[keyPath: T.openAPIComponentsKeyPath][key] = try value.externallyDereferenced(with: &self)
        return try components.reference(named: key.rawValue, ofType: T.self)
    }
}
