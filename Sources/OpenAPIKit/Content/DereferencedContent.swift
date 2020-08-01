//
//  DereferencedContent.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

/// An `OpenAPI.Content` type that guarantees
/// its `schema`, `encoding`, and `examples` are
/// inlined instead of referenced.
@dynamicMemberLookup
public struct DereferencedContent: Equatable {
    public let underlyingContent: OpenAPI.Content
    public let schema: DereferencedJSONSchema
    public let examples: OrderedDictionary<String, OpenAPI.Example>?
    public let example: AnyCodable?
    public let encoding: OrderedDictionary<String, DereferencedContentEncoding>?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Content, T>) -> T {
        return underlyingContent[keyPath: path]
    }

    /// Create a `DereferencedContent` if all references in the
    /// content can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(_ content: OpenAPI.Content, resolvingIn components: OpenAPI.Components) throws {
        self.schema = try DereferencedJSONSchema(
            try components.forceDereference(content.schema),
            resolvingIn: components
        )
        let examples = try content.examples?.mapValues { try components.forceDereference($0) }
        self.examples = examples

        self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            ?? content.example

        self.encoding = try content.encoding.map { encodingMap in
            try encodingMap.mapValues { encoding in
                try DereferencedContentEncoding(
                    encoding,
                    resolvingIn: components
                )
            }
        }

        self.underlyingContent = content
    }

    public typealias Map = OrderedDictionary<OpenAPI.ContentType, DereferencedContent>
}
