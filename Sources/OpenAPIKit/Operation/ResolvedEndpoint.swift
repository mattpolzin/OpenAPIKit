//
//  ResolvedEndpoint.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

/// The canonical definition of an endpoint. All information
/// from throughout the OpenAPI document that is relevant
/// to a particular endpoint is collected and exposed in this
/// type.
///
/// You can access resolved endpoints via the
/// `ResolvedDocument` type. You make a `ResolvedDocument`
/// from an `OpenAPI.Document` by calling:
///
///     try document
///         .locallyDereferenced()
///         .resolved()
///
/// See `ResolvedDocument` for more information.
public struct ResolvedEndpoint: Equatable {
    /// The summary for the route that contains this
    /// endpoint.
    public let routeSummary: String?
    /// The description of the route that contains this
    /// endpoint.
    public let routeDescription: String?
    /// The OpenAPI Specification Extensions available
    /// on the route that contains this endpoint.
    public let routeVendorExtensions: [String: AnyCodable]

    /// The tags that are applicable to this endpoint.
    public let tags: [String]
    /// The summary for the operation this endpoint performs.
    public let operationSummary: String?
    /// The description of the operation this endpoint performs.
    public let operationDescription: String?
    /// The OpenAPI Specification Extensions available
    /// on this endpoint.
    public let operationVendorExtensions: [String: AnyCodable]
    /// The unique Id for the operation this endpoint performs.
    public let operationId: String?

    /// Any external documentation for this endpoint.
    public let externalDocs: OpenAPI.ExternalDocumentation?

    /// Servers applicable to this endpoint.
    public let servers: [OpenAPI.Server]
    /// The HTTP method of this endpoint.
    ///
    /// e.g. GET, POST, PUT, PATCH, etc.
    public let method: OpenAPI.HttpMethod
    /// The path for this endpoint.
    public let path: OpenAPI.Path
    /// The parameters this endpoint accepts.
    ///
    /// This array includes both parameters that apply to
    /// all endpoints at the same route and also parameters
    /// that only apply to this endpoint. It is comprehensive.
    public let parameters: [DereferencedParameter]
    /// Security requirements for this endpoint.
    ///
    /// An empty array means there are no requirements.
    /// If the array contains more than one entry, each entry is
    /// an alternative security requirement.
    ///
    /// By contrast, each security requirement can itself contain
    /// any number of schemes and all schemes specified are
    /// required for each request ot this endpoint.
    public let security: [DereferencedSecurityRequirement]
    /// The request body (if applicable) for this endpoint.
    public let requestBody: DereferencedRequest?
    /// All possible responses, keyed by the status code for each
    /// response.
    public let responses: DereferencedResponse.Map
    /// Indicates whether this endpoint should be used anymore
    /// or not.
    public let deprecated: Bool

    /// Get only the `parameters` that are required.
    public var requiredParameters: [DereferencedParameter] {
        return parameters.filter { $0.required }
    }

    /// Get only the `parameters` that are optional.
    public var optionalParameters: [DereferencedParameter] {
        return parameters.filter { !$0.required }
    }

    /// Get all response outcomes for this endpoint.
    ///
    /// - Returns: An array of `ResponseOutcomes` with the status
    ///     and the response for the status.
    public var responseOutcomes: [DereferencedOperation.ResponseOutcome] {
        return responses.map { (status, response) in .init(status: status, response: response) }
    }
}

extension DereferencedDocument {
    /// Return an array of all resolved endpoints under
    /// the given path.
    internal func resolvedEndpoints(at path: OpenAPI.Path) -> [ResolvedEndpoint] {
        guard let pathItem = paths[path] else { return [] }

        func uniqueParametersForCurrentPath(_ operation: DereferencedOperation) -> [DereferencedParameter] {
            let allParameters = pathItem.parameters + operation.parameters

            var seenParameterIdentities = Set<OpenAPI.Parameter.ParameterIdentity>()
            var uniqueParameters = [DereferencedParameter]()

            for parameter in allParameters {
                let identity = OpenAPI.Parameter.ParameterIdentity(name: parameter.name, location: parameter.location)
                if !seenParameterIdentities.contains(identity) {
                    seenParameterIdentities.insert(identity)
                    uniqueParameters.append(parameter)
                }
            }
            return uniqueParameters
        }

        return pathItem.endpoints.map { endpoint in
            ResolvedEndpoint(
                routeSummary: pathItem.summary,
                routeDescription: pathItem.description,
                routeVendorExtensions: pathItem.vendorExtensions,
                tags: endpoint.operation.tags ?? [],
                operationSummary: endpoint.operation.summary,
                operationDescription: endpoint.operation.description,
                operationVendorExtensions: endpoint.operation.vendorExtensions,
                operationId: endpoint.operation.operationId,
                externalDocs: endpoint.operation.externalDocs,
                servers: endpoint.operation.servers ?? pathItem.servers ?? self.servers,
                method: endpoint.method,
                path: path,
                parameters: uniqueParametersForCurrentPath(endpoint.operation),
                security: endpoint.operation.security ?? security,
                requestBody: endpoint.operation.requestBody,
                responses: endpoint.operation.responses,
                deprecated: endpoint.operation.deprecated
            )
        }
    }

    /// Return all resolved endpoints for the whole document.
    ///
    /// If you are working with resolved endpoints and routes
    /// the `ResolvedDocument` type might offer the best
    /// interface.
    public func resolvedEndpoints() -> [ResolvedEndpoint] {
        return paths.keys.flatMap(resolvedEndpoints(at:))
    }

    /// Returns all resolved endpoints for the whole document
    /// grouped by the paths for the routes containing them.
    ///
    /// If you are working with resolved endpoints and routes
    /// the `ResolvedDocument` type might offer the best
    /// interface.
    public func resolvedEndpointsByPath() -> OrderedDictionary<OpenAPI.Path, [ResolvedEndpoint]> {
        return OrderedDictionary(grouping: resolvedEndpoints(), by: { $0.path })
    }
}
