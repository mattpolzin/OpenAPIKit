//
//  Parameter.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import Foundation

extension OpenAPI.PathItem {
    /// OpenAPI Spec "Parameter Object"
    /// 
    /// See [OpenAPI Parameter Object](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#parameter-object).
    public struct Parameter: Equatable, CodableVendorExtendable {
        public var name: String

        /// OpenAPI Spec "in" property determines the `Context`.
        public var context: Context
        public var description: String?
        public var deprecated: Bool // default is false

        /// OpenAPI Spec "content" or "schema" properties.
        public var schemaOrContent: Either<Schema, OpenAPI.Content.Map>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        public var required: Bool { context.required }
        public var location: Context.Location { return context.location }

        /// An array of parameters that are `Either` `Parameters` or references to parameters.
        public typealias Array = [Either<JSONReference<Parameter>, Parameter>]

        public init(name: String,
                    context: Context,
                    schemaOrContent: Either<Schema, OpenAPI.Content.Map>,
                    description: String? = nil,
                    deprecated: Bool = false,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.name = name
            self.context = context
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(name: String,
                    context: Context,
                    schema: Schema,
                    description: String? = nil,
                    deprecated: Bool = false,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(schema)
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(name: String,
                    context: Context,
                    schema: JSONSchema,
                    description: String? = nil,
                    deprecated: Bool = false,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(Schema(schema, style: .default(for: context)))
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(name: String,
                    context: Context,
                    schemaReference: JSONReference<JSONSchema>,
                    description: String? = nil,
                    deprecated: Bool = false,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(Schema(schemaReference: schemaReference, style: .default(for: context)))
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        public init(name: String,
                    context: Context,
                    content: OpenAPI.Content.Map,
                    description: String? = nil,
                    deprecated: Bool = false,
                    vendorExtensions: [String: AnyCodable] = [:]) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(content)
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }
    }
}

// MARK: `Either` convenience methods
// OpenAPI.PathItem.Array.Element =>
extension Either where A == JSONReference<OpenAPI.PathItem.Parameter>, B == OpenAPI.PathItem.Parameter {

    /// Construct a parameter.
    public static func parameter(
        name: String,
        context: OpenAPI.PathItem.Parameter.Context,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                name: name,
                context: context,
                schema: schema,
                description: description,
                deprecated: deprecated,
                vendorExtensions: vendorExtensions
            )
        )
    }

    /// Construct a parameter.
    public static func parameter(
        name: String,
        context: OpenAPI.PathItem.Parameter.Context,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                name: name,
                context: context,
                content: content,
                description: description,
                deprecated: deprecated,
                vendorExtensions: vendorExtensions
            )
        )
    }
}

// MARK: - Codable

extension OpenAPI.PathItem.Parameter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool
        let location: Context.Location
        switch context {
        case .query(required: let req, allowEmptyValue: let allowEmptyValue):
            required = req
            location = .query

            if allowEmptyValue {
                try container.encode(allowEmptyValue, forKey: .allowEmptyValue)
            }
        case .header(required: let req):
            required = req
            location = .header
        case .path:
            required = true
            location = .path
        case .cookie(required: let req):
            required = req
            location = .cookie
        }
        try container.encode(location, forKey: .parameterLocation)

        if required {
            try container.encode(required, forKey: .required)
        }

        switch schemaOrContent {
        case .a(let schema):
            try schema.encode(to: encoder, for: context)
        case .b(let contentMap):
            try container.encode(contentMap, forKey: .content)
        }

        try description.encodeIfNotNil(to: &container, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        try encodeExtensions(to: &container)
    }
}

extension OpenAPI.PathItem.Parameter: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        self.name = name

        let required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        let location = try container.decode(Context.Location.self, forKey: .parameterLocation)

        switch location {
        case .query:
            let allowEmptyValue = try container.decodeIfPresent(Bool.self, forKey: .allowEmptyValue) ?? false
            context = .query(required: required, allowEmptyValue: allowEmptyValue)
        case .header:
            context = .header(required: required)
        case .path:
            if !required {
                throw InconsistencyError(
                    subjectName: name,
                    details: "positional path parameters must be explicitly set to required",
                    codingPath: decoder.codingPath
                )
            }
            context = .path
        case .cookie:
            context = .cookie(required: required)
        }

        let maybeContent = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content)

        let maybeSchema: Schema?
        if container.contains(.schema) {
            maybeSchema = try Schema(from: decoder, for: context)
        } else {
            maybeSchema = nil
        }

        switch (maybeContent, maybeSchema) {
        case (let content?, nil):
            schemaOrContent = .init(content)
        case (nil, let schema?):
            schemaOrContent = .init(schema)
        default:
            throw InconsistencyError(
                subjectName: name,
                details: "A single path parameter must specify one but not both `content` and `schema`",
                codingPath: decoder.codingPath
            )
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.PathItem.Parameter {
    internal enum CodingKeys: ExtendableCodingKey {
        case name
        case parameterLocation
        case description
        case required
        case deprecated
        case allowEmptyValue

        // the following are alternatives
        case content
        case schema

        // the following are parsed as part of Schema
        case style
        case explode
        case allowReserved
        case example
        case examples

        case extended(String)

        static var allBuiltinKeys: [CodingKeys] {
            return [
                .name,
                .parameterLocation,
                .description,
                .required,
                .deprecated,
                .allowEmptyValue,

                .content,
                .schema,

                .style,
                .explode,
                .allowReserved,
                .schema,
                .example,
                .examples
            ]
        }

        static func extendedKey(for value: String) -> CodingKeys {
            return .extended(value)
        }

        init?(stringValue: String) {
            switch stringValue {
            case "name":
                self = .name
            case "in":
                self = .parameterLocation
            case "description":
                self = .description
            case "required":
                self = .required
            case "deprecated":
                self = .deprecated
            case "allowEmptyValue":
                self = .allowEmptyValue
            case "content":
                self = .content
            case "schema":
                self = .schema
            case "style":
                self = .style
            case "explode":
                self = .explode
            case "allowReserved":
                self = .allowReserved
            case "example":
                self = .example
            case "examples":
                self = .examples
            default:
                self = .extendedKey(for: stringValue)
            }
        }

        init?(intValue: Int) {
            return nil
        }

        var stringValue: String {
            switch self {
            case .name:
                return "name"
            case .parameterLocation:
                return "in"
            case .description:
                return "description"
            case .required:
                return "required"
            case .deprecated:
                return "deprecated"
            case .allowEmptyValue:
                return "allowEmptyValue"
            case .content:
                return "content"
            case .schema:
                return "schema"
            case .style:
                return "style"
            case .explode:
                return "explode"
            case .allowReserved:
                return "allowReserved"
            case .example:
                return "example"
            case .examples:
                return "examples"
            case .extended(let key):
                return key
            }
        }

        var intValue: Int? {
            return nil
        }
    }
}
