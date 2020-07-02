//
//  DereferencedHeader.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

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
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(_ header: OpenAPI.Header, resolvingIn components: OpenAPI.Components) throws {
        switch header.schemaOrContent {
        case .a(let schemaContext):
            self.schemaOrContent = .a(
                try DereferencedSchemaContext(
                    schemaContext,
                    resolvingIn: components
                )
            )
        case .b(let contentMap):
            self.schemaOrContent = .b(
                try contentMap.mapValues {
                    try DereferencedContent(
                        $0,
                        resolvingIn: components
                    )
                }
            )
        }

        self.underlyingHeader = header
    }

    public typealias Map = OrderedDictionary<String, DereferencedHeader>
}
