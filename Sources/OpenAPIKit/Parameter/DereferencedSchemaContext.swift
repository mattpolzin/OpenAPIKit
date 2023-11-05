//
//  DereferencedSchemaContext.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// A `SchemaContext` type that guarantees its
/// `schema` and `examples` are inlined instead
/// of referenced.
@dynamicMemberLookup
public struct DereferencedSchemaContext: Equatable {
    /// The original `OpenAPI.Parameter.SchemaContext` prior to being dereferenced.
    public let underlyingSchemaContext: OpenAPI.Parameter.SchemaContext
    /// The dereferenced schema.
    public let schema: DereferencedJSONSchema
    /// The dereferenced examples (if defined).
    public let examples: OrderedDictionary<String, OpenAPI.Example>?
    /// The dereferenced example (if defined).
    ///
    /// This will expose the first example in the `examples`
    /// property if that is defined. OpenAPI also allows defining
    /// a single `example` which results in this property being
    /// non-`nil` while the `examples` property is `nil`.
    public let example: AnyCodable?

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Parameter.SchemaContext, T>) -> T {
        return underlyingSchemaContext[keyPath: path]
    }

    /// Create a `DereferencedSchemaContext` if all references in the
    /// schema context can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ schemaContext: OpenAPI.Parameter.SchemaContext,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>
    ) throws {
        self.schema = try schemaContext.schema._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
        let examples = try schemaContext.examples?
            .mapValues { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
        self.examples = examples

        self.example = examples.flatMap(OpenAPI.Content.firstExample(from:))
            ?? schemaContext.example

        self.underlyingSchemaContext = schemaContext
    }
}

extension OpenAPI.Parameter.SchemaContext: LocallyDereferenceable {
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
    ) throws -> DereferencedSchemaContext {
        return try DereferencedSchemaContext(self, resolvingIn: components, following: references)
    }
}
