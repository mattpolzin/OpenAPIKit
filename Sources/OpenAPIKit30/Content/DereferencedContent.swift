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
        self.schema = try content.schema?._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        let examples = try content.examples?
            .mapValues {
                try $0._dereferenced(
                    in: components, 
                    following: references, 
                    dereferencedFromComponentNamed: nil
                )
            }
        self.examples = examples

        self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            ?? content.example

        self.encoding = try content.encoding.map { encodingMap in
            try encodingMap.mapValues { encoding in
                try encoding._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
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
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> DereferencedContent {
        return try DereferencedContent(self, resolvingIn: components, following: references)
    }
}

extension OpenAPI.Content: ExternallyDereferenceable {
    public func externallyDereferenced<Context: ExternalLoaderContext>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) { 
      let oldSchema = schema

      async let (newSchema, c1) = oldSchema.externallyDereferenced(with: loader)

      var newContent = self
      var newComponents = try await c1

      newContent.schema = try await newSchema

        if let oldExamples = examples {
            let (newExamples, c2) = try await oldExamples.externallyDereferenced(with: loader)
            newContent.examples = newExamples
            try newComponents.merge(c2)
        }

        if let oldEncoding = encoding {
            let (newEncoding, c3) = try await oldEncoding.externallyDereferenced(with: loader)
            newContent.encoding = newEncoding
            try newComponents.merge(c3)
        }

        return (newContent, newComponents)
    }
}
