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

    /// Validate the OpenAPI Document's `Tags` all have unique names.
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
}
