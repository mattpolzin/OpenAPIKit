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
        public var schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map> {
              switch context {
              case .query(required: _, allowEmptyValue: _, schemaOrContent: let schemaOrContent):
                  return schemaOrContent
              case .header(required: _, schemaOrContent: let schemaOrContent):
                  return schemaOrContent
              case .path(schemaOrContent: let schemaOrContent):
                  return schemaOrContent
              case .cookie(required: _, schemaOrContent: let schemaOrContent):
                  return schemaOrContent
              case .querystring(required: _, content: let content):
                  return .content(content)
              }
        }

        /// Create a parameter.
        public init(
            name: String,
            context: Context,
            description: String? = nil,
            deprecated: Bool = false,
            vendorExtensions: [String: AnyCodable] = [:]
        ) {
            self.name = name
            self.context = context
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

// MARK: Convenience constructors
extension OpenAPI.Parameter {
    public static func cookie(
        name: String,
        required: Bool = false,
        schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .cookie(required: required, schemaOrContent: schemaOrContent),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func cookie(
        name: String,
        required: Bool = false,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .cookie(
                required: required,
                content: content
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func cookie(
        name: String,
        required: Bool = false,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .cookie(
                required: required,
                schema: schema
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func cookie(
        name: String,
        required: Bool = false,
        schemaReference: OpenAPI.Reference<JSONSchema>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .cookie(
                required: required,
                schemaOrContent: .schema(.init(schemaReference: schemaReference, style: .default(for: .cookie)))
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func header(
        name: String,
        required: Bool = false,
        schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .header(required: required, schemaOrContent: schemaOrContent),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func header(
        name: String,
        required: Bool = false,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .header(
                required: required, 
                content: content
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func header(
        name: String,
        required: Bool = false,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .header(
                required: required, 
                schema: schema
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func header(
        name: String,
        required: Bool = false,
        schemaReference: OpenAPI.Reference<JSONSchema>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .header(
                required: required, 
                schemaOrContent: .schema(.init(schemaReference: schemaReference, style: .default(for: .header)))
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func path(
        name: String,
        schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .path(schemaOrContent: schemaOrContent),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func path(
        name: String,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .path(content: content),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func path(
        name: String,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .path(schema: schema),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func path(
        name: String,
        schemaReference: OpenAPI.Reference<JSONSchema>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .path(schemaOrContent: .schema(.init(schemaReference: schemaReference, style: .default(for: .path)))),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func query(
        name: String,
        required: Bool = false,
        allowEmptyValue: Bool = false,
        schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .query(required: required, allowEmptyValue: allowEmptyValue, schemaOrContent: schemaOrContent),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func query(
        name: String,
        required: Bool = false,
        allowEmptyValue: Bool = false,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .query(
                required: required,
                allowEmptyValue: allowEmptyValue,
                content: content
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func query(
        name: String,
        required: Bool = false,
        allowEmptyValue: Bool = false,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .query(
                required: required,
                allowEmptyValue: allowEmptyValue,
                schema: schema
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func query(
        name: String,
        required: Bool = false,
        allowEmptyValue: Bool = false,
        schemaReference: OpenAPI.Reference<JSONSchema>,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .query(
                required: required,
                allowEmptyValue: allowEmptyValue,
                schemaOrContent: .schema(.init(schemaReference: schemaReference, style: .default(for: .query)))
            ),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }

    public static func querystring(
        name: String,
        required: Bool = false,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        .init(
            name: name,
            context: .querystring(content: content),
            description: description,
            deprecated: deprecated,
            vendorExtensions: vendorExtensions
        )
    }
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

    /// Construct a parameter.
    public static func parameter(
        name: String,
        context: OpenAPI.Parameter.Context,
        description: String? = nil,
        deprecated: Bool = false,
        vendorExtensions: [String: AnyCodable] = [:]
    ) -> Self {
        return .b(
            .init(
                name: name,
                context: context,
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
        case .query(required: let req, allowEmptyValue: let allowEmptyValue, schemaOrContent: _):
            required = req
            location = .query

            if allowEmptyValue {
                try container.encode(allowEmptyValue, forKey: .allowEmptyValue)
            }
        case .header(required: let req, schemaOrContent: _):
            required = req
            location = .header
        case .path(schemaOrContent: _):
            required = true
            location = .path
        case .cookie(required: let req, schemaOrContent: _):
            required = req
            location = .cookie
        case .querystring(required: let req, content: _):
            required = req
            location = .querystring
        }
        try container.encode(location, forKey: .parameterLocation)

        if required {
            try container.encode(required, forKey: .required)
        }

        switch schemaOrContent {
        case .a(let schema):
            try schema.encode(to: encoder, for: location)
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

        let maybeContent = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content)

        let maybeSchema: SchemaContext?
        if container.contains(.schema) {
            maybeSchema = try SchemaContext(from: decoder, for: location)
        } else {
            maybeSchema = nil
        }

        let schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
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

        switch location {
        case .query:
            let allowEmptyValue = try container.decodeIfPresent(Bool.self, forKey: .allowEmptyValue) ?? false
            context = .query(required: required, allowEmptyValue: allowEmptyValue, schemaOrContent: schemaOrContent)
        case .header:
            context = .header(required: required, schemaOrContent: schemaOrContent)
        case .path:
            if !required {
                throw GenericError(
                    subjectName: name,
                    details: "positional path parameters must be explicitly set to required",
                    codingPath: decoder.codingPath
                )
            }
            context = .path(schemaOrContent: schemaOrContent)
        case .cookie:
            context = .cookie(required: required, schemaOrContent: schemaOrContent)
        case .querystring:
            guard case .b(let content) = schemaOrContent else {
                throw GenericError(
                    subjectName: name,
                    details: "`schema` and `style` are disallowed for `querystring` parameters",
                    codingPath: decoder.codingPath
                )
            }
            context = .querystring(required: required, content: content)
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
