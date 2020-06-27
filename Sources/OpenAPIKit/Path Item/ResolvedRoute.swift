//
//  ResolvedRoute.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

public struct ResolvedRoute: Equatable {
    public let summary: String?
    public let description: String?
    public let vendorExtensions: [String :AnyCodable]

    public let path: OpenAPI.Path
    public let parameters: [DereferencedParameter]
    public let servers: [OpenAPI.Server]

    public let endpointsByMethod: [OpenAPI.HttpMethod: ResolvedEndpoint]

    public var get: ResolvedEndpoint? { endpointsByMethod[.get] }
    public var put: ResolvedEndpoint? { endpointsByMethod[.put] }
    public var post: ResolvedEndpoint? { endpointsByMethod[.post] }
    public var delete: ResolvedEndpoint? { endpointsByMethod[.delete] }
    public var options: ResolvedEndpoint? { endpointsByMethod[.options] }
    public var head: ResolvedEndpoint? { endpointsByMethod[.head] }
    public var patch: ResolvedEndpoint? { endpointsByMethod[.patch] }
    public var trace: ResolvedEndpoint? { endpointsByMethod[.trace] }

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

    public func resolvedRoutes() -> [ResolvedRoute] {
        return paths.keys.compactMap(resolvedRoute(at:))
    }

    public func resolvedRoutesByPath() -> OrderedDictionary<OpenAPI.Path, ResolvedRoute> {
        let routes = resolvedRoutes().map { ($0.path, $0) }
        return OrderedDictionary(routes, uniquingKeysWith: { $1 })
    }
}
