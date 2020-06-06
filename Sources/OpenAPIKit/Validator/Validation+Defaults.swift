//
//  Validation+Defaults.swift
//  
//
//  Created by Mathew Polzin on 6/3/20.
//

import Foundation

extension Validation {
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
            check: take(\.parameters, check: parametersAreUnique),
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
            check: take(\.parameters, check: parametersAreUnique),
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
}

/// Used by both the Path Item parameter check and the
/// Operation parameter check in the default validations.
fileprivate func parametersAreUnique(_ parameters: OpenAPI.Parameter.Array) -> Bool {
    let inlinedParameters = parameters.compactMap { $0.parameterValue }

    let identities = inlinedParameters.map { PathItemParameterIdentity(name: $0.name, location: $0.location) }

    return Set(identities).count == inlinedParameters.count
}

fileprivate struct PathItemParameterIdentity: Hashable {
    let name: String
    let location: OpenAPI.Parameter.Context.Location
}
