//
//  DereferencedPathItem.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

/// An `OpenAPI.PathItem` type that guarantees
/// its `parameters` and operations are inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedPathItem: Equatable {
    public let underlyingPathItem: OpenAPI.PathItem
    public let parameters: [DereferencedParameter]

    public let get: DereferencedOperation?
    public let put: DereferencedOperation?
    public let post: DereferencedOperation?
    public let delete: DereferencedOperation?
    public let options: DereferencedOperation?
    public let head: DereferencedOperation?
    public let patch: DereferencedOperation?
    public let trace: DereferencedOperation?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.PathItem, T>) -> T {
        return underlyingPathItem[keyPath: path]
    }

    /// Create a `DereferencedPathItem` if all references in the
    /// path item can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(pathItem: OpenAPI.PathItem, resolvingIn components: OpenAPI.Components) throws {
        self.parameters = try pathItem.parameters.map { parameter in
            try DereferencedParameter(
                parameter: try components.forceDereference(parameter),
                resolvingIn: components
            )
        }

        self.get = try pathItem.get.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.put = try pathItem.put.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.post = try pathItem.post.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.delete = try pathItem.delete.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.options = try pathItem.options.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.head = try pathItem.head.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.patch = try pathItem.patch.map { try DereferencedOperation(operation: $0, resolvingIn: components) }
        self.trace = try pathItem.trace.map { try DereferencedOperation(operation: $0, resolvingIn: components) }

        self.underlyingPathItem = pathItem
    }
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
