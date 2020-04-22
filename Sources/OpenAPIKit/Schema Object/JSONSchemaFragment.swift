//
//  JSONSchemaFragment.swift
//  
//
//  Created by Mathew Polzin on 4/20/20.
//

public protocol JSONSchemaFragmentContext {
    var format: String? { get }
    var description: String? { get }
    var title: String? { get }
    var nullable: Bool? { get }
    var deprecated: Bool? { get }
    var externalDocs: OpenAPI.ExternalDocumentation? { get }
    var allowedValues: [AnyCodable]? { get }
    var example: AnyCodable? { get }
    var readOnly: Bool? { get }
    var writeOnly: Bool? { get }
}

public enum JSONSchemaFragment: Equatable {

    case general(GeneralContext)
    case boolean(GeneralContext)
    case integer(
        GeneralContext,
        IntegerContext
    )
    case number(
        GeneralContext,
        NumericContext
    )
    case string(
        GeneralContext,
        StringContext
    )
    case array(
        GeneralContext,
        ArrayContext
    )

    // object context
    case object(
        GeneralContext,
        ObjectContext
    )
}

extension JSONSchemaFragment {
    public struct GeneralContext: Equatable {
        public var format: String? = nil
        public var description: String? = nil
        public var title: String? = nil
        public var nullable: Bool? = nil
        public var deprecated: Bool? = nil
        public var externalDocs: OpenAPI.ExternalDocumentation? = nil
        public var allowedValues: [AnyCodable]? = nil
        public var example: AnyCodable? = nil
        public var readOnly: Bool? = nil
        public var writeOnly: Bool? = nil

        public init(
            format: String? = nil,
            description: String? = nil,
            title: String? = nil,
            nullable: Bool? = nil,
            deprecated: Bool? = nil,
            externalDocs: OpenAPI.ExternalDocumentation? = nil,
            allowedValues: [AnyCodable]? = nil,
            example: AnyCodable? = nil,
            readOnly: Bool? = nil,
            writeOnly: Bool? = nil
        ) {
            self.format = format
            self.description = description
            self.title = title
            self.nullable = nullable
            self.deprecated = deprecated
            self.externalDocs = externalDocs
            self.allowedValues = allowedValues
            self.example = example
            self.readOnly = readOnly
            self.writeOnly = writeOnly
        }
    }

    public struct IntegerContext: Equatable {
        public var multipleOf: Int? = nil
        public var maximum: Int? = nil
        public var exclusiveMaximum: Bool? = nil
        public var minimum: Int? = nil
        public var exclusiveMinimum: Bool? = nil

        public init(
            multipleOf: Int? = nil,
            maximum: Int? = nil,
            exclusiveMaximum: Bool? = nil,
            minimum: Int? = nil,
            exclusiveMinimum: Bool? = nil
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum
            self.minimum = minimum
            self.exclusiveMaximum = exclusiveMaximum
            self.exclusiveMinimum = exclusiveMinimum
        }

        public init?(from numericContext: NumericContext) {
            if let multipleOf = numericContext.multipleOf {
                guard let integerMultipleOf = Int(exactly: multipleOf) else { return nil }
                self.multipleOf = integerMultipleOf
            } else {
                self.multipleOf = nil
            }

            if let maximum = numericContext.maximum {
                guard let integerMaximum = Int(exactly: maximum) else { return nil }
                self.maximum = integerMaximum
            } else {
                self.maximum = nil
            }

            if let minimum = numericContext.minimum {
                guard let integerMinimum = Int(exactly: minimum) else { return nil }
                self.minimum = integerMinimum
            } else {
                self.minimum = nil
            }

            self.exclusiveMaximum = numericContext.exclusiveMaximum
            self.exclusiveMinimum = numericContext.exclusiveMinimum
        }
    }

    public struct NumericContext: Equatable {
        public var multipleOf: Double? = nil
        public var maximum: Double? = nil
        public var exclusiveMaximum: Bool? = nil
        public var minimum: Double? = nil
        public var exclusiveMinimum: Bool? = nil

        public init(
            multipleOf: Double? = nil,
            maximum: Double? = nil,
            exclusiveMaximum: Bool? = nil,
            minimum: Double? = nil,
            exclusiveMinimum: Bool? = nil
        ) {
            self.multipleOf = multipleOf
            self.maximum = maximum
            self.minimum = minimum
            self.exclusiveMaximum = exclusiveMaximum
            self.exclusiveMinimum = exclusiveMinimum
        }
    }

    public struct StringContext: Equatable {
        public var maxLength: Int? = nil
        public var minLength: Int? = nil
        public var pattern: String? = nil // regex

        public init(
            maxLength: Int? = nil,
            minLength: Int? = nil,
            pattern: String? = nil
        ) {
            self.maxLength = maxLength
            self.minLength = minLength
            self.pattern = pattern
        }
    }

    public struct ArrayContext: Equatable {
        public var items: JSONSchema? = nil
        public var maxItems: Int? = nil
        public var minItems: Int? = nil
        public var uniqueItems: Bool? = nil

        public init(
            items: JSONSchema? = nil,
            maxItems: Int? = nil,
            minItems: Int? = nil,
            uniqueItems: Bool? = nil
        ) {
            self.items = items
            self.maxItems = maxItems
            self.minItems = minItems
            self.uniqueItems = uniqueItems
        }
    }

    public struct ObjectContext: Equatable {
        public var maxProperties: Int? = nil
        public var minProperties: Int? = nil
        public var properties: [String: JSONSchema]? = nil
        public var additionalProperties: Either<Bool, JSONSchema>? = nil
        public var required: [String]? = nil

        public init(
            maxProperties: Int? = nil,
            minProperties: Int? = nil,
            properties: [String: JSONSchema]? = nil,
            additionalProperties: Either<Bool, JSONSchema>? = nil,
            required: [String]? = nil
        ) {
            self.maxProperties = maxProperties
            self.minProperties = minProperties
            self.properties = properties
            self.additionalProperties = additionalProperties
            self.required = required
        }
    }
}

extension JSONSchemaFragment: JSONSchemaFragmentContext {

    public var format: String? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.format
        }
    }

    public var description: String? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.description
        }
    }

    public var title: String? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.title
        }
    }

    public var nullable: Bool? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.nullable
        }
    }

    public var deprecated: Bool? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.deprecated
        }
    }

    public var externalDocs: OpenAPI.ExternalDocumentation? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.externalDocs
        }
    }

    public var allowedValues: [AnyCodable]? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.allowedValues
        }
    }

    public var example: AnyCodable? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.example
        }
    }

    public var readOnly: Bool? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.readOnly
        }
    }

    public var writeOnly: Bool? {
        switch self {
        case .general(let generalContext),
             .boolean(let generalContext),
             .integer(let generalContext, _),
             .number(let generalContext, _),
             .string(let generalContext, _),
             .array(let generalContext, _),
             .object(let generalContext, _):
            return generalContext.writeOnly
        }
    }
}

extension JSONSchemaFragment {
    private typealias GeneralCodingKeys = JSONSchema.ContextCodingKeys
    private typealias IntegerCodingKeys = JSONSchema.IntegerContext.CodingKeys
    private typealias NumericCodingKeys = JSONSchema.NumericContext.CodingKeys
    private typealias StringCodingKeys = JSONSchema.StringContext.CodingKeys
    private typealias ArrayCodingKeys = JSONSchema.ArrayContext.CodingKeys
    private typealias ObjectCodingKeys = JSONSchema.ObjectContext.CodingKeys
}

extension JSONSchemaFragment: Encodable {
    private func encodeGeneralProperties(for type: JSONType?, to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: GeneralCodingKeys.self)

        try type.encodeIfNotNil(to: &container, forKey: .type)
        try format.encodeIfNotNil(to: &container, forKey: .format)
        try description.encodeIfNotNil(to: &container, forKey: .description)
        try title.encodeIfNotNil(to: &container, forKey: .title)
        try nullable.encodeIfNotNil(to: &container, forKey: .nullable)
        try deprecated.encodeIfNotNil(to: &container, forKey: .deprecated)
        try externalDocs.encodeIfNotNil(to: &container, forKey: .externalDocs)
        try allowedValues.encodeIfNotNil(to: &container, forKey: .allowedValues)
        try example.encodeIfNotNil(to: &container, forKey: .example)
        try readOnly.encodeIfNotNil(to: &container, forKey: .readOnly)
        try writeOnly.encodeIfNotNil(to: &container, forKey: .writeOnly)
    }

    public func encode(to encoder: Encoder) throws {

        switch self {
        case .general:
            try encodeGeneralProperties(for: nil, to: encoder)
        case .boolean:
            try encodeGeneralProperties(for: .boolean, to: encoder)
        case .integer(_, let integerContext):
            try encodeGeneralProperties(for: .integer, to: encoder)

            var container = encoder.container(keyedBy: IntegerCodingKeys.self)
            try integerContext.multipleOf.encodeIfNotNil(to: &container, forKey: .multipleOf)
            try integerContext.maximum.encodeIfNotNil(to: &container, forKey: .maximum)
            try integerContext.exclusiveMaximum.encodeIfNotNil(to: &container, forKey: .exclusiveMaximum)
            try integerContext.minimum.encodeIfNotNil(to: &container, forKey: .minimum)
            try integerContext.exclusiveMinimum.encodeIfNotNil(to: &container, forKey: .exclusiveMinimum)
        case .number(_, let numericContext):
            try encodeGeneralProperties(for: .number, to: encoder)

            var container = encoder.container(keyedBy: NumericCodingKeys.self)
            try numericContext.multipleOf.encodeIfNotNil(to: &container, forKey: .multipleOf)
            try numericContext.maximum.encodeIfNotNil(to: &container, forKey: .maximum)
            try numericContext.exclusiveMaximum.encodeIfNotNil(to: &container, forKey: .exclusiveMaximum)
            try numericContext.minimum.encodeIfNotNil(to: &container, forKey: .minimum)
            try numericContext.exclusiveMinimum.encodeIfNotNil(to: &container, forKey: .exclusiveMinimum)

        case .string(_, let stringContext):
            try encodeGeneralProperties(for: .string, to: encoder)

            var container = encoder.container(keyedBy: StringCodingKeys.self)
            try stringContext.maxLength.encodeIfNotNil(to: &container, forKey: .maxLength)
            try stringContext.minLength.encodeIfNotNil(to: &container, forKey: .minLength)
            try stringContext.pattern.encodeIfNotNil(to: &container, forKey: .pattern)

        case .array(_, let arrayContext):
            try encodeGeneralProperties(for: .array, to: encoder)

            var container = encoder.container(keyedBy: ArrayCodingKeys.self)
            try arrayContext.items.encodeIfNotNil(to: &container, forKey: .items)
            try arrayContext.maxItems.encodeIfNotNil(to: &container, forKey: .maxItems)
            try arrayContext.minItems.encodeIfNotNil(to: &container, forKey: .minItems)
            try arrayContext.uniqueItems.encodeIfNotNil(to: &container, forKey: .uniqueItems)

        case .object(_, let objectContext):
            try encodeGeneralProperties(for: .object, to: encoder)

            var container = encoder.container(keyedBy: ObjectCodingKeys.self)
            try objectContext.maxProperties.encodeIfNotNil(to: &container, forKey: .maxProperties)
            try objectContext.minProperties.encodeIfNotNil(to: &container, forKey: .minProperties)
            try objectContext.properties.encodeIfNotNil(to: &container, forKey: .properties)
            try objectContext.additionalProperties.encodeIfNotNil(to: &container, forKey: .additionalProperties)
            try objectContext.required.encodeIfNotNil(to: &container, forKey: .required)
        }
    }
}

extension JSONSchemaFragment.GeneralContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.GeneralCodingKeys.self)

        format = try container.decodeIfPresent(String.self, forKey: .format)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        nullable = try container.decodeIfPresent(Bool.self, forKey: .nullable)
        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated)
        externalDocs = try container.decodeIfPresent(OpenAPI.ExternalDocumentation.self, forKey: .externalDocs)
        allowedValues = try container.decodeIfPresent([AnyCodable].self, forKey: .allowedValues)
        example = try container.decodeIfPresent(AnyCodable.self, forKey: .example)
        readOnly = try container.decodeIfPresent(Bool.self, forKey: .readOnly)
        writeOnly = try container.decodeIfPresent(Bool.self, forKey: .writeOnly)
    }
}

extension JSONSchemaFragment.IntegerContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.IntegerCodingKeys.self)

        multipleOf = try container.decodeIfPresent(Int.self, forKey: .multipleOf)
        maximum = try container.decodeIfPresent(Int.self, forKey: .maximum)
        exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum)
        minimum = try container.decodeIfPresent(Int.self, forKey: .minimum)
        exclusiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMinimum)
    }
}

extension JSONSchemaFragment.NumericContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.NumericCodingKeys.self)

        multipleOf = try container.decodeIfPresent(Double.self, forKey: .multipleOf)
        maximum = try container.decodeIfPresent(Double.self, forKey: .maximum)
        exclusiveMaximum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMaximum)
        minimum = try container.decodeIfPresent(Double.self, forKey: .minimum)
        exclusiveMinimum = try container.decodeIfPresent(Bool.self, forKey: .exclusiveMinimum)
    }
}

extension JSONSchemaFragment.StringContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.StringCodingKeys.self)

        maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
        minLength = try container.decodeIfPresent(Int.self, forKey: .minLength)
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
    }
}

extension JSONSchemaFragment.ArrayContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.ArrayCodingKeys.self)

        items = try container.decodeIfPresent(JSONSchema.self, forKey: .items)
        maxItems = try container.decodeIfPresent(Int.self, forKey: .maxItems)
        minItems = try container.decodeIfPresent(Int.self, forKey: .minItems)
        uniqueItems = try container.decodeIfPresent(Bool.self, forKey: .uniqueItems)
    }
}

extension JSONSchemaFragment.ObjectContext: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONSchemaFragment.ObjectCodingKeys.self)

        maxProperties = try container.decodeIfPresent(Int.self, forKey: .maxProperties)
        minProperties = try container.decodeIfPresent(Int.self, forKey: .minProperties)
        properties = try container.decodeIfPresent([String: JSONSchema].self, forKey: .properties)
        additionalProperties = try container.decodeIfPresent(Either<Bool, JSONSchema>.self, forKey: .additionalProperties)
        required = try container.decodeIfPresent([String].self, forKey: .required)
    }
}

extension JSONSchemaFragment: Decodable {
    public init(from decoder: Decoder) throws {

        let generalContext = try GeneralContext(from: decoder)

        let generalContainer = try decoder.container(keyedBy: JSONSchemaFragment.GeneralCodingKeys.self)
        let numericOrIntegerContainer = try decoder.container(keyedBy: JSONSchemaFragment.NumericCodingKeys.self)
        let stringContainer = try decoder.container(keyedBy: JSONSchemaFragment.StringCodingKeys.self)
        let arrayContainer = try decoder.container(keyedBy: JSONSchemaFragment.ArrayCodingKeys.self)
        let objectContainer = try decoder.container(keyedBy: JSONSchemaFragment.ObjectCodingKeys.self)

        let typeHint = try generalContainer.decodeIfPresent(JSONType.self, forKey: .type)

        let keysFrom = [
            numericOrIntegerContainer.allKeys.isEmpty ? nil : "number/integer",
            stringContainer.allKeys.isEmpty ? nil : "string",
            arrayContainer.allKeys.isEmpty ? nil : "array",
            objectContainer.allKeys.isEmpty ? nil : "object"
        ].compactMap { $0 }

        if keysFrom.count > 1 {
            throw InconsistencyError(
                subjectName: "Schema Fragment",
                details: "A schema fragment within an `allOf` contains properties for multiple types of schemas, namely: \(keysFrom).",
                codingPath: decoder.codingPath
            )
        }

        func assertNoTypeConflict(with type: JSONType) throws {
            guard let typeHint = typeHint else { return }
            guard typeHint == type else {
                throw InconsistencyError(
                    subjectName: "Schema Fragment",
                    details: "Found schema attributes not consistent with the type specified: \(typeHint)",
                    codingPath: decoder.codingPath
                )
            }
        }

        if typeHint == .integer || typeHint == .number || !numericOrIntegerContainer.allKeys.isEmpty {
            if typeHint == .integer {
                self = .integer(generalContext, try .init(from: decoder))
            } else {
                self = .number(generalContext, try .init(from: decoder))
            }
        } else if typeHint == .string || !stringContainer.allKeys.isEmpty {
            try assertNoTypeConflict(with: .string)
            self = .string(generalContext, try .init(from: decoder))

        } else if typeHint == .array || !arrayContainer.allKeys.isEmpty {
            try assertNoTypeConflict(with: .array)
            self = .array(generalContext, try .init(from: decoder))

        } else if typeHint == .object || !objectContainer.allKeys.isEmpty {
            try assertNoTypeConflict(with: .object)
            self = .object(generalContext, try .init(from: decoder))

        } else if typeHint == .boolean {
            self = .boolean(generalContext)
            
        } else if !generalContainer.allKeys.isEmpty {
            self = .general(generalContext)

        } else {
            throw InconsistencyError(
                subjectName: "Schema Fragment",
                details: "A totally empty schema fragment was found in an `allOf` array.",
                codingPath: decoder.codingPath
            )
        }
    }
}
