//
//  DereferencedDocument.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

/// An `OpenAPI.Document` type that guarantees
/// its `paths` are inlined instead of referenced.
@dynamicMemberLookup
public struct DereferencedDocument: Equatable {
    public let underlyingDocument: OpenAPI.Document
    public let paths: OrderedDictionary<OpenAPI.Path, DereferencedPathItem>
    public let security: [DereferencedSecurityRequirement]

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Document, T>) -> T {
        return underlyingDocument[keyPath: path]
    }

    /// Create a `DereferencedDocument` if all references in the
    /// document can be found in its Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(document: OpenAPI.Document) throws {
        self.paths = try document.paths.mapValues {
            try DereferencedPathItem(
                pathItem: $0,
                resolvingIn: document.components
            )
        }
        self.security = try document.security.map {
            try DereferencedSecurityRequirement(
                securityRequirement: $0,
                resolvingIn: document.components
            )
        }

        self.underlyingDocument = document
    }
}

extension DereferencedDocument {
    public struct Route: Equatable {
        public let path: OpenAPI.Path
        public let pathItem: DereferencedPathItem

        public init(
            path: OpenAPI.Path,
            pathItem: DereferencedPathItem
        ) {
            self.path = path
            self.pathItem = pathItem
        }
    }

    public var routes: [Route] {
        return paths.map { (path, pathItem) in .init(path: path, pathItem: pathItem) }
    }
}

extension DereferencedDocument {
    /// Resolve the document's routes and endpoints.
    ///
    /// OpenAPI allows routes and endpoints to take on things like
    /// servers, parameters, and security requirements from
    /// various different locations in the `OpenAPI.Document`. A
    /// `ResolvedDocument` offers access to canonical routes
    /// and endpoints that collect and self-contain all necessary
    /// information about the given component.
    ///
    /// **Example**
    ///
    /// A particular `GET` endpoint takes its security
    /// requirements from the root OpenAPI `security`
    /// array, it takes a path item parameter from the `PathItem` it
    /// resides within, and it defines an additional query parameter.
    ///
    /// The `ResolvedEndpoint` exposed by the `ResolvedDocument`
    /// will have the inherited security in its `security` array and it will have
    /// both the path and query parameters in its `parameters` array.
    public func resolved() -> ResolvedDocument {
        return ResolvedDocument(dereferencedDocument: self)
    }
}
