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
    public let itemSchema: DereferencedJSONSchema?
    public let examples: OrderedDictionary<String, OpenAPI.Example>?
    public let example: AnyCodable?
    public let encoding: Either<OrderedDictionary<String, DereferencedContentEncoding>, DereferencedPositionalEncoding>?

    public var encodingMap: OrderedDictionary<String, DereferencedContentEncoding>? { encoding?.a }
    public var prefixEncoding: [DereferencedContentEncoding]? { encoding?.b?.prefixEncoding }
    public var itemEncoding: DereferencedContentEncoding? { encoding?.b?.itemEncoding }

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
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws {
        self.schema = try content.schema?._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        self.itemSchema = try content.itemSchema?._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
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

        switch content.encoding {
        case .a(let encodingMap):
            self.encoding = .a(try encodingMap.mapValues { encoding in
                try encoding._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
            })
        case .b(let positionalEncoding):
            let prefixEncoding = try  positionalEncoding.prefixEncoding.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            let itemEncoding = try positionalEncoding.itemEncoding.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            self.encoding = .b(.init(prefixEncoding: prefixEncoding, itemEncoding: itemEncoding))
        case nil:
            self.encoding = nil
        }

        var content = content
        if let name {
            content.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
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
        return try DereferencedContent(self, resolvingIn: components, following: references, dereferencedFromComponentNamed: name)
    }
}

extension OpenAPI.Content: ExternallyDereferenceable {
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 
      let oldSchema = schema
      let oldItemSchema = itemSchema

      async let (newSchema, c1, m1) = oldSchema.externallyDereferenced(with: loader)
      async let (newItemSchema, c2, m2) = oldItemSchema.externallyDereferenced(with: loader)

      var newContent = self
      var newComponents = try await c1
      var newMessages = try await m1

      newContent.schema = try await newSchema

      try await newComponents.merge(c2)
      newMessages += try await m2
      newContent.itemSchema = try await newItemSchema

        if let oldExamples = examples {
            let (newExamples, c3, m3) = try await oldExamples.externallyDereferenced(with: loader)
            newContent.examples = newExamples
            try newComponents.merge(c3)
            newMessages += m3
        }

        if let oldEncoding = encoding {
            switch oldEncoding {
            case .a(let oldEncoding):
                let (newEncoding, c4, m4) = try await oldEncoding.externallyDereferenced(with: loader)
                newContent.encoding = .a(newEncoding)
                try newComponents.merge(c4)
                newMessages += m4

            case .b(let oldPositionalEncoding):
                async let (newItemEncoding, c4, m4) = try oldPositionalEncoding.itemEncoding.externallyDereferenced(with: loader)
                async let (newPrefixEncoding, c5, m5) = try oldPositionalEncoding.prefixEncoding.externallyDereferenced(with: loader)
                newContent.encoding = try await .b(.init(prefixEncoding: newPrefixEncoding, itemEncoding: newItemEncoding))
                try await newComponents.merge(c4)
                try await newComponents.merge(c5)
                newMessages += try await m4 + m5
            }
        }

        return (newContent, newComponents, newMessages)
    }
}
