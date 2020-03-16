//
//  Either.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 11/22/18.
//

import Foundation

public enum Either<A, B> {
	case a(A)
	case b(B)

	public var a: A? {
		guard case let .a(ret) = self else { return nil }
		return ret
	}

	public init(_ a: A) {
		self = .a(a)
	}

	public var b: B? {
		guard case let .b(ret) = self else { return nil }
		return ret
	}

	public init(_ b: B) {
		self = .b(b)
	}

    public var value: Any {
        switch self {
        case .a(let ret): return ret
        case .b(let ret): return ret
        }
    }
}

extension Either: Equatable where A: Equatable, B: Equatable {}

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
