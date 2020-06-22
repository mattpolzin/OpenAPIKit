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
    public let underlyingRequest: OpenAPI.Request
    public let content: DereferencedContent.Map

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Request, T>) -> T {
        return underlyingRequest[keyPath: path]
    }

    /// Create a `DereferencedRequest` if all references in the
    /// request can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(_ request: OpenAPI.Request, resolvingIn components: OpenAPI.Components) throws {
        self.content = try request.content.mapValues { content in
            try DereferencedContent(content, resolvingIn: components)
        }

        self.underlyingRequest = request
    }
}
