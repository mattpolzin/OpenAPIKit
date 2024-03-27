//
//  DereferencedRequest.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Request` type that guarantees
/// its `content` is inlined instead of referenced.
@dynamicMemberLookup
public struct DereferencedRequest: Equatable {
    /// The original `OpenAPI.Request` prior to being dereferenced.
    public let underlyingRequest: OpenAPI.Request
    /// The dereferenced map of content for this request.
    public let content: DereferencedContent.Map

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Request, T>) -> T {
        return underlyingRequest[keyPath: path]
    }

    /// Create a `DereferencedRequest` if all references in the
    /// request can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ request: OpenAPI.Request,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws {
        self.content = try request.content.mapValues { content in
            try DereferencedContent(content, resolvingIn: components, following: references)
        }

        var request = request
        if let name {
            request.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        self.underlyingRequest = request
    }
}

extension OpenAPI.Request: LocallyDereferenceable {
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
    ) throws -> DereferencedRequest {
        return try DereferencedRequest(self, resolvingIn: components, following: references, dereferencedFromComponentNamed: name)
    }
}
