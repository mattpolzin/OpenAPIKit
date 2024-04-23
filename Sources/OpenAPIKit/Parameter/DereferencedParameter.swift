//
//  DereferencedParameter.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

import OpenAPIKitCore

/// An `OpenAPI.Parameter` type that guarantees
/// its `schemaOrContent` is inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedParameter: Equatable {
    /// The original `OpenAPI.Parameter` prior to being dereferenced.
    public let underlyingParameter: OpenAPI.Parameter
    /// The dereferenced schema or content for the parameter.
    ///
    /// Only one of a "schema" or "content" can apply to any given
    /// parameter.
    public let schemaOrContent: Either<DereferencedSchemaContext, DereferencedContent.Map>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Parameter, T>) -> T {
        return underlyingParameter[keyPath: path]
    }

    /// Create a `DereferencedParameter` if all references in the
    /// parameter can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    internal init(
        _ parameter: OpenAPI.Parameter,
        resolvingIn components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws {
        switch parameter.schemaOrContent {
        case .a(let schemaContext):
            self.schemaOrContent = .a(
                try DereferencedSchemaContext(
                    schemaContext,
                    resolvingIn: components,
                    following: references
                )
            )
        case .b(let contentMap):
            self.schemaOrContent = .b(
                try contentMap.mapValues {
                    try DereferencedContent(
                        $0,
                        resolvingIn: components,
                        following: references
                    )
                }
            )
        }

        var parameter = parameter
        if let name {
            parameter.vendorExtensions[OpenAPI.Components.componentNameExtension] = .init(name)
        }

        self.underlyingParameter = parameter
    }
}

extension OpenAPI.Parameter: LocallyDereferenceable {
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
    ) throws -> DereferencedParameter {
        return try DereferencedParameter(self, resolvingIn: components, following: references, dereferencedFromComponentNamed: name)
    }
}

extension OpenAPI.Parameter: ExternallyDereferenceable {
    public func externallyDereferenced<Context: ExternalLoader>(with loader: Context.Type) async throws -> (Self, OpenAPI.Components) { 

        // if not for a Swift bug, this whole function would just be the
        // next line:
//        let (newSchemaOrContent, components) = try await schemaOrContent.externallyDereferenced(with: loader)

        let newSchemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
        let newComponents: OpenAPI.Components

        switch schemaOrContent {
        case .a(let schemaContext):
            let (context, components) = try await schemaContext.externallyDereferenced(with: loader)
            newSchemaOrContent = .a(context)
            newComponents = components
        case .b(let contentMap):
            let (map, components) = try await contentMap.externallyDereferenced(with: loader)
            newSchemaOrContent = .b(map)
            newComponents = components
        }

        var newParameter = self
        newParameter.schemaOrContent = newSchemaOrContent

        return (newParameter, newComponents)
    }
}
