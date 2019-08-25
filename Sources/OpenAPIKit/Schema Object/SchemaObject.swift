//
//  SchemaObject.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import AnyCodable
import Poly

public enum JSONSchema: Equatable, JSONSchemaContext {
    case boolean(Context<JSONTypeFormat.BooleanFormat>)
    indirect case object(Context<JSONTypeFormat.ObjectFormat>, ObjectContext)
    indirect case array(Context<JSONTypeFormat.ArrayFormat>, ArrayContext)
    case number(Context<JSONTypeFormat.NumberFormat>, NumericContext)
    case integer(Context<JSONTypeFormat.IntegerFormat>, IntegerContext)
    case string(Context<JSONTypeFormat.StringFormat>, StringContext)
    indirect case all(of: [JSONSchema])
    indirect case one(of: [JSONSchema])
    indirect case any(of: [JSONSchema])
    indirect case not(JSONSchema)
    case reference(JSONReference<OpenAPI.Components, JSONSchema>)

    public var jsonTypeFormat: JSONTypeFormat? {
        switch self {
        case .boolean(let context):
            return .boolean(context.format)
        case .object(let context, _):
            return .object(context.format)
        case .array(let context, _):
            return .array(context.format)
        case .number(let context, _):
            return .number(context.format)
        case .integer(let context, _):
            return .integer(context.format)
        case .string(let context, _):
            return .string(context.format)
        case .all, .one, .any, .not, .reference:
            return nil
        }
    }

    public var required: Bool {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.required
        case .all, .one, .any, .not, .reference:
            return true
        }
    }

    public var nullable: Bool {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.nullable
        case .all, .one, .any, .not, .reference:
            return false
        }
    }

    public var title: String? {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.title
        case .all, .one, .any, .not, .reference:
            return nil
        }
    }

    public var description: String? {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.description
        case .all, .one, .any, .not, .reference:
            return nil
        }
    }

    /// Allowed values, if specified. If unspecified, returns `nil`.
    public var allowedValues: [AnyCodable]? {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.allowedValues
        case .all, .one, .any, .not, .reference:
            return nil
        }
    }

    /// An example, encoded as a `String`, if specified. If unspecified, returns `nil`.
    public var example: String? {
        switch self {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _):
            return context.example
        case .all, .one, .any, .not, .reference:
            return nil
        }
    }
}

// MARK: - Transformations
extension JSONSchema {
    /// Return the optional version of this `JSONSchema`
    public func optionalSchemaObject() -> JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context.optionalContext())
        case .object(let contextA, let contextB):
            return .object(contextA.optionalContext(), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.optionalContext(), contextB)
        case .number(let context, let contextB):
            return .number(context.optionalContext(), contextB)
        case .integer(let context, let contextB):
            return .integer(context.optionalContext(), contextB)
        case .string(let context, let contextB):
            return .string(context.optionalContext(), contextB)
        case .all, .one, .any, .not, .reference:
            return self
        }
    }

    /// Return the required version of this `JSONSchema`
    public func requiredSchemaObject() -> JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context.requiredContext())
        case .object(let contextA, let contextB):
            return .object(contextA.requiredContext(), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.requiredContext(), contextB)
        case .number(let context, let contextB):
            return .number(context.requiredContext(), contextB)
        case .integer(let context, let contextB):
            return .integer(context.requiredContext(), contextB)
        case .string(let context, let contextB):
            return .string(context.requiredContext(), contextB)
        case .all, .one, .any, .not, .reference:
            return self
        }
    }

    /// Return the nullable version of this `JSONSchema`
    public func nullableSchemaObject() -> JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context.nullableContext())
        case .object(let contextA, let contextB):
            return .object(contextA.nullableContext(), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.nullableContext(), contextB)
        case .number(let context, let contextB):
            return .number(context.nullableContext(), contextB)
        case .integer(let context, let contextB):
            return .integer(context.nullableContext(), contextB)
        case .string(let context, let contextB):
            return .string(context.nullableContext(), contextB)
        case .all, .one, .any, .not, .reference:
            return self
        }
    }

    /// Return a version of this `JSONSchema` that only allows the given
    /// values.
    public func with(allowedValues: [AnyCodable]) -> JSONSchema {

        switch self {
        case .boolean(let context):
            return .boolean(context.with(allowedValues: allowedValues))
        case .object(let contextA, let contextB):
            return .object(contextA.with(allowedValues: allowedValues), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.with(allowedValues: allowedValues), contextB)
        case .number(let context, let contextB):
            return .number(context.with(allowedValues: allowedValues), contextB)
        case .integer(let context, let contextB):
            return .integer(context.with(allowedValues: allowedValues), contextB)
        case .string(let context, let contextB):
            return .string(context.with(allowedValues: allowedValues), contextB)
        case .all, .one, .any, .not, .reference:
            return self
        }
    }

    public func with<T: Encodable>(example codableExample: T,
                                   using encoder: JSONEncoder) throws -> JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context.with(example: codableExample, using: encoder))
        case .object(let contextA, let contextB):
            return .object(contextA.with(example: codableExample, using: encoder), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.with(example: codableExample, using: encoder), contextB)
        case .number(let context, let contextB):
            return .number(context.with(example: codableExample, using: encoder), contextB)
        case .integer(let context, let contextB):
            return .integer(context.with(example: codableExample, using: encoder), contextB)
        case .string(let context, let contextB):
            return .string(context.with(example: codableExample, using: encoder), contextB)
        case .all, .one, .any, .not, .reference:
            throw OpenAPI.CodableError.exampleNotSupported("examples not supported for `.allOf`, `.oneOf`, `.anyOf`, `.not` or for JSON references ($ref).")
        }
    }
}

// MARK: - Fragment Handling
private protocol _Dictionary {}
extension Dictionary: _Dictionary {}

private protocol _Array {}
extension Array: _Array {}

extension JSONSchema {
    /// Attempts to create a String from a JSON fragment (e.g. Bool, Double, String, etc.)
    internal static func fragmentString(from value: Any) -> String? {
        switch type(of: value).self {
        case is _Dictionary.Type,
             is _Array.Type:
            return nil
        case is String.Type:
            return "\"\(value)\""
        default:
            return "\(value)"
        }
    }
}

// MARK: - Convenience

extension JSONSchema {
    public static func boolean(
        format: JSONTypeFormat.BooleanFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        title: String? = nil,
        description: String? = nil,
        allowedValues: [AnyCodable]? = nil,
        example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
    ) -> JSONSchema {
        let context = JSONSchema.Context<JSONTypeFormat.BooleanFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )
        return .boolean(context)
    }

    public static var boolean: JSONSchema {
        return .boolean()
    }

    public static func string(
        format: JSONTypeFormat.StringFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        title: String? = nil,
        description: String? = nil,
        minLength: Int = 0,
        maxLength: Int? = nil,
        pattern: String? = nil,
        allowedValues: [AnyCodable]? = nil,
        example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.Context<JSONTypeFormat.StringFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )
        let stringContext = JSONSchema.StringContext(
            maxLength: maxLength,
            minLength: minLength,
            pattern: pattern
        )
        return .string(genericContext, stringContext)
    }

    public static var string: JSONSchema {
        return .string()
    }

    public static func number(
        format: JSONTypeFormat.NumberFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        title: String? = nil,
        description: String? = nil,
        multipleOf: Double? = nil,
        maximum: (Double, exclusive: Bool)? = nil,
        minimum: (Double, exclusive: Bool)? = nil,
        allowedValues: [AnyCodable]? = nil,
        example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.Context<JSONTypeFormat.NumberFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )
        let numbericContext = JSONSchema.NumericContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.0, exclusive: $0.exclusive) },
            minimum: minimum.map { ($0.0, exclusive: $0.exclusive) }
        )
        return .number(genericContext, numbericContext)
    }

    public static var number: JSONSchema {
        return .number()
    }

    public static func integer(
        format: JSONTypeFormat.IntegerFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        title: String? = nil,
        description: String? = nil,
        multipleOf: Int? = nil,
        maximum: (Int, exclusive: Bool)? = nil,
        minimum: (Int, exclusive: Bool)? = nil,
        allowedValues: [AnyCodable]? = nil,
        example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.Context<JSONTypeFormat.IntegerFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )
        let integerContext = JSONSchema.IntegerContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.0, exclusive: $0.exclusive) },
            minimum: minimum.map { ($0.0, exclusive: $0.exclusive) }
        )
        return .integer(genericContext, integerContext)
    }

    public static var integer: JSONSchema {
        return .integer()
    }

    public static func object(
        format: JSONTypeFormat.ObjectFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        title: String? = nil,
        description: String? = nil,
        minProperties: Int = 0,
        maxProperties: Int? = nil,
        properties: [String: JSONSchema] = [:],
        additionalProperties: Either<Bool, JSONSchema>? = nil,
        allowedValues: [AnyCodable]? = nil,
        example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
        ) -> JSONSchema {
        let generalContext = JSONSchema.Context<JSONTypeFormat.ObjectFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )
        let objectContext = JSONSchema.ObjectContext(
            properties: properties,
            additionalProperties: additionalProperties,
            maxProperties: maxProperties,
            minProperties: minProperties
        )
        return .object(generalContext, objectContext)
    }

    public static var object: JSONSchema {
        return .object()
    }

    public static func array(format: JSONTypeFormat.ArrayFormat = .unspecified,
                             required: Bool = true,
                             nullable: Bool = false,
                             title: String? = nil,
                             description: String? = nil,
                             minItems: Int = 0,
                             maxItems: Int? = nil,
                             uniqueItems: Bool = false,
                             items: JSONSchema? = nil,
                             allowedValues: [AnyCodable]? = nil,
                             example: (codable: AnyCodable, encoder: JSONEncoder)? = nil
        ) -> JSONSchema {
        let generalContext = JSONSchema.Context<JSONTypeFormat.ArrayFormat>(
            format: format,
            required: required,
            nullable: nullable,
            title: title,
            description: description,
            allowedValues: allowedValues,
            example: example
        )

        let arrayContext = JSONSchema.ArrayContext(
            items: items,
            maxItems: maxItems,
            minItems: minItems,
            uniqueItems: uniqueItems
        )
        return .array(generalContext, arrayContext)
    }
}

// MARK: - Codable

extension JSONSchema {
    private enum SubschemaCodingKeys: String, CodingKey {
        case allOf
        case oneOf
        case anyOf
        case not
    }
}

extension JSONSchema: Encodable {

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

extension JSONSchema: Decodable {

    private enum HintCodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {

        if let singleValueContainer = try? decoder.singleValueContainer() {
            if let ref = try? singleValueContainer.decode(JSONReference<OpenAPI.Components, JSONSchema>.self) {
                self = .reference(ref)
                return
            }
        }

        let container = try decoder.container(keyedBy: SubschemaCodingKeys.self)

        if container.contains(.allOf) {
            self = .all(of: try container.decode([JSONSchema].self, forKey: .allOf))
            return
        }

        if container.contains(.anyOf) {
            self = .any(of: try container.decode([JSONSchema].self, forKey: .anyOf))
            return
        }

        if container.contains(.oneOf) {
            self = .one(of: try container.decode([JSONSchema].self, forKey: .oneOf))
            return
        }

        if container.contains(.not) {
            self = .not(try container.decode(JSONSchema.self, forKey: .not))
            return
        }

        let hintContainer = try decoder.container(keyedBy: HintCodingKeys.self)

        let type: JSONType
        do {
            type = try hintContainer.decode(JSONType.self, forKey: .type)
        } catch {
            throw OpenAPI.DecodingError.missingKeyword(underlyingError: "A JSON Schema object is expected to be `oneOf`, `anyOf`, `allOf`, `not`, or have a `type` key.", codingPath: decoder.codingPath)
        }

        switch type {
        case .boolean:
            self = .boolean(try Context<JSONTypeFormat.BooleanFormat>(from: decoder))
        case .object:
            self = .object(try Context<JSONTypeFormat.ObjectFormat>(from: decoder),
                           try ObjectContext(from: decoder))
        case .array:
            self = .array(try Context<JSONTypeFormat.ArrayFormat>(from: decoder),
                           try ArrayContext(from: decoder))
        case .number:
            self = .number(try Context<JSONTypeFormat.NumberFormat>(from: decoder),
                           try NumericContext(from: decoder))
        case .integer:
            self = .integer(try Context<JSONTypeFormat.IntegerFormat>(from: decoder),
                           try IntegerContext(from: decoder))
        case .string:
            self = .string(try Context<JSONTypeFormat.StringFormat>(from: decoder),
                           try StringContext(from: decoder))
        }
    }
}
