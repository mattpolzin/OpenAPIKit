//
//  JSONTypeFormat.swift
//  
//
//  Created by Mathew Polzin on 12/17/22.
//


extension Shared {
    /// A format used when no type is known or any type is allowed.
    ///
    /// There are no built-in formats that do not have an associated
    /// type, but it is still important to be able to specify a format without
    /// a type. This can come into play when writing fragments of schemas
    /// to be combined later.
    public enum AnyFormat: RawRepresentable, Equatable {
        case generic
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = AnyCodable

        public static var unspecified: AnyFormat {
            return .generic
        }
    }

    /// The allowed "format" properties for `.boolean` schemas.
    public enum BooleanFormat: RawRepresentable, Equatable {
        case generic
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = Bool

        public static var unspecified: BooleanFormat {
            return .generic
        }
    }

    /// The allowed "format" properties for `.object` schemas.
    public enum ObjectFormat: RawRepresentable, Equatable {
        case generic
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = AnyCodable

        public static var unspecified: ObjectFormat {
            return .generic
        }
    }

    /// The allowed "format" properties for `.array` schemas.
    public enum ArrayFormat: RawRepresentable, Equatable {
        case generic
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = [AnyCodable]

        public static var unspecified: ArrayFormat {
            return .generic
        }
    }

    /// The allowed "format" properties for `.number` schemas.
    public enum NumberFormat: RawRepresentable, Equatable {
        case generic
        case float
        case double
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .float: return "float"
            case .double: return "double"
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            case "float": self = .float
            case "double": self = .double
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = Double

        public static var unspecified: NumberFormat {
            return .generic
        }
    }

    /// The allowed "format" properties for `.integer` schemas.
    public enum IntegerFormat: RawRepresentable, Equatable {
        case generic
        case int32
        case int64
        case other(String)

        public var rawValue: String {
            switch self {
            case .generic: return ""
            case .int32: return "int32"
            case .int64: return "int64"
            case .other(let other):
                return other
            }
        }

        public init(rawValue: String) {
            switch rawValue {
            case "": self = .generic
            case "int32": self = .int32
            case "int64": self = .int64
            default: self = .other(rawValue)
            }
        }

        public typealias SwiftType = Int

        public static var unspecified: IntegerFormat {
            return .generic
        }
    }

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

extension Shared.StringFormat {
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

extension Shared.IntegerFormat {
    /// Popular non-standard "format" properties for `.integer` schemas.
    ///
    /// Specify with e.g. `.integer(format: .extended(.uint32))`
    public enum Extended: String, Equatable {
        case uint32 = "uint32"
        case uint64 = "uint64"
    }

    public static func extended(_ format: Extended) -> Self {
        return .other(format.rawValue)
    }
}
