//
//  JSONSchema+Combining.swift
//  
//
//  Created by Mathew Polzin on 8/1/20.
//

import OpenAPIKitCore

extension Array where Element == JSONSchema {
    /// An array of schema fragments can be combined into a
    /// single `DereferencedJSONSchema` if all references can
    /// be looked up locally and none of the fragments conflict.
    ///
    /// Combining fragments will both remove references and attempt
    /// to reject any results that would represent impossible schemas
    /// -- that is, schemas that cannot be satisfied and could not ever
    /// be used to validate anything (guaranteed validation failure).
    public func combined(resolvingAgainst components: OpenAPI.Components) throws -> DereferencedJSONSchema {
        var resolver = FragmentCombiner(components: components)
        try resolver.combine(self)
        return try resolver.dereferencedSchema()
    }
}

public struct JSONSchemaResolutionError: Swift.Error, CustomStringConvertible {
    internal let underlyingError: _JSONSchemaResolutionError

    internal init(_ underlyingError: _JSONSchemaResolutionError) {
        self.underlyingError = underlyingError
    }

    public var description: String {
        String(describing: underlyingError)
    }

    // The following can be used for pattern matching but are not good
    // errors for totally lacking any context:
    public static let unsupported: JSONSchemaResolutionError = .init(.unsupported(because: ""))
    public static let typeConflict: JSONSchemaResolutionError = .init(.typeConflict(original: .string, new: .string))
    public static let formatConflict: JSONSchemaResolutionError = .init(.formatConflict(original: "", new: ""))
    public static let attributeConflict: JSONSchemaResolutionError = .init(.attributeConflict(jsonType: nil, name: "", original: "", new: ""))
    public static let inconsistency: JSONSchemaResolutionError = .init(.inconsistency(""))
}

public func ~=(lhs: JSONSchemaResolutionError, rhs: JSONSchemaResolutionError) -> Bool {
    switch (lhs.underlyingError, rhs.underlyingError) {
    case (.unsupported, .unsupported),
         (.typeConflict, .typeConflict),
         (.formatConflict, .formatConflict),
         (.attributeConflict, .attributeConflict),
         (.inconsistency, .inconsistency):
        return true
    default:
        return false
    }
}

/// Just an internal error enum to ensure I have all errors covered but
/// also allow adding cases without being a breaking change.
///
/// I expect this to be an area where I may want to make fixes and add
/// errors without breaknig changes, so this annoying workaround for
/// the absense of a "non-frozen" enum is a must.
internal enum _JSONSchemaResolutionError: CustomStringConvertible, Equatable {
    case unsupported(because: String)
    case typeConflict(original: JSONType, new: JSONType)
    case formatConflict(original: String, new: String)
    case attributeConflict(jsonType: JSONType?, name: String, original: String, new: String)

    case inconsistency(String)

    var description: String {
        switch self {
        case .unsupported(because: let reason):
            return "The given schema does not yet support combining in OpenAPIKit because \(reason)."
        case .typeConflict(original: let original, new: let new):
            return "Found conflicting schema types. A schema cannot be both \(original.rawValue) and \(new.rawValue)."
        case .formatConflict(original: let original, new: let new):
            return "Found conflicting formats. A schema cannot be both \(original) and \(new)."
        case .attributeConflict(jsonType: let jsonType, name: let name, original: let original, new: let new):
            let contextString = jsonType?.rawValue ?? "A schema"
            return "Found conflicting properties. \(contextString) cannot have \(name) with both \(original) and \(new) values."
        case .inconsistency(let description):
            return "Found inconsistency: \(description)."
        }
    }
}

/// The FragmentCombiner takes any number of fragments and determines if they can be
/// meaningfully combined.
///
/// Conflicts will be determined as fragments are added and when you ask for
/// a `dereferencedSchema()` the fragment resolver will determine if it has enough information
/// to build and dereference the schema.
///
/// Current Limitations (will throw `.unsupported` for these reasons):
/// - Does not handle inversion via `not` or combination via `any`, `one`, `all`.
internal struct FragmentCombiner {
    private let components: OpenAPI.Components
    private var combinedFragment: JSONSchema?

    /// Set up for constructing a schema using the given Components Object. Call `combine(_:)`
    /// to start adding schema fragments to the partial schema definition.
    ///
    /// Once all fragments have been combined, call `dereferencedSchema` to attempt to build a `DereferencedJSONSchema`.
    init(components: OpenAPI.Components) {
        self.components = components
    }

    /// Combine the existing partial schema with the given fragment.
    ///
    /// - Throws: If any fragments combined together would result in an invalid schema or
    ///     if there is not enough information in the fragments to build a complete schema.
    mutating func combine(_ fragment: JSONSchema) throws {

        let combinedFragment: JSONSchema
        if let currentFragment = self.combinedFragment {
            combinedFragment = currentFragment
        } else {
            // combination can turn `required: false` into `required: true`
            // but not the other way around. We start optional and the first
            // time we combine with something required we become required.
            combinedFragment = .fragment(.init(required: false))
        }

        // make sure any less specialized fragment (i.e. general) is on the left
        let lessSpecializedFragment: JSONSchema
        let equallyOrMoreSpecializedFragment: JSONSchema
        switch (combinedFragment.value, fragment.value) {
        case (.fragment, _):
            lessSpecializedFragment = combinedFragment
            equallyOrMoreSpecializedFragment = fragment
         default:
            lessSpecializedFragment = fragment
            equallyOrMoreSpecializedFragment = combinedFragment
        }

        switch (lessSpecializedFragment.value, equallyOrMoreSpecializedFragment.value) {
        case (.all(let schemas, core: let core), let other), (let other, .all(let schemas, core: let core)):
            // tease apart one allOf if there is one and continue from there.
            try self.combine(schemas + [.fragment(core), JSONSchema(schema: other)])

        case (_, .reference(let reference, let context)), (.reference(let reference, let context), _):
            var component = try components.lookup(reference)
            if !context.required {
                component = component.optionalSchemaObject()
            }
            try combine(component)

        case (.fragment(let leftCoreContext), .fragment(let rightCoreContext)):
            self.combinedFragment = .fragment(try leftCoreContext.combined(with: rightCoreContext))
        case (.fragment(let leftCoreContext), .boolean(let rightCoreContext)):
            self.combinedFragment = .boolean(try leftCoreContext.combined(with: rightCoreContext))
        case (.fragment(let leftCoreContext), .integer(let rightCoreContext, let integerContext)):
            self.combinedFragment = .integer(try leftCoreContext.combined(with: rightCoreContext), integerContext)
        case (.fragment(let leftCoreContext), .number(let rightCoreContext, let numericContext)):
            self.combinedFragment = .number(try leftCoreContext.combined(with: rightCoreContext), numericContext)
        case (.fragment(let leftCoreContext), .string(let rightCoreContext, let stringContext)):
            self.combinedFragment = .string(try leftCoreContext.combined(with: rightCoreContext), stringContext)
        case (.fragment(let leftCoreContext), .array(let rightCoreContext, let arrayContext)):
            self.combinedFragment = .array(try leftCoreContext.combined(with: rightCoreContext), arrayContext)
        case (.fragment(let leftCoreContext), .object(let rightCoreContext, let objectContext)):
            self.combinedFragment = .object(try leftCoreContext.combined(with: rightCoreContext), objectContext)
        case (.boolean(let leftCoreContext), .boolean(let rightCoreContext)):
            self.combinedFragment = .boolean(try leftCoreContext.combined(with: rightCoreContext))
        case (.integer(let leftCoreContext, let leftIntegerContext), .integer(let rightCoreContext, let rightIntegerContext)):
            self.combinedFragment = .integer(try leftCoreContext.combined(with: rightCoreContext), try leftIntegerContext.combined(with: rightIntegerContext))
        case (.number(let leftCoreContext, let leftNumericContext), .number(let rightCoreContext, let rightNumericContext)):
            self.combinedFragment = .number(try leftCoreContext.combined(with: rightCoreContext), try leftNumericContext.combined(with: rightNumericContext))
        case (.string(let leftCoreContext, let leftStringContext), .string(let rightCoreContext, let rightStringContext)):
            self.combinedFragment = .string(try leftCoreContext.combined(with: rightCoreContext), try leftStringContext.combined(with: rightStringContext))
        case (.array(let leftCoreContext, let leftArrayContext), .array(let rightCoreContext, let rightArrayContext)):
            self.combinedFragment = .array(try leftCoreContext.combined(with: rightCoreContext), try leftArrayContext.combined(with: rightArrayContext))
        case (.object(let leftCoreContext, let leftObjectContext), .object(let rightCoreContext, let rightObjectContext)):
            self.combinedFragment = .object(try leftCoreContext.combined(with: rightCoreContext), try leftObjectContext.combined(with: rightObjectContext, resolvingIn: components))

        case (_, .any), (.any, _), (_, .not), (.not, _), (_, .one), (.one, _):
            throw JSONSchemaResolutionError(.unsupported(because: "not, any(of:), and one(of:) are not yet supported for schema resolution"))
        case (.boolean, _),
             (.integer, _),
             (.number, _),
             (.string, _),
             (.array, _),
             (.object, _):
            throw (
                zip(combinedFragment.jsonType, fragment.jsonType).map {
                    JSONSchemaResolutionError(.typeConflict(original: $0, new: $1))
                } ?? JSONSchemaResolutionError(
                    .unsupported(because: "Encountered an unexpected problem with schema fragments of types \(String(describing: combinedFragment.jsonType)) and \(String(describing: fragment.jsonType))")
                )
            )
        }
    }

    /// Combine the existing partial schema with the given fragments.
    ///
    /// - Throws: If any fragments combined together would result in an invalid schema or
    ///     if there is not enough information in the fragments to build a complete schema.
    mutating func combine(_ fragments: [JSONSchema]) throws {
        for fragment in fragments {
            try combine(fragment)
        }
    }

    func dereferencedSchema() throws -> DereferencedJSONSchema {
        guard let combinedFragment = self.combinedFragment else {
            // just give the more bare-bones schema possible if nothing
            // has been combined yet. This schema is `{ }` (empty).
            return .fragment(.init())
        }

        let jsonSchema: JSONSchema
        switch combinedFragment.value {
        case .fragment, .reference:
            jsonSchema = combinedFragment
        case .boolean(let coreContext):
            jsonSchema = .boolean(try coreContext.validatedContext())
        case .integer(let coreContext, let integerContext):
            jsonSchema = .integer(try coreContext.validatedContext(), try integerContext.validatedContext())
        case .number(let coreContext, let numericContext):
            jsonSchema = .number(try coreContext.validatedContext(), try numericContext.validatedContext())
        case .string(let coreContext, let stringContext):
            jsonSchema = .string(try coreContext.validatedContext(), try stringContext.validatedContext())
        case .array(let coreContext, let arrayContext):
            jsonSchema = .array(try coreContext.validatedContext(), try arrayContext.validatedContext())
        case .object(let coreContext, let objectContext):
            jsonSchema = .object(try coreContext.validatedContext(), try objectContext.validatedContext())
        case .all(of: let schemas, core: let coreContext):
            jsonSchema = try .all(of: schemas, core: coreContext.validatedContext())
        case .any(of: let schemas, core: let coreContext):
            jsonSchema = try .any(of: schemas, core: coreContext.validatedContext())
        case .one(of: let schemas, core: let coreContext):
            jsonSchema = try .one(of: schemas, core: coreContext.validatedContext())
        case .not:
            throw JSONSchemaResolutionError(.unsupported(because: "`.not` is not yet supported for schema simplification"))
        }
        return try jsonSchema.simplified(given: components)
    }
}

// MARK: - Combining Fragments

internal func conflicting<T>(_ left: T?, _ right: T?) -> (T, T)? where T: Equatable {
    return zip(left, right).flatMap { $0 == $1 ? nil : ($0, $1) }
}

extension JSONSchema.CoreContext where Format == JSONTypeFormat.AnyFormat {
    /// Go from less specialized to more specialized while combining.
    internal func combined<OtherFormat: OpenAPIFormat>(
        with other: JSONSchema.CoreContext<OtherFormat>
    ) throws -> JSONSchema.CoreContext<OtherFormat> {
        guard let newFormat = OtherFormat(rawValue: format.rawValue) else {
            throw JSONSchemaResolutionError(.inconsistency("A given format (\(format.rawValue) cannot be applied to the format type: \(OtherFormat.self)"))
        }

        typealias OtherContext = JSONSchema.CoreContext<OtherFormat>

        let transformedContext = OtherContext(
            format: newFormat,
            required: required,
            nullable: _nullable,
            permissions: _permissions.map(OtherContext.Permissions.init),
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
        return try transformedContext.combined(with: other)
    }
}

extension JSONSchema.CoreContext {
    internal func combined(with other: Self) throws -> Self {
        let newFormat = try format.combined(with: other.format)

        if let conflict = conflicting(description, other.description) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "description", original: conflict.0, new: conflict.1))
        }
        let newDescription = description ?? other.description

        if let conflict = conflicting(_permissions, other._permissions) {
            throw JSONSchemaResolutionError(.inconsistency("A schema cannot be both \(conflict.0.rawValue) and \(conflict.1.rawValue)."))
        }
        let newPermissions: JSONSchema.CoreContext<Format>.Permissions?
        if _permissions == nil && other._permissions == nil {
            newPermissions = nil
        } else {
            switch (_permissions, other._permissions) {
            case (.readOnly, .writeOnly), (.writeOnly, .readOnly):
                throw JSONSchemaResolutionError(.inconsistency("Schemas cannot be read-only and write-only"))
            case (.readOnly, .readOnly), (nil, .readOnly), (.readOnly, nil):
                newPermissions = .readOnly
            case (.writeOnly, .writeOnly), (nil, .writeOnly), (.writeOnly, nil):
                newPermissions = .writeOnly
            default:
                newPermissions = .readWrite
            }
        }

        if let conflict = conflicting(discriminator, other.discriminator) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "discriminator", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        let newDiscriminator = discriminator ?? other.discriminator

        if let conflict = conflicting(title, other.title) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "title", original: conflict.0, new: conflict.1))
        }
        let newTitle = title ?? other.title

        if let conflict = conflicting(_nullable, other._nullable) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "nullable", original: String(conflict.0), new: String(conflict.1)))
        }
        let newNullable = _nullable ?? other._nullable

        if let conflict = conflicting(_deprecated, other._deprecated) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "deprecated", original: String(conflict.0), new: String(conflict.1)))
        }
        let newDeprecated = _deprecated ?? other._deprecated

        if let conflict = conflicting(externalDocs, other.externalDocs) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "externalDocs", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        let newExternalDocs = externalDocs ?? other.externalDocs

        if let conflict = conflicting(allowedValues, other.allowedValues) {
            throw JSONSchemaResolutionError(
                .attributeConflict(
                    jsonType: nil,
                    name: "allowedValues",
                    original: conflict.0.map(String.init(describing:)).joined(separator: ", "),
                    new: conflict.1.map(String.init(describing:)).joined(separator: ", ")
                )
            )
        }
        let newAllowedValues = allowedValues ?? other.allowedValues
        let newDefaultValue = defaultValue ?? other.defaultValue

        if let conflict = conflicting(example, other.example) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "example", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        let newExample = example ?? other.example

        let newRequired = required || other.required
        return .init(
            format: newFormat,
            required: newRequired,
            nullable: newNullable,
            permissions: newPermissions,
            deprecated: newDeprecated,
            title: newTitle,
            description: newDescription,
            discriminator: newDiscriminator,
            externalDocs: newExternalDocs,
            allowedValues: newAllowedValues,
            defaultValue: newDefaultValue,
            example: newExample
        )
    }
}

extension OpenAPIFormat {
    internal func combined(with other: Self) throws -> Self {
        switch (self, other) {
        case (.unspecified, .unspecified):
            return .unspecified
        case (.unspecified, _):
            return other
        case (_, .unspecified):
            return self
        default:
            if let conflict = conflicting(self, other) {
                throw JSONSchemaResolutionError(.formatConflict(original: conflict.0.rawValue, new: conflict.1.rawValue))
            } else {
                return self
            }
        }
    }
}

extension JSONSchema.IntegerContext {
    internal func combined(with other: JSONSchema.IntegerContext) throws -> JSONSchema.IntegerContext {
        if let conflict = conflicting(multipleOf, other.multipleOf) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "multipleOf", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum?.value, other.maximum?.value) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "maximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum?.exclusive, other.maximum?.exclusive) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "exclusiveMaximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum?.value, other.minimum?.value) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "minimum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum?.exclusive, other.minimum?.exclusive) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "exclusiveMinimum", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMultipleOf = multipleOf ?? other.multipleOf
        let newMaximum = maximum ?? other.maximum
        let newMinimum = minimum ?? other.minimum
        return .init(
            multipleOf: newMultipleOf,
            maximum: newMaximum,
            minimum: newMinimum
        )
    }
}

extension JSONSchema.NumericContext {
    internal func combined(with other: JSONSchema.NumericContext) throws -> JSONSchema.NumericContext {
        if let conflict = conflicting(multipleOf, other.multipleOf) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "multipleOf", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum?.value, other.maximum?.value) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "maximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum?.exclusive, other.maximum?.exclusive) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "exclusiveMaximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum?.value, other.minimum?.value) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "minimum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum?.exclusive, other.minimum?.exclusive) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "exclusiveMinimum", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMultipleOf = multipleOf ?? other.multipleOf
        let newMaximum = maximum ?? other.maximum
        let newMinimum = minimum ?? other.minimum
        return .init(
            multipleOf: newMultipleOf,
            maximum: newMaximum,
            minimum: newMinimum
        )
    }
}

extension JSONSchema.StringContext {
    internal func combined(with other: JSONSchema.StringContext) throws -> JSONSchema.StringContext {
        if let conflict = conflicting(maxLength, other.maxLength) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "maxLength", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(_minLength, other._minLength) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "minLength", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(pattern, other.pattern) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "pattern", original: conflict.0, new: conflict.1))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMaxLength = maxLength ?? other.maxLength
        let newMinLength = _minLength ?? other._minLength
        let newPattern = pattern ?? other.pattern
        return .init(
            maxLength: newMaxLength,
            minLength: newMinLength,
            pattern: newPattern
        )
    }
}

extension JSONSchema.ArrayContext {
    internal func combined(with other: JSONSchema.ArrayContext) throws -> JSONSchema.ArrayContext {
        if let conflict = conflicting(items, other.items) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "items", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        if let conflict = conflicting(maxItems, other.maxItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "maxItems", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(_minItems, other._minItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "minItems", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(_uniqueItems, other._uniqueItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "uniqueItems", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newItems = items ?? other.items
        let newMaxItems = maxItems ?? other.maxItems
        let newMinItesm = _minItems ?? other._minItems
        let newUniqueItesm = _uniqueItems ?? other._uniqueItems
        return .init(
            items: newItems,
            maxItems: newMaxItems,
            minItems: newMinItesm,
            uniqueItems: newUniqueItesm
        )
    }
}

extension JSONSchema.ObjectContext {
    internal func combined(with other: JSONSchema.ObjectContext, resolvingIn components: OpenAPI.Components) throws -> JSONSchema.ObjectContext {
        let combinedProperties = try combine(properties: properties, with: other.properties, resolvingIn: components)

        if let conflict = conflicting(maxProperties, other.maxProperties) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .object, name: "maxProperties", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(_minProperties, other._minProperties) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .object, name: "minProperties", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(additionalProperties, other.additionalProperties) {
            let originalDescription: String
            switch conflict.0 {
            case .a(let bool):
                originalDescription = String(bool)
            case .b(let schema):
                originalDescription = String(describing: schema)
            }
            let newDescription: String
            switch conflict.1 {
            case .a(let bool):
                newDescription = String(bool)
            case .b(let schema):
                newDescription = String(describing: schema)
            }
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .object, name: "additionalProperties", original: originalDescription, new: newDescription))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMaxProperties = maxProperties ?? other.maxProperties
        let newMinProperties = _minProperties ?? other._minProperties
        let newAdditionalProperties = additionalProperties ?? other.additionalProperties
        return .init(
            properties: combinedProperties,
            additionalProperties: newAdditionalProperties,
            maxProperties: newMaxProperties,
            minProperties: newMinProperties
        )
    }
}

internal func combine(properties left: OrderedDictionary<String, JSONSchema>, with right: OrderedDictionary<String, JSONSchema>, resolvingIn components: OpenAPI.Components) throws -> OrderedDictionary<String, JSONSchema> {
    var combined = right
    for (key, lhs) in left {
        if let rhs = combined[key] {
            var resolver = FragmentCombiner(components: components)
            try resolver.combine([lhs, rhs])
            combined[key] = try resolver.dereferencedSchema().jsonSchema
        } else {
            combined[key] = lhs
        }
    }
    return combined
}

// MARK: - Fragment Context -> Full Context

extension JSONSchema.CoreContext {
    internal func validatedContext<NewFormat: OpenAPIFormat>() throws -> JSONSchema.CoreContext<NewFormat> {
        guard let newFormat = NewFormat(rawValue: format.rawValue) else {
            throw JSONSchemaResolutionError(.inconsistency("Tried to create a \(NewFormat.self) from the incompatible format value: \(format.rawValue)"))
        }
        let newPermissions = _permissions.map(JSONSchema.CoreContext<NewFormat>.Permissions.init)

        return .init(
            format: newFormat,
            required: required,
            nullable: _nullable,
            permissions: newPermissions,
            deprecated: _deprecated,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            defaultValue: defaultValue,
            example: example
        )
    }
}

extension JSONSchema.IntegerContext {
    internal func validatedContext() throws -> JSONSchema.IntegerContext {
        let validatedMinimum: Bound?
        if let minimum = minimum {
            guard minimum.value >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Integer minimum (\(minimum.value) cannot be below 0"))
            }

            validatedMinimum = minimum
        } else {
            validatedMinimum = nil
        }
        if let (min, max) = zip(validatedMinimum, maximum) {
            guard min.value <= max.value else {
                throw JSONSchemaResolutionError(.inconsistency("Integer minimum (\(min.value) cannot be higher than maximum (\(max.value)"))
            }
        }
        return .init(
            multipleOf: multipleOf,
            maximum: maximum,
            minimum: validatedMinimum
        )
    }
}

extension JSONSchema.NumericContext {
    internal func validatedContext() throws -> JSONSchema.NumericContext {
        let validatedMinimum: Bound?
        if let minimum = minimum {
            guard minimum.value >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Number minimum (\(minimum.value) cannot be below 0"))
            }

            validatedMinimum = minimum
        } else {
            validatedMinimum = nil
        }
        if let (min, max) = zip(validatedMinimum, maximum) {
            guard min.value <= max.value else {
                throw JSONSchemaResolutionError(.inconsistency("Number minimum (\(min.value) cannot be higher than maximum (\(max.value)"))
            }
        }
        return .init(
            multipleOf: multipleOf,
            maximum: maximum,
            minimum: validatedMinimum
        )
    }
}

extension JSONSchema.StringContext {
    internal func validatedContext() throws -> JSONSchema.StringContext {
        if let minimum = _minLength {
            guard minimum >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("String minimum length (\(minimum) cannot be less than 0"))
            }
        }
        if let (min, max) = zip(minLength, maxLength) {
            guard min <= max else {
                throw JSONSchemaResolutionError(.inconsistency("String minimum length (\(min) cannot be higher than maximum (\(max)"))
            }
        }
        return .init(
            maxLength: maxLength,
            minLength: _minLength,
            pattern: pattern
        )
    }
}

extension JSONSchema.ArrayContext {
    internal func validatedContext() throws -> JSONSchema.ArrayContext {
        if let minimum = _minItems {
            guard minimum >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Array minimum length (\(minimum) cannot be less than 0"))
            }
        }
        if let (min, max) = zip(minItems, maxItems) {
            guard min <= max else {
                throw JSONSchemaResolutionError(.inconsistency("Array minimum length (\(min) cannot be higher than maximum (\(max)"))
            }
        }
        return .init(
            items: items,
            maxItems: maxItems,
            minItems: _minItems,
            uniqueItems: _uniqueItems
        )
    }
}

extension JSONSchema.ObjectContext {
    internal func validatedContext() throws -> JSONSchema.ObjectContext {
        if let minimum = _minProperties {
            guard minimum >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Object minimum number of properties (\(minimum) cannot be less than 0"))
            }
        }
        if let (min, max) = zip(minProperties, maxProperties) {
            guard min <= max else {
                throw JSONSchemaResolutionError(.inconsistency("Object minimum number of properties (\(min) cannot be higher than maximum (\(max)"))
            }
        }
        return .init(
            properties: properties,
            additionalProperties: additionalProperties,
            maxProperties: maxProperties,
            minProperties: _minProperties
        )
    }
}
