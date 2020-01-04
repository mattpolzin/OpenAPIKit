//
//  ParameterLocation.swift
//  
//
//  Created by Mathew Polzin on 12/29/19.
//

extension OpenAPI.PathItem.Parameter {
    public enum Location: Equatable {
        case query(required: Bool, allowEmptyValue: Bool)
        case header(required: Bool)
        case path
        case cookie(required: Bool)

        public static func query(required: Bool) -> Location { return .query(required: required, allowEmptyValue: false) }

        public static func query(allowEmptyValue: Bool) -> Location { return .query(required: false, allowEmptyValue: allowEmptyValue) }

        public static var query: Location { return .query(required: false, allowEmptyValue: false) }

        public static var header: Location { return .header(required: false) }

        public static var cookie: Location { return .cookie(required: false) }

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
