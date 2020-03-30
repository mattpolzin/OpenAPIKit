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
    public struct Parameter: Equatable {
        public var name: String

        /// OpenAPI Spec "in" property.
        public var parameterLocation: Location
        public var description: String?
        public var deprecated: Bool // default is false

        /// OpenAPI Spec "content" or "schema" properties.
        public var schemaOrContent: Either<Schema, OpenAPI.Content.Map>

        public var required: Bool { parameterLocation.required }

        /// An array of parameters that are `Either` `Parameters` or references to parameters.
        public typealias Array = [Either<JSONReference<Parameter>, Parameter>]

        public init(name: String,
                    parameterLocation: Location,
                    schemaOrContent: Either<Schema, OpenAPI.Content.Map>,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = schemaOrContent
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schema: Schema,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(schema)
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schema: JSONSchema,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(Schema(schema, style: .default(for: parameterLocation)))
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    schemaReference: JSONReference<JSONSchema>,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(Schema(schemaReference: schemaReference, style: .default(for: parameterLocation)))
            self.description = description
            self.deprecated = deprecated
        }

        public init(name: String,
                    parameterLocation: Location,
                    content: OpenAPI.Content.Map,
                    description: String? = nil,
                    deprecated: Bool = false) {
            self.name = name
            self.parameterLocation = parameterLocation
            self.schemaOrContent = .init(content)
            self.description = description
            self.deprecated = deprecated
        }
    }
}

// MARK: `Either` convenience methods
// OpenAPI.PathItem.Array.Element =>
extension Either where A == JSONReference<OpenAPI.PathItem.Parameter>, B == OpenAPI.PathItem.Parameter {

    /// Construct a parameter.
    public static func parameter(
        name: String,
        parameterLocation: OpenAPI.PathItem.Parameter.Location,
        schema: JSONSchema,
        description: String? = nil,
        deprecated: Bool = false
    ) -> Self {
        return .b(
            .init(
                name: name,
                parameterLocation: parameterLocation,
                schema: schema,
                description: description,
                deprecated: deprecated
            )
        )
    }

    /// Construct a parameter.
    public static func parameter(
        name: String,
        parameterLocation: OpenAPI.PathItem.Parameter.Location,
        content: OpenAPI.Content.Map,
        description: String? = nil,
        deprecated: Bool = false
    ) -> Self {
        return .b(
            .init(
                name: name,
                parameterLocation: parameterLocation,
                content: content,
                description: description,
                deprecated: deprecated
            )
        )
    }
}

// MARK: - Codable
extension OpenAPI.PathItem.Parameter {
    private enum CodingKeys: String, CodingKey {
        case name
        case parameterLocation = "in"
        case description
        case required
        case deprecated
        case allowEmptyValue

        // the following are alternatives
        case content
        case schema
    }

    private enum LocationString: String, Codable {
        case query
        case header
        case path
        case cookie
    }
}

extension OpenAPI.PathItem.Parameter: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)

        let required: Bool
        let location: LocationString
        switch parameterLocation {
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
            try schema.encode(to: encoder, for: parameterLocation)
        case .b(let contentMap):
            try container.encode(contentMap, forKey: .content)
        }

        try description.encodeIfNotNil(to: &container, forKey: .description)

        if deprecated {
            try container.encode(deprecated, forKey: .deprecated)
        }
    }
}

extension OpenAPI.PathItem.Parameter: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let name = try container.decode(String.self, forKey: .name)
        self.name = name

        let required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        let location = try container.decode(LocationString.self, forKey: .parameterLocation)

        switch location {
        case .query:
            let allowEmptyValue = try container.decodeIfPresent(Bool.self, forKey: .allowEmptyValue) ?? false
            parameterLocation = .query(required: required, allowEmptyValue: allowEmptyValue)
        case .header:
            parameterLocation = .header(required: required)
        case .path:
            if !required {
                throw InconsistencyError(
                    subjectName: name,
                    details: "positional path parameters must be explicitly set to required",
                    codingPath: decoder.codingPath
                )
            }
            parameterLocation = .path
        case .cookie:
            parameterLocation = .cookie(required: required)
        }

        let maybeContent = try container.decodeIfPresent(OpenAPI.Content.Map.self, forKey: .content)

        let maybeSchema: Schema?
        if container.contains(.schema) {
            maybeSchema = try Schema(from: decoder, for: parameterLocation)
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
    }
}
