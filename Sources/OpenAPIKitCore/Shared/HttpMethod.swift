//
//  HttpMethod.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension Shared {
    /// Represents the HTTP methods supported by the
    /// OpenAPI Specification.
    ///
    /// See [OpenAPI Path Item Object](https://spec.openapis.org/oas/v3.0.4.html#path-item-object) because the supported
    /// HTTP methods are enumerated as properties on that
    /// object.
    public enum HttpMethod: String, CaseIterable {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case trace = "TRACE"
    }
}
