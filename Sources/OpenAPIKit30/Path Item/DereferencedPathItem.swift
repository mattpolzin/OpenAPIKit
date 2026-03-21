//
//  DereferencedPathItem.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.PathItem` type that guarantees
/// its `parameters` and operations are inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedPathItem: Equatable {
    /// The original `OpenAPI.PathItem` prior to being dereferenced.
    public let underlyingPathItem: OpenAPI.PathItem
    /// The dereferenced list of parameters.
    public let parameters: [DereferencedParameter]

    /// The dereferenced GET operation, if defined.
    public let get: DereferencedOperation?
    /// The dereferenced PUT operation, if defined.
    public let put: DereferencedOperation?
    /// The dereferenced POST operation, if defined.
    public let post: DereferencedOperation?
    /// The dereferenced DELETE operation, if defined.
    public let delete: DereferencedOperation?
    /// The dereferenced OPTIONS operation, if defined.
    public let options: DereferencedOperation?
    /// The dereferenced HEAD operation, if defined.
    public let head: DereferencedOperation?
    /// The dereferenced PATCH operation, if defined.
    public let patch: DereferencedOperation?
    /// The dereferenced TRACE operation, if defined.
    public let trace: DereferencedOperation?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.PathItem, T>) -> T {
        return underlyingPathItem[keyPath: path]
    }

    /// Create a `DereferencedPathItem` if all references in the
    /// path item can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ pathItem: OpenAPI.PathItem,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws {
        self.parameters = try pathItem.parameters.map { parameter in
            try parameter._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        }

        self.get = try pathItem.get.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.put = try pathItem.put.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.post = try pathItem.post.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.delete = try pathItem.delete.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.options = try pathItem.options.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.head = try pathItem.head.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.patch = try pathItem.patch.map { try DereferencedOperation($0, resolvingIn: components, following: references) }
        self.trace = try pathItem.trace.map { try DereferencedOperation($0, resolvingIn: components, following: references) }

        var pathItem = pathItem
        if let name {
            pathItem.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        self.underlyingPathItem = pathItem
    }

    public typealias Map = OrderedDictionary<OpenAPI.Path, DereferencedPathItem>
}

extension DereferencedPathItem {
    /// Retrieve the operation for the given verb, if one is set for this path.
    public func `for`(_ verb: OpenAPI.BuiltinHttpMethod) -> DereferencedOperation? {
        switch verb {
        case .delete:
            return self.delete
        case .get:
            return self.get
        case .head:
            return self.head
        case .options:
            return self.options
        case .patch:
            return self.patch
        case .post:
            return self.post
        case .put:
            return self.put
        case .trace:
            return self.trace
        case .query:
            return nil
        }
    }

    public subscript(verb: OpenAPI.BuiltinHttpMethod) -> DereferencedOperation? {
        get {
            return `for`(verb)
        }
    }

    /// An `Endpoint` is the combination of an
    /// HTTP method and an operation.
    public struct Endpoint: Equatable {
        public let method: OpenAPI.BuiltinHttpMethod
        public let operation: DereferencedOperation
    }

    /// Get all endpoints defined at this path.
    ///
    /// - Returns: An array of `Endpoints` with the method (i.e. `.get`) and the operation for
    ///     the method.
    public var endpoints: [Endpoint] {
        return OpenAPI.BuiltinHttpMethod.allCases.compactMap { method in
            self.for(method).map { .init(method: method, operation: $0) }
        }
    }
}

extension OpenAPI.PathItem: LocallyDereferenceable {
    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> DereferencedPathItem {
        return try DereferencedPathItem(self, resolvingIn: components, following: references, dereferencedFromComponentNamed: name)
    }
}

extension OpenAPI.PathItem: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
        async let (newParameters, c1, m1) = parameters.externallyDereferenced(with: loader)
        var pathItem = self
        var newComponents = try await c1
        var newMessages = try await m1

        pathItem.parameters = try await newParameters

        let (newGet, c2, m2) = try await get.externallyDereferenced(with: loader)
        pathItem.get = newGet
        try newComponents.merge(c2)
        newMessages += m2

        let (newPut, c3, m3) = try await put.externallyDereferenced(with: loader)
        pathItem.put = newPut
        try newComponents.merge(c3)
        newMessages += m3

        let (newPost, c4, m4) = try await post.externallyDereferenced(with: loader)
        pathItem.post = newPost
        try newComponents.merge(c4)
        newMessages += m4

        let (newDelete, c5, m5) = try await delete.externallyDereferenced(with: loader)
        pathItem.delete = newDelete
        try newComponents.merge(c5)
        newMessages += m5

        let (newOptions, c6, m6) = try await options.externallyDereferenced(with: loader)
        pathItem.options = newOptions
        try newComponents.merge(c6)
        newMessages += m6

        let (newHead, c7, m7) = try await head.externallyDereferenced(with: loader)
        pathItem.head = newHead
        try newComponents.merge(c7)
        newMessages += m7

        let (newPatch, c8, m8) = try await patch.externallyDereferenced(with: loader)
        pathItem.patch = newPatch
        try newComponents.merge(c8)
        newMessages += m8

        let (newTrace, c9, m9) = try await trace.externallyDereferenced(with: loader)
        pathItem.trace = newTrace
        try newComponents.merge(c9)
        newMessages += m9

        if let servers {
            let (newServers, c10, m10) = try await servers.externallyDereferenced(with: loader)
            pathItem.servers = newServers
            try newComponents.merge(c10)
            newMessages += m10
        }

        return (pathItem, newComponents, newMessages)
    }
}
