//
//  Callbacks.swift
//  
//
//  Created by Mathew Polzin on 11/1/20.
//

import OpenAPIKitCore
import Foundation

extension OpenAPI {

    /// A map from runtime expressions to path items to be used as
    /// callbacks for the API. The OpenAPI Spec "Callback Object."
    ///
    /// See [OpenAPI Callback Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#callback-object).
    ///
    public typealias Callbacks = OrderedDictionary<CallbackURL, Either<OpenAPI.Reference<PathItem>, PathItem>>

    /// A map of named collections of Callback Objects (`OpenAPI.Callbacks`).
    public typealias CallbacksMap = OrderedDictionary<String, Either<OpenAPI.Reference<Callbacks>, Callbacks>>

    /// A dictionary of Dereferenced of callbacks.
    public typealias DereferencedCallbacks = OrderedDictionary<CallbackURL, DereferencedPathItem>

    /// A dictionary of Dereferenced map of callbacks.
    public typealias DereferencedCallbacksMap = OrderedDictionary<String, DereferencedCallbacks>
}

extension OpenAPI.CallbackURL: LocallyDereferenceable {
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> OpenAPI.CallbackURL {
        self
    }
}

extension OpenAPI.CallbackURL: ExternallyDereferenceable {
    public func externallyDereferenced<Context: ExternalLoaderContext>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) { 
        // TODO: externally dereference security, responses, requestBody, and parameters
#warning("externally dereference security, responses, requestBody, and parameters")
        return (self, .init())
    }
}
