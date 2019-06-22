//
//  OpenAPITypes+Codable.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 1/14/19.
//

extension JSONNode.Context: Encodable {

	private enum CodingKeys: String, CodingKey {
		case type
		case format
		case allowedValues = "enum"
		case nullable
		case example
//		case constantValue = "const"
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(format.jsonType, forKey: .type)

		if format != Format.unspecified {
			try container.encode(format, forKey: .format)
		}

		if allowedValues != nil {
			try container.encode(allowedValues, forKey: .allowedValues)
		}

//		if constantValue != nil {
//			try container.encode(constantValue, forKey: .constantValue)
//		}

		try container.encode(nullable, forKey: .nullable)

		if example != nil {
			try container.encode(example, forKey: .example)
		}
	}
}

extension JSONNode.NumericContext: Encodable {
	private enum CodingKeys: String, CodingKey {
		case multipleOf
		case maximum
		case exclusiveMaximum
		case minimum
		case exclusiveMinimum
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if multipleOf != nil {
			try container.encode(multipleOf, forKey: .multipleOf)
		}

		if maximum != nil {
			try container.encode(maximum, forKey: .maximum)
		}

		if exclusiveMaximum != nil {
			try container.encode(exclusiveMaximum, forKey: .exclusiveMaximum)
		}

		if minimum != nil {
			try container.encode(minimum, forKey: .minimum)
		}

		if exclusiveMinimum != nil {
			try container.encode(exclusiveMinimum, forKey: .exclusiveMinimum)
		}
	}
}

extension JSONNode.StringContext: Encodable {
	private enum CodingKeys: String, CodingKey {
		case maxLength
		case minLength
		case pattern
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if maxLength != nil {
			try container.encode(maxLength, forKey: .maxLength)
		}

		try container.encode(minLength, forKey: .minLength)

		if pattern != nil {
			try container.encode(pattern, forKey: .pattern)
		}
	}
}

extension JSONNode.ArrayContext: Encodable {
	private enum CodingKeys: String, CodingKey {
		case items
		case maxItems
		case minItems
		case uniqueItems
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(items, forKey: .items)

		if maxItems != nil {
			try container.encode(maxItems, forKey: .maxItems)
		}

		try container.encode(minItems, forKey: .minItems)

		try container.encode(uniqueItems, forKey: .uniqueItems)
	}
}

extension JSONNode.ObjectContext : Encodable {
	private enum CodingKeys: String, CodingKey {
		case maxProperties
		case minProperties
		case properties
		case additionalProperties
		case required
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if maxProperties != nil {
			try container.encode(maxProperties, forKey: .maxProperties)
		}

		try container.encode(properties, forKey: .properties)

		if additionalProperties != nil {
			try container.encode(additionalProperties, forKey: .additionalProperties)
		}

		try container.encode(requiredProperties, forKey: .required)

		try container.encode(minProperties, forKey: .minProperties)
	}
}

extension JSONNode: Encodable {

	private enum SubschemaCodingKeys: String, CodingKey {
		case allOf
		case oneOf
		case anyOf
		case not
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
		case .boolean(let context):
			try context.encode(to: encoder)

		case .object(let contextA as Encodable, let contextB as Encodable),
			 .array(let contextA as Encodable, let contextB as Encodable),
			 .number(let contextA as Encodable, let contextB as Encodable),
			 .integer(let contextA as Encodable, let contextB as Encodable),
			 .string(let contextA as Encodable, let contextB as Encodable):
			try contextA.encode(to: encoder)
			try contextB.encode(to: encoder)

		case .all(of: let nodes):
			var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

			try container.encode(nodes, forKey: .allOf)

		case .one(of: let nodes):
			var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

			try container.encode(nodes, forKey: .oneOf)

		case .any(of: let nodes):
			var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

			try container.encode(nodes, forKey: .anyOf)

		case .not(let node):
			var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

			try container.encode(node, forKey: .not)

		case .reference(let reference):
			var container = encoder.singleValueContainer()

			try container.encode(reference)
		}
	}
}

extension JSONReference: Encodable {
	private enum CodingKeys: String, CodingKey {
		case ref = "$ref"
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		let referenceString: String = {
			switch self {
			case .file(let reference):
				return reference
			case .node(let reference):
				return "#/\(Root.refName)/\(reference.refName)/\(reference.selector)"
			}
		}()

		try container.encode(referenceString, forKey: .ref)
	}
}

extension RefDict: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		try container.encode(dict)
	}
}

extension OpenAPIResponse.Code: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		let string: String
		switch self {
		case .`default`:
			string = "default"

		case .status(code: let code):
			string = String(code)
		}

		try container.encode(string)
	}
}

extension OpenAPIRequestBody: Encodable {
	private enum CodingKeys: String, CodingKey {
		case description
		case content
		case required
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if description != nil {
			try container.encode(description, forKey: .description)
		}

		// Hack to work around Dictionary encoding
		// itself as an array in this case:
		let stringKeyedDict = Dictionary(
			content.map { ($0.key.rawValue, $0.value) },
			uniquingKeysWith: { $1 }
		)
		try container.encode(stringKeyedDict, forKey: .content)

		try container.encode(required, forKey: .required)
	}
}

extension OpenAPIPathItem.PathProperties.Operation: Encodable {
	private enum CodingKeys: String, CodingKey {
		case tags
		case summary
		case description
		case externalDocs
		case operationId
		case parameters
		case requestBody
		case responses
		case callbacks
		case deprecated
		case security
		case servers
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if tags != nil {
			try container.encode(tags, forKey: .tags)
		}

		if summary != nil {
			try container.encode(summary, forKey: .summary)
		}

		if description != nil {
			try container.encode(description, forKey: .description)
		}

		try container.encode(operationId, forKey: .operationId)

		try container.encode(parameters, forKey: .parameters)

		if requestBody != nil {
			try container.encode(requestBody, forKey: .requestBody)
		}

		// Hack to work around Dictionary encoding
		// itself as an array in this case:
		let stringKeyedDict = Dictionary(
			responses.map { ($0.key.rawValue, $0.value) },
			uniquingKeysWith: { $1 }
		)
		try container.encode(stringKeyedDict, forKey: .responses)

		try container.encode(deprecated, forKey: .deprecated)
	}
}

extension OpenAPIPathItem.PathProperties.Parameter: Encodable {
	private enum CodingKeys: String, CodingKey {
		case name
		case parameterLocation = "in"
		case description
		case required
		case deprecated

		// the following are alternatives
		case content
		case schema
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(name, forKey: .name)

		let required: Bool?
		let location: String
		switch parameterLocation {
		case .query(required: let req):
			required = req
			location = "query"
		case .header(required: let req):
			required = req
			location = "header"
		case .path:
			required = true
			location = "path"
		case .cookie(required: let req):
			required = req
			location = "cookie"
		}
		try container.encode(location, forKey: .parameterLocation)

		try container.encode(required, forKey: .required)

		switch schemaOrContent {
		case .a(let schema):
			try container.encode(schema, forKey: .schema)
		case .b(let contentMap):
			// Hack to work around Dictionary encoding
			// itself as an array in this case:
			let stringKeyedDict = Dictionary(
				contentMap.map { ($0.key.rawValue, $0.value) },
				uniquingKeysWith: { $1 }
			)
			try container.encode(stringKeyedDict, forKey: .content)
		}

		if description != nil {
			try container.encode(description, forKey: .description)
		}

		try container.encode(deprecated, forKey: .deprecated)
	}
}

extension OpenAPIPathItem.PathProperties: Encodable {
	private enum CodingKeys: String, CodingKey {
		case summary
		case description
		case servers
		case parameters

		case get
		case put
		case post
		case delete
		case options
		case head
		case patch
		case trace
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		if summary != nil {
			try container.encode(summary, forKey: .summary)
		}

		if description != nil {
			try container.encode(description, forKey: .description)
		}

		try container.encode(parameters, forKey: .parameters)

		if get != nil {
			try container.encode(get, forKey: .get)
		}

		if put != nil {
			try container.encode(put, forKey: .put)
		}

		if post != nil {
			try container.encode(post, forKey: .post)
		}

		if delete != nil {
			try container.encode(delete, forKey: .delete)
		}

		if options != nil {
			try container.encode(options, forKey: .options)
		}

		if head != nil {
			try container.encode(head, forKey: .head)
		}

		if patch != nil {
			try container.encode(patch, forKey: .patch)
		}

		if trace != nil {
			try container.encode(trace, forKey: .trace)
		}
	}
}

extension OpenAPIResponse: Encodable {
	private enum CodingKeys: String, CodingKey {
		case description
		case headers
		case content
		case links
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(description, forKey: .description)

		// Hack to work around Dictionary encoding
		// itself as an array in this case:
		let stringKeyedDict = Dictionary(
			content.map { ($0.key.rawValue, $0.value) },
			uniquingKeysWith: { $1 }
		)
		try container.encode(stringKeyedDict, forKey: .content)
	}
}

extension OpenAPIPathItem: Encodable {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case .reference(let reference):
			try container.encode(reference)

		case .operations(let operations):
			try container.encode(operations)
		}
	}
}

extension OpenAPISchema: Encodable {
	private enum CodingKeys: String, CodingKey {
		case openAPIVersion = "openapi"
		case info
		case servers
		case paths
		case components
		case security
		case tags
		case externalDocs
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(openAPIVersion, forKey: .openAPIVersion)

		try container.encode(info, forKey: .info)

		// Hack to work around Dictionary encoding
		// itself as an array in this case:
		let stringKeyedDict = Dictionary(
			paths.map { ($0.key.rawValue, $0.value) },
			uniquingKeysWith: { $1 }
		)
		try container.encode(stringKeyedDict, forKey: .paths)

		try container.encode(components, forKey: .components)
	}
}
