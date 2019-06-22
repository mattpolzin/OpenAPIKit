//
//  PrimitiveTypes.swift
//  OpenAPI
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

RFC3339 date-time:
.string(.dateTime)

A hint to UIs to obscure input:
.string(.password)

Any object:
.object(.generic)

**/

extension Optional: OpenAPINodeType where Wrapped: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return try Wrapped.openAPINode().optionalNode()
	}
}

extension Optional: RawOpenAPINodeType where Wrapped: RawRepresentable, Wrapped.RawValue: OpenAPINodeType {
	static public func rawOpenAPINode() throws -> JSONNode {
		return try Wrapped.RawValue.openAPINode().optionalNode()
	}
}

extension Optional: WrappedRawOpenAPIType where Wrapped: RawOpenAPINodeType {
	static public func wrappedOpenAPINode() throws -> JSONNode {
		return try Wrapped.rawOpenAPINode().optionalNode()
	}
}

extension Optional: DoubleWrappedRawOpenAPIType where Wrapped: WrappedRawOpenAPIType {
	static public func wrappedOpenAPINode() throws -> JSONNode {
		return try Wrapped.wrappedOpenAPINode().optionalNode()
	}
}

extension Optional: AnyJSONCaseIterable where Wrapped: CaseIterable, Wrapped: Codable {
	public static func allCases(using encoder: JSONEncoder) -> [AnyCodable] {
		return (try? allCases(from: Array(Wrapped.allCases), using: encoder)) ?? []
	}
}

extension Optional: DateOpenAPINodeType where Wrapped: DateOpenAPINodeType {
	static public func dateOpenAPINodeGuess(using encoder: JSONEncoder) -> JSONNode? {
		return Wrapped.dateOpenAPINodeGuess(using: encoder)?.optionalNode()
	}
}

extension String: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .string(.init(format: .generic,
							 required: true),
					   .init())
	}
}

extension Bool: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .boolean(.init(format: .generic,
							  required: true))
	}
}

extension Array: OpenAPINodeType where Element: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .array(.init(format: .generic,
							required: true),
					  .init(items: try Element.openAPINode()))
	}
}

extension Double: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .number(.init(format: .double,
							 required: true),
					   .init())
	}
}

extension Float: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .number(.init(format: .float,
							 required: true),
					   .init())
	}
}

extension Int: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .integer(.init(format: .generic,
							  required: true),
						.init())
	}
}

extension Int32: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .integer(.init(format: .int32,
							  required: true),
						.init())
	}
}

extension Int64: OpenAPINodeType {
	static public func openAPINode() throws -> JSONNode {
		return .integer(.init(format: .int64,
							  required: true),
						.init())
	}
}
