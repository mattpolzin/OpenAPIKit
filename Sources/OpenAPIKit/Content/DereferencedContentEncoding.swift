//
//  DereferencedContentEncoding.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

/// An `OpenAPI.Content.Encoding` type that
/// guarantees its `headers` are inlined instead
/// of referenced
@dynamicMemberLookup
public struct DereferencedContentEncoding: Equatable {
    public let underlyingContentEncoding: OpenAPI.Content.Encoding
    public let headers: DereferencedHeader.Map?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Content.Encoding, T>) -> T {
        return underlyingContentEncoding[keyPath: path]
    }

    /// Create a `DereferencedContentEncoding` if all references in the
    /// content can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(_ contentEncoding: OpenAPI.Content.Encoding, resolvingIn components: OpenAPI.Components) throws {
        self.headers = try contentEncoding.headers.map { headersMap in
            try headersMap.mapValues { header in
                try DereferencedHeader(
                    try components.forceDereference(header),
                    resolvingIn: components
                )
            }
        }

        self.underlyingContentEncoding = contentEncoding
    }
}
