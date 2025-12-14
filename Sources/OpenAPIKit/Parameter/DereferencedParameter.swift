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
                    try $0._dereferenced(
                        in: components,
                        following: references,
                        dereferencedFromComponentNamed: nil
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
    public func externallyDereferenced<Loader: ExternalLoader>(with loader: Loader.Type) async throws -> (Self, OpenAPI.Components, [Loader.Message]) { 

        // if not for a Swift bug, this whole function would just be the
        // next line:
//        let (newSchemaOrContent, components) = try await schemaOrContent.externallyDereferenced(with: loader)

        let newContext: OpenAPI.Parameter.Context
        let newComponents: OpenAPI.Components
        let newMessages: [Loader.Message]

        switch context {
        case .query(required: let required, allowEmptyValue: let allowEmptyValue, schemaOrContent: let schemaOrContent):
            let newSchemaOrContent: Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>
            (newSchemaOrContent, newComponents, newMessages) = try await externallyDereference(schemaOrContent: schemaOrContent, with: Loader.self)

            newContext = .query(required: required, allowEmptyValue: allowEmptyValue, schemaOrContent: newSchemaOrContent)

        case .header(required: let required, schemaOrContent: let schemaOrContent):
            let newSchemaOrContent: Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>
            (newSchemaOrContent, newComponents, newMessages) = try await externallyDereference(schemaOrContent: schemaOrContent, with: Loader.self)

            newContext = .header(required: required, schemaOrContent: newSchemaOrContent)

        case .path(schemaOrContent: let schemaOrContent):
            let newSchemaOrContent: Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>
            (newSchemaOrContent, newComponents, newMessages) = try await externallyDereference(schemaOrContent: schemaOrContent, with: Loader.self)

            newContext = .path(schemaOrContent: newSchemaOrContent)

        case .cookie(required: let required, schemaOrContent: let schemaOrContent):
            let newSchemaOrContent: Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>
            (newSchemaOrContent, newComponents, newMessages) = try await externallyDereference(schemaOrContent: schemaOrContent, with: Loader.self)

            newContext = .cookie(required: required, schemaOrContent: newSchemaOrContent)

        case .querystring(required: let required, content: let content):
            let newContent: OpenAPI.Content.Map
            (newContent, newComponents, newMessages) = try await content.externallyDereferenced(with: Loader.self)

            newContext = .querystring(required: required, content: newContent)
        }

        var newParameter = self
        newParameter.context = newContext

        return (newParameter, newComponents, newMessages)
    }
}

fileprivate func externallyDereference<Loader: ExternalLoader>(
    schemaOrContent: Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>,
    with loader: Loader.Type
) async throws -> (Either<OpenAPI.Parameter.SchemaContext, OpenAPI.Content.Map>, OpenAPI.Components, [Loader.Message]) {
    switch schemaOrContent {
    case .a(let schemaContext):
        let (context, components, messages) = try await schemaContext.externallyDereferenced(with: loader)
        return (.a(context), components, messages)
    case .b(let contentMap):
        let (map, components, messages) = try await contentMap.externallyDereferenced(with: loader)
        return (.b(map), components, messages)
    }
}
