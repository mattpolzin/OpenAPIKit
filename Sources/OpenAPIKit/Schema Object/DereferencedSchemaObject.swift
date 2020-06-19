//
//  DereferencedSchemaObject.swift
//  
//
//  Created by Mathew Polzin on 6/17/20.
//

@dynamicMemberLookup
public enum DereferencedJSONSchema: Equatable, JSONSchemaContext {
    public typealias Context<Format: OpenAPIFormat> = JSONSchema.Context<Format>
    public typealias ObjectContext = JSONSchema.ObjectContext
    public typealias ArrayContext = JSONSchema.ArrayContext
    public typealias NumericContext = JSONSchema.NumericContext
    public typealias IntegerContext = JSONSchema.IntegerContext
    public typealias StringContext = JSONSchema.StringContext

    case boolean(Context<JSONTypeFormat.BooleanFormat>)
    indirect case object(Context<JSONTypeFormat.ObjectFormat>, ObjectContext)
    indirect case array(Context<JSONTypeFormat.ArrayFormat>, ArrayContext)
    case number(Context<JSONTypeFormat.NumberFormat>, NumericContext)
    case integer(Context<JSONTypeFormat.IntegerFormat>, IntegerContext)
    case string(Context<JSONTypeFormat.StringFormat>, StringContext)
    indirect case all(of: [JSONSchemaFragment], discriminator: OpenAPI.Discriminator?)
    indirect case one(of: [DereferencedJSONSchema], discriminator: OpenAPI.Discriminator?)
    indirect case any(of: [DereferencedJSONSchema], discriminator: OpenAPI.Discriminator?)
    indirect case not(DereferencedJSONSchema)
    /// This schema does not have a `type` specified. This is allowed
    /// but does not offer much in the way of documenting the schema
    /// so it is represented here as "undefined" with an optional
    /// description.
    case undefined(description: String?) // This is the "{}" case where not even a type constraint is given. If a 'description' property is found, it is used as the associated value.

    /// Create a `DereferencedJSONSchema` if possible.
    ///
    /// If the `JSONSchema` passed to this initializer has any `references`
    /// this initializer will return `nil`.
    ///
    /// Use the `init(jsonSchema:resolvingIn:)` initializer to resolve
    /// references to schemas in the Components Object when possible.
    public init?(jsonSchema: JSONSchema) {
        switch jsonSchema {
        case .reference:
            return nil
        case .boolean(let context):
            self = .boolean(context)
        case .object(let generalContext, let objectContext):
            self = .object(generalContext, objectContext)
        case .array(let generalContext, let arrayContext):
            self = .array(generalContext, arrayContext)
        case .number(let generalContext, let numberContext):
            self = .number(generalContext, numberContext)
        case .integer(let generalContext, let integerContext):
            self = .integer(generalContext, integerContext)
        case .string(let generalContext, let stringContext):
            self = .string(generalContext, stringContext)
        case .all(of: let fragments, discriminator: let discriminator):
            self = .all(of: fragments, discriminator: discriminator)
        case .one(of: let jsonSchemas, discriminator: let discriminator):
            let schemas = jsonSchemas.compactMap(DereferencedJSONSchema.init(jsonSchema:))
            guard schemas.count == jsonSchemas.count else { return nil }
            self = .one(of: schemas, discriminator: discriminator)
        case .any(of: let jsonSchemas, discriminator: let discriminator):
            let schemas = jsonSchemas.compactMap(DereferencedJSONSchema.init(jsonSchema:))
            guard schemas.count == jsonSchemas.count else { return nil }
            self = .any(of: schemas, discriminator: discriminator)
        case .not(let jsonSchema):
            guard let schema = DereferencedJSONSchema(jsonSchema: jsonSchema) else { return nil }
            self = .not(schema)
        case .undefined(description: let description):
            self = .undefined(description: description)
        }
    }

    /// Create a `DereferencedJSONSchema` if all references in the
    /// schema can be found in the given Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `MissingReferenceError.referenceMissingOnLookup(name:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public init(jsonSchema: JSONSchema, resolvingIn components: OpenAPI.Components) throws {
        switch jsonSchema {
        case .reference(let reference):
            self = try DereferencedJSONSchema(jsonSchema: try components.forceDereference(reference), resolvingIn: components)
        case .boolean(let context):
            self = .boolean(context)
        case .object(let generalContext, let objectContext):
            self = .object(generalContext, objectContext)
        case .array(let generalContext, let arrayContext):
            self = .array(generalContext, arrayContext)
        case .number(let generalContext, let numberContext):
            self = .number(generalContext, numberContext)
        case .integer(let generalContext, let integerContext):
            self = .integer(generalContext, integerContext)
        case .string(let generalContext, let stringContext):
            self = .string(generalContext, stringContext)
        case .all(of: let fragments, discriminator: let discriminator):
            self = .all(of: fragments, discriminator: discriminator)
        case .one(of: let jsonSchemas, discriminator: let discriminator):
            let schemas = try jsonSchemas.map { try DereferencedJSONSchema.init(jsonSchema: $0, resolvingIn: components) }
            self = .one(of: schemas, discriminator: discriminator)
        case .any(of: let jsonSchemas, discriminator: let discriminator):
            let schemas = try jsonSchemas.map { try DereferencedJSONSchema.init(jsonSchema: $0, resolvingIn: components) }
            self = .any(of: schemas, discriminator: discriminator)
        case .not(let jsonSchema):
            self = .not(try DereferencedJSONSchema(jsonSchema: jsonSchema, resolvingIn: components))
        case .undefined(description: let description):
            self = .undefined(description: description)
        }
    }

    /// Get the JSONSchema representation of this
    /// dereferenced schema.
    ///
    /// It is always possible to represent a
    /// `DereferencedJSONSchema` as a
    /// `JSONSchema`, although the reverse is
    /// not true.
    public var jsonSchema: JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context)
        case .object(let generalContext, let objectContext):
            return .object(generalContext, objectContext)
        case .array(let generalContext, let arrayContext):
            return .array(generalContext, arrayContext)
        case .number(let generalContext, let numberContext):
            return .number(generalContext, numberContext)
        case .integer(let generalContext, let integerContext):
            return .integer(generalContext, integerContext)
        case .string(let generalContext, let stringContext):
            return .string(generalContext, stringContext)
        case .all(of: let fragments, discriminator: let discriminator):
            return .all(of: fragments, discriminator: discriminator)
        case .one(of: let schemas, discriminator: let discriminator):
            return .one(of: schemas.map { $0.jsonSchema }, discriminator: discriminator)
        case .any(of: let schemas, discriminator: let discriminator):
            return .any(of: schemas.map { $0.jsonSchema }, discriminator: discriminator)
        case .not(let schema):
            return .not(schema.jsonSchema)
        case .undefined(description: let description):
            return .undefined(description: description)
        }
    }

    // automatic forwarding where possible
    public subscript<T>(dynamicMember path: KeyPath<JSONSchema, T>) -> T {
        return jsonSchema[keyPath: path]
    }

    // See `JSONSchemaContext`
    public var required: Bool { jsonSchema.required }

    // See `JSONSchemaContext`
    public var nullable: Bool { jsonSchema.nullable }

    // See `JSONSchemaContext`
    public var title: String? { jsonSchema.title }

    // See `JSONSchemaContext`
    public var description: String? { jsonSchema.description }

    // See `JSONSchemaContext`
    public var discriminator: OpenAPI.Discriminator? { jsonSchema.discriminator }

    // See `JSONSchemaContext`
    public var externalDocs: OpenAPI.ExternalDocumentation? { jsonSchema.externalDocs }

    // See `JSONSchemaContext`
    public var allowedValues: [AnyCodable]? { jsonSchema.allowedValues }

    // See `JSONSchemaContext`
    public var example: AnyCodable? { jsonSchema.example }

    // See `JSONSchemaContext`
    public var readOnly: Bool { jsonSchema.readOnly }

    // See `JSONSchemaContext`
    public var writeOnly: Bool { jsonSchema.writeOnly }

    // See `JSONSchemaContext`
    public var deprecated: Bool { jsonSchema.deprecated }
}
