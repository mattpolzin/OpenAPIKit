//
//  Date+OpenAPI.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/24/19.
//

import Foundation

extension Date: DateOpenAPISchemaType {
	public static func dateOpenAPISchemaGuess(using encoder: JSONEncoder) -> JSONSchema? {

		switch encoder.dateEncodingStrategy {
		case .deferredToDate, .custom:
			// I don't know if we can say anything about this case without
			// encoding the Date and looking at it, which is what `primitiveGuess()`
			// does.
			return nil

		case .secondsSince1970,
			 .millisecondsSince1970:
			return .number(.init(format: .double,
								 required: true),
						   .init())

		case .iso8601:
			return .string(.init(format: .dateTime,
								 required: true),
						   .init())

		case .formatted(let formatter):
			let hasTime = formatter.timeStyle != .none
			let format: JSONTypeFormat.StringFormat = hasTime ? .dateTime : .date

			return .string(.init(format: format,
								 required: true),
						   .init())

        @unknown default:
            return nil
        }
	}
}

extension Date: OpenAPIEncodedSchemaType {
    public static func openAPISchema(using encoder: JSONEncoder) throws -> JSONSchema {
        guard let dateSchema: JSONSchema = try openAPINodeGuess(for: Date(), using: encoder) else {
            throw OpenAPITypeError.unknownNodeType(type(of: self))
        }

        return dateSchema
    }
}
