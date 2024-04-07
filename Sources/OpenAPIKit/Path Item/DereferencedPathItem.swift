//
//  DereferencedPathItem.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore
import Foundation

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
    public func `for`(_ verb: OpenAPI.HttpMethod) -> DereferencedOperation? {
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
        }
    }

    public subscript(verb: OpenAPI.HttpMethod) -> DereferencedOperation? {
        get {
            return `for`(verb)
        }
    }

    /// An `Endpoint` is the combination of an
    /// HTTP method and an operation.
    public struct Endpoint: Equatable {
        public let method: OpenAPI.HttpMethod
        public let operation: DereferencedOperation
    }

    /// Get all endpoints defined at this path.
    ///
    /// - Returns: An array of `Endpoints` with the method (i.e. `.get`) and the operation for
    ///     the method.
    public var endpoints: [Endpoint] {
        return OpenAPI.HttpMethod.allCases.compactMap { method in
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
    public func externallyDereferenced<Context: ExternalLoaderContext>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) { 
        let oldParameters = parameters
        let oldServers = servers
        let oldGet = get
        let oldPut = put
        let oldPost = post
        let oldDelete = delete
        let oldOptions = options
        let oldHead = head
        let oldPatch = patch
        let oldTrace = trace

        async let (newParameters, c1) = oldParameters.externallyDereferenced(with: loader)
//        async let (newServers, c2) = oldServers.externallyDereferenced(with: loader)
//        async let (newGet, c3) = oldGet.externallyDereferenced(with: loader)
//        async let (newPut, c4) = oldPut.externallyDereferenced(with: loader)
//        async let (newPost, c5) = oldPost.externallyDereferenced(with: loader)
//        async let (newDelete, c6) = oldDelete.externallyDereferenced(with: loader)
//        async let (newOptions, c7) = oldOptions.externallyDereferenced(with: loader)
//        async let (newHead, c8) = oldHead.externallyDereferenced(with: loader)
//        async let (newPatch, c9) = oldPatch.externallyDereferenced(with: loader)
//        async let (newTrace, c10) = oldTrace.externallyDereferenced(with: loader)

        var pathItem = self
        var newComponents = try await c1

        // ideally we would async let all of the props above and then set them here,
        // but for now since there seems to be some sort of compiler bug we will do
        // most of them in if lets below
        pathItem.parameters = try await newParameters

        if let oldServers {
            async let (newServers, c2) = oldServers.externallyDereferenced(with: loader)
            pathItem.servers = try await newServers
            try await newComponents.merge(c2)
        }

        if let oldGet {
            async let (newGet, c3) = oldGet.externallyDereferenced(with: loader)
            pathItem.get = try await newGet
            try await newComponents.merge(c3)
        }

        if let oldPut {
            async let (newPut, c4) = oldPut.externallyDereferenced(with: loader)
            pathItem.put = try await newPut
            try await newComponents.merge(c4)
        }
        
        if let oldPost {
            async let (newPost, c5) = oldPost.externallyDereferenced(with: loader)
            pathItem.post = try await newPost
            try await newComponents.merge(c5)
        }
        
        if let oldDelete {
            async let (newDelete, c6) = oldDelete.externallyDereferenced(with: loader)
            pathItem.delete = try await newDelete
            try await newComponents.merge(c6)
        }
        
        if let oldOptions {
            async let (newOptions, c7) = oldOptions.externallyDereferenced(with: loader)
            pathItem.options = try await newOptions
            try await newComponents.merge(c7)
        }
        
        if let oldHead {
            async let (newHead, c8) = oldHead.externallyDereferenced(with: loader)
            pathItem.head = try await newHead
            try await newComponents.merge(c8)
        }
        
        if let oldPatch {
            async let (newPatch, c9) = oldPatch.externallyDereferenced(with: loader)
            pathItem.patch = try await newPatch
            try await newComponents.merge(c9)
        }
        
        if let oldTrace {
            async let (newTrace, c10) = oldTrace.externallyDereferenced(with: loader)
            pathItem.trace = try await newTrace
            try await newComponents.merge(c10)
        }

        return (pathItem, newComponents)
    }
}
