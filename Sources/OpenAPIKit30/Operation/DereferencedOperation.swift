//
//  DereferencedOperation.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Operation` type that guarantees
/// its `parameters`, `requestBody`, `responses`,
/// and `security` are inlined instead of referenced.
@dynamicMemberLookup
public struct DereferencedOperation: Equatable {
    /// The original `OpenAPI.Operation` prior to being dereferenced.
    public let underlyingOperation: OpenAPI.Operation
    /// A dereferenced array of parameters.
    public let parameters: [DereferencedParameter]
    /// A dereferenced request body.
    public let requestBody: DereferencedRequest?
    /// A dereferenced map of responses.
    public let responses: DereferencedResponse.Map
    /// A dereferenced map of callbacks.
    public let callbacks: OpenAPI.DereferencedCallbacksMap

    /// An array of dereferenced security requirements.
    ///
    /// If defined, overrides the security requirements in the
    /// root document `security` array.
    ///
    /// Each secutity requirement in this array is an alternative, only
    /// one of which must be met for the request to be authorized.
    ///
    /// By contrast, all entries in an individual `DereferencedSecurityRequirement`
    /// (which is itself a dictionary) must be met.
    ///
    /// `nil` indicates this operation uses the security requirements
    /// defined at the root of the document.
    public let security: [DereferencedSecurityRequirement]?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Operation, T>) -> T {
        return underlyingOperation[keyPath: path]
    }

    /// Create a `DereferencedOperation` if all references in the
    /// operation can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ operation: OpenAPI.Operation,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {
        self.parameters = try operation.parameters.map { parameter in
            try parameter._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        }

        self.requestBody = try operation.requestBody.map { request in
            try request._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        }

        self.responses = try operation.responses.mapValues { response in
            try response._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        }

        self.security = try operation.security?.map {
            try DereferencedSecurityRequirement(
                $0,
                resolvingIn: components,
                following: references
            )
        }

        self.callbacks = try operation.callbacks.mapValues { callback in
            try callback._dereferenced(in: components,
                                       following: references,
                                       dereferencedFromComponentNamed: nil)
        }

        self.underlyingOperation = operation
    }
}

extension DereferencedOperation {
    /// A `ResponseOutcome` is the combination of a
    /// status code and a response.
    public struct ResponseOutcome: Equatable {
        public let status: OpenAPI.Response.StatusCode
        public let response: DereferencedResponse

        public init(
            status: OpenAPI.Response.StatusCode,
            response: DereferencedResponse
        ) {
            self.status = status
            self.response = response
        }
    }

    /// Get all response outcomes for this operation.
    ///
    /// - Returns: An array of `ResponseOutcomes` with the status
    ///     and the response for the status.
    public var responseOutcomes: [ResponseOutcome] {
        return responses.map { (status, response) in .init(status: status, response: response) }
    }
}

extension OpenAPI.Operation: LocallyDereferenceable {
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
    ) throws -> DereferencedOperation {
        return try DereferencedOperation(self, resolvingIn: components, following: references)
    }
}

extension OpenAPI.Operation: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components) { 
        let oldParameters = parameters
        let oldRequestBody = requestBody
        let oldResponses = responses

        async let (newParameters, c1) = oldParameters.externallyDereferenced(with: loader)
        async let (newRequestBody, c2) = oldRequestBody.externallyDereferenced(with: loader)
        async let (newResponses, c3) = oldResponses.externallyDereferenced(with: loader)
        async let (newCallbacks, c4) = callbacks.externallyDereferenced(with: loader)
//        let (newServers, c6) = try await servers.externallyDereferenced(with: loader)

        var newOperation = self
        var newComponents = try await c1

        newOperation.parameters = try await newParameters
        newOperation.requestBody = try await newRequestBody
        try await newComponents.merge(c2)
        newOperation.responses = try await newResponses
        try await newComponents.merge(c3)
        newOperation.callbacks = try await newCallbacks
        try await newComponents.merge(c4)

        if let oldServers = servers {
            let (newServers, c6) = try await oldServers.externallyDereferenced(with: loader)
            newOperation.servers = newServers
            try newComponents.merge(c6)
        }

        // should not be necessary but current Swift compiler can't figure out conformance of ExternallyDereferenceable:
        if let oldServers = servers {
            let (newServers, c6) = try await oldServers.externallyDereferenced(with: loader)
            newOperation.servers = newServers
            try newComponents.merge(c6)
        }

        return (newOperation, newComponents)
    }
}
