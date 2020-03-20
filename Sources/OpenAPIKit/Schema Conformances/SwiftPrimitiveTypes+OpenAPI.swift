//
//  SwiftPrimitiveTypes+OpenAPI.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 01/13/19.
//

import Foundation

/**

Notable omissions in this library's default offerings:

Base 64 encoded characters:
.string(.byte)

Any sequence of octets:
.string(.binary)

RFC3339 full-date:
.string(.date)

RFC3339 date-time: (note this is somewhat covered in `Date+OpenAPI.swift`)
.string(.dateTime)

A hint to UIs to obscure input:
.string(.password)

Any object:
.object(.generic)

**/

extension Optional: OpenAPISchemaType where Wrapped: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return try Wrapped.openAPISchema().optionalSchemaObject()
	}
}

extension Array: OpenAPISchemaType where Element: OpenAPISchemaType {
    static public func openAPISchema() throws -> JSONSchema {
        return .array(.init(format: .generic,
                            required: true),
                      .init(items: try Element.openAPISchema()))
    }
}

extension Dictionary: OpenAPISchemaType where Key == String, Value: OpenAPISchemaType {
    static public func openAPISchema() throws -> JSONSchema {
        return .object(.init(format: .generic,
                             required: true),
                       .init(properties: [:],
                             additionalProperties: .init(try Value.openAPISchema())))
    }
}

extension String: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .string(.init(format: .generic,
							 required: true),
					   .init())
	}
}

extension Bool: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .boolean(.init(format: .generic,
							  required: true))
	}
}

extension Double: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .number(.init(format: .double,
							 required: true),
					   .init())
	}
}

extension Float: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .number(.init(format: .float,
							 required: true),
					   .init())
	}
}

extension Int: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .integer(.init(format: .generic,
							  required: true),
						.init())
	}
}

extension Int32: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .integer(.init(format: .int32,
							  required: true),
						.init())
	}
}

extension Int64: OpenAPISchemaType {
	static public func openAPISchema() throws -> JSONSchema {
		return .integer(.init(format: .int64,
							  required: true),
						.init())
	}
}
