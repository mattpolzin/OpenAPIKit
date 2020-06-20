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

    public let endpoints: [ResolvedEndpoint]
}

extension DereferencedDocument {
    internal func resolvedRoute(at path: OpenAPI.Path) -> ResolvedRoute? {
        guard let pathItem = paths[path] else { return nil }

        return ResolvedRoute(
            summary: pathItem.summary,
            description: pathItem.description,
            vendorExtensions: pathItem.vendorExtensions,
            path: path,
            parameters: pathItem.parameters,
            servers: pathItem.servers ?? self.servers,
            endpoints: resolvedEndpoints(at: path)
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
