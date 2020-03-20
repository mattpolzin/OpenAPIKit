//
//  SwiftPrimitiveTypes+OpenAPI.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 01/13/19.
//

import Foundation

extension Optional: OpenAPISchemaType where Wrapped: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
		return Wrapped.openAPISchema.optionalSchemaObject()
	}
}

extension Array: OpenAPISchemaType where Element: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
        return .array(.init(format: .generic,
                            required: true),
                      .init(items: Element.openAPISchema))
    }
}

extension Dictionary: OpenAPISchemaType where Key == String, Value: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
        return .object(.init(format: .generic,
                             required: true),
                       .init(properties: [:],
                             additionalProperties: .init(Value.openAPISchema)))
    }
}

extension String: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .string(.init(format: .generic,
							 required: true),
					   .init())
	}
}

extension Bool: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .boolean(.init(format: .generic,
							  required: true))
	}
}

extension Double: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .number(.init(format: .double,
							 required: true),
					   .init())
	}
}

extension Float: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .number(.init(format: .float,
							 required: true),
					   .init())
	}
}

extension Int: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .integer(.init(format: .generic,
							  required: true),
						.init())
	}
}

extension Int32: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .integer(.init(format: .int32,
							  required: true),
						.init())
	}
}

extension Int64: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
		return .integer(.init(format: .int64,
							  required: true),
						.init())
	}
}
