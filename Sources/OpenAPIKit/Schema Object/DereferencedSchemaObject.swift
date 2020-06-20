//
//  DereferencedSchemaObject.swift
//  
//
//  Created by Mathew Polzin on 6/17/20.
//

/// A `JSONSchema` type that guarantees none of its
/// nodes are references.
@dynamicMemberLookup
public enum DereferencedJSONSchema: Equatable, JSONSchemaContext {
    public typealias Context<Format: OpenAPIFormat> = JSONSchema.Context<Format>
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
    internal init?(jsonSchema: JSONSchema) {
        switch jsonSchema {
        case .reference:
            return nil
        case .boolean(let context):
            self = .boolean(context)
        case .object(let generalContext, let objectContext):
            guard let objectContext = ObjectContext(objectContext) else { return nil }
            self = .object(generalContext, objectContext)
        case .array(let generalContext, let arrayContext):
            guard let arrayContext = ArrayContext(arrayContext) else { return nil }
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
    internal init(jsonSchema: JSONSchema, resolvingIn components: OpenAPI.Components) throws {
        switch jsonSchema {
        case .reference(let reference):
            self = try DereferencedJSONSchema(jsonSchema: try components.forceDereference(reference), resolvingIn: components)
        case .boolean(let context):
            self = .boolean(context)
        case .object(let generalContext, let objectContext):
            self = try .object(
                generalContext,
                ObjectContext(objectContext, resolvingIn: components)
            )
        case .array(let generalContext, let arrayContext):
            self = try .array(
                generalContext,
                ArrayContext(arrayContext, resolvingIn: components)
            )
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
    public var underlyingJsonSchema: JSONSchema {
        switch self {
        case .boolean(let context):
            return .boolean(context)
        case .object(let generalContext, let objectContext):
            return .object(generalContext, objectContext.jsonSchemaObjectContext)
        case .array(let generalContext, let arrayContext):
            return .array(generalContext, arrayContext.jsonSchemaArrayContext)
        case .number(let generalContext, let numberContext):
            return .number(generalContext, numberContext)
        case .integer(let generalContext, let integerContext):
            return .integer(generalContext, integerContext)
        case .string(let generalContext, let stringContext):
            return .string(generalContext, stringContext)
        case .all(of: let fragments, discriminator: let discriminator):
            return .all(of: fragments, discriminator: discriminator)
        case .one(of: let schemas, discriminator: let discriminator):
            return .one(of: schemas.map { $0.underlyingJsonSchema }, discriminator: discriminator)
        case .any(of: let schemas, discriminator: let discriminator):
            return .any(of: schemas.map { $0.underlyingJsonSchema }, discriminator: discriminator)
        case .not(let schema):
            return .not(schema.underlyingJsonSchema)
        case .undefined(description: let description):
            return .undefined(description: description)
        }
    }

    // automatic forwarding where possible
    public subscript<T>(dynamicMember path: KeyPath<JSONSchema, T>) -> T {
        return underlyingJsonSchema[keyPath: path]
    }

    // See `JSONSchemaContext`
    public var required: Bool { underlyingJsonSchema.required }

    // See `JSONSchemaContext`
    public var nullable: Bool { underlyingJsonSchema.nullable }

    // See `JSONSchemaContext`
    public var title: String? { underlyingJsonSchema.title }

    // See `JSONSchemaContext`
    public var description: String? { underlyingJsonSchema.description }

    // See `JSONSchemaContext`
    public var discriminator: OpenAPI.Discriminator? { underlyingJsonSchema.discriminator }

    // See `JSONSchemaContext`
    public var externalDocs: OpenAPI.ExternalDocumentation? { underlyingJsonSchema.externalDocs }

    // See `JSONSchemaContext`
    public var allowedValues: [AnyCodable]? { underlyingJsonSchema.allowedValues }

    // See `JSONSchemaContext`
    public var example: AnyCodable? { underlyingJsonSchema.example }

    // See `JSONSchemaContext`
    public var readOnly: Bool { underlyingJsonSchema.readOnly }

    // See `JSONSchemaContext`
    public var writeOnly: Bool { underlyingJsonSchema.writeOnly }

    // See `JSONSchemaContext`
    public var deprecated: Bool { underlyingJsonSchema.deprecated }
}

extension DereferencedJSONSchema {
    /// The context that only applies to `.array` schemas.
    public struct ArrayContext: Equatable {
        /// A JSON Type Node that describes
        /// the type of each element in the array.
        public let items: DereferencedJSONSchema?

        /// Maximum number of items in array.
        public let maxItems: Int?

        /// Minimum number of items in array.
        /// Defaults to 0.
        public let minItems: Int

        /// Setting to true indicates all
        /// elements of the array are expected
        /// to be unique. Defaults to false.
        public let uniqueItems: Bool

        internal init?(_ arrayContext: JSONSchema.ArrayContext) {
            if let otherItems = arrayContext.items {
                guard let dereferencedOtherItems = DereferencedJSONSchema.init(jsonSchema: otherItems) else {
                    return nil
                }
                items = dereferencedOtherItems
            } else {
                items = nil
            }

            maxItems = arrayContext.maxItems
            minItems = arrayContext.minItems
            uniqueItems = arrayContext.uniqueItems
        }

        internal init(_ arrayContext: JSONSchema.ArrayContext, resolvingIn components: OpenAPI.Components) throws {
            items = try arrayContext.items.map { try DereferencedJSONSchema(jsonSchema: $0, resolvingIn: components) }
            maxItems = arrayContext.maxItems
            minItems = arrayContext.minItems
            uniqueItems = arrayContext.uniqueItems
        }

        internal var jsonSchemaArrayContext: JSONSchema.ArrayContext {
            .init(
                items: items.map { $0.underlyingJsonSchema },
                maxItems: maxItems,
                minItems: minItems,
                uniqueItems: uniqueItems
            )
        }
    }

    /// The context that only applies to `.object` schemas.
    public struct ObjectContext: Equatable {
        public let maxProperties: Int?
        let _minProperties: Int
        public let properties: [String: DereferencedJSONSchema]
        public let additionalProperties: Either<Bool, DereferencedJSONSchema>?

        // NOTE that an object's required properties
        // array is determined by looking at its properties'
        // required Bool.
        public var requiredProperties: [String] {
            return Array(properties.filter { (_, schemaObject) in
                schemaObject.required
            }.keys)
        }

        public var optionalProperties: [String] {
            return Array(properties.filter { (_, schemaObject) in
                !schemaObject.required
            }.keys)
        }

        /// The minimum number of properties allowed.
        ///
        /// This might constradict a value explicitly specified on initialization
        /// or when decoding if the number of required properties is greater
        /// than the explicitly set minimum.
        public var minProperties: Int {
            return max(_minProperties, requiredProperties.count)
        }

        internal init?(_ objectContext: JSONSchema.ObjectContext) {

            var otherProperties = [String: DereferencedJSONSchema]()
            for (name, property) in objectContext.properties {
                guard let dereferencedProperty = DereferencedJSONSchema(jsonSchema: property) else {
                    return nil
                }
                otherProperties[name] = dereferencedProperty
            }

            properties = otherProperties
            maxProperties = objectContext.maxProperties
            _minProperties = objectContext._minProperties
            switch objectContext.additionalProperties {
            case .a(let bool):
                additionalProperties = .a(bool)
            case .b(let schema):
                guard let schema = DereferencedJSONSchema(jsonSchema: schema) else {
                    return nil
                }
                additionalProperties = .b(schema)
            case nil:
                additionalProperties = nil
            }
        }

        internal init(_ objectContext: JSONSchema.ObjectContext, resolvingIn components: OpenAPI.Components) throws {
            properties = try objectContext.properties.mapValues { try DereferencedJSONSchema(jsonSchema: $0, resolvingIn: components) }
            maxProperties = objectContext.maxProperties
            _minProperties = objectContext._minProperties
            switch objectContext.additionalProperties {
            case .a(let bool):
                additionalProperties = .a(bool)
            case .b(let schema):
                additionalProperties = .b(try DereferencedJSONSchema(jsonSchema: schema, resolvingIn: components))
            case nil:
                additionalProperties = nil
            }
        }

        internal var jsonSchemaObjectContext: JSONSchema.ObjectContext {
            let underlyingAdditionalProperties: Either<Bool, JSONSchema>?
            switch additionalProperties {
            case .a(let bool):
                underlyingAdditionalProperties = .a(bool)
            case .b(let schema):
                underlyingAdditionalProperties = .b(schema.underlyingJsonSchema)
            case nil:
                underlyingAdditionalProperties = nil
            }

            return .init(
                properties: properties.mapValues { $0.underlyingJsonSchema },
                additionalProperties: underlyingAdditionalProperties,
                maxProperties: maxProperties,
                minProperties: minProperties
            )
        }
    }
}
