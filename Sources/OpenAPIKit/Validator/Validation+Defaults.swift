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
            check: { context in
                context.subject.count > 0
                    ? []
                    : [ ValidationError(reason: "Document does not contain any paths.", at: context.codingPath) ]
            }
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
            check: { context in
                context.subject.endpoints.count > 0
                    ? []
                    : [ ValidationError(reason: "Path does not contain operations.", at: context.codingPath) ]
            }
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
            check: { context in
                context.subject.count > 0
                    ? []
                    : [ ValidationError(reason: "All operations must contain at least one response.", at: context.codingPath) ]
            }
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
            check: { context in
                guard let tags = context.subject.tags else { return [] }
                let tagNames = tags.map { $0.name }
                return Set(tagNames).count == tags.count
                    ? []
                    : [ ValidationError(reason: "The names of Tags in the Document must be unique.", at: context.codingPath) ]
            }
        )
    }
}
