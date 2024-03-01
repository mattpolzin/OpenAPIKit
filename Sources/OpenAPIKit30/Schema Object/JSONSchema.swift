//
//  JSONSchema.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

/// OpenAPI "Schema Object"
/// 
/// See [OpenAPI Schema Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#schema-object).
public struct JSONSchema: JSONSchemaContext, HasWarnings, VendorExtendable {
    public let warnings: [OpenAPI.Warning]
    public let value: Schema

    public let vendorExtensions: [String: AnyCodable]

    internal init(warnings: [OpenAPI.Warning], schema: Schema, vendorExtensions: [String: AnyCodable]) {
        self.warnings = warnings
        self.value = schema
        self.vendorExtensions = vendorExtensions
    }

    public init(schema: Schema, vendorExtensions: [String: AnyCodable] = [:]) {
        value = schema
        warnings = []
        self.vendorExtensions = vendorExtensions
    }

    /// Initialize with the value and warnings of the given schema but take on
    /// these new vendor extensions.
    public init(_ schema: JSONSchema, vendorExtensions: [String: AnyCodable]) {
        self.value = schema.value
        self.warnings = schema.warnings
        self.vendorExtensions = vendorExtensions
    }

    public static func boolean(_ core: CoreContext<JSONTypeFormat.BooleanFormat>) -> Self {
        .init(schema: .boolean(core))
    }
    public static func number(_ core: CoreContext<JSONTypeFormat.NumberFormat>, _ numeric: NumericContext) -> Self {
        .init(schema: .number(core, numeric))
    }
    public static func integer(_ core: CoreContext<JSONTypeFormat.IntegerFormat>, _ integral: IntegerContext) -> Self {
        .init(schema: .integer(core, integral))
    }
    public static func string(_ core: CoreContext<JSONTypeFormat.StringFormat>, _ string: StringContext) -> Self {
        .init(schema: .string(core, string))
    }
    public static func object(_ core: CoreContext<JSONTypeFormat.ObjectFormat>, _ object: ObjectContext) -> Self {
        .init(schema: .object(core, object))
    }
    public static func array(_ core: CoreContext<JSONTypeFormat.ArrayFormat>, _ array: ArrayContext) -> Self {
        .init(schema: .array(core, array))
    }
    public static func all(of schemas: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .all(of: schemas, core: core))
    }
    public static func one(of schemas: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .one(of: schemas, core: core))
    }
    public static func any(of schemas: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .any(of: schemas, core: core))
    }
    public static func not(_ schema: JSONSchema, core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .not(schema, core: core))
    }
    public static func reference(_ reference: JSONReference<JSONSchema>, _ context: ReferenceContext) -> Self {
        .init(schema: .reference(reference, context))
    }
        /// Schemas without a `type`.
    public static func fragment(_ core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .fragment(core))
    }

    public enum Schema: Equatable {
        case boolean(CoreContext<JSONTypeFormat.BooleanFormat>)
        case number(CoreContext<JSONTypeFormat.NumberFormat>, NumericContext)
        case integer(CoreContext<JSONTypeFormat.IntegerFormat>, IntegerContext)
        case string(CoreContext<JSONTypeFormat.StringFormat>, StringContext)
        indirect case object(CoreContext<JSONTypeFormat.ObjectFormat>, ObjectContext)
        indirect case array(CoreContext<JSONTypeFormat.ArrayFormat>, ArrayContext)
        indirect case all(of: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
        indirect case one(of: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
        indirect case any(of: [JSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
        indirect case not(JSONSchema, core: CoreContext<JSONTypeFormat.AnyFormat>)
        case reference(JSONReference<JSONSchema>, ReferenceContext)
        /// Schemas without a `type`.
        case fragment(CoreContext<JSONTypeFormat.AnyFormat>) // This allows for the "{}" case and also fragments of schemas that will later be combined with `all(of:)`.
    }

    /// The type and format of the schema.
    public var jsonTypeFormat: JSONTypeFormat? {
        switch value {
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
        case .all, .one, .any, .not, .reference, .fragment:
            return nil
        }
    }

    /// The fundamental type of the schema.
    ///
    /// - Important: "object," "array," "allOf,", "oneOf,"
    ///     "anyOf," "not," "reference," and "undefined" are
    ///     not considered types and such schemas will
    ///     return `nil` for this property.
    public var jsonType: JSONType? {
        return jsonTypeFormat?.jsonType
    }

    /// The format of the schema as a string value.
    ///
    /// This can be set even when a schema type has
    /// not be specified. If a type has been specified,
    /// a type-safe format can be used and retrieved
    /// via the `jsonTypeFormat` property.
    public var formatString: String? {
        switch value {
        case .boolean(let context):
            return context.format.rawValue
        case .object(let context, _):
            return context.format.rawValue
        case .array(let context, _):
            return context.format.rawValue
        case .number(let context, _):
            return context.format.rawValue
        case .integer(let context, _):
            return context.format.rawValue
        case .string(let context, _):
            return context.format.rawValue
        case .fragment(let context),
             .all(of: _, core: let context),
             .one(of: _, core: let context),
             .any(of: _, core: let context),
             .not(_, core: let context):
            return context.format.rawValue
        case .reference:
            return nil
        }
    }

    // See `JSONSchemaContext`
    public var required: Bool {
        switch value {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _),
             .fragment(let context as JSONSchemaContext),
             .all(of: _, core: let context as JSONSchemaContext),
             .one(of: _, core: let context as JSONSchemaContext),
             .any(of: _, core: let context as JSONSchemaContext),
             .not(_, core: let context as JSONSchemaContext):
            return context.required
        case .reference(_, let context):
            return context.required
        }
    }

    // See `JSONSchemaContext`
    public var description: String? {
        switch value {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _),
             .fragment(let context as JSONSchemaContext),
             .all(of: _, core: let context as JSONSchemaContext),
             .one(of: _, core: let context as JSONSchemaContext),
             .any(of: _, core: let context as JSONSchemaContext),
             .not(_, core: let context as JSONSchemaContext):
            return context.description
        case .reference:
            return nil
        }
    }

    // See `JSONSchemaContext`
    public var discriminator: OpenAPI.Discriminator? {
        switch value {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _),
             .fragment(let context as JSONSchemaContext),
             .all(of: _, core: let context as JSONSchemaContext),
             .one(of: _, core: let context as JSONSchemaContext),
             .any(of: _, core: let context as JSONSchemaContext),
             .not(_, core: let context as JSONSchemaContext):
            return context.discriminator
        case .reference:
            return nil
        }
    }

    // See `JSONSchemaContext`
    public var nullable: Bool {
        return coreContext?.nullable ?? false
    }

    // See `JSONSchemaContext`
    public var readOnly: Bool {
        return coreContext?.readOnly ?? false
    }

    // See `JSONSchemaContext`
    public var writeOnly: Bool {
        return coreContext?.writeOnly ?? false
    }

    // See `JSONSchemaContext`
    public var deprecated: Bool {
        return coreContext?.deprecated ?? false
    }

    // See `JSONSchemaContext`
    public var title: String? {
        return coreContext?.title
    }

    // See `JSONSchemaContext`
    public var externalDocs: OpenAPI.ExternalDocumentation? {
        return coreContext?.externalDocs
    }

    // See `JSONSchemaContext`
    public var allowedValues: [AnyCodable]? {
        return coreContext?.allowedValues
    }

    // See `JSONSchemaContext`
    public var defaultValue: AnyCodable? {
        return coreContext?.defaultValue
    }

    // See `JSONSchemaContext`
    public var example: AnyCodable? {
        return coreContext?.example
    }

    // See `JSONSchemaContext`
    public var inferred: Bool {
        return coreContext?.inferred ?? false
    }
}

extension JSONSchema: Equatable {
    public static func == (lhs: JSONSchema, rhs: JSONSchema) -> Bool {
        lhs.value == rhs.value
    }
}

// MARK: - Case Checks
extension JSONSchema {
    /// Check if this schema is an _empty_ `.fragment`.
    ///
    /// A special case of the `.fragment` schema is the "empty"
    /// schema where no information about the schema component
    /// is available.
    ///
    /// This is equivalent to the following JSON Schema:
    ///
    ///     {
    ///     }
    ///
    public var isEmpty: Bool {
        guard case .fragment(let context) = value, context.isEmpty else {
            return false
        }
        return true
    }

    /// Check if this schema is a `.fragment`.
    public var isFragment: Bool {
        guard case .fragment = value else { return false }
        return true
    }

    /// Check if a schema is a `.boolean`.
    public var isBoolean: Bool {
        guard case .boolean = value else { return false }
        return true
    }

    /// Check if a schema is a `.number`.
    ///
    /// This returns `false` if the schema is an
    /// `.integer` even though Integer schemas
    /// can be easily transformed into Number schemas.
    public var isNumber: Bool {
        guard case .number = value else { return false }
        return true
    }

    /// Check if a schema is an `.integer`.
    public var isInteger: Bool {
        guard case .integer = value else { return false }
        return true
    }

    /// Check if a schema is a `.string`.
    public var isString: Bool {
        guard case .string = value else { return false }
        return true
    }

    /// Check if a schema is an `.object`.
    public var isObject: Bool {
        guard case .object = value else { return false }
        return true
    }

    /// Check if a schema is an `.array`.
    public var isArray: Bool {
        guard case .array = value else { return false }
        return true
    }

    /// Check if a schema is a `.reference`.
    public var isReference: Bool {
        guard case .reference = value else { return false }
        return true
    }
}

// MARK: - Context Accessors
extension JSONSchema {
    /// Get the core context most JSONSchemas have.
    ///
    /// This is the information shared by most schemas.
    ///
    /// Notably, `reference` schemas do not have this core context.
    ///
    public var coreContext: JSONSchemaContext? {
        switch value {
        case .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _),
             .fragment(let context as JSONSchemaContext),
             .all(of: _, core: let context as JSONSchemaContext),
             .one(of: _, core: let context as JSONSchemaContext),
             .any(of: _, core: let context as JSONSchemaContext),
             .not(_, core: let context as JSONSchemaContext):
            return context
        case .reference:
            return nil
        }
    }

    /// Get the context specific to an `object` schema. If not an
    /// object schema, returns `nil`.
    public var objectContext: ObjectContext? {
        guard case .object(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get the context specific to an `array` schema. If not an
    /// array schema, returns `nil`.
    public var arrayContext: ArrayContext? {
        guard case .array(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get the context specific to a `number` schema. If not a
    /// number schema, returns `nil`.
    ///
    /// Although integers are numbers, an `integer` schema will
    /// still return `nil` when asked for a `numberContext`.
    ///
    /// If you wish to get a `NumericContext` from an `integer`
    /// schema, take an `IntegerContext` and explicitly request
    /// a `NumericContext` from it via its `numericContext`
    /// accessor.
    ///
    public var numberContext: NumericContext? {
        guard case .number(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get the context specific to an `integer` schema. If not an
    /// integer schema, returns `nil`.
    public var integerContext: IntegerContext? {
        guard case .integer(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get the context specific to a `string` schema. If not a
    /// string schema, returns `nil`.
    public var stringContext: StringContext? {
        guard case .string(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get the context specific to a `reference` schema. If not a
    /// reference schema, returns `nil`.
    public var referenceContext: ReferenceContext? {
        guard case .reference(_, let context) = value else {
            return nil
        }
        return context
    }

    /// Get subschemas if this schema is an anyOf, allOf, etc.
    /// Returns an empty array for any schema that does not have
    /// subschemas.
    ///
    /// - IMPORTANT: An object's properties are NOT considered
    ///              subschemas.
    public var subschemas: [JSONSchema] {
        switch self.value {
            case .not(let schema, core: _):
                return [schema]
            case .array(_, let arrayContext):
                return arrayContext.items.map { [$0] } ?? []
            case .all(of: let schemas, core: _):
                return schemas
            case .any(of: let schemas, core: _):
                return schemas
            case .one(of: let schemas, core: _):
                return schemas
            default:
                return []
        }
    }
}

// MARK: - Transformations
extension JSONSchema {
    /// Return the optional version of this `JSONSchema`
    public func optionalSchemaObject() -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.optionalContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.optionalContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.optionalContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.optionalContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.optionalContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments.map { $0.optionalSchemaObject() }, core: core.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        case .reference(let reference, let context):
            return .init(
                warnings: warnings,
                schema: .reference(reference, context.optionalContext()),
                vendorExtensions: vendorExtensions
            )
        }
    }

    /// Return the required version of this `JSONSchema`
    public func requiredSchemaObject() -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.requiredContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.requiredContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.requiredContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.requiredContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.requiredContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments.map { $0.requiredSchemaObject() }, core: core.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        case .reference(let reference, let context):
            return .init(
                warnings: warnings,
                schema: .reference(reference, context.requiredContext()),
                vendorExtensions: vendorExtensions
            )
        }
    }

    /// Return the nullable version of this `JSONSchema`
    public func nullableSchemaObject() -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.nullableContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.nullableContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.nullableContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.nullableContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.nullableContext(), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.nullableContext()),
                vendorExtensions: vendorExtensions
            )
        case .reference:
            return self
        }
    }

    /// Return a version of this `JSONSchema` that only allows the given
    /// values.
    public func with(allowedValues: [AnyCodable]) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(allowedValues: allowedValues), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(allowedValues: allowedValues), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(allowedValues: allowedValues), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(allowedValues: allowedValues), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(allowedValues: allowedValues), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(allowedValues: allowedValues)),
                vendorExtensions: vendorExtensions
            )
        case .reference:
            return self
        }
    }

    /// Return a version of this `JSONSchema` that has the given default value.
    public func with(defaultValue: AnyCodable) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(defaultValue: defaultValue), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(defaultValue: defaultValue), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(defaultValue: defaultValue), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(defaultValue: defaultValue), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(defaultValue: defaultValue), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(defaultValue: defaultValue)),
                vendorExtensions: vendorExtensions
            )
        case .reference:
            return self
        }
    }

    /// Returns a version of this `JSONSchema` that has the given example
    /// attached.
    public func with(example: AnyCodable) throws -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(example: example), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(example: example), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(example: example), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(example: example), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(example: example), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(example: example)),
                vendorExtensions: vendorExtensions
            )
        case .reference:
            throw Self.Error.exampleNotSupported
        }
    }

    /// Returns a version of this `JSONSchema` that has the given discriminator.
    public func with(discriminator: OpenAPI.Discriminator) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(discriminator: discriminator), contextB),
                vendorExtensions: vendorExtensions
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(discriminator: discriminator), contextB),
                vendorExtensions: vendorExtensions
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(discriminator: discriminator), contextB),
                vendorExtensions: vendorExtensions
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(discriminator: discriminator), contextB),
                vendorExtensions: vendorExtensions
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(discriminator: discriminator), contextB),
                vendorExtensions: vendorExtensions
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(discriminator: discriminator)),
                vendorExtensions: vendorExtensions
            )
        case .reference:
            return self
        }
    }
}

extension JSONSchema {
    internal enum Error: Swift.Error, CustomStringConvertible, Equatable {
        case exampleNotSupported

        public var description: String {
            switch self {
            case .exampleNotSupported:
                return "examples not supported for `.allOf`, `.oneOf`, `.anyOf`, `.not` or for JSON references ($ref)."
            }
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
    // array allowedValues
    /// Construct a boolean schema.
    public static func boolean(
        format: JSONTypeFormat.BooleanFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let context = JSONSchema.CoreContext<JSONTypeFormat.BooleanFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        return .boolean(context)
    }

    // variadic allowedValues
    /// Construct a boolean schema passing a variadic list of allowed values.
    public static func boolean(
        format: JSONTypeFormat.BooleanFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        return .boolean(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// A required, non-nullable boolean schema.
    public static var boolean: JSONSchema {
        return .boolean()
    }

    // array allowedValues
    /// Construct a fragment of a schema.
    public static func fragment(
        format: JSONTypeFormat.AnyFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let context = JSONSchema.CoreContext<JSONTypeFormat.AnyFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        return .fragment(context)
    }

    // variadic allowedValues
    /// Construct a fragment of a schema passing a variadic list of allowed values.
    public static func fragment(
        format: JSONTypeFormat.AnyFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        return .fragment(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// A required, non-nullable fragment of a schema.
    ///
    /// This is also known as the "empty" schema because
    /// its representation in JSON is just an empty object `{ }`.
    public static var fragment: JSONSchema {
        return .fragment()
    }

    // array allowedValues
    /// Construct a string schema.
    public static func string(
        format: JSONTypeFormat.StringFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.CoreContext<JSONTypeFormat.StringFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        let stringContext = JSONSchema.StringContext(
            maxLength: maxLength,
            minLength: minLength,
            pattern: pattern
        )
        return .string(genericContext, stringContext)
    }

    // variadic allowedValues
    /// Construct a string schema passing a variadic list of allowed values.
    public static func string(
        format: JSONTypeFormat.StringFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        return .string(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            minLength: minLength,
            maxLength: maxLength,
            pattern: pattern,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// A required, non-nullable string schema.
    public static var string: JSONSchema {
        return .string()
    }

    // array allowedValues
    /// Construct a number schema.
    public static func number(
        format: JSONTypeFormat.NumberFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        multipleOf: Double? = nil,
        maximum: (Double, exclusive: Bool)? = nil,
        minimum: (Double, exclusive: Bool)? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.CoreContext<JSONTypeFormat.NumberFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        let numbericContext = JSONSchema.NumericContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.0, exclusive: $0.exclusive) },
            minimum: minimum.map { ($0.0, exclusive: $0.exclusive) }
        )
        return .number(genericContext, numbericContext)
    }

    // variadic allowedValues
    /// Construct a number schema passing a variadic list of allowed values.
    public static func number(
        format: JSONTypeFormat.NumberFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        multipleOf: Double? = nil,
        maximum: (Double, exclusive: Bool)? = nil,
        minimum: (Double, exclusive: Bool)? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        return .number(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            multipleOf: multipleOf,
            maximum: maximum,
            minimum: minimum,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// A required, non-nullable number schema.
    public static var number: JSONSchema {
        return .number()
    }

    // array allowedValues
    /// Construct an integer schema.
    public static func integer(
        format: JSONTypeFormat.IntegerFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        multipleOf: Int? = nil,
        maximum: (Int, exclusive: Bool)? = nil,
        minimum: (Int, exclusive: Bool)? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let genericContext = JSONSchema.CoreContext<JSONTypeFormat.IntegerFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        let integerContext = JSONSchema.IntegerContext(
            multipleOf: multipleOf,
            maximum: maximum.map { ($0.0, exclusive: $0.exclusive) },
            minimum: minimum.map { ($0.0, exclusive: $0.exclusive) }
        )
        return .integer(genericContext, integerContext)
    }

    // variadic allowedValues
    /// Construct an integer schema passing a variadic list of allowed values.
    public static func integer(
        format: JSONTypeFormat.IntegerFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        multipleOf: Int? = nil,
        maximum: (Int, exclusive: Bool)? = nil,
        minimum: (Int, exclusive: Bool)? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        return .integer(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            multipleOf: multipleOf,
            maximum: maximum,
            minimum: minimum,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }

    /// A required, non-nullable integer schema.
    public static var integer: JSONSchema {
        return .integer()
    }

    // array allowedValues
    /// Construct an objecy schema.
    public static func object(
        format: JSONTypeFormat.ObjectFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minProperties: Int? = nil,
        maxProperties: Int? = nil,
        properties: OrderedDictionary<String, JSONSchema> = [:],
        additionalProperties: Either<Bool, JSONSchema>? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let coreContext = JSONSchema.CoreContext<JSONTypeFormat.ObjectFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        let objectContext = JSONSchema.ObjectContext(
            properties: properties,
            additionalProperties: additionalProperties,
            maxProperties: maxProperties,
            minProperties: minProperties
        )
        return .object(coreContext, objectContext)
    }

    /// A required, non-nullable object schema.
    public static var object: JSONSchema {
        return .object()
    }

    // array allowedValues
    /// Construct an array schema.
    public static func array(
        format: JSONTypeFormat.ArrayFormat = .unspecified,
        required: Bool = true,
        nullable: Bool? = nil,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minItems: Int? = nil,
        maxItems: Int? = nil,
        uniqueItems: Bool? = nil,
        items: JSONSchema? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        example: AnyCodable? = nil
    ) -> JSONSchema {
        let coreContext = JSONSchema.CoreContext<JSONTypeFormat.ArrayFormat>(
            format: format,
            required: required,
            nullable: nullable,
            permissions: permissions,
            deprecated: deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )

        let arrayContext = JSONSchema.ArrayContext(
            items: items,
            maxItems: maxItems,
            minItems: minItems,
            uniqueItems: uniqueItems
        )
        return .array(coreContext, arrayContext)
    }

    /// A required, non-nullable array schema.
    public static var array: JSONSchema {
        return .array()
    }

    /// Construct a schema stating all of the given fragment
    /// requirements are met.
    public static func all(
        of schemas: [JSONSchema]
    ) -> JSONSchema {
        return .all(of: schemas, core: .init())
    }

    /// Construct a schema stating all of the given fragment
    /// requirements are met given a discriminator.
    public static func all(
        of schemas: JSONSchema...,
        required: Bool = true,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil
    ) -> JSONSchema {
        return .all(
            of: schemas,
            core: .init(
                required: required,
                title: title,
                description: description,
                discriminator: discriminator
            )
        )
    }

    /// Construct a schema stating one of the given schema's
    /// requirements are met.
    public static func one(
        of schemas: [JSONSchema]
    ) -> JSONSchema {
        return .one(of: schemas, core: .init())
    }

    /// Construct a schema stating one of the given schema's
    /// requirements are met given a discriminator.
    public static func one(
        of schemas: JSONSchema...,
        required: Bool = true,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil
    ) -> JSONSchema {
        return .one(
            of: schemas,
            core: .init(
                required: required,
                title: title,
                description: description,
                discriminator: discriminator
            )
        )
    }

    /// Construct a schema stating any of the given schema's
    /// requirements are met.
    public static func any(
        of schemas: [JSONSchema]
    ) -> JSONSchema {
        return .any(of: schemas, core: .init())
    }

    /// Construct a schema stating any of the given schema's
    /// requirements are met given a discriminator.
    public static func any(
        of schemas: JSONSchema...,
        required: Bool = true,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil
    ) -> JSONSchema {
        return .any(
            of: schemas,
            core: .init(
                required: required,
                title: title,
                description: description,
                discriminator: discriminator
            )
        )
    }

    /// Construct a schema stating the given schema's
    /// requirements are _not_ met.
    ///
    /// Only the schema taken as the first
    /// argument is inverted by the **not** logic. Any
    /// other arguments are here to directly describe what
    /// this schema _is_ as opposed to what it _is not_.
    public static func not(
        _ schema: JSONSchema,
        required: Bool = true,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil
    ) -> JSONSchema {
        return .not(
            schema,
            core: .init(
                required: required,
                title: title,
                description: description,
                discriminator: discriminator
            )
        )
    }

    /// Construct a reference schema
    public static func reference(
        _ reference: JSONReference<JSONSchema>,
        required: Bool = true
    ) -> JSONSchema {
        return .reference(reference, .init(required: required))
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

    private enum VendorExtensionKeys: CodingKey, ExtendableCodingKey {
        case extended(String)

        static let allBuiltinKeys: [JSONSchema.VendorExtensionKeys] = []

        static func extendedKey(for value: String) -> JSONSchema.VendorExtensionKeys {
            .extended(value)
        }

        var stringValue: String {
            switch self {
            case .extended(let value):
                return value
            }
        }

        init?(stringValue: String) {
            self = .extended(stringValue)
        }
    }
}

extension JSONSchema: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch value {
        case .boolean(let context):
            try context.encode(to: encoder)

        case .object(let contextA as Encodable, let contextB as Encodable),
             .array(let contextA as Encodable, let contextB as Encodable),
             .number(let contextA as Encodable, let contextB as Encodable),
             .integer(let contextA as Encodable, let contextB as Encodable),
             .string(let contextA as Encodable, let contextB as Encodable):
            try contextA.encode(to: encoder)
            try contextB.encode(to: encoder)

        case .all(of: let nodes, core: let core):
            var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

            try container.encode(nodes, forKey: .allOf)
            try core.encode(to: encoder)

        case .one(of: let nodes, core: let core):
            var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

            try container.encode(nodes, forKey: .oneOf)
            try core.encode(to: encoder)

        case .any(of: let nodes, core: let core):
            var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

            try container.encode(nodes, forKey: .anyOf)
            try core.encode(to: encoder)

        case .not(let node, core: let core):
            var container = encoder.container(keyedBy: SubschemaCodingKeys.self)

            try container.encode(node, forKey: .not)
            try core.encode(to: encoder)

        case .reference(let reference, _):
            var container = encoder.singleValueContainer()

            try container.encode(reference)

        case .fragment(let context):
            var container = encoder.singleValueContainer()

            try container.encode(context)
        }

        // Ad-hoc vendor extension encoding because keys are done differently for
        // JSONSchema
        guard VendorExtensionsConfiguration.isEnabled else {
            return
        }
        var container = encoder.container(keyedBy: VendorExtensionKeys.self)

        for (key, value) in vendorExtensions {
            let xKey = key.starts(with: "x-") ? key : "x-\(key)"
            try container.encode(value, forKey: .extendedKey(for: xKey))
        }
    }
}

extension JSONSchema: Decodable {

    private enum HintCodingKeys: String, CodingKey {
        case type
        case other

        init(stringValue: String) {
            self = Self(rawValue: stringValue) ?? .other
        }
    }

    public init(from decoder: Decoder) throws {

        if let singleValueContainer = try? decoder.singleValueContainer() {
            if let ref = try? singleValueContainer.decode(JSONReference<JSONSchema>.self) {
                self = .reference(ref, .init(required: true))
                return
            }
        }

        let container = try decoder.container(keyedBy: SubschemaCodingKeys.self)

        if container.contains(.allOf) {
            var schema: JSONSchema = .all(
                of: try container.decode([JSONSchema].self, forKey: .allOf),
                core: try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.anyOf) {
            var schema: JSONSchema = .any(
                of: try container.decode([JSONSchema].self, forKey: .anyOf),
                core: try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.oneOf) {
            var schema: JSONSchema = .one(
                of: try container.decode([JSONSchema].self, forKey: .oneOf),
                core: try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.not) {
            let schema: JSONSchema = .not(
                try container.decode(JSONSchema.self, forKey: .not),
                core: try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            )

            self = schema
            return
        }

        let hintContainer = try decoder.container(keyedBy: HintCodingKeys.self)
        let hintContainerCount = hintContainer.allKeys.count
        let typeHint = try hintContainer.decodeIfPresent(JSONType.self, forKey: .type)

        let numericOrIntegerContainer = try decoder.container(keyedBy: JSONSchema.NumericContext.CodingKeys.self)
        let stringContainer = try decoder.container(keyedBy: JSONSchema.StringContext.CodingKeys.self)
        let arrayContainer = try decoder.container(keyedBy: JSONSchema.ArrayContext.CodingKeys.self)
        let objectContainer = try decoder.container(keyedBy: JSONSchema.ObjectContext.CodingKeys.self)

        let keysFrom = [
            numericOrIntegerContainer.allKeys.isEmpty ? nil : JSONType.number.group,
            stringContainer.allKeys.isEmpty ? nil : JSONType.string.group,
            arrayContainer.allKeys.isEmpty ? nil : JSONType.array.group,
            objectContainer.allKeys.isEmpty ? nil : JSONType.object.group
        ].compactMap { $0 }

        var _warnings = [OpenAPI.Warning]()

        if keysFrom.count > 1 {
            _warnings.append(
                .underlyingError(
                    InconsistencyError(
                        subjectName: "Schema",
                        details: "A schema contains properties for multiple types of schemas, namely: \(keysFrom).",
                        codingPath: decoder.codingPath
                    )
                )
            )
        }

        if let typeHint = typeHint {
            let keysFromElsewhere = keysFrom.filter({ $0 != typeHint.group })
            if !keysFromElsewhere.isEmpty {
                _warnings.append(
                    .underlyingError(
                        InconsistencyError(
                            subjectName: "OpenAPI Schema",
                            details: "Found schema attributes not consistent with the type specified: \(typeHint). Specifically, attributes for these other types: \(keysFromElsewhere)",
                            codingPath: decoder.codingPath
                        )
                    )
                )
            }
        }

        if typeHint == .integer || typeHint == .number || (typeHint == nil && !numericOrIntegerContainer.allKeys.isEmpty) {
            if typeHint == .integer {
                value = .integer(try CoreContext<JSONTypeFormat.IntegerFormat>(from: decoder),
                                try IntegerContext(from: decoder))
            } else {
                value = .number(try CoreContext<JSONTypeFormat.NumberFormat>(from: decoder),
                               try NumericContext(from: decoder))
            }

        } else if typeHint == .string || (typeHint == nil && !stringContainer.allKeys.isEmpty) {
            value = .string(try CoreContext<JSONTypeFormat.StringFormat>(from: decoder),
                           try StringContext(from: decoder))

        } else if typeHint == .array || (typeHint == nil && !arrayContainer.allKeys.isEmpty) {
            value = .array(try CoreContext<JSONTypeFormat.ArrayFormat>(from: decoder),
                          try ArrayContext(from: decoder))

        } else if typeHint == .object || (typeHint == nil && !objectContainer.allKeys.isEmpty) {
            value = .object(try CoreContext<JSONTypeFormat.ObjectFormat>(from: decoder),
                           try ObjectContext(from: decoder))

        } else if typeHint == .boolean {
            value = .boolean(try CoreContext<JSONTypeFormat.BooleanFormat>(from: decoder))

        } else {
            let fragmentContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            if fragmentContext.isEmpty && hintContainerCount > 0 {
                _warnings.append(
                    .underlyingError(
                        InconsistencyError(
                            subjectName: "OpenAPI Schema",
                            details: "Found nothing but unsupported attributes.",
                            codingPath: decoder.codingPath
                        )
                    )
                )
            }
            value = .fragment(fragmentContext)
        }

        self.warnings = _warnings

        // Ad-hoc vendor extension support since JSONSchema does coding keys differently. 
        guard VendorExtensionsConfiguration.isEnabled else {
            self.vendorExtensions = [:]
            return
        }

        let decoded = try AnyCodable(from: decoder).value

        guard (decoded as? [Any]) == nil else {
            throw VendorExtensionDecodingError.selfIsArrayNotDict
        }

        guard let decodedAny = decoded as? [String: Any] else {
            throw VendorExtensionDecodingError.foundNonStringKeys
        }

        let extensions = decodedAny.filter { $0.key.lowercased().starts(with: "x-") }

        self.vendorExtensions = extensions.mapValues(AnyCodable.init)
    }
}

extension JSONSchema: Validatable {}
