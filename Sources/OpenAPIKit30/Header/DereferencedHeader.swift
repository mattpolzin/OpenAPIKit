//
//  DereferencedHeader.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Header` type that guarantees
/// its `schemaOrContent` is inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedHeader: Equatable {
    /// The original `OpenAPI.Header` prior to being dereferenced.
    public let underlyingHeader: OpenAPI.Header
    /// The dereferenced schema or content for the header, only one
    /// of which can apply to a given Header.
    public let schemaOrContent: Either<DereferencedSchemaContext, DereferencedContent.Map>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Header, T>) -> T {
        return underlyingHeader[keyPath: path]
    }

    /// Create a `DereferencedHeader` if all references in the
    /// header can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ header: OpenAPI.Header,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws {
        switch header.schemaOrContent {
        case .a(let schemaContext):
            self.schemaOrContent = .a(
                try DereferencedSchemaContext(
                    schemaContext,
                    resolvingIn: components,
                    following: references
                )
            )
        case .b(let contentMap):
            self.schemaOrContent = .b(
                try contentMap.mapValues {
                    try DereferencedContent(
                        $0,
                        resolvingIn: components,
                        following: references
                    )
                }
            )
        }

        var header = header
        if let name = name {
            header.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        self.underlyingHeader = header
    }

    public typealias Map = OrderedDictionary<String, DereferencedHeader>
}

extension OpenAPI.Header: LocallyDereferenceable {
    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> DereferencedHeader {
        return try DereferencedHeader(self, resolvingIn: components, following: references, dereferencedFromComponentNamed: name)
    }
}
