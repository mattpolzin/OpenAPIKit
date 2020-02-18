//
//  TypesAndFormats.swift
//  
//
//  Created by Mathew Polzin on 6/22/19.
//

import Foundation
import AnyCodable

// MARK: Types
public protocol SwiftTyped {
    associatedtype SwiftType: Codable, Equatable
}

public enum JSONType: String, Codable {
    case boolean = "boolean"
    case object = "object"
    case array = "array"
    case number = "number"
    case integer = "integer"
    case string = "string"
}

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
public protocol OpenAPIFormat: SwiftTyped, Codable, Equatable {
    static var unspecified: Self { get }

    var jsonType: JSONType { get }
}

extension JSONTypeFormat {
    public enum BooleanFormat: RawRepresentable, Equatable, OpenAPIFormat {
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

        public var jsonType: JSONType {
            return .boolean
        }
    }

    public enum ObjectFormat: RawRepresentable, Equatable, OpenAPIFormat {
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

        public var jsonType: JSONType {
            return .object
        }
    }

    public enum ArrayFormat: RawRepresentable, Equatable, OpenAPIFormat {
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

        public var jsonType: JSONType {
            return .array
        }
    }

    public enum NumberFormat: RawRepresentable, Equatable, OpenAPIFormat {
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

        public var jsonType: JSONType {
            return .number
        }
    }

    public enum IntegerFormat: RawRepresentable, Equatable, OpenAPIFormat {
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

        public var jsonType: JSONType {
            return .integer
        }
    }

    public enum StringFormat: RawRepresentable, Equatable, OpenAPIFormat {
        case generic
        case byte
        case binary
        case date
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

        public var jsonType: JSONType {
            return .string
        }
    }
}

extension JSONTypeFormat.StringFormat {
    public enum Extended {
        public static let uuid: JSONTypeFormat.StringFormat = .other("uuid")
        public static let email: JSONTypeFormat.StringFormat = .other("email")
    }
}

extension JSONTypeFormat.IntegerFormat {
    public enum Extended {
        public static let uint32: JSONTypeFormat.IntegerFormat = .other("uint32")
        public static let uint64: JSONTypeFormat.IntegerFormat = .other("uint64")
    }
}
