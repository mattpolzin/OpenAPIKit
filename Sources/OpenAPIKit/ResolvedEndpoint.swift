//
//  ResolvedEndpoint.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

public struct ResolvedEndpoint: Equatable {
    public let routeSummary: String?
    public let routeDescription: String?
    public let routeVendorExtensions: [String: AnyCodable]

    public let tags: [String]
    public let operationSummary: String?
    public let operationDescription: String?
    public let operationVendorExtensions: [String: AnyCodable]
    public let operationId: String?

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
    public let responses: OrderedDictionary<OpenAPI.Response.StatusCode, DereferencedResponse>
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

    public func resolvedEndpoints() -> [ResolvedEndpoint] {
        return paths.keys.flatMap(resolvedEndpoints(at:))
    }

    public func resolvedEndpointsByPath() -> OrderedDictionary<OpenAPI.Path, [ResolvedEndpoint]> {
        return OrderedDictionary(grouping: resolvedEndpoints(), by: { $0.path })
    }
}
