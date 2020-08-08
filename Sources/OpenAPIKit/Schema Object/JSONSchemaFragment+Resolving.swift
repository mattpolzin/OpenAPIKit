//
//  JSONSchemaFragment+Resolving.swift
//  
//
//  Created by Mathew Polzin on 8/1/20.
//

extension Array where Element == JSONSchemaFragment {
    /// An array of schema fragments can be resolved into a
    /// single `DereferencedJSONSchema` if all references can
    /// be looked up locally and none of the fragments conflict.
    ///
    /// Resolving fragments will both remove references and attempt
    /// to reject any results that would represent impossible schemas
    /// -- that is, schemas that cannot be satisfied and could not ever
    /// be used to validate anything (guaranteed validation failure).
    public func resolved(against components: OpenAPI.Components) throws -> DereferencedJSONSchema {
        var resolver = FragmentResolver(components: components)
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
        underlyingError.description
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
            return "The given `all(of:)` schema does not yet support resolving in OpenAPIKit because \(reason)."
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

/// The FragmentResolver takes any number of fragments and determines if they can be
/// meaningfully combined.
///
/// Conflicts will be determined as fragments are added and when you ask for
/// a `dereferencedSchema()` the fragment resolver will determine if it has enough information
/// to build and dereference the schema.
///
/// Current Limitations (will throw `.unsupported` for these reasons):
/// - Does not handle inversion via `not` or combination via `any`, `one`, `all`.
internal struct FragmentResolver {
    private let components: OpenAPI.Components
    private var combinedFragment: JSONSchemaFragment

    /// Set up for constructing a schema using the given Components Object. Call `combine(_:)`
    /// to start adding schema fragments to the partial schema definition.
    ///
    /// Once all fragments have been combined, call `dereferencedSchema` to attempt to build a `DereferencedJSONSchema`.
    init(components: OpenAPI.Components) {
        self.components = components
        self.combinedFragment = .general(.init())
    }

    /// Combine the existing partial schema with the given fragment.
    ///
    /// - Throws: If any fragments combined together would result in an invalid schema or
    ///     if there is not enough information in the fragments to build a complete schema.
    mutating func combine(_ fragment: JSONSchemaFragment) throws {
        // make sure any less specialized fragment (i.e. general) is on the left
        let lessSpecializedFragment: JSONSchemaFragment
        let equallyOrMoreSpecializedFragment: JSONSchemaFragment
        switch (combinedFragment, fragment) {
        case (.general, _):
            lessSpecializedFragment = combinedFragment
            equallyOrMoreSpecializedFragment = fragment
         default:
            lessSpecializedFragment = fragment
            equallyOrMoreSpecializedFragment = combinedFragment
        }

        switch (lessSpecializedFragment, equallyOrMoreSpecializedFragment) {
        case (_, .reference(let reference)), (.reference(let reference), _):
            try combine(components.lookup(reference).asFragment())
        case (.general(let leftGeneralContext), .general(let rightGeneralContext)):
            combinedFragment = .general(try leftGeneralContext.combined(with: rightGeneralContext))
        case (.general(let leftGeneralContext), .boolean(let rightGeneralContext)):
            combinedFragment = .boolean(try leftGeneralContext.combined(with: rightGeneralContext))
        case (.general(let leftGeneralContext), .integer(let rightGeneralContext, let integerContext)):
            combinedFragment = .integer(try leftGeneralContext.combined(with: rightGeneralContext), integerContext)
        case (.general(let leftGeneralContext), .number(let rightGeneralContext, let numericContext)):
            combinedFragment = .number(try leftGeneralContext.combined(with: rightGeneralContext), numericContext)
        case (.general(let leftGeneralContext), .string(let rightGeneralContext, let stringContext)):
            combinedFragment = .string(try leftGeneralContext.combined(with: rightGeneralContext), stringContext)
        case (.general(let leftGeneralContext), .array(let rightGeneralContext, let arrayContext)):
            combinedFragment = .array(try leftGeneralContext.combined(with: rightGeneralContext), arrayContext)
        case (.general(let leftGeneralContext), .object(let rightGeneralContext, let objectContext)):
            combinedFragment = .object(try leftGeneralContext.combined(with: rightGeneralContext), objectContext)
        case (.boolean(let leftGeneralContext), .boolean(let rightGeneralContext)):
            combinedFragment = .boolean(try leftGeneralContext.combined(with: rightGeneralContext))
        case (.integer(let leftGeneralContext, let leftIntegerContext), .integer(let rightGeneralContext, let rightIntegerContext)):
            combinedFragment = .integer(try leftGeneralContext.combined(with: rightGeneralContext), try leftIntegerContext.combined(with: rightIntegerContext))
        case (.number(let leftGeneralContext, let leftNumericContext), .number(let rightGeneralContext, let rightNumericContext)):
            combinedFragment = .number(try leftGeneralContext.combined(with: rightGeneralContext), try leftNumericContext.combined(with: rightNumericContext))
        case (.string(let leftGeneralContext, let leftStringContext), .string(let rightGeneralContext, let rightStringContext)):
            combinedFragment = .string(try leftGeneralContext.combined(with: rightGeneralContext), try leftStringContext.combined(with: rightStringContext))
        case (.array(let leftGeneralContext, let leftArrayContext), .array(let rightGeneralContext, let rightArrayContext)):
            combinedFragment = .array(try leftGeneralContext.combined(with: rightGeneralContext), try leftArrayContext.combined(with: rightArrayContext))
        case (.object(let leftGeneralContext, let leftObjectContext), .object(let rightGeneralContext, let rightObjectContext)):
            combinedFragment = .object(try leftGeneralContext.combined(with: rightGeneralContext), try leftObjectContext.combined(with: rightObjectContext, resolvingIn: components))
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
    mutating func combine(_ fragments: [JSONSchemaFragment]) throws {
        for fragment in fragments {
            try combine(fragment)
        }
    }

    func dereferencedSchema() throws -> DereferencedJSONSchema {
        let jsonSchema: JSONSchema
        switch combinedFragment {
        case .general(let generalContext):
            jsonSchema = .undefined(description: generalContext.description)
        case .reference(let reference):
            jsonSchema = .reference(reference)
        case .boolean(let generalContext):
            jsonSchema = .boolean(try generalContext.validatedContext())
        case .integer(let generalContext, let integerContext):
            jsonSchema = .integer(try generalContext.validatedContext(), try integerContext.validatedContext())
        case .number(let generalContext, let numericContext):
            jsonSchema = .number(try generalContext.validatedContext(), try numericContext.validatedContext())
        case .string(let generalContext, let stringContext):
            jsonSchema = .string(try generalContext.validatedContext(), try stringContext.validatedContext())
        case .array(let generalContext, let arrayContext):
            jsonSchema = .array(try generalContext.validatedContext(), try arrayContext.validatedContext())
        case .object(let generalContext, let objectContext):
            jsonSchema = .object(try generalContext.validatedContext(), try objectContext.validatedContext())
        }
        return try jsonSchema.dereferenced(in: components)
    }
}

// MARK: - Combining Fragments

internal func conflicting<T>(_ left: T?, _ right: T?) -> (T, T)? where T: Equatable {
    return zip(left, right).flatMap { $0 == $1 ? nil : ($0, $1) }
}

extension JSONSchemaFragment.GeneralContext {
    internal func combined(with other: JSONSchemaFragment.GeneralContext) throws -> JSONSchemaFragment.GeneralContext {
        if let conflict = conflicting(format, other.format) {
            throw JSONSchemaResolutionError(.formatConflict(original: conflict.0, new: conflict.1))
        }
        if let conflict = conflicting(description, other.description) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "description", original: conflict.0, new: conflict.1))
        }
        if let conflict = conflicting(discriminator, other.discriminator) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "discriminator", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        if let conflict = conflicting(title, other.title) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "title", original: conflict.0, new: conflict.1))
        }
        if let conflict = conflicting(nullable, other.nullable) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "nullable", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(deprecated, other.deprecated) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "deprecated", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(externalDocs, other.externalDocs) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "externalDocs", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
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
        if let conflict = conflicting(example, other.example) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "example", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        if let conflict = conflicting(readOnly, other.readOnly) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "readOnly", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(writeOnly, other.writeOnly) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: nil, name: "writeOnly", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newFormat = format ?? other.format
        let newDescription = description ?? other.description
        let newDiscriminator = discriminator ?? other.discriminator
        let newTitle = title ?? other.title
        let newNullable = nullable ?? other.nullable
        let newDeprecated = deprecated ?? other.deprecated
        let newExternalDocs = externalDocs ?? other.externalDocs
        let newAllowedValues = allowedValues ?? other.allowedValues
        let newExample = example ?? other.example
        let newReadOnly = readOnly ?? other.readOnly
        let newWriteOnly = writeOnly ?? other.writeOnly
        return .init(
            format: newFormat,
            description: newDescription,
            discriminator: newDiscriminator,
            title: newTitle,
            nullable: newNullable,
            deprecated: newDeprecated,
            externalDocs: newExternalDocs,
            allowedValues: newAllowedValues,
            example: newExample,
            readOnly: newReadOnly,
            writeOnly: newWriteOnly
        )
    }
}

extension JSONSchemaFragment.IntegerContext {
    internal func combined(with other: JSONSchemaFragment.IntegerContext) throws -> JSONSchemaFragment.IntegerContext {
        if let conflict = conflicting(multipleOf, other.multipleOf) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "multipleOf", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum, other.maximum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "maximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(exclusiveMaximum, other.exclusiveMaximum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "exclusiveMaximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum, other.minimum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "minimum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(exclusiveMinimum, other.exclusiveMinimum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .integer, name: "exclusiveMinimum", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMultipleOf = multipleOf ?? other.multipleOf
        let newMaximum = maximum ?? other.maximum
        let newExclusiveMaximum = exclusiveMaximum ?? other.exclusiveMaximum
        let newMinimum = minimum ?? other.minimum
        let newExclusiveMinimum = exclusiveMinimum ?? other.exclusiveMinimum
        return .init(
            multipleOf: newMultipleOf,
            maximum: newMaximum,
            exclusiveMaximum: newExclusiveMaximum,
            minimum: newMinimum,
            exclusiveMinimum: newExclusiveMinimum
        )
    }
}

extension JSONSchemaFragment.NumericContext {
    internal func combined(with other: JSONSchemaFragment.NumericContext) throws -> JSONSchemaFragment.NumericContext {
        if let conflict = conflicting(multipleOf, other.multipleOf) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "multipleOf", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(maximum, other.maximum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "maximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(exclusiveMaximum, other.exclusiveMaximum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "exclusiveMaximum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minimum, other.minimum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "minimum", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(exclusiveMinimum, other.exclusiveMinimum) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .number, name: "exclusiveMinimum", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMultipleOf = multipleOf ?? other.multipleOf
        let newMaximum = maximum ?? other.maximum
        let newExclusiveMaximum = exclusiveMaximum ?? other.exclusiveMaximum
        let newMinimum = minimum ?? other.minimum
        let newExclusiveMinimum = exclusiveMinimum ?? other.exclusiveMinimum
        return .init(
            multipleOf: newMultipleOf,
            maximum: newMaximum,
            exclusiveMaximum: newExclusiveMaximum,
            minimum: newMinimum,
            exclusiveMinimum: newExclusiveMinimum
        )
    }
}

extension JSONSchemaFragment.StringContext {
    internal func combined(with other: JSONSchemaFragment.StringContext) throws -> JSONSchemaFragment.StringContext {
        if let conflict = conflicting(maxLength, other.maxLength) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "maxLength", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minLength, other.minLength) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "minLength", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(pattern, other.pattern) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .string, name: "pattern", original: conflict.0, new: conflict.1))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMaxLength = maxLength ?? other.maxLength
        let newMinLength = minLength ?? other.minLength
        let newPattern = pattern ?? other.pattern
        return .init(
            maxLength: newMaxLength,
            minLength: newMinLength,
            pattern: newPattern
        )
    }
}

extension JSONSchemaFragment.ArrayContext {
    internal func combined(with other: JSONSchemaFragment.ArrayContext) throws -> JSONSchemaFragment.ArrayContext {
        if let conflict = conflicting(items, other.items) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "items", original: String(describing: conflict.0), new: String(describing: conflict.1)))
        }
        if let conflict = conflicting(maxItems, other.maxItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "maxItems", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minItems, other.minItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "minItems", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(uniqueItems, other.uniqueItems) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .array, name: "uniqueItems", original: String(conflict.0), new: String(conflict.1)))
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newItems = items ?? other.items
        let newMaxItems = maxItems ?? other.maxItems
        let newMinItesm = minItems ?? other.minItems
        let newUniqueItesm = uniqueItems ?? other.uniqueItems
        return .init(
            items: newItems,
            maxItems: newMaxItems,
            minItems: newMinItesm,
            uniqueItems: newUniqueItesm
        )
    }
}

extension JSONSchemaFragment.ObjectContext {
    internal func combined(with other: JSONSchemaFragment.ObjectContext, resolvingIn components: OpenAPI.Components) throws -> JSONSchemaFragment.ObjectContext {
        let newProperties: [String : JSONSchema]?
        if let conflict = conflicting(properties, other.properties) {
            newProperties = try combine(properties: conflict.0, with: conflict.1, resolvingIn: components)
        } else {
            newProperties = properties ?? other.properties
        }
        if let conflict = conflicting(maxProperties, other.maxProperties) {
            throw JSONSchemaResolutionError(.attributeConflict(jsonType: .object, name: "maxProperties", original: String(conflict.0), new: String(conflict.1)))
        }
        if let conflict = conflicting(minProperties, other.minProperties) {
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
        if let conflict = conflicting(requiredProperties, other.requiredProperties) {
            throw JSONSchemaResolutionError(
                .attributeConflict(
                    jsonType: .object,
                    name: "required",
                    original: conflict.0.joined(separator: ", "),
                    new: conflict.1.joined(separator: ", ")
                )
            )
        }
        // explicitly declaring these constants one at a time
        // helps the type checker a lot.
        let newMaxProperties = maxProperties ?? other.maxProperties
        let newMinProperties = minProperties ?? other.minProperties
        let newAdditionalProperties = additionalProperties ?? other.additionalProperties
        let newRequired = requiredProperties ?? other.requiredProperties
        return .init(
            maxProperties: newMaxProperties,
            minProperties: newMinProperties,
            properties: newProperties,
            additionalProperties: newAdditionalProperties,
            requiredProperties: newRequired
        )
    }
}

internal func combine(properties left: [String: JSONSchema], with right: [String: JSONSchema], resolvingIn components: OpenAPI.Components) throws -> [String: JSONSchema] {
    var combined = left
    try combined.merge(right) { (left, right) throws -> JSONSchema in
        var resolve = FragmentResolver(components: components)
        try resolve.combine([try left.asFragment(), try right.asFragment()])
        return try resolve.dereferencedSchema().jsonSchema
    }
    return combined
}

// MARK: - Full Context -> Fragment Context

fileprivate extension JSONSchema {
    /// - Throws: If the schema cannot be represented as a fragment.
    func asFragment() throws -> JSONSchemaFragment {
        switch self {
        case .all, .any, .one, .not:
            throw JSONSchemaResolutionError(.unsupported(because: "`any`, `all`, `one`, and `not` aren't yet supported for schema fragment resolution."))
        case .reference(let reference):
            return .reference(reference)
        case .undefined(description: let description):
            return .general(.init(description: description))
        case .array(let generalContext, let arrayContext):
            return .array(
                generalContext.fragmentContext,
                .init(
                    items: arrayContext.items,
                    maxItems: arrayContext.maxItems,
                    minItems: arrayContext.minItems,
                    uniqueItems: arrayContext.uniqueItems
                )
            )
        case .object(let generalContext, let objectContext):
            // a _minProperties of 0 is also the default if omitted, so omit (as `nil`) if it is 0.
            let minProperties = objectContext._minProperties > 0 ? objectContext._minProperties : nil
            return .object(
                generalContext.fragmentContext,
                .init(
                    maxProperties: objectContext.maxProperties,
                    minProperties: minProperties,
                    properties: objectContext.properties,
                    additionalProperties: objectContext.additionalProperties,
                    requiredProperties: objectContext.requiredProperties
                )
            )
        case .string(let generalContext, let stringContext):
            return .string(
                generalContext.fragmentContext,
                .init(
                    maxLength: stringContext.maxLength,
                    minLength: stringContext.minLength,
                    pattern: stringContext.pattern
                )
            )
        case .integer(let generalContext, let integerContext):
            return .integer(
                generalContext.fragmentContext,
                .init(
                    multipleOf: integerContext.multipleOf,
                    maximum: integerContext.maximum?.value,
                    exclusiveMaximum: integerContext.maximum?.exclusive,
                    minimum: integerContext.minimum?.value,
                    exclusiveMinimum: integerContext.minimum?.exclusive
                )
            )
        case .number(let generalContext, let numberContext):
            return .number(
                generalContext.fragmentContext,
                .init(
                    multipleOf: numberContext.multipleOf,
                    maximum: numberContext.maximum?.value,
                    exclusiveMaximum: numberContext.maximum?.exclusive,
                    minimum: numberContext.minimum?.value,
                    exclusiveMinimum: numberContext.minimum?.exclusive
                )
            )
        case .boolean(let generalContext):
            return .boolean(generalContext.fragmentContext)
        }
    }
}

fileprivate extension JSONSchema.Context {
    var fragmentContext: JSONSchemaFragment.GeneralContext {
        let formatString: String? = format.rawValue == "" ? nil : format.rawValue
        return .init(
            format: formatString,
            description: description,
            discriminator: discriminator,
            title: title,
            nullable: nullable,
            deprecated: deprecated,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            example: example,
            readOnly: readOnly,
            writeOnly: writeOnly
        )
    }
}

// MARK: - Fragment Context -> Full Context

extension JSONSchemaFragment.GeneralContext {
    internal func validatedContext<T: OpenAPIFormat>() throws -> JSONSchema.Context<T> {
        let permissions: JSONSchema.Context<T>.Permissions
        switch (self.readOnly, self.writeOnly) {
        case (true, true):
            throw JSONSchemaResolutionError(.inconsistency("Schemas cannot be read-only and write-only"))
        case (true, _):
            permissions = .readOnly
        case (_, true):
            permissions = .writeOnly
        default:
            permissions = .readWrite
        }
        let validatedFormat: T
        if let formatString = format {
            guard let formatValue = T(rawValue: formatString) else {
                throw JSONSchemaResolutionError(.inconsistency("The format \(formatString) is not one of the options for the given type of schema"))
            }
            validatedFormat = formatValue
        } else {
            validatedFormat = .unspecified
        }
        return .init(
            format: validatedFormat,
            required: true,
            nullable: false,
            permissions: permissions,
            deprecated: deprecated ?? false,
            title: title,
            description: description,
            discriminator: discriminator,
            externalDocs: externalDocs,
            allowedValues: allowedValues,
            example: example
        )
    }
}

extension JSONSchemaFragment.IntegerContext {
    internal func validatedContext() throws -> JSONSchema.IntegerContext {
        let validatedMaximum: (value: Int, exclusive: Bool)?
        if let maximum = maximum {
            let exclusive = exclusiveMaximum ?? JSONSchema.IntegerContext.Bound.defaultExclusion
            validatedMaximum = (maximum, exclusive: exclusive)
        } else {
            validatedMaximum = nil
        }
        let validatedMinimum: (value: Int, exclusive: Bool)?
        if let minimum = minimum {
            guard minimum >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Integer minimum (\(minimum) cannot be below 0"))
            }

            let exclusive = exclusiveMinimum ?? JSONSchema.IntegerContext.Bound.defaultExclusion
            validatedMinimum = (minimum, exclusive: exclusive)
        } else {
            validatedMinimum = nil
        }
        if let (min, max) = zip(validatedMinimum, validatedMaximum) {
            guard min.value <= max.value else {
                throw JSONSchemaResolutionError(.inconsistency("Integer minimum (\(min.value) cannot be higher than maximum (\(max.value)"))
            }
        }
        return .init(
            multipleOf: multipleOf,
            maximum: validatedMaximum,
            minimum: validatedMinimum
        )
    }
}

extension JSONSchemaFragment.NumericContext {
    internal func validatedContext() throws -> JSONSchema.NumericContext {
        let validatedMaximum: (value: Double, exclusive: Bool)?
        if let maximum = maximum {
            let exclusive = exclusiveMaximum ?? JSONSchema.NumericContext.Bound.defaultExclusion
            validatedMaximum = (maximum, exclusive: exclusive)
        } else {
            validatedMaximum = nil
        }
        let validatedMinimum: (value: Double, exclusive: Bool)?
        if let minimum = minimum {
            guard minimum >= 0 else {
                throw JSONSchemaResolutionError(.inconsistency("Number minimum (\(minimum) cannot be below 0"))
            }

            let exclusive = exclusiveMinimum ?? JSONSchema.NumericContext.Bound.defaultExclusion
            validatedMinimum = (minimum, exclusive: exclusive)
        } else {
            validatedMinimum = nil
        }
        if let (min, max) = zip(validatedMinimum, validatedMaximum) {
            guard min.value <= max.value else {
                throw JSONSchemaResolutionError(.inconsistency("Number minimum (\(min.value) cannot be higher than maximum (\(max.value)"))
            }
        }
        return .init(
            multipleOf: multipleOf,
            maximum: validatedMaximum,
            minimum: validatedMinimum
        )
    }
}

extension JSONSchemaFragment.StringContext {
    internal func validatedContext() throws -> JSONSchema.StringContext {
        if let minimum = minLength {
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
            minLength: minLength ?? 0,
            pattern: pattern
        )
    }
}

extension JSONSchemaFragment.ArrayContext {
    internal func validatedContext() throws -> JSONSchema.ArrayContext {
        if let minimum = minItems {
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
            minItems: minItems ?? 0,
            uniqueItems: uniqueItems ?? false
        )
    }
}

extension JSONSchemaFragment.ObjectContext {
    internal func validatedContext() throws -> JSONSchema.ObjectContext {
        if let minimum = minProperties {
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
            properties: properties ?? [:],
            additionalProperties: additionalProperties,
            maxProperties: maxProperties,
            minProperties: minProperties ?? 0
        )
    }
}
