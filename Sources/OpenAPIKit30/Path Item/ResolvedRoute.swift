//
//  ResolvedRoute.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

import OpenAPIKitCore

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

    /// The HTTP `GET` endpoint at this route.
    public let get: ResolvedEndpoint?
    /// The HTTP `PUT` endpoint at this route.
    public let put: ResolvedEndpoint?
    /// The HTTP `POST` endpoint at this route.
    public let post: ResolvedEndpoint?
    /// The HTTP `DELETE` endpoint at this route.
    public let delete: ResolvedEndpoint?
    /// The HTTP `OPTIONS` endpoint at this route.
    public let options: ResolvedEndpoint?
    /// The HTTP `HEAD` endpoint at this route.
    public let head: ResolvedEndpoint?
    /// The HTTP `PATCH` endpoint at this route.
    public let patch: ResolvedEndpoint?
    /// The HTTP `TRACE` endpoint at this route.
    public let trace: ResolvedEndpoint?

    /// Create a ResolvedRoute.
    ///
    /// `ResolvedRoute` creation is only publicly
    /// exposed by methods on `ResolvedDocument`
    /// and `DereferencedDocument`.
    ///
    /// - Important: The endpoints passed in must each
    /// be associated with a different HTTP method. Naturally
    /// a route can only define one operation for each method.
    internal init(
        summary: String?,
        description: String?,
        vendorExtensions: [String: AnyCodable],
        path: OpenAPI.Path,
        parameters: [DereferencedParameter],
        servers: [OpenAPI.Server],
        endpoints: [ResolvedEndpoint]
    ) {
        let endpoints = Dictionary(
            endpoints.map { ($0.method, $0) },
            uniquingKeysWith: { $1 }
        )

        self.summary = summary
        self.description = description
        self.vendorExtensions = vendorExtensions
        self.path = path
        self.parameters = parameters
        self.servers = servers

        self.get = endpoints[.get]
        self.put = endpoints[.put]
        self.post = endpoints[.post]
        self.delete = endpoints[.delete]
        self.options = endpoints[.options]
        self.head = endpoints[.head]
        self.patch = endpoints[.patch]
        self.trace = endpoints[.trace]
    }

    /// An array of all endpoints at this route.
    public var endpoints: [ResolvedEndpoint] {
        [
            self.get,
            self.put,
            self.post,
            self.delete,
            self.options,
            self.head,
            self.patch,
            self.trace
        ].compactMap { $0 }
    }

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
        case .query:
            return nil
        }
    }

    public subscript(verb: OpenAPI.HttpMethod) -> ResolvedEndpoint? {
        get {
            return `for`(verb)
        }
    }
}

extension DereferencedDocument {
    /// Return the resolved route for a given path.
    internal func resolvedRoute(at path: OpenAPI.Path) -> ResolvedRoute? {
        guard let pathItem = paths[path] else { return nil }

        return ResolvedRoute(
            summary: pathItem.summary,
            description: pathItem.description,
            vendorExtensions: pathItem.vendorExtensions,
            path: path,
            parameters: pathItem.parameters,
            servers: pathItem.servers ?? self.servers,
            endpoints: self.resolvedEndpoints(at: path)
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
