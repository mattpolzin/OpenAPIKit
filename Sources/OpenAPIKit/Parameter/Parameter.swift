//
//  Parameter.swift
//  OpenAPI
//
//  Created by Mathew Polzin on 7/4/19.
//

import OpenAPIKitCore

extension OpenAPI {
    /// OpenAPI Spec "Parameter Object"
    /// 
    /// See [OpenAPI Parameter Object](https://spec.openapis.org/oas/v3.1.1.html#parameter-object).
    public struct Parameter: Equatable, CodableVendorExtendable, Sendable {
        public var name: String

        /// OpenAPI Spec "in" property determines the `Context`.
        ///
        /// This context stores the location (e.g. "query" or "header") of
        /// the parameter and any additional information relevant to
        /// parameters in the given location.
        public var context: Context
        public var description: String?
        /// Whether or not the parameter is deprecated. Defaults to false
        /// if unspecified and only gets encoded if true.
        public var deprecated: Bool // default is false

        /// OpenAPI Spec "content" or "schema" properties.
        ///
        /// You can access the schema context (if it is in use for
        /// this parameter) with `schemaOrContent.schemaContextValue`.
        /// The schema context contains lots of information detailed in the
        /// OpenAPI specification under the **Parameter Object** section.
        ///
        /// You can directly access the underlying `JSONSchema` with
        /// `schemaOrContent.schemaValue`. If the schema is a reference
        /// instead of an inline value, `schemaOrContent.schemaReference`
        /// will get you the reference.
        ///
        /// You can access the content map (if it is in use for
        /// this parameter) with `schemaOrContent.contentValue`.
        public var schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>

        /// Dictionary of vendor extensions.
        ///
        /// These should be of the form:
        /// `[ "x-extensionKey": <anything>]`
        /// where the values are anything codable.
        public var vendorExtensions: [String: AnyCodable]

        /// Whether or not this parameter is required. See the context
        /// which determines whether the parameter is required or not.
        public var required: Bool { context.required }

        /// The location (e.g. "query") of the parameter.
        ///
        /// See the `context` property for more details on the
        /// parameter.
        public var location: Context.Location { return context.location }

        /// Create a parameter with an `Either<SchemaContext, OpenAPI.Content.Map>`.
        public init(
            name: String,
            context: Context,
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        /// Create a parameter with a `SchemaContext`.
        public init(
            name: String,
            context: Context,
            schema: SchemaContext,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(schema)
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        /// Create a parameter with a `JSONSchema` and the default
        /// `style` for the given `Context`.
        public init(
            name: String,
            context: Context,
            schema: JSONSchema,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(SchemaContext(schema, style: .default(for: context)))
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        /// Create a parameter with a reference to a `JSONSchema`
        /// and the default `style` for the given `Context`.
        public init(
            name: String,
            context: Context,
            schemaReference: OpenAPI.Reference<JSONSchema>,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(SchemaContext(schemaReference: schemaReference, style: .default(for: context)))
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }

        /// Create a parameter with a `Content.Map`.
        public init(
            name: String,
            context: Context,
            content: OpenAPI.Content.Map,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
            self.schemaOrContent = .init(content)
            self.description = description
            self.deprecated = deprecated
            self.vendorExtensions = vendorExtensions
        }
    }
}

extension OpenAPI.Parameter {
    /// An array of parameters that are `Either` `Parameters` or references to parameters.
    ///
    /// You can use the `lookup(_:)` or subscript
    /// methods on the `OpenAPI.Components` found at
    /// `document.components` to resolve an `Either` to
    /// an `OpenAPI.Parameter`.
    public typealias Array = [Either<OpenAPI.Reference<OpenAPI.Parameter>, OpenAPI.Parameter>]
}

extension OpenAPI.Parameter {
    /// A parameter identity is just a hashable struct
    /// containing exactly the things that differentiate
    /// one parameter from another, per the specification.
    ///
    /// See [Parameter Object](https://spec.openapis.org/oas/v3.1.1.html#parameter-object).
    internal struct ParameterIdentity: Hashable {
        let name: String
        let location: Context.Location
    }
}

// MARK: `Either` convenience methods
// OpenAPI.PathItem.Array.Element =>
extension Either where A == OpenAPI.Reference<OpenAPI.Parameter>, B == OpenAPI.Parameter {

    /// Construct a parameter using a `JSONSchema`.
    public static func parameter(
        name: String,
        context: OpenAPI.Parameter.Context,
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

    /// Construct a parameter using a `Content.Map`.
    public static func parameter(
        name: String,
        context: OpenAPI.Parameter.Context,
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

// MARK: - Describable

extension OpenAPI.Parameter : OpenAPIDescribable {
    public func overriddenNonNil(description: String?) -> OpenAPI.Parameter {
        guard let description = description else { return self }
        var parameter = self
        parameter.description = description
        return parameter
    }
}

// MARK: - Codable

extension OpenAPI.Parameter: Encodable {
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

        try container.encodeIfPresent(description, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }

        if VendorExtensionsConfiguration.isEnabled(for: encoder) {
            try encodeExtensions(to: &container)
        }
    }
}

extension OpenAPI.Parameter: Decodable {
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
                throw GenericError(
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

        let maybeSchema: SchemaContext?
        if container.contains(.schema) {
            maybeSchema = try SchemaContext(from: decoder, for: context)
        } else {
            maybeSchema = nil
        }

        switch (maybeContent, maybeSchema) {
        case (let content?, nil):
            schemaOrContent = .init(content)
        case (nil, let schema?):
            schemaOrContent = .init(schema)
        case (nil, nil):
            throw GenericError(
                subjectName: name,
                details: "A parameter must specify either `content` or `schema`",
                codingPath: decoder.codingPath
            )
        case (_, _):
            throw GenericError(
                subjectName: name,
                details: "A parameter must specify one but not both `content` and `schema`",
                codingPath: decoder.codingPath
            )
        }

        description = try container.decodeIfPresent(String.self, forKey: .description)

        deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated) ?? false

        vendorExtensions = try Self.extensions(from: decoder)
    }
}

extension OpenAPI.Parameter {
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
    }
}

extension OpenAPI.Parameter: Validatable {}
