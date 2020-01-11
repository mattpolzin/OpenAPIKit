//
//  SwiftPrimitiveTypes+OpenAPI.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 01/13/19.
//

import AnyCodable
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

extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: OpenAPISchemaType {
	static public func rawOpenAPISchema() throws -> JSONSchema {
		return try Wrapped.RawValue.openAPISchema().optionalSchemaObject()
	}
}

extension Optional: RawOpenAPISchemaType where Wrapped: RawOpenAPISchemaType {
    static public func rawOpenAPISchema() throws -> JSONSchema {
        return try Wrapped.rawOpenAPISchema().optionalSchemaObject()
    }
}

extension Optional: AnyRawRepresentable, AnyJSONCaseIterable where Wrapped: CaseIterable, Wrapped: Codable {
	public static func allCases(using encoder: JSONEncoder) -> [AnyCodable] {
		return (try? allCases(from: Array(Wrapped.allCases), using: encoder)) ?? []
	}
}

extension Optional: AnyWrappedJSONCaseIterable where Wrapped: AnyJSONCaseIterable, Wrapped: Codable {
    public static func wrappedAllCases(using encoder: JSONEncoder) -> [AnyCodable] {
        return Wrapped.allCases(using: encoder)
    }
}

extension Optional: DateOpenAPISchemaType where Wrapped: DateOpenAPISchemaType {
	static public func dateOpenAPISchemaGuess(using encoder: JSONEncoder) -> JSONSchema? {
		return Wrapped.dateOpenAPISchemaGuess(using: encoder)?.optionalSchemaObject()
	}
}

extension RawRepresentable where RawValue: OpenAPISchemaType {
    static public func rawOpenAPISchema() throws -> JSONSchema {
        return try RawValue.openAPISchema()
    }
}

extension Array: OpenAPISchemaType where Element: OpenAPISchemaType {
    static public func openAPISchema() throws -> JSONSchema {
        return .array(.init(format: .generic,
                            required: true),
                      .init(items: try Element.openAPISchema()))
    }
}

extension Array: OpenAPIEncodedSchemaType where Element: OpenAPIEncodedSchemaType {
    public static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        return .array(.init(format: .generic,
                            required: true),
                      .init(items: try Element.openAPISchema(using: encoder)))
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

extension Dictionary: RawOpenAPISchemaType where Key: RawRepresentable, Key.RawValue == String, Value: OpenAPISchemaType {
    static public func rawOpenAPISchema() throws -> JSONSchema {
        return .object(.init(format: .generic,
                             required: true),
                       .init(properties: [:],
                             additionalProperties: .init(try Value.openAPISchema())))
    }
}

extension Dictionary: OpenAPIEncodedSchemaType where Key == String, Value: OpenAPIEncodedSchemaType {
    public static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        return .object(.init(format: .generic,
                             required: true),
                       .init(properties: [:],
                             additionalProperties: .init(try Value.openAPISchema(using: encoder))))
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
