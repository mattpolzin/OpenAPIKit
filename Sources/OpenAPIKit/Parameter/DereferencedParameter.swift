//
//  DereferencedParameter.swift
//  
//
//  Created by Mathew Polzin on 6/18/20.
//

/// An `OpenAPI.Parameter` type that guarantees
/// its `schemaOrContent` is inlined instead of
/// referenced.
@dynamicMemberLookup
public struct DereferencedParameter: Equatable {
    public let parameter: OpenAPI.Parameter
    public let schemaOrContent: Either<DereferencedSchemaContext, OrderedDictionary<OpenAPI.ContentType, DereferencedContent>>

    public subscript<T>(dynamicMember path: KeyPath<OpenAPI.Parameter, T>) -> T {
        return parameter[keyPath: path]
    }

    /// Create a `DereferencedParameter` if all references in the
    /// parameter can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(parameter: OpenAPI.Parameter, resolvingIn components: OpenAPI.Components) throws {
        switch parameter.schemaOrContent {
        case .a(let schemaContext):
            self.schemaOrContent = .a(
                try DereferencedSchemaContext(
                    schemaContext: schemaContext,
                    resolvingIn: components
                )
            )
        case .b(let contentMap):
            self.schemaOrContent = .b(
                try contentMap.mapValues {
                    try DereferencedContent(
                        content: $0,
                        resolvingIn: components
                    )
                }
            )
        }

        self.parameter = parameter
    }
}
