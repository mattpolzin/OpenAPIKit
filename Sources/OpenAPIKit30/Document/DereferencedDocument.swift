//
//  DereferencedDocument.swift
//  
//
//  Created by Mathew Polzin on 6/19/20.
//

import OpenAPIKitCore

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
            try $0._dereferenced(
                in: document.components,
                following: [],
                dereferencedFromComponentNamed: nil
            )
        }
        self.security = try document.security.map {
            try DereferencedSecurityRequirement(
                $0,
                resolvingIn: document.components,
                following: []
            )
        }

        self.underlyingDocument = document
    }
}

// MARK: - Dereferenced Helpers
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

    /// Retrieve an array of all Operation Ids defined by
    /// this API. These Ids are guaranteed to be unique by
    /// the OpenAPI Specification.
    ///
    /// The ordering is not necessarily significant, but it will
    /// be the order in which each operation is occurred within
    /// each path, traversed in the order the paths appear in
    /// the document.
    ///
    /// See [Operation Object](https://spec.openapis.org/oas/v3.0.4.html#operation-object) in the specifcation.
    ///
    public var allOperationIds: [String] {
        return paths.values
            .flatMap { $0.endpoints }
            .compactMap { $0.operation.operationId }
    }

    /// All servers referenced anywhere in the whole document.
    ///
    /// This property contains all servers defined at any level the document
    /// and therefore may or may not contain servers not found in the
    /// root servers array.
    ///
    /// The `servers` property on `OpenAPI.Document`, by contrast, contains
    /// servers that are applicable to all paths and operations that
    /// do not define their own `serves` array to override the root array.
    ///
    /// - Important: For the purposes of returning one of each `Server`,
    ///     two servers are considered identical if they have the same `url`
    ///     and `variables`. Differing `description` properties for
    ///     otherwise identical servers are considered to be two ways to
    ///     describe the same server. `vendorExtensions` are also
    ///     ignored when determining server uniqueness.
    ///
    ///     The first `Server` encountered will be used, so if the only
    ///     difference between a server at the root document level and
    ///     one in an `Operation`'s override of the servers array is the
    ///     description, the description of the `Server` returned by this
    ///     property will be that of the root document definition.
    ///
    public var allServers: [OpenAPI.Server] {
        // We hash `Variable` without its
        // `description` or `vendorExtensions`.
        func hash(variable: OpenAPI.Server.Variable, into hasher: inout Hasher) {
            hasher.combine(variable.enum)
            hasher.combine(variable.default)
        }

        // We hash `Server` without its `description` or
        // `vendorExtensions`.
        func hash(server: OpenAPI.Server, into hasher: inout Hasher) {
            hasher.combine(server.urlTemplate)
            for (key, value) in server.variables {
                hasher.combine(key)
                hash(variable: value, into: &hasher)
            }
        }

        func hash(for server: OpenAPI.Server) -> Int {
            var hasher = Hasher()
            hash(server: server, into: &hasher)
            return hasher.finalize()
        }

        var collectedServers = underlyingDocument.servers
        var seenHashes = Set(underlyingDocument.servers.map(hash(for:)))

        func insertUniquely(server: OpenAPI.Server) {
            let serverHash = hash(for: server)
            if !seenHashes.contains(serverHash) {
                seenHashes.insert(serverHash)
                collectedServers.append(server)
            }
        }

        for pathItem in paths.values {
            let pathItemServers = pathItem.servers ?? []
            pathItemServers.forEach(insertUniquely)

            let endpointServers = pathItem.endpoints.flatMap { $0.operation.servers ?? [] }
            endpointServers.forEach(insertUniquely)
        }

        return collectedServers
    }

    /// All Tags used anywhere in the document.
    ///
    /// The tags stored in the `OpenAPI.Document.tags`
    /// property need not contain all tags used anywhere in
    /// the document. This property is comprehensive.
    public var allTags: Set<String> {
        return Set(
            (underlyingDocument.tags ?? []).map { $0.name }
            + paths.values.flatMap { $0.endpoints }
                .flatMap { $0.operation.tags ?? [] }
        )
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
