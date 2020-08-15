//
//  Validation+Defaults.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

extension Validation {
    // MARK: - Optionally added with `Validator.validating()`

    /// Validate the OpenAPI Document has at least one path in its
    /// `PathItem.Map`.
    ///
    /// The OpenAPI Specifcation does not require that the document
    /// contain any paths for [security reasons](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#security-filtering)
    /// but documentation that is public in nature might only ever have
    /// an empty `PathItem.Map` in error.
    ///
    /// - Important: This is not an included validation by default.
    public static var documentContainsPaths: Validation<OpenAPI.PathItem.Map> {
        .init(
            description: "Document contains at least one path",
            check: \.count > 0
        )
    }

    /// Validate the OpenAPI Document's `PathItems` all have at least
    /// one operation.
    ///
    /// The OpenAPI Specifcation does not require that path items
    /// contain any operations for [security reasons](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#security-filtering)
    /// but documentation that is public in nature might only ever have
    /// a `PathItem` with no operations in error.
    ///
    /// - Important: This is not an included validation by default.
    public static var pathsContainOperations: Validation<OpenAPI.PathItem> {
        .init(
            description: "Paths contain at least one operation",
            check: \.endpoints.count > 0
        )
    }

    /// Validate the OpenAPI Document's `Operations` all have at least
    /// one response.
    ///
    /// The OpenAPI Specifcation requires that Responses Objects
    /// contain [at least one response](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#responses-object).
    /// The specification recommends that if there is only one response then
    /// it be a successful response.
    ///
    /// - Important: This is included in validation by default.
    public static var operationsContainResponses: Validation<OpenAPI.Response.Map> {
        .init(
            description: "Operations contain at least one response",
            check: \.count > 0
        )
    }

    // MARK: - Included with `Validator()` by default

    // You can start with no validations (not even the defaults below)
    // by calling `Validator.blank`.

    /// Validate that the OpenAPI Document's `Tags` all have unique names.
    ///
    /// The OpenAPI Specifcation requires that tag names on the Document
    /// [are unique](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#openapi-object).
    ///
    /// - Important: This is included in validation by default.
    public static var documentTagNamesAreUnique: Validation<OpenAPI.Document> {
        .init(
            description: "The names of Tags in the Document are unique",
            check: take(\.tags) { maybeTags in
                guard let tags = maybeTags else { return true }

                return Set(tags.map { $0.name }).count == tags.count
            }
        )
    }

    /// Validate that all OpenAPI Path Items have no duplicate parameters defined
    /// within them.
    ///
    /// A Path Item Parameter's identity is defined as the pairing of its `name` and
    /// `location`.
    ///
    /// The OpenAPI Specification requires that these parameters [are unique](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#path-item-object).
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var pathItemParametersAreUnique: Validation<OpenAPI.PathItem> {
        .init(
            description: "Path Item parameters are unqiue (identity is defined by the 'name' and 'location')",
            check: { parametersAreUnique($0.subject.parameters, components: $0.document.components) },
            when: \.parameters.count > 0
        )
    }

    /// Validate that all OpenAPI Operations have no duplicate parameters defined
    /// within them.
    ///
    /// An Operation's Parameter's identity is defined as the pairing of its `name` and
    /// `location`.
    ///
    /// The OpenAPI Specification requires that these parameters [are unique](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#operation-object).
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var operationParametersAreUnique: Validation<OpenAPI.Operation> {
        .init(
            description: "Operation parameters are unqiue (identity is defined by the 'name' and 'location')",
            check: { parametersAreUnique($0.subject.parameters, components: $0.document.components) },
            when: \.parameters.count > 0
        )
    }

    /// Validate that all OpenAPI Operation Ids are unique across the whole Document.
    ///
    /// The OpenAPI Specification requires that Operation Ids [are unique](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#operation-object).
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var operationIdsAreUnique: Validation<OpenAPI.Document> {
        .init(
            description: "All Operation Ids in Document are unique",
            check: take(\.allOperationIds) { operationIds in
                return Set(operationIds).count == operationIds.count
            }
        )
    }

    /// Validate that all JSONSchema references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var schemaReferencesAreValid: Validation<JSONReference<JSONSchema>> {
        .init(
            description: "JSONSchema reference can be found in components/schemas",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                    // don't make assertions about external references
                    // TODO: could make a stronger assertion including
                    // internal references outside of components given
                    // some way to resolve those references.
                    return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }

    /// Validate that all Response references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var responseReferencesAreValid: Validation<JSONReference<OpenAPI.Response>> {
        .init(
            description: "Response reference can be found in components/responses",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                        // don't make assertions about external references
                        // TODO: could make a stronger assertion including
                        // internal references outside of components given
                        // some way to resolve those references.
                        return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }

    /// Validate that all Parameter references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var parameterReferencesAreValid: Validation<JSONReference<OpenAPI.Parameter>> {
        .init(
            description: "Parameter reference can be found in components/parameters",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                        // don't make assertions about external references
                        // TODO: could make a stronger assertion including
                        // internal references outside of components given
                        // some way to resolve those references.
                        return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }

    /// Validate that all Example references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var exampleReferencesAreValid: Validation<JSONReference<OpenAPI.Example>> {
        .init(
            description: "Example reference can be found in components/examples",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                        // don't make assertions about external references
                        // TODO: could make a stronger assertion including
                        // internal references outside of components given
                        // some way to resolve those references.
                        return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }

    /// Validate that all Request references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var requestReferencesAreValid: Validation<JSONReference<OpenAPI.Request>> {
        .init(
            description: "Request reference can be found in components/requestBodies",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                        // don't make assertions about external references
                        // TODO: could make a stronger assertion including
                        // internal references outside of components given
                        // some way to resolve those references.
                        return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }

    /// Validate that all Header references are found in the document's
    /// components dictionary.
    ///
    /// - Important: This is included in validation by default.
    ///
    public static var headerReferencesAreValid: Validation<JSONReference<OpenAPI.Header>> {
        .init(
            description: "Header reference can be found in components/headers",
            check: { context in
                guard case let .internal(internalReference) = context.subject,
                    case .component = internalReference else {
                        // don't make assertions about external references
                        // TODO: could make a stronger assertion including
                        // internal references outside of components given
                        // some way to resolve those references.
                        return true
                }
                return context.document.components.contains(internalReference)
            }
        )
    }
}

/// Used by both the Path Item parameter check and the
/// Operation parameter check in the default validations.
fileprivate func parametersAreUnique(_ parameters: OpenAPI.Parameter.Array, components: OpenAPI.Components) -> Bool {
    let foundParameters = parameters.compactMap { try? components.lookup($0) }

    let identities = foundParameters.map { OpenAPI.Parameter.ParameterIdentity(name: $0.name, location: $0.location) }

    return Set(identities).count == foundParameters.count
}
