//
//  DereferencedRequest.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

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
    public init(_ request: OpenAPI.Request, resolvingIn components: OpenAPI.Components) throws {
        self.content = try request.content.mapValues { content in
            try DereferencedContent(content, resolvingIn: components)
        }

        self.underlyingRequest = request
    }
}
