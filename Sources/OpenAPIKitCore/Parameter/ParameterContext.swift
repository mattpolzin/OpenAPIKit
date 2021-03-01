//
//  ParameterContext.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI.Parameter {
    /// OpenAPI Spec "Parameter Object" location-specific configuration.
    /// 
    /// See [OpenAPI Parameter Locations](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#parameter-locations).
    ///
    /// Query, Header, and Cookie parameters are
    /// all optional by default unless you pass
    /// `required: true` to the context construction.
    /// Path parameters are always required.
    public enum Context: Equatable {
        case query(required: Bool, allowEmptyValue: Bool)
        case header(required: Bool)
        case path
        case cookie(required: Bool)

        public static func query(required: Bool) -> Context { return .query(required: required, allowEmptyValue: false) }

        public static func query(allowEmptyValue: Bool) -> Context { return .query(required: false, allowEmptyValue: allowEmptyValue) }

        /// An optional query parameter that does not allow
        /// empty values.
        public static var query: Context { return .query(required: false, allowEmptyValue: false) }

        /// An optional header parameter.
        public static var header: Context { return .header(required: false) }

        /// An optional cookie parameter.
        public static var cookie: Context { return .cookie(required: false) }

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

        public var inPath: Bool { return self == .path }

        public var inCookie: Bool {
            guard case .cookie = self else {
                return false
            }
            return true
        }

        public var required: Bool {
            switch self {
            case .query(required: let required, allowEmptyValue: _),
                 .header(required: let required),
                 .cookie(required: let required):
                return required
            case .path:
                return true
            }
        }
    }
}

extension OpenAPI.Parameter.Context {
    public enum Location: String, CaseIterable, Codable {
        case query
        case header
        case path
        case cookie
    }

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
        }
    }
}

extension OpenAPI.Parameter.Context.Location: Validatable {}
