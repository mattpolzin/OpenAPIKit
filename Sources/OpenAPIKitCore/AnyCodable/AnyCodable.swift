/*
    Copyright 2018 Read Evaluate Press, LLC

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*/

import Foundation

/**
 A type-erased `Codable` value.

 The `AnyCodable` type forwards encoding and decoding responsibilities
 to an underlying value, hiding its specific underlying type.

 You can encode or decode mixed-type values in dictionaries
 and other collections that require `Encodable` or `Decodable` conformance
 by declaring their contained type to be `AnyCodable`.
 */
public enum AnyCodable: Equatable {
    
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case object([String: AnyCodable])
    case array([AnyCodable])
    case null
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(value): try value.encode(to: encoder)
        case let .bool(value): try value.encode(to: encoder)
        case let .int(value): try value.encode(to: encoder)
        case let .double(value): try value.encode(to: encoder)
        case let .object(value): try value.encode(to: encoder)
        case let .array(value): try value.encode(to: encoder)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

extension AnyCodable: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self = .array(array)
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self = .object(dictionary)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let string):
            return "\"\(string.description)\""
        case .bool(let bool):
            return bool.description
        case .int(let int):
            return int.description
        case .double(let double):
            return double.description
        case .object(let dictionary):
            return "[\(dictionary.sorted(by: { $0.key < $1.key }).map { "\"\($0)\": \($1.description)" }.joined(separator: ", "))]"
        case .array(let array):
            return "[\(array.map { $0.description }.joined(separator: ", "))]"
        case .null:
            return "nil"
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        "AnyCodable(\(description))"
    }
}

extension AnyCodable: ExpressibleByNilLiteral {}
extension AnyCodable: ExpressibleByBooleanLiteral {}
extension AnyCodable: ExpressibleByIntegerLiteral {}
extension AnyCodable: ExpressibleByFloatLiteral {}
extension AnyCodable: ExpressibleByStringLiteral {}
extension AnyCodable: ExpressibleByArrayLiteral {}
extension AnyCodable: ExpressibleByDictionaryLiteral {}

extension AnyCodable {
    public init(nilLiteral _: ()) {
        self = .null
    }

    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }

    public init(integerLiteral value: Int) {
        self = .int(value)
    }

    public init(floatLiteral value: Double) {
        self = .double(value)
    }

    public init(stringLiteral value: String) {
        self = .string(value)
    }

    public init(arrayLiteral elements: AnyCodable...) {
        self = .array(elements)
    }

    public init(dictionaryLiteral elements: (String, AnyCodable)...) {
        self = .object([String: AnyCodable](elements, uniquingKeysWith: { first, _ in first }))
    }
}

extension AnyCodable {

    @available(*, deprecated, message: "`value` doesn't present the value was wrapped anymore, use typed vars or switch instead")
    public var value: Any {
        switch self {
        case .string(let string):
            return string
        case .bool(let bool):
            return bool
        case .int(let int):
            return int
        case .double(let double):
            return double
        case .object(let dictionary):
            return dictionary.mapValues { $0.value }
        case .array(let array):
            return array.map { $0.value }
        case .null:
            return Optional<Any>.none as Any
        }
    }
    
    public var string: String? {
        if case let .string(string) = self {
            return string
        }
        return nil
    }
    
    public var bool: Bool? {
        if case let .bool(bool) = self {
            return bool
        }
        return nil
    }
    
    public var int: Int? {
        if case let .int(int) = self {
            return int
        }
        return nil
    }
    
    public var double: Double? {
        if case let .double(double) = self {
            return double
        }
        return nil
    }
    
    public var object: [String: AnyCodable]? {
        if case let .object(object) = self {
            return object
        }
        return nil
    }
    
    public var array: [AnyCodable]? {
        if case let .array(array) = self {
            return array
        }
        return nil
    }
    
    public var isNull: Bool {
        if case .null = self {
            return true
        }
        return false
    }
    
    public init(_ value: Any?) {
        guard var value = value else {
            self = .null
            return
        }
        while let optional = value as? OptionalProtocol {
            if let unwrapped = optional.anyValue {
                value = unwrapped
            } else {
                self = .null
                return
            }
        }
        switch value {
        case let anyCodable as AnyCodable:
            self = anyCodable
        case is NSNull, is Void:
            self = .null
        case let bool as Bool:
            self = .bool(bool)
        case let int as Int:
            self = .int(int)
        case let int8 as Int8:
            self = .int(Int(int8))
        case let int16 as Int16:
            self = .int(Int(int16))
        case let int32 as Int32:
            self = .int(Int(int32))
        case let int64 as Int64:
            self = .int(Int(int64))
        case let uint as UInt:
            self = .int(Int(uint))
        case let uint8 as UInt8:
            self = .int(Int(uint8))
        case let uint16 as UInt16:
            self = .int(Int(uint16))
        case let uint32 as UInt32:
            self = .int(Int(uint32))
        case let uint64 as UInt64:
            self = .int(Int(min(uint64, UInt64(Int.max))))
        case let float as Float:
            self = .double(Double(float))
        case let double as Double:
            self = .double(double)
        case let string as String:
            self = .string(string)
        case let date as Date:
            self = .double(date.timeIntervalSince1970)
        case let url as URL:
            self = .string(url.absoluteString)
        case let array as [Any?]:
            self = .array(array.map { AnyCodable($0) })
        case let dictionary as [String: Any?]:
            self = .object(dictionary.mapValues { AnyCodable($0) })
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        case let number as NSNumber:
            self = .encode(nsnumber: number)
#endif
        default:
            if let encodable = value as? Encodable, let anyCodable = try? AnyCodable.encoded(encodable) {
                self = anyCodable
                return
            }
            let mirror = Mirror(reflecting: value)
            switch mirror.displayStyle {
            case .optional:
                if mirror.children.isEmpty {
                    self = .null
                } else {
                    self = AnyCodable(mirror.children.first?.value)
                }
            case .collection, .set:
                self = .array(mirror.children.map { AnyCodable($0.value) })
            default:
                if mirror.children.isEmpty {
                    self = .string("\(value)")
                } else {
                    self = .object(
                        mirror.children.reduce(into: [String: AnyCodable]()) { result, child in
                            result[child.label ?? ".\(result.count)"] = AnyCodable(child.value)
                        }
                    )
                }
            }
        }
    }
}

private extension AnyCodable {
    
    static func encode(nsnumber: NSNumber) -> AnyCodable {
        switch CFNumberGetType(nsnumber) {
        case .charType, .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type,
                .shortType, .longType, .longLongType, .intType, .nsIntegerType, .cfIndexType:
            return .int(nsnumber.intValue)
        case .floatType, .float32Type, .doubleType, .float64Type, .cgFloatType:
            return .double(nsnumber.doubleValue)
#if swift(>=5.0)
        @unknown default:
            fatalError()
#endif
        }
    }
}

private protocol OptionalProtocol {

    var anyValue: Any? { get }
}

extension Optional: OptionalProtocol {

    var anyValue: Any? { self }
}
