//
//  DereferencedResponse.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Response` type that guarantees
/// its `headers` and `content` are inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedResponse: Equatable {
    /// The original `OpenAPI.Response` prior to being dereferenced.
    public let underlyingResponse: OpenAPI.Response
    /// The map of dereferenced headers for this response.
    public let headers: DereferencedHeader.Map?
    /// The map of dereferenced content for this response.
    public let content: DereferencedContent.Map

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Response, T>) -> T {
        return underlyingResponse[keyPath: path]
    }

    /// Create a `DereferencedResponse` if all references in the
    /// response can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ response: OpenAPI.Response,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {
        self.headers = try response.headers?.mapValues { header in
            try header._dereferenced(in: components, following: references)
        }

        self.content = try response.content.mapValues { content in
            try content._dereferenced(in: components, following: references)
        }

        self.underlyingResponse = response
    }

    public typealias Map = OrderedDictionary<OpenAPI.Response.StatusCode, DereferencedResponse>
}

extension OpenAPI.Response: LocallyDereferenceable {
    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    public func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> DereferencedResponse {
        return try DereferencedResponse(self, resolvingIn: components, following: references)
    }
}
