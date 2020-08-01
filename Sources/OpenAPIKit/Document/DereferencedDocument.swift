//
//  DereferencedDocument.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

/// An `OpenAPI.Document` type that guarantees
/// its `paths` and `security` are inlined instead of
/// referenced. You create a `DereferencedDocument`
///  by calling the `locallyDereferenced()` method
/// on an `OpenAPI.Document`.
@dynamicMemberLookup
public struct DereferencedDocument: Equatable {
    /// The original OpenAPI document prior to being
    /// dereferenced.
    public let underlyingDocument: OpenAPI.Document

    /// This property maps the path of each route (`OpenAPI.Path`) to the
    /// documentation for that route (`DereferencedPathItem`).
    public let paths: DereferencedPathItem.Map

    /// A declaration of which security mechanisms can be used across the API.
    ///
    /// The list of values includes alternative security requirement objects that can
    /// be used. Only one of the security requirement objects need to be satisfied
    /// to authorize a request. Individual operations can override this definition.
    ///
    /// To make security optional, an empty security requirement can be included
    /// in the array.
    public let security: [DereferencedSecurityRequirement]

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Document, T>) -> T {
        return underlyingDocument[keyPath: path]
    }

    /// Create a `DereferencedDocument` if all references in the
    /// document can be found in its Components Object.
    ///
    /// - Important: This only attempts to dereference components in the
    ///     Components Object. Any references pointing to other files or other
    ///     locations in the same file will `throw`.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(_ document: OpenAPI.Document) throws {
        self.paths = try document.paths.mapValues {
            try DereferencedPathItem(
                $0,
                resolvingIn: document.components
            )
        }
        self.security = try document.security.map {
            try DereferencedSecurityRequirement(
                $0,
                resolvingIn: document.components
            )
        }

        self.underlyingDocument = document
    }
}

extension DereferencedDocument {
    /// The pairing of a path and the path item that describes the
    /// route at that path.
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

    /// Get an array of all routes in the document. A route is
    /// the pairing of a path and the path item that describes the
    /// route at that path.
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
