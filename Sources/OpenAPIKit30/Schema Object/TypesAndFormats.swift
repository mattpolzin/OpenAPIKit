//
//  TypesAndFormats.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import OpenAPIKitCore

// MARK: Types
/// An OpenAPI type with an associated value representing its Swift type.
///
/// For example, `JSONTypeFormat.BooleanFormat` is associated with
/// the `Bool` Swift type.
public protocol SwiftTyped {
    associatedtype SwiftType: Codable, Equatable
}

/// The raw types supported by JSON Schema.
///
/// These are the OpenAPI [data types](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#data-types)
/// and additionally the `object` and `array`
/// "compound" data types.
/// - boolean
/// - object
/// - array
/// - number
/// - integer
/// - string
public enum JSONType: String, Codable {
    case boolean = "boolean"
    case object = "object"
    case array = "array"
    case number = "number"
    case integer = "integer"
    case string = "string"

    public var group: String {
        switch self {
        case .boolean: return "boolean"
        case .object: return "object"
        case .array: return "array"
        case .number, .integer: return "number/integer"
        case .string: return "string"
        }
    }
}

/// The combination of a JSON Schema type and format.
///
/// See the `JSONType` and `OpenAPIFormat`
/// types for more information on each.
///
/// You can also find information on types and
/// formats in the OpenAPI Specification's
/// section on [data types](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#data-types).
public enum JSONTypeFormat: Equatable {
    case boolean(BooleanFormat)
    case object(ObjectFormat)
    case array(ArrayFormat)
    case number(NumberFormat)
    case integer(IntegerFormat)
    case string(StringFormat)

    public var jsonType: JSONType {
        switch self {
        case .boolean:
            return .boolean
        case .object:
            return .object
        case .array:
            return .array
        case .number:
            return .number
        case .integer:
            return .integer
        case .string:
            return .string
        }
    }

    public var swiftType: Any.Type {
        switch self {
        case .boolean(let format):
            return type(of: format).SwiftType.self
        case .object(let format):
            return type(of: format).SwiftType.self
        case .array(let format):
            return type(of: format).SwiftType.self
        case .number(let format):
            return type(of: format).SwiftType.self
        case .integer(let format):
            return type(of: format).SwiftType.self
        case .string(let format):
            return type(of: format).SwiftType.self
        }
    }
}

// MARK: Formats
/// OpenAPI formats represent the valid formats a
/// raw type can take on to better specify its allowed
/// values and intended semantics.
///
/// For example, a `string` might have the `date-time` format, indicating
/// it is representative of a date/time and also indicating its format
/// adheres to the [RFC3339](https://xml2rfc.ietf.org/public/rfc/html/rfc3339.html#anchor14)
/// specification for a "date-time."
///
/// See "formats" under the OpenAPI [data type](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.3.md#data-types)
/// documentation.
public protocol OpenAPIFormat: SwiftTyped, Codable, Equatable, RawRepresentable, Validatable where RawValue == String {
    static var unspecified: Self { get }

    var jsonType: JSONType { get }
}

/// These are just the OpenAPIFormats that are specific to this module; there are shared
/// formats in OpenAPIKitCore/Shared/JSONTypeFormat.swift as well.
extension JSONTypeFormat {
    /// The allowed "format" properties for `.string` schemas.
    public enum StringFormat: RawRepresentable, Equatable {
        case generic
        case byte
        case binary
        case date
        /// A string instance is valid against this attribute if it is a valid
        /// date representation as defined by
        /// https://tools.ietf.org/html/rfc3339#section-5.6
        case dateTime
        case password
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .byte: return "byte"
            case .binary: return "binary"
            case .date: return "date"
            case .dateTime: return "date-time"
            case .password: return "password"
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            case "byte": self = .byte
            case "binary": self = .binary
            case "date": self = .date
            case "date-time": self = .dateTime
            case "password": self = .password
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = String

        public static var unspecified: StringFormat {
            return .generic
        }
    }
}

extension JSONTypeFormat.StringFormat {

    /// Popular non-standard "format" properties for `.string` schemas.
    ///
    /// Specify with e.g. `.string(format: .extended(.uuid))`
    public enum Extended: String, Equatable {
        case uuid = "uuid"
        case email = "email"
        case hostname = "hostname"
        case ipv4 = "ipv4"
        case ipv6 = "ipv6"
            /// A string instance is valid against this attribute if it is a valid
            /// URI, according to
            /// https://tools.ietf.org/html/rfc3986
        case uri = "uri"
            /// A string instance is valid against this attribute if it is a valid
            /// URI, according to
            /// https://tools.ietf.org/html/rfc3986
        case uriReference = "uriref"
    }

    public static func extended(_ format: Extended) -> Self {
        return .other(format.rawValue)
    }
}

/// A format used when no type is known or any type is allowed.
///
/// There are no built-in formats that do not have an associated
/// type, but it is still important to be able to specify a format without
/// a type. This can come into play when writing fragments of schemas
/// to be combined later.
extension JSONTypeFormat.AnyFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .object
    }
}

/// The allowed "format" properties for `.boolean` schemas.
extension JSONTypeFormat.BooleanFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .boolean
    }
}

/// The allowed "format" properties for `.object` schemas.
extension JSONTypeFormat.ObjectFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .object
    }
}

/// The allowed "format" properties for `.array` schemas.
extension JSONTypeFormat.ArrayFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .array
    }
}

/// The allowed "format" properties for `.number` schemas.
extension JSONTypeFormat.NumberFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .number
    }
}

/// The allowed "format" properties for `.integer` schemas.
extension JSONTypeFormat.IntegerFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .integer
    }
}

/// The allowed "format" properties for `.string` schemas.
extension JSONTypeFormat.StringFormat: OpenAPIFormat {
    public var jsonType: JSONType {
        return .string
    }
}

extension JSONType: Validatable {}
