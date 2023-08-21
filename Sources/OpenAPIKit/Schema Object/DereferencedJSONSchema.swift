//
//  DereferencedJSONSchema.swift
//  
//
//  Created by Mathew Polzin on 6/17/20.
//

import OpenAPIKitCore

/// A `JSONSchema` type that guarantees none of its
/// nodes are references.
@dynamicMemberLookup
public enum DereferencedJSONSchema: Equatable, JSONSchemaContext {
    public typealias CoreContext<Format: OpenAPIFormat> = JSONSchema.CoreContext<Format>
    public typealias NumericContext = JSONSchema.NumericContext
    public typealias IntegerContext = JSONSchema.IntegerContext
    public typealias StringContext = JSONSchema.StringContext

    case null
    case boolean(CoreContext<JSONTypeFormat.BooleanFormat>)
    case number(CoreContext<JSONTypeFormat.NumberFormat>, NumericContext)
    case integer(CoreContext<JSONTypeFormat.IntegerFormat>, IntegerContext)
    case string(CoreContext<JSONTypeFormat.StringFormat>, StringContext)
    indirect case object(CoreContext<JSONTypeFormat.ObjectFormat>, ObjectContext)
    indirect case array(CoreContext<JSONTypeFormat.ArrayFormat>, ArrayContext)
    indirect case all(of: [DereferencedJSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
    indirect case one(of: [DereferencedJSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
    indirect case any(of: [DereferencedJSONSchema], core: CoreContext<JSONTypeFormat.AnyFormat>)
    indirect case not(DereferencedJSONSchema, core: CoreContext<JSONTypeFormat.AnyFormat>)
    /// Schemas without a `type`.
    case fragment(CoreContext<JSONTypeFormat.AnyFormat>) // This is the "{}" case where not even a type constraint is given.

    /// Get the JSONSchema representation of this
    /// dereferenced schema.
    ///
    /// This will not necessarily be the same schema that
    /// was used to create this dereferenced schema if
    /// there was one.
    ///
    /// It is always possible to represent a
    /// `DereferencedJSONSchema` as a
    /// `JSONSchema`, although the reverse is
    /// not true.
    public var jsonSchema: JSONSchema {
        switch self {
        case .null:
            return .null
        case .boolean(let context):
            return .boolean(context)
        case .object(let coreContext, let objectContext):
            return .object(coreContext, objectContext.jsonSchemaObjectContext)
        case .array(let coreContext, let arrayContext):
            return .array(coreContext, arrayContext.jsonSchemaArrayContext)
        case .number(let coreContext, let numberContext):
            return .number(coreContext, numberContext)
        case .integer(let coreContext, let integerContext):
            return .integer(coreContext, integerContext)
        case .string(let coreContext, let stringContext):
            return .string(coreContext, stringContext)
        case .all(of: let schemas, core: let coreContext):
            return .all(of: schemas.map { $0.jsonSchema }, core: coreContext)
        case .one(of: let schemas, core: let coreContext):
            return .one(of: schemas.map { $0.jsonSchema }, core: coreContext)
        case .any(of: let schemas, core: let coreContext):
            return .any(of: schemas.map { $0.jsonSchema }, core: coreContext)
        case .not(let schema, core: let coreContext):
            return .not(schema.jsonSchema, core: coreContext)
        case .fragment(let context):
            return .fragment(context)
        }
    }

    func optionalSchemaObject() -> DereferencedJSONSchema {
        switch self {
        case .null:
            return .null
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
        case .fragment(let context):
            return .fragment(context.optionalContext())
        case .all(of: let fragments, core: let core):
            return .all(of: fragments, core: core.optionalContext())
        case .one(of: let schemas, core: let core):
            return .one(of: schemas, core: core.optionalContext())
        case .any(of: let schemas, core: let core):
            return .any(of: schemas, core: core.optionalContext())
        case .not(let schema, core: let core):
            return .not(schema, core: core.optionalContext())
        }
    }

    // automatic forwarding where possible
    public subscript<T>(dynamicMember path: KeyPath<JSONSchema, T>) -> T {
        return jsonSchema[keyPath: path]
    }

    // See `JSONSchemaContext`
    public var formatString: String? { jsonSchema.formatString }

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
    public var defaultValue: AnyCodable? { jsonSchema.defaultValue }

    // See `JSONSchemaContext`
    public var examples: [AnyCodable] { jsonSchema.examples }

    // See `JSONSchemaContext`
    public var readOnly: Bool { jsonSchema.readOnly }

    // See `JSONSchemaContext`
    public var writeOnly: Bool { jsonSchema.writeOnly }

    // See `JSONSchemaContext`
    public var deprecated: Bool { jsonSchema.deprecated }
}

extension DereferencedJSONSchema {
    /// Get the context specific to an `object` schema. If not an
    /// object schema, returns `nil`.
    public var objectContext: ObjectContext? {
        guard case .object(_, let context) = self else {
            return nil
        }
        return context
    }

    /// Get the context specific to an `array` schema. If not an
    /// array schema, returns `nil`.
    public var arrayContext: ArrayContext? {
        guard case .array(_, let context) = self else {
            return nil
        }
        return context
    }

    /// The context that only applies to `.array` schemas.
    public struct ArrayContext: Equatable {
        /// A JSON Type Node that describes
        /// the type of each element in the array.
        public let items: DereferencedJSONSchema?

        /// Maximum number of items in array.
        public let maxItems: Int?

        let _minItems: Int?
        /// Minimum number of items in array.
        /// Defaults to 0.
        public var minItems: Int { _minItems ?? 0 }

        let _uniqueItems: Bool?
        /// Setting to true indicates all
        /// elements of the array are expected
        /// to be unique. Defaults to false.
        public var uniqueItems: Bool { _uniqueItems ?? false }

        public init?(_ arrayContext: JSONSchema.ArrayContext) {
            if let otherItems = arrayContext.items {
                guard let dereferencedOtherItems = otherItems.dereferenced() else {
                    return nil
                }
                items = dereferencedOtherItems
            } else {
                items = nil
            }

            maxItems = arrayContext.maxItems
            _minItems = arrayContext._minItems
            _uniqueItems = arrayContext._uniqueItems
        }

        internal init(
            _ arrayContext: JSONSchema.ArrayContext,
            resolvingIn components: OpenAPI.Components,
            following references: Set<AnyHashable>
        ) throws {
            items = try arrayContext.items.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            maxItems = arrayContext.maxItems
            _minItems = arrayContext._minItems
            _uniqueItems = arrayContext._uniqueItems
        }

        internal init(
            items: DereferencedJSONSchema? = nil,
            maxItems: Int? = nil,
            minItems: Int? = nil,
            uniqueItems: Bool? = nil
        ) {
            self.items = items
            self.maxItems = maxItems
            self._minItems = minItems
            self._uniqueItems = uniqueItems
        }

        internal var jsonSchemaArrayContext: JSONSchema.ArrayContext {
            .init(
                items: items.map { $0.jsonSchema },
                maxItems: maxItems,
                minItems: _minItems,
                uniqueItems: _uniqueItems
            )
        }
    }

    /// The context that only applies to `.object` schemas.
    public struct ObjectContext: Equatable {
        public let maxProperties: Int?
        let _minProperties: Int?
        public let properties: OrderedDictionary<String, DereferencedJSONSchema>
        public let additionalProperties: Either<Bool, DereferencedJSONSchema>?

        // NOTE that an object's required properties
        // array is determined by looking at its properties'
        // required Bool.
        public var requiredProperties: [String] {
            properties.filter { _, schema in schema.required }.map { $0.key }
        }

        public var optionalProperties: [String] {
            properties.filter { _, schema in !schema.required }.map { $0.key }
        }

        /// The minimum number of properties allowed.
        ///
        /// This might constradict a value explicitly specified on initialization
        /// or when decoding if the number of required properties is greater
        /// than the explicitly set minimum.
        public var minProperties: Int {
            return max(_minProperties ?? 0, requiredProperties.count)
        }

        public init?(_ objectContext: JSONSchema.ObjectContext) {

            var otherProperties = OrderedDictionary<String, DereferencedJSONSchema>()
            for (name, property) in objectContext.properties {
                guard let dereferencedProperty = property.dereferenced() else {
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
                guard let schema = schema.dereferenced() else {
                    return nil
                }
                additionalProperties = .b(schema)
            case nil:
                additionalProperties = nil
            }
        }

        internal init(
            _ objectContext: JSONSchema.ObjectContext,
            resolvingIn components: OpenAPI.Components,
            following references: Set<AnyHashable>
        ) throws {
            properties = try objectContext.properties.mapValues { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            maxProperties = objectContext.maxProperties
            _minProperties = objectContext._minProperties
            switch objectContext.additionalProperties {
            case .a(let bool):
                additionalProperties = .a(bool)
            case .b(let schema):
                additionalProperties = .b(try schema._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil))
            case nil:
                additionalProperties = nil
            }
        }

        internal init(
            properties: OrderedDictionary<String, DereferencedJSONSchema>,
            additionalProperties: Either<Bool, DereferencedJSONSchema>? = nil,
            maxProperties: Int? = nil,
            minProperties: Int? = nil
        ) {
            self.properties = properties
            self.additionalProperties = additionalProperties
            self.maxProperties = maxProperties
            self._minProperties = minProperties
        }

        internal var jsonSchemaObjectContext: JSONSchema.ObjectContext {
            let underlyingAdditionalProperties: Either<Bool, JSONSchema>?
            switch additionalProperties {
            case .a(let bool):
                underlyingAdditionalProperties = .a(bool)
            case .b(let schema):
                underlyingAdditionalProperties = .b(schema.jsonSchema)
            case nil:
                underlyingAdditionalProperties = nil
            }

            return .init(
                properties: properties.mapValues { $0.jsonSchema },
                additionalProperties: underlyingAdditionalProperties,
                maxProperties: maxProperties,
                minProperties: _minProperties
            )
        }
    }
}

extension JSONSchema: LocallyDereferenceable {

    /// Returns a dereferenced schema object if all references in
    /// this schema object can be found in the Components Object.
    ///
    /// `_dereferenced(in:following:)` is meant for internal use
    /// but this type gets a public-facing `dereferenced(in:)` function
    /// for free from the `LocallyDereferenceable` protocol. For all
    /// external uses, call `dereferenced(in:)`.
    ///
    /// - Important: Local dereferencing will `throw` if any
    ///     `JSONReferences` point to other files or to
    ///     locations within the same file other than the
    ///     Components Object. It will also fail if any components
    ///     are missing from the Components Object.
    ///
    /// - Throws: `ReferenceError.cannotLookupRemoteReference` or
    ///     `ReferenceError.missingOnLookup(name:key:)` depending
    ///     on whether an unresolvable reference points to another file or just points to a
    ///     component in the same file that cannot be found in the Components Object.
    public func _dereferenced(
        in components: OpenAPI.Components,
        following references: Set<AnyHashable>,
        dereferencedFromComponentNamed name: String?
    ) throws -> DereferencedJSONSchema {
        switch value {
        case .null:
            return .null
        case .reference(let reference, let context):
            var dereferenced = try reference._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil)
            if !context.required {
                dereferenced = dereferenced.optionalSchemaObject()
            }
            return dereferenced
        case .boolean(let context):
            return .boolean(context)
        case .object(let coreContext, let objectContext):
            return try .object(
                coreContext,
                DereferencedJSONSchema.ObjectContext(objectContext, resolvingIn: components, following: references)
            )
        case .array(let coreContext, let arrayContext):
            return try .array(
                coreContext,
                DereferencedJSONSchema.ArrayContext(arrayContext, resolvingIn: components, following: references)
            )
        case .number(let coreContext, let numberContext):
            return .number(coreContext, numberContext)
        case .integer(let coreContext, let integerContext):
            return .integer(coreContext, integerContext)
        case .string(let coreContext, let stringContext):
            return .string(coreContext, stringContext)
        case .all(of: let jsonSchemas, core: let coreContext):
            let schemas = try jsonSchemas.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            return .all(of: schemas, core: coreContext)
        case .one(of: let jsonSchemas, core: let coreContext):
            let schemas = try jsonSchemas.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            return .one(of: schemas, core: coreContext)
        case .any(of: let jsonSchemas, core: let coreContext):
            let schemas = try jsonSchemas.map { try $0._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil) }
            return .any(of: schemas, core: coreContext)
        case .not(let jsonSchema, core: let coreContext):
            return .not(try jsonSchema._dereferenced(in: components, following: references, dereferencedFromComponentNamed: nil), core: coreContext)
        case .fragment(let context):
            return .fragment(context)
        }
    }

    /// Returns a dereferenced schema object if this schema object
    /// already does not contain any references.
    ///
    /// To create a dereferenced schema object from a schema object
    /// that does have references, use `dereferenced(in:)`.
    public func dereferenced() -> DereferencedJSONSchema? {
        return try? dereferenced(in: .noComponents)
    }
}
