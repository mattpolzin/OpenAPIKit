//
//  Either+Convenience.swift
//  
//
//  Created by Mathew Polzin on 3/29/20.
//

import Foundation

// MARK: - Convenience accessors
extension Either where A: OpenAPIKit._OpenAPIReference {
    /// Retrieve the JSON Reference if that is what this property contains.
    public var reference: A? { a }
}

extension Either where A == Bool {
    /// Retrieve the boolean value if that is what this property contains.
    public var booleanValue: A? { a }
}

extension Either where A == URL {
    /// Retrieve the URL if that is what this property contains.
    public var urlValue: A? { a }
}

extension Either where A == OpenAPI.Header.Schema {
    /// Retrieve the schema if that is what this property contains.
    public var schemaValue: A? { a }
}

extension Either where B == OpenAPI.PathItem.Parameter {
    /// Retrieve the parameter if that is what this property contains.
    public var parameterValue: B? { b }
}

extension Either where B == OpenAPI.Request {
    /// Retrieve the request if that is what this property contains.
    public var requestValue: B? { b }
}

extension Either where B == OpenAPI.Response {
    /// Retrieve the response if that is what this property contains.
    public var responseValue: B? { b }
}

extension Either where B == OpenAPI.Content.Map {
    /// Retrieve the content map if that is what this property contains.
    public var contentValue: B? { b }
}

extension Either where B == JSONSchema {
    /// Retrieve the schema if that is what this property contains.
    public var schemaValue: B? { b }
}

extension Either where B == OpenAPI.Example {
    /// Retrieve the example if that is what this property contains.
    public var exampleValue: B? { b }
}

extension Either where B == AnyCodable {
    /// Retrieve the codable value if that is what this property contains.
    public var codableValue: B? { b }
}

extension Either where B == OpenAPI.Header {
    /// Retrieve the header if that is what this property contains.
    public var headerValue: B? { b }
}

// MARK: - Convenience constructors
extension Either where A == Bool {
    /// Construct a boolean value.
    public static func boolean(_ boolean: Bool) -> Self { .a(boolean) }
}

extension Either where A: _OpenAPIReference {
    /// Construct a reference value.
    public static func reference(_ reference: A) -> Self { .a(reference) }
}

extension Either where A == OpenAPI.PathItem.Parameter.Schema {
    /// Construct a schema value.
    public static func schema(_ schema: OpenAPI.PathItem.Parameter.Schema) -> Self { .a(schema) }
}

extension Either where B == JSONSchema {
    /// Construct a schema value.
    public static func schema(_ schema: JSONSchema) -> Self { .b(schema) }
}

extension Either where B == OpenAPI.PathItem.Parameter {
    /// Construct a parameter value.
    public static func parameter(_ parameter: OpenAPI.PathItem.Parameter) -> Self { .b(parameter) }
}

extension Either where B == OpenAPI.Content.Map {
    /// Construct a content map.
    public static func content(_ map: OpenAPI.Content.Map) -> Self { .b(map) }
}

extension Either where B == OpenAPI.Example {
    /// Construct an example value.
    public static func example(_ example: OpenAPI.Example) -> Self { .b(example) }
}

extension Either where B == OpenAPI.Response {
    /// Construct a response value.
    public static func response(_ response: OpenAPI.Response) -> Self { .b(response) }
}
