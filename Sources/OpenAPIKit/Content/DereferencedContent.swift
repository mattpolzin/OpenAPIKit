//
//  DereferencedContent.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Content` type that guarantees
/// its `schema`, `encoding`, and `examples` are
/// inlined instead of referenced.
@dynamicMemberLookup
public struct DereferencedContent: Equatable {
    public let underlyingContent: OpenAPI.Content
    public let schema: DereferencedJSONSchema?
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
    internal init(
        _ content: OpenAPI.Content,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {
        self.schema = try content.schema?._dereferenced(in: components, following: references)
        let examples = try content.examples?.mapValues { try components.lookup($0) }
        self.examples = examples

        self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            ?? content.example

        self.encoding = try content.encoding.map { encodingMap in
            try encodingMap.mapValues { encoding in
                try encoding._dereferenced(in: components, following: references)
            }
        }

        self.underlyingContent = content
    }

    public typealias Map = OrderedDictionary<OpenAPI.ContentType, DereferencedContent>
}

extension OpenAPI.Content: LocallyDereferenceable {
    /// An internal-use method that facilitates reference cycle detection by tracking past references followed
    /// in the course of dereferencing.
    ///
    /// For all external-use, see `dereferenced(in:)` (provided by the `LocallyDereferenceable` protocol).
    /// All types that provide a `_dereferenced(in:following:)` implementation have a `dereferenced(in:)`
    /// implementation for free.
    public func _dereferenced(in components: OpenAPI.Components, following references: Set<AnyHashable>) throws -> DereferencedContent {
        return try DereferencedContent(self, resolvingIn: components, following: references)
    }

    public func externallyDereferenced<Context>(with loader: inout ExternalLoader<Context>) throws -> OpenAPI.Content where Context : ExternalLoaderContext {
        var content = self

       // TOOD: need to locally dereference the schema, examples, and content encoding here.
#warning("need to locally dereference the schema, examples, and content encoding here.")
        return content
    }
}
