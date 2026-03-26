//
//  DereferencedPathItem.swift
//  

import OpenAPIKitCore

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

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
    /// The dereferenced QUERY operation, if defined.
    public let query: DereferencedOperation?

    /// Additional operations, keyed by all-caps HTTP method names. This
    /// map MUST NOT contain any entries that can be represented by the
    /// fixed fields on this type (e.g. `post`, `get`, etc.).
    public let additionalOperations: OrderedDictionary<OpenAPI.HttpMethod, DereferencedOperation>

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
        self.query = try pathItem.query.map { try DereferencedOperation($0, resolvingIn: components, following: references) }

        self.additionalOperations = try pathItem.additionalOperations.mapValues { try DereferencedOperation($0, resolvingIn: components, following: references) }

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
        case .builtin(let builtin):
            switch builtin {
            case .delete: self.delete
            case .get: self.get
            case .head: self.head
            case .options: self.options
            case .patch: self.patch
            case .post: self.post
            case .put: self.put
            case .trace: self.trace
            case .query: self.query
            }
        case .other(let other):
            additionalOperations[.other(other)]
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
        let builtins = OpenAPI.BuiltinHttpMethod.allCases.compactMap { method -> Endpoint? in
            self.for(.builtin(method)).map { .init(method: .builtin(method), operation: $0) }
        }

        return builtins + additionalOperations.map { key, value in .init(method: key, operation: value) }
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
        let oldQuery = query

        let oldAdditionalOperations = additionalOperations

        var pathItem = self

        // Older Swift 6.0/6.1 Linux runtimes have been observed crashing when this
        // dereference path fans out into a large batch of `async let` child tasks.
        // The sequential form keeps behavior the same while staying compatible
        // across the full test matrix.
        let (newParameters, c1, m1) = try await oldParameters.externallyDereferenced(with: loader)
        pathItem.parameters = newParameters

        var newComponents = c1
        var newMessages = m1

        let (newGet, c3, m3) = try await oldGet.externallyDereferenced(with: loader)
        pathItem.get = newGet
        try newComponents.merge(c3)
        newMessages += m3

        let (newPut, c4, m4) = try await oldPut.externallyDereferenced(with: loader)
        pathItem.put = newPut
        try newComponents.merge(c4)
        newMessages += m4

        let (newPost, c5, m5) = try await oldPost.externallyDereferenced(with: loader)
        pathItem.post = newPost
        try newComponents.merge(c5)
        newMessages += m5

        let (newDelete, c6, m6) = try await oldDelete.externallyDereferenced(with: loader)
        pathItem.delete = newDelete
        try newComponents.merge(c6)
        newMessages += m6

        let (newOptions, c7, m7) = try await oldOptions.externallyDereferenced(with: loader)
        pathItem.options = newOptions
        try newComponents.merge(c7)
        newMessages += m7

        let (newHead, c8, m8) = try await oldHead.externallyDereferenced(with: loader)
        pathItem.head = newHead
        try newComponents.merge(c8)
        newMessages += m8

        let (newPatch, c9, m9) = try await oldPatch.externallyDereferenced(with: loader)
        pathItem.patch = newPatch
        try newComponents.merge(c9)
        newMessages += m9

        let (newTrace, c10, m10) = try await oldTrace.externallyDereferenced(with: loader)
        pathItem.trace = newTrace
        try newComponents.merge(c10)
        newMessages += m10

        let (newQuery, c11, m11) = try await oldQuery.externallyDereferenced(with: loader)
        pathItem.query = newQuery
        try newComponents.merge(c11)
        newMessages += m11

        let (newAdditionalOperations, c12, m12) = try await oldAdditionalOperations.externallyDereferenced(with: loader)
        pathItem.additionalOperations = newAdditionalOperations
        try newComponents.merge(c12)
        newMessages += m12

        if let oldServers {
            let (newServers, c2, m2) = try await oldServers.externallyDereferenced(with: loader)
            pathItem.servers = newServers
            try newComponents.merge(c2)
            newMessages += m2
        }

        return (pathItem, newComponents, newMessages)
    }
}
