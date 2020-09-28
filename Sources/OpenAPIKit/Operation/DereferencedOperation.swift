//
//  DereferencedOperation.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

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
    internal init(_ operation: OpenAPI.Operation, resolvingIn components: OpenAPI.Components) throws {
        self.parameters = try operation.parameters.map { parameter in
            try parameter.dereferenced(in: components)
        }

        self.requestBody = try operation.requestBody.map { request in
            try request.dereferenced(in: components)
        }

        self.responses = try operation.responses.mapValues { response in
            try response.dereferenced(in: components)
        }

        self.security = try operation.security?.map {
            try DereferencedSecurityRequirement(
                $0,
                resolvingIn: components
            )
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
    /// Create a `DereferencedOperation` if all references in the
    /// operation can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public func dereferenced(in components: OpenAPI.Components) throws -> DereferencedOperation {
        return try DereferencedOperation(self, resolvingIn: components)
    }
}
