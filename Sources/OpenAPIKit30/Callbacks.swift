//
//  Callback.swift
//  

import OpenAPIKitCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

extension OpenAPI {
    /// A map from runtime expressions to path items to be used as
    /// callbacks for the API.
    ///
    /// See [OpenAPI Callback Object](https://spec.openapis.org/oas/v3.0.4.html#callback-object).
    ///
    public typealias Callbacks = OrderedDictionary<CallbackURL, PathItem>

    /// A map of named collections of Callback Objects (`OpenAPI.Callbacks`).
    public typealias CallbacksMap = OrderedDictionary<String, Either<JSONReference<Callbacks>, Callbacks>>

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

// The following conformance is theoretically unnecessary but the compiler is
// only able to find the conformance if we explicitly declare it here, though
// it is apparently able to determine the conformance is already satisfied here
// at least.
extension OpenAPI.Callbacks: ExternallyDereferenceable { }
