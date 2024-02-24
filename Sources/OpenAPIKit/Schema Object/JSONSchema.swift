//
//  JSONSchema.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

/// OpenAPI "Schema Object"
/// 
/// See [OpenAPI Schema Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.1.0.md#schema-object).
public struct JSONSchema: JSONSchemaContext, HasWarnings {

    public let warnings: [OpenAPI.Warning]
    public let value: Schema

    internal init(warnings: [OpenAPI.Warning], schema: Schema) {
        self.warnings = warnings
        self.value = schema
    }

    public init(schema: Schema) {
        warnings = []
        value = schema
    }

    /// The null type, which replaces the functionality of the `nullable` property from
    /// previous versions of the OpenAPI specification.
    public static func null(_ core: CoreContext<JSONTypeFormat.AnyFormat> = .init(nullable: true)) -> Self {
        .init(schema: .null(core.nullableContext()))
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
    public static func reference(_ reference: JSONReference<JSONSchema>, _ context: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .reference(reference, context))
    }
    /// Schemas without a `type`.
    public static func fragment(_ core: CoreContext<JSONTypeFormat.AnyFormat>) -> Self {
        .init(schema: .fragment(core))
    }

    public enum Schema: Equatable {
        /// The null type, which replaces the functionality of the `nullable` property from
        /// previous versions of the OpenAPI specification.
        case null(CoreContext<JSONTypeFormat.AnyFormat>)
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
        case reference(JSONReference<JSONSchema>, CoreContext<JSONTypeFormat.AnyFormat>)
        /// Schemas without a `type`.
        case fragment(CoreContext<JSONTypeFormat.AnyFormat>) // This allows for the "{}" case and also fragments of schemas that will later be combined with `all(of:)`.
    }

    /// The type and format of the schema.
    public var jsonTypeFormat: JSONTypeFormat? {
        switch value {
        case .null:
            return .null
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
        case .reference, .null:
            return nil
        }
    }

    // See `JSONSchemaContext`
    public var required: Bool {
        return coreContext.required
    }

    // See `JSONSchemaContext`
    public var description: String? {
        return coreContext.description
    }

    // See `JSONSchemaContext`
    public var discriminator: OpenAPI.Discriminator? {
        switch value {
        case .null(let context as JSONSchemaContext),
             .boolean(let context as JSONSchemaContext),
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
        return coreContext.nullable
    }

    // See `JSONSchemaContext`
    public var readOnly: Bool {
        return coreContext.readOnly
    }

    // See `JSONSchemaContext`
    public var writeOnly: Bool {
        return coreContext.writeOnly
    }

    // See `JSONSchemaContext`
    public var deprecated: Bool {
        return coreContext.deprecated
    }

    // See `JSONSchemaContext`
    public var title: String? {
        return coreContext.title
    }

    // See `JSONSchemaContext`
    public var externalDocs: OpenAPI.ExternalDocumentation? {
        return coreContext.externalDocs
    }

    // See `JSONSchemaContext`
    public var allowedValues: [AnyCodable]? {
        return coreContext.allowedValues
    }

    // See `JSONSchemaContext`
    public var defaultValue: AnyCodable? {
        return coreContext.defaultValue
    }

    // See `JSONSchemaContext`
    public var examples: [AnyCodable] {
        return coreContext.examples
    }

    // See `JSONSchemaContext`
    public var inferred: Bool {
        return coreContext.inferred
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

    /// Check if schema is `.null`
    public var isNull : Bool {
        guard case .null = value else { return false }
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
    /// This is the information shared by all schemas.
    public var coreContext: JSONSchemaContext {
        switch value {
        case .null(let context as JSONSchemaContext),
             .boolean(let context as JSONSchemaContext),
             .object(let context as JSONSchemaContext, _),
             .array(let context as JSONSchemaContext, _),
             .number(let context as JSONSchemaContext, _),
             .integer(let context as JSONSchemaContext, _),
             .string(let context as JSONSchemaContext, _),
             .fragment(let context as JSONSchemaContext),
             .all(of: _, core: let context as JSONSchemaContext),
             .one(of: _, core: let context as JSONSchemaContext),
             .any(of: _, core: let context as JSONSchemaContext),
             .not(_, core: let context as JSONSchemaContext),
             .reference(_, let context as JSONSchemaContext):
            return context
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

// MARK: - Vendor Extensions
extension JSONSchema: VendorExtendable {
    /// Dictionary of vendor extensions.
    ///
    /// These should be of the form:
    /// `[ "x-extensionKey": <anything>]`
    /// where the values are anything codable.
    public var vendorExtensions: VendorExtensions {
        coreContext.vendorExtensions
    }

    public func with(vendorExtensions: [String: AnyCodable]) -> JSONSchema {
        .init(
            warnings: warnings, 
            schema: value.with(vendorExtensions: vendorExtensions)
        )
    }
}

extension JSONSchema.Schema {
    public func with(vendorExtensions: [String: AnyCodable]) -> JSONSchema.Schema {
        switch self {
        case .null(let context):
            return .null(context.with(vendorExtensions: vendorExtensions))
        case .boolean(let context):
            return .boolean(context.with(vendorExtensions: vendorExtensions))
        case .number(let contextA, let contextB):
            return .number(contextA.with(vendorExtensions: vendorExtensions), contextB)
        case .integer(let contextA, let contextB):
            return .integer(contextA.with(vendorExtensions: vendorExtensions), contextB)
        case .string(let contextA, let contextB):
            return .string(contextA.with(vendorExtensions: vendorExtensions), contextB)
        case .object(let contextA, let contextB):
            return .object(contextA.with(vendorExtensions: vendorExtensions), contextB)
        case .array(let contextA, let contextB):
            return .array(contextA.with(vendorExtensions: vendorExtensions), contextB)
        case .all(of: let of, core: let core):
            return .all(of: of, core: core.with(vendorExtensions: vendorExtensions))
        case .one(of: let of, core: let core):
            return .one(of: of, core: core.with(vendorExtensions: vendorExtensions))
        case .any(of: let of, core: let core):
            return .any(of: of, core: core.with(vendorExtensions: vendorExtensions))
        case .not(let of, core: let core):
            return .not(of, core: core.with(vendorExtensions: vendorExtensions))
        case .reference(let context, let coreContext):
            return .reference(context, coreContext.with(vendorExtensions: vendorExtensions))
        case .fragment(let context):
            return .fragment(context.with(vendorExtensions: vendorExtensions))
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
                schema: .boolean(context.optionalContext())
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.optionalContext(), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.optionalContext(), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.optionalContext(), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.optionalContext(), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.optionalContext(), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.optionalContext())
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments.map { $0.optionalSchemaObject() }, core: core.optionalContext())
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.optionalContext())
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.optionalContext())
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.optionalContext())
            )
        case .reference(let reference, let context):
            return .init(
                warnings: warnings,
                schema: .reference(reference, context.optionalContext())
            )
        case .null(let context):
            return .init(
                warnings: warnings,
                schema: .null(context.optionalContext())
            )
        }
    }

    /// Return the required version of this `JSONSchema`
    public func requiredSchemaObject() -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.requiredContext())
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.requiredContext(), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.requiredContext(), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.requiredContext(), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.requiredContext(), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.requiredContext(), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.requiredContext())
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments.map { $0.requiredSchemaObject() }, core: core.requiredContext())
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.requiredContext())
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.requiredContext())
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.requiredContext())
            )
        case .reference(let reference, let context):
            return .init(
                warnings: warnings,
                schema: .reference(reference, context.requiredContext())
            )
        case .null(let context):
            return .init(
                warnings: warnings,
                schema: .null(context.requiredContext())
            )
        }
    }

    /// Return the nullable version of this `JSONSchema`
    public func nullableSchemaObject() -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.nullableContext())
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.nullableContext(), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.nullableContext(), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.nullableContext(), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.nullableContext(), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.nullableContext(), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.nullableContext())
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.nullableContext())
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.nullableContext())
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.nullableContext())
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.nullableContext())
            )
        case .reference, .null:
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
                schema: .boolean(context.with(allowedValues: allowedValues))
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(allowedValues: allowedValues), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(allowedValues: allowedValues), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(allowedValues: allowedValues), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(allowedValues: allowedValues), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(allowedValues: allowedValues), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(allowedValues: allowedValues))
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(allowedValues: allowedValues))
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(allowedValues: allowedValues))
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(allowedValues: allowedValues))
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(allowedValues: allowedValues))
            )
        case .reference(let schema, let core):
            return .init(
                warnings: warnings,
                schema: .reference(schema, core.with(allowedValues: allowedValues))
            )
        case .null(let core):
            return .init(
                warnings: warnings,
                schema: .null(core.with(allowedValues: allowedValues))
            )
        }
    }

    /// Return a version of this `JSONSchema` that has the given default value.
    public func with(defaultValue: AnyCodable) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(defaultValue: defaultValue))
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(defaultValue: defaultValue), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(defaultValue: defaultValue), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(defaultValue: defaultValue), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(defaultValue: defaultValue), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(defaultValue: defaultValue), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(defaultValue: defaultValue))
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(defaultValue: defaultValue))
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(defaultValue: defaultValue))
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(defaultValue: defaultValue))
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(defaultValue: defaultValue))
            )
        case .reference(let schema, let core):
            return .init(
                warnings: warnings,
                schema: .reference(schema, core.with(defaultValue: defaultValue))
            )
        case .null(let core):
            return .init(
                warnings: warnings,
                schema: .null(core.with(defaultValue: defaultValue))
            )
        }
    }

    /// Returns a version of this `JSONSchema` that has the given example
    /// attached.
    public func with(example: AnyCodable) throws -> JSONSchema {
        return try with(examples: [example])
    }

    /// Returns a version of this `JSONSchema` that has the given examples
    /// attached.
    public func with(examples: [AnyCodable]) throws -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(examples: examples))
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(examples: examples), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(examples: examples), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(examples: examples), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(examples: examples), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(examples: examples), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(examples: examples))
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(examples: examples))
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(examples: examples))
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(examples: examples))
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(examples: examples))
            )
        case .reference(let schema, let core):
            return .init(
                warnings: warnings,
                schema: .reference(schema, core.with(examples: examples))
            )
        case .null(let core):
            return .init(
                warnings: warnings,
                schema: .null(core.with(examples: examples))
            )
        }
    }

    /// Returns a version of this `JSONSchema` that has the given discriminator.
    public func with(discriminator: OpenAPI.Discriminator) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(discriminator: discriminator))
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(discriminator: discriminator), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(discriminator: discriminator), contextB)
            )
        case .number(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(context.with(discriminator: discriminator), contextB)
            )
        case .integer(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(context.with(discriminator: discriminator), contextB)
            )
        case .string(let context, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(context.with(discriminator: discriminator), contextB)
            )
        case .fragment(let context):
            return .init(
                warnings: warnings,
                schema: .fragment(context.with(discriminator: discriminator))
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(discriminator: discriminator))
            )
        case .one(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: schemas, core: core.with(discriminator: discriminator))
            )
        case .any(of: let schemas, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: schemas, core: core.with(discriminator: discriminator))
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(discriminator: discriminator))
            )
        case .reference, .null:
            return self
        }
    }

    /// Returns a version of this `JSONSchema` that has the given description.
    public func with(description: String) -> JSONSchema {
        switch value {
        case .boolean(let context):
            return .init(
                warnings: warnings,
                schema: .boolean(context.with(description: description))
            )
        case .number(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .number(contextA.with(description: description), contextB)
            )
        case .integer(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .integer(contextA.with(description: description), contextB)
            )
        case .string(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .string(contextA.with(description: description), contextB)
            )
        case .object(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .object(contextA.with(description: description), contextB)
            )
        case .array(let contextA, let contextB):
            return .init(
                warnings: warnings,
                schema: .array(contextA.with(description: description), contextB)
            )
        case .all(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .all(of: fragments, core: core.with(description: description))
            )
        case .one(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .one(of: fragments, core: core.with(description: description))
            )
        case .any(of: let fragments, core: let core):
            return .init(
                warnings: warnings,
                schema: .any(of: fragments, core: core.with(description: description))
            )
        case .not(let schema, core: let core):
            return .init(
                warnings: warnings,
                schema: .not(schema, core: core.with(description: description))
            )
        case .fragment(let fragment):
            return .init(
                warnings: warnings,
                schema: .fragment(fragment.with(description: description))
            )
        case .reference(let ref, let referenceContext):
            return .init(
                warnings: warnings,
                schema: .reference(ref, referenceContext.with(description: description))
            )
        case .null(let referenceContext):
            return .init(
                warnings: warnings,
                schema: .null(referenceContext.with(description: description))
            )
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
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            examples: examples
        )
        return .boolean(context)
    }

    // variadic allowedValues
    /// Construct a boolean schema passing a variadic list of allowed values.
    public static func boolean(
        format: JSONTypeFormat.BooleanFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            examples: examples
        )
        return .fragment(context)
    }

    // variadic allowedValues
    /// Construct a fragment of a schema passing a variadic list of allowed values.
    public static func fragment(
        format: JSONTypeFormat.AnyFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        contentMediaType: OpenAPI.ContentType? = nil,
        contentEncoding: OpenAPI.ContentEncoding? = nil,
        allowedValues: [AnyCodable]? = nil,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            examples: examples
        )
        let stringContext = JSONSchema.StringContext(
            maxLength: maxLength,
            minLength: minLength,
            pattern: pattern,
            contentMediaType: contentMediaType,
            contentEncoding: contentEncoding
        )
        return .string(genericContext, stringContext)
    }

    // variadic allowedValues
    /// Construct a string schema passing a variadic list of allowed values.
    public static func string(
        format: JSONTypeFormat.StringFormat = .unspecified,
        required: Bool = true,
        nullable: Bool = false,
        permissions: Permissions? = nil,
        deprecated: Bool? = nil,
        title: String? = nil,
        description: String? = nil,
        discriminator: OpenAPI.Discriminator? = nil,
        externalDocs: OpenAPI.ExternalDocumentation? = nil,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        pattern: String? = nil,
        contentMediaType: OpenAPI.ContentType? = nil,
        contentEncoding: OpenAPI.ContentEncoding? = nil,
        allowedValues: AnyCodable...,
        defaultValue: AnyCodable? = nil,
        examples: [AnyCodable] = []
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
            contentMediaType: contentMediaType,
            contentEncoding: contentEncoding,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        nullable: Bool = false,
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
        examples: [AnyCodable] = []
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
            examples: examples
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
        required: Bool = true,
        title: String? = nil,
        description: String? = nil
    ) -> JSONSchema {
        return .reference(reference, .init(required: required, title: title, description: description))
    }
}

// MARK: - Describable

extension JSONSchema : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> JSONSchema {
        guard let description = description else { return self }
        return self.with(description: description)
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

    private enum NullCodingKeys: String, CodingKey {
        case type
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
        case .null(let coreContext):
            var container = encoder.container(keyedBy: NullCodingKeys.self)
            try container.encode(JSONType.null.rawValue, forKey: .type)
            try coreContext.encode(to: encoder)

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

        case .reference(let reference, let core):
            try core.encode(to: encoder)
            try reference.encode(to: encoder)

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

        if let ref = try? JSONReference<JSONSchema>(from: decoder) {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            self = .init(warnings: coreContext.warnings, schema: .reference(ref, coreContext))
            return
        }

        let container = try decoder.container(keyedBy: SubschemaCodingKeys.self)

        if container.contains(.allOf) {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            var schema: JSONSchema = .init(
                warnings: coreContext.warnings,
                schema: .all(
                    of: try container.decode([JSONSchema].self, forKey: .allOf),
                    core: coreContext
                )
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.anyOf) {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            var schema: JSONSchema = .init(
                warnings: coreContext.warnings,
                schema: .any(
                    of: try container.decode([JSONSchema].self, forKey: .anyOf),
                    core: coreContext
                )
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.oneOf) {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            var schema: JSONSchema = .init(warnings: coreContext.warnings,
                schema: .one(
                    of: try container.decode([JSONSchema].self, forKey: .oneOf),
                    core: coreContext
                )
            )
            if schema.subschemas.contains(where: { $0.nullable }) {
                schema = schema.nullableSchemaObject()
            }

            self = schema
            return
        }

        if container.contains(.not) {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            let schema: JSONSchema = .init(warnings: coreContext.warnings,
                schema: .not(
                    try container.decode(JSONSchema.self, forKey: .not),
                    core: coreContext
                )
            )
            
            self = schema
            return
        }

        let hintContainer = try decoder.container(keyedBy: HintCodingKeys.self)
        let hintContainerCount = hintContainer.allKeys.count
        let typeHints = try Self.decodeTypes(from: hintContainer)

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

        // TODO: probably support properties from multiple types by turning into
        //       a oneOf for each type.
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

        // TODO: support multiple types instead of just grabbing the first one (see TODO immediately above as well)
        let typeHint = typeHints.first

        if let typeHint {
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

        let value: Schema
        if typeHint == .null {
            let coreContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            _warnings += coreContext.warnings
            value = .null(coreContext)

        } else if typeHint == .integer || typeHint == .number || (typeHint == nil && !numericOrIntegerContainer.allKeys.isEmpty) {
            if typeHint == .integer {
                let coreContext = try CoreContext<JSONTypeFormat.IntegerFormat>(from: decoder)
                _warnings += coreContext.warnings
                value = .integer(coreContext,
                                try IntegerContext(from: decoder))
            } else {
                let coreContext = try CoreContext<JSONTypeFormat.NumberFormat>(from: decoder)
                _warnings += coreContext.warnings
                value = .number(coreContext,
                               try NumericContext(from: decoder))
            }

        } else if typeHint == .string || (typeHint == nil && !stringContainer.allKeys.isEmpty) {
            let coreContext = try CoreContext<JSONTypeFormat.StringFormat>(from: decoder)
            _warnings += coreContext.warnings
            value = .string(coreContext,
                           try StringContext(from: decoder))

        } else if typeHint == .array || (typeHint == nil && !arrayContainer.allKeys.isEmpty) {
            let coreContext = try CoreContext<JSONTypeFormat.ArrayFormat>(from: decoder)
            _warnings += coreContext.warnings
            value = .array(coreContext,
                          try ArrayContext(from: decoder))

        } else if typeHint == .object || (typeHint == nil && !objectContainer.allKeys.isEmpty) {
            let coreContext = try CoreContext<JSONTypeFormat.ObjectFormat>(from: decoder)
            _warnings += coreContext.warnings
            value = .object(coreContext,
                           try ObjectContext(from: decoder))

        } else if typeHint == .boolean {
            let coreContext = try CoreContext<JSONTypeFormat.BooleanFormat>(from: decoder)
            _warnings += coreContext.warnings
            value = .boolean(coreContext)

        } else {
            let fragmentContext = try CoreContext<JSONTypeFormat.AnyFormat>(from: decoder)
            _warnings += fragmentContext.warnings
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
        let extensions: [String: AnyCodable]

        guard VendorExtensionsConfiguration.isEnabled else {
            self.value = value
            return
        }

        let decoded = try AnyCodable(from: decoder).value

        guard (decoded as? [Any]) == nil else {
            throw VendorExtensionDecodingError.selfIsArrayNotDict
        }

        guard let decodedAny = decoded as? [String: Any] else {
            throw VendorExtensionDecodingError.foundNonStringKeys
        }

        extensions = decodedAny
            .filter { $0.key.lowercased().starts(with: "x-") }
            .mapValues(AnyCodable.init)

        self.value = value.with(vendorExtensions: extensions)
    }

    private static func decodeTypes(from container: KeyedDecodingContainer<JSONSchema.HintCodingKeys>) throws -> [JSONType] {
        let typeHints = try container.decodeIfPresent(Either<JSONType, [JSONType]>.self, forKey: .type)
        switch typeHints {
        case nil:
            return []
        case .a(let type):
            return [type]
        case .b(let types):
            // filter out null if there are multiple types specified; null is handled by
            // the `nullable` decoding done by the CoreContext.
            return types.filter { $0 != .null }
        }
    }
}

extension JSONSchema: Validatable {}
