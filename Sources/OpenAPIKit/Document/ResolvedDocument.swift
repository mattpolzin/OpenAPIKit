//
//  ResolvedDocument.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

@dynamicMemberLookup
public struct ResolvedDocument: Equatable {
    public let underlyingDocument: DereferencedDocument
    public let routes: OrderedDictionary<OpenAPI.Path, ResolvedRoute>
    public let endpoints: OrderedDictionary<OpenAPI.Path, [ResolvedEndpoint]>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Document, T>) -> T {
        return underlyingDocument.underlyingDocument[keyPath: path]
    }

    internal init(dereferencedDocument: DereferencedDocument) {
        self.routes = dereferencedDocument.resolvedRoutesByPath()
        self.endpoints = dereferencedDocument.resolvedEndpointsByPath()

        self.underlyingDocument = dereferencedDocument
    }

    // The following just mask the dynamic member lookup of the `OpenAPI.Document`
    // to provide the values from the `DereferencedDocument` instead.
    public var paths: DereferencedPathItem.Map { underlyingDocument.paths }
    public var security: [DereferencedSecurityRequirement] { underlyingDocument.security }
}
