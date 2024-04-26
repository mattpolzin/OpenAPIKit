//
//  ExternalLoader.swift
//  
//
//  Created by Mathew Polzin on 7/30/2023.
//

import OpenAPIKitCore
import Foundation

/// An `ExternalLoader` enables `OpenAPIKit` to load external references 
/// without knowing the details of what decoder is being used or how new internal 
/// references should be named.
public protocol ExternalLoader {
    /// This can be anything that an implementor of this protocol wants to pass back from
    /// the `load()` function and have available after all external loading has been done.
    ///
    /// A trivial type if no Messages are needed would be Void.
    associatedtype Message

    /// Load the given URL and decode it as Type `T`. All Types `T` are `Decodable`, so
    /// the only real responsibility of a `load` function is to locate and load the given
    /// `URL` and pass its `Data` or `String` (depending on the decoder) to an appropriate
    /// `Decoder` for the given file type.
    static func load<T>(_: URL) async throws -> (T, [Message]) where T: Decodable

    /// Determine the next Component Key (where to store something in the 
    /// Components Object) for a new object of the given type that was loaded
    /// at the given external URL.
    ///
    /// - Important: Ideally, this function returns distinct keys for all different objects
    ///    but the same key for all equal objects. In practice, this probably means that any
    ///    time the same type and URL pair are passed in the same `ComponentKey` should be 
    ///    returned.
    static func componentKey<T>(type: T.Type, at url: URL) throws -> OpenAPI.ComponentKey
}

public protocol ExternallyDereferenceable {
    func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message])
}
