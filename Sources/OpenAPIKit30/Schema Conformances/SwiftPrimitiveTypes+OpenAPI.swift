//
//  SwiftPrimitiveTypes+OpenAPI.swift
//  OpenAPIKit
//
//  Created by Mathew Polzin on 01/13/19.
//

import Foundation

extension Optional: OpenAPISchemaType where Wrapped: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
		Wrapped.openAPISchema.optionalSchemaObject()
	}
}

extension Array: OpenAPISchemaType where Element: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
        .array(
            items: Element.openAPISchema
        )
    }
}

extension Dictionary: OpenAPISchemaType where Key == String, Value: OpenAPISchemaType {
    static public var openAPISchema: JSONSchema {
        .object(
            additionalProperties: .init(Value.openAPISchema)
        )
    }
}

extension String: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .string
	}
}

extension Bool: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .boolean
	}
}

extension Double: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .number(format: .double)
	}
}

extension Float: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .number(format: .float)
	}
}

extension Int: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .integer
	}
}

extension Int32: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .integer(format: .int32)
	}
}

extension Int64: OpenAPISchemaType {
	static public var openAPISchema: JSONSchema {
        .integer(format: .int64)
	}
}

extension URL: OpenAPISchemaType {
    public static var openAPISchema: JSONSchema {
        .string(format: .extended(.uri))
    }
}

extension UUID: OpenAPISchemaType {
    public static var openAPISchema: JSONSchema {
        .string(format: .extended(.uuid))
    }
}
