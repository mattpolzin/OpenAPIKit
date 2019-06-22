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
}

// MARK: Formats
public protocol OpenAPIFormat: SwiftTyped, Codable, Equatable {
    static var unspecified: Self { get }

    var jsonType: JSONType { get }
}

extension JSONTypeFormat {
    public enum BooleanFormat: String, Equatable, OpenAPIFormat {
        case generic = ""

        public typealias SwiftType = Bool

        public static var unspecified: BooleanFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .boolean
        }
    }

    public enum ObjectFormat: String, Equatable, OpenAPIFormat {
        case generic = ""

        public typealias SwiftType = AnyCodable

        public static var unspecified: ObjectFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .object
        }
    }

    public enum ArrayFormat: String, Equatable, OpenAPIFormat {
        case generic = ""

        public typealias SwiftType = [AnyCodable]

        public static var unspecified: ArrayFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .array
        }
    }

    public enum NumberFormat: String, Equatable, OpenAPIFormat {
        case generic = ""
        case float = "float"
        case double = "double"

        public typealias SwiftType = Double

        public static var unspecified: NumberFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .number
        }
    }

    public enum IntegerFormat: String, Equatable, OpenAPIFormat {
        case generic = ""
        case int32 = "int32"
        case int64 = "int64"

        public typealias SwiftType = Int

        public static var unspecified: IntegerFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .integer
        }
    }

    public enum StringFormat: String, Equatable, OpenAPIFormat {
        case generic = ""
        case byte = "byte"
        case binary = "binary"
        case date = "date"
        case dateTime = "date-time"
        case password = "password"

        public typealias SwiftType = String

        public static var unspecified: StringFormat {
            return .generic
        }

        public var jsonType: JSONType {
            return .string
        }
    }
}
