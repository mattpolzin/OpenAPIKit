//
//  ParameterContext.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

import OpenAPIKitCore

extension OpenAPI.Parameter {
    /// OpenAPI Spec "Parameter Object" location-specific configuration.
    /// 
    /// See [OpenAPI Parameter Locations](https://spec.openapis.org/oas/v3.1.1.html#parameter-locations).
    ///
    /// Query, Header, and Cookie parameters are
    /// all optional by default unless you pass
    /// `required: true` to the context construction.
    /// Path parameters are always required.
    public enum Context: Equatable, Sendable {
        case query(required: Bool, allowEmptyValue: Bool, schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>)
        case header(required: Bool, schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>)
        case path(schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>)
        case cookie(required: Bool, schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>)
        case querystring(required: Bool, content: OpenAPI.Content.Map)

        /// A query parameter that does not allow empty values.
        public static func query(
            required: Bool = false,
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
        ) -> Context { return .query(required: required, allowEmptyValue: false, schemaOrContent: schemaOrContent) }

        /// A query parameter that is not required.
        public static func query(
            allowEmptyValue: Bool,
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
        ) -> Context { return .query(required: false, allowEmptyValue: allowEmptyValue, schemaOrContent: schemaOrContent) }

        public static func query(
            required: Bool = false,
            allowEmptyValue: Bool = false,
            schema: JSONSchema
        ) -> Context { return .query(required: required, allowEmptyValue: allowEmptyValue, schemaOrContent: .schema(.init(schema, style: .default(for: .query)))) }

        public static func query(
            required: Bool = false,
            allowEmptyValue: Bool = false,
            content: OpenAPI.Content.Map
        ) -> Context { return .query(required: required, allowEmptyValue: allowEmptyValue, schemaOrContent: .content(content)) }

        /// An optional header parameter.
        public static func header(
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
        ) -> Context { return .header(required: false, schemaOrContent: schemaOrContent) }

        public static func header(
            required: Bool = false,
            schema: JSONSchema
        ) -> Context { return .header(required: required, schemaOrContent: .schema(.init(schema, style: .default(for: .header)))) }

        public static func header(
            required: Bool = false,
            content: OpenAPI.Content.Map
        ) -> Context { return .header(required: required, schemaOrContent: .content(content)) }

        /// An optional cookie parameter.
        public static func cookie(
            schemaOrContent: Either<SchemaContext, OpenAPI.Content.Map>
        ) ->  Context { return .cookie(required: false, schemaOrContent: schemaOrContent) }

        public static func cookie(
            required: Bool = false,
            schema: JSONSchema
        ) ->  Context { return .cookie(required: required, schemaOrContent: .schema(.init(schema, style: .default(for: .cookie)))) }

        public static func cookie(
            required: Bool = false,
            content: OpenAPI.Content.Map
        ) ->  Context { return .cookie(required: required, schemaOrContent: .content(content)) }

        public static func path(
            schema: JSONSchema
        ) -> Context { return .path(schemaOrContent: .schema(.init(schema, style: .default(for: .path)))) }

        public static func path(
            content: OpenAPI.Content.Map
        ) -> Context { return .path(schemaOrContent: .content(content)) }

        /// An optional querystring parameter.
        public static func querystring(
            content: OpenAPI.Content.Map
        ) ->  Context { return .querystring(required: false, content: content) }

        public var inQuery: Bool {
            guard case .query = self else {
                return false
            }
            return true
        }

        public var inHeader: Bool {
            guard case .header = self else {
                return false
            }
            return true
        }

        public var inPath: Bool { 
            guard case .path = self else {
                return false
            }
            return true
        }

        public var inCookie: Bool {
            guard case .cookie = self else {
                return false
            }
            return true
        }

        public var inQuerystring: Bool {
            guard case .querystring = self else {
                return false
            }
            return true
        }

        public var required: Bool {
            switch self {
            case .query(required: let required, allowEmptyValue: _, schemaOrContent: _),
                 .header(required: let required, schemaOrContent: _),
                 .cookie(required: let required, schemaOrContent: _),
                 .querystring(required: let required, content: _):
                return required
            case .path(schemaOrContent: _):
                return true
            }
        }
    }
}

extension OpenAPI.Parameter.Context {
    public var location: Location {
        switch self {
        case .query:
            return .query
        case .header:
            return .header
        case .path:
            return .path
        case .cookie:
            return .cookie
        case .querystring:
            return .querystring
        }
    }
}
