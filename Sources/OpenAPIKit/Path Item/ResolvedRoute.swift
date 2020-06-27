//
//  ResolvedRoute.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

/// The canonical definition of a route. All information
/// from throughout the OpenAPI document that is relevant
/// to a particular route is collected and exposed in this
/// type.
///
/// You can access resolved routes via the
/// `ResolvedDocument` type. You make a `ResolvedDocument`
/// from an `OpenAPI.Document` by calling:
///
///     try document
///         .locallyDereferenced()
///         .resolved()
///
/// See `ResolvedDocument` for more information.
public struct ResolvedRoute: Equatable {
    /// The summary of this route.
    public let summary: String?
    /// The description of this route.
    public let description: String?
    /// The OpenAPI Specification Extensions available
    /// on this route.
    public let vendorExtensions: [String :AnyCodable]

    /// The path at which this route is exposed.
    public let path: OpenAPI.Path
    /// All parameters that apply to all endpoints
    /// at this route. This array does not include
    /// parameters that apply to some but not all
    /// endpoints.
    ///
    /// For a comprehensive array of parameters
    /// relevant to any particular _endpoint_, use
    /// the `ResolvedEndpoint` `parameters`
    /// property. That property will contain both
    /// parameters that are relevant to all endpoints
    /// at this route and also parameters only
    /// relevant to the given endpoint.
    public let parameters: [DereferencedParameter]
    /// The list of servers that support this route.
    public let servers: [OpenAPI.Server]

    /// All endpoints at this route, keyed by
    /// the HTTP method (`GET`, `PATCH`, etc.) the
    /// endpoint supports.
    ///
    /// You can also retrieve individual endpoints
    /// with properties named after the HTTP method
    ///
    ///     resolvedRoute.put
    ///
    /// Or using the `for(_:)` method
    ///
    ///     resolvedRoute.for(.patch)
    public let endpointsByMethod: [OpenAPI.HttpMethod: ResolvedEndpoint]

    /// The HTTP `GET` endpoint at this route.
    public var get: ResolvedEndpoint? { endpointsByMethod[.get] }
    /// The HTTP `PUT` endpoint at this route.
    public var put: ResolvedEndpoint? { endpointsByMethod[.put] }
    /// The HTTP `POST` endpoint at this route.
    public var post: ResolvedEndpoint? { endpointsByMethod[.post] }
    /// The HTTP `DELETE` endpoint at this route.
    public var delete: ResolvedEndpoint? { endpointsByMethod[.delete] }
    /// The HTTP `OPTIONS` endpoint at this route.
    public var options: ResolvedEndpoint? { endpointsByMethod[.options] }
    /// The HTTP `HEAD` endpoint at this route.
    public var head: ResolvedEndpoint? { endpointsByMethod[.head] }
    /// The HTTP `PATCH` endpoint at this route.
    public var patch: ResolvedEndpoint? { endpointsByMethod[.patch] }
    /// The HTTP `TRACE` endpoint at this route.
    public var trace: ResolvedEndpoint? { endpointsByMethod[.trace] }

    /// An array of all endpoints at this route.
    ///
    /// The ordering of this array is neither guaranteed
    /// nor stable.
    public var endpoints: [ResolvedEndpoint] { Array(endpointsByMethod.values) }

    /// Retrieve the endpoint for the given method, if one exists for this route.
    public func `for`(_ verb: OpenAPI.HttpMethod) -> ResolvedEndpoint? {
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
}

extension DereferencedDocument {
    /// Return the resolved route for a given path.
    internal func resolvedRoute(at path: OpenAPI.Path) -> ResolvedRoute? {
        guard let pathItem = paths[path] else { return nil }

        let endpoints = self.resolvedEndpoints(at: path)
            .map { ($0.method, $0) }

        return ResolvedRoute(
            summary: pathItem.summary,
            description: pathItem.description,
            vendorExtensions: pathItem.vendorExtensions,
            path: path,
            parameters: pathItem.parameters,
            servers: pathItem.servers ?? self.servers,
            endpointsByMethod: Dictionary(uniqueKeysWithValues: endpoints)
        )
    }

    /// Return all resolved routes for the whole document.
    ///
    /// If you are working with resolved endpoints and routes
    /// the `ResolvedDocument` type might offer the best
    /// interface.
    public func resolvedRoutes() -> [ResolvedRoute] {
        return paths.keys.compactMap(resolvedRoute(at:))
    }

    /// Returns all resolved routes for the whole document
    /// keyed by the paths each route is found at.
    ///
    /// If you are working with resolved endpoints and routes
    /// the `ResolvedDocument` type might offer the best
    /// interface.
    public func resolvedRoutesByPath() -> OrderedDictionary<OpenAPI.Path, ResolvedRoute> {
        let routes = resolvedRoutes().map { ($0.path, $0) }
        return OrderedDictionary(routes, uniquingKeysWith: { $1 })
    }
}
