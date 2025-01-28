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

 Note that there are some caveats related to the fact that this type centers around
 encoding/decoding values. For example, some technically distinct nil-like types
 are all encoded as `nil` and compare equally under the `AnyCodable` type:
   - `nil`
   - `NSNull()`
   - `Void()`
 */
public struct AnyCodable: @unchecked Sendable {
    // IMPORTANT: 
    //  We rely on the fact that AnyCodable can only be constructed with an initializer that knows
    //  the type of its argument to be Sendable in order to confidently state that AnyCodable itself
    //  is @unchecked Sendable.
    public let value: Any

    public init<T: Sendable>(_ value: T?) {
        self.value = value ?? ()
    }

    // Dangerous, but we use this below where we must transform AnyCodable by e.g. mapping on its value
    fileprivate init(trusted value: Any) {
        self.value = value
    }
}

protocol _Optional {
    var isNil: Bool { get }
}

extension Optional: _Optional {
    var isNil: Bool { self == nil }
}

extension NSNull: _Optional {
    var isNil: Bool { true }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        // special nil case
        if let optionalValue = value as? _Optional, optionalValue.isNil {
          try container.encodeNil()
          return
        }

        switch value {
            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        case let number as NSNumber:
            try encode(nsnumber: number, into: &container)
            #endif
        case is NSNull, is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let int8 as Int8:
            try container.encode(int8)
        case let int16 as Int16:
            try container.encode(int16)
        case let int32 as Int32:
            try container.encode(int32)
        case let int64 as Int64:
            try container.encode(int64)
        case let uint as UInt:
            try container.encode(uint)
        case let uint8 as UInt8:
            try container.encode(uint8)
        case let uint16 as UInt16:
            try container.encode(uint16)
        case let uint32 as UInt32:
            try container.encode(uint32)
        case let uint64 as UInt64:
            try container.encode(uint64)
        case let float as Float:
            try container.encode(float)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let date as Date:
            try container.encode(date)
        case let url as URL:
            try container.encode(url)
        case let array as [(any Sendable)?]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: (any Sendable)?]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        case let encodableValue as Encodable:
            try container.encode(encodableValue)
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    private func encode(nsnumber: NSNumber, into container: inout SingleValueEncodingContainer) throws {
        switch CFNumberGetType(nsnumber) {
        case .charType:
            try container.encode(nsnumber.boolValue)
        case .sInt8Type:
            try container.encode(nsnumber.int8Value)
        case .sInt16Type:
            try container.encode(nsnumber.int16Value)
        case .sInt32Type:
            try container.encode(nsnumber.int32Value)
        case .sInt64Type:
            try container.encode(nsnumber.int64Value)
        case .shortType:
            try container.encode(nsnumber.uint16Value)
        case .longType:
            try container.encode(nsnumber.uint32Value)
        case .longLongType:
            try container.encode(nsnumber.uint64Value)
        case .intType, .nsIntegerType, .cfIndexType:
            try container.encode(nsnumber.intValue)
        case .floatType, .float32Type:
            try container.encode(nsnumber.floatValue)
        case .doubleType, .float64Type, .cgFloatType:
            try container.encode(nsnumber.doubleValue)
            #if swift(>=5.0)
        @unknown default:
            fatalError()
            #endif
        }
    }
    #endif
}

extension AnyCodable: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.init(NSNull())
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([AnyCodable].self) {
            self.init(trusted: array.map { $0.value })
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.init(trusted: dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
}

func isNilEquivalent(value: AnyCodable) -> Bool {
    let valueIsNil: Bool

    if let optionalValue = value.value as? _Optional,
           optionalValue.isNil {
        valueIsNil = true
    } else if let _ = value.value as? Void {
        valueIsNil = true
    } else {
        valueIsNil = false
    }

    return valueIsNil
}

extension AnyCodable: Equatable {
    public static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // special case for nil
        if isNilEquivalent(value: lhs) && isNilEquivalent(value: rhs) {
            return true
        }

        switch (lhs.value, rhs.value) {
        case is (Void, Void):
            return true
        case let (lhs as Bool, rhs as Bool):
            return lhs == rhs
        case let (lhs as Int, rhs as Int):
            return lhs == rhs
        case let (lhs as Int8, rhs as Int8):
            return lhs == rhs
        case let (lhs as Int16, rhs as Int16):
            return lhs == rhs
        case let (lhs as Int32, rhs as Int32):
            return lhs == rhs
        case let (lhs as Int64, rhs as Int64):
            return lhs == rhs
        case let (lhs as UInt, rhs as UInt):
            return lhs == rhs
        case let (lhs as UInt8, rhs as UInt8):
            return lhs == rhs
        case let (lhs as UInt16, rhs as UInt16):
            return lhs == rhs
        case let (lhs as UInt32, rhs as UInt32):
            return lhs == rhs
        case let (lhs as UInt64, rhs as UInt64):
            return lhs == rhs
        case let (lhs as Float, rhs as Float):
            return lhs == rhs
        case let (lhs as Double, rhs as Double):
            return lhs == rhs
        case let (lhs as String, rhs as String):
            return lhs == rhs
        case let (lhs as URL, rhs as URL):
            return lhs == rhs
        case let (lhs as [String: String], rhs as [String: String]):
            return lhs == rhs
        case let (lhs as [String: Int], rhs as [String: Int]):
            return lhs == rhs
        case let (lhs as [String: Double], rhs as [String: Double]):
            return lhs == rhs
        case let (lhs as [String: Bool], rhs as [String: Bool]):
            return lhs == rhs
        case let (lhs as [String: AnyCodable], rhs as [String: AnyCodable]):
            return lhs == rhs
        case let (lhs as [String: Any], rhs as [String: Any]):
            return lhs.mapValues(AnyCodable.init) == rhs.mapValues(AnyCodable.init)
        case let (lhs as [String], rhs as [String]):
            return lhs == rhs
        case let (lhs as [Int], rhs as [Int]):
            return lhs == rhs
        case let (lhs as [Double], rhs as [Double]):
            return lhs == rhs
        case let (lhs as [Bool], rhs as [Bool]):
            return lhs == rhs
        case let (lhs as [AnyCodable], rhs as [AnyCodable]):
            return lhs == rhs
        case let (lhs as [Any], rhs as [Any]):
            return lhs.map(AnyCodable.init) == rhs.map(AnyCodable.init)
        default:
            return false
        }
    }
}

extension AnyCodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

extension AnyCodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyCodable(\(value.debugDescription))"
        default:
            return "AnyCodable(\(description))"
        }
    }
}

extension AnyCodable: ExpressibleByNilLiteral {}
extension AnyCodable: ExpressibleByBooleanLiteral {}
extension AnyCodable: ExpressibleByIntegerLiteral {}
extension AnyCodable: ExpressibleByFloatLiteral {}
extension AnyCodable: ExpressibleByStringLiteral {}

extension AnyCodable {
    public init(nilLiteral _: ()) {
        self.init(trusted: (nil as Any?) as Any)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(floatLiteral value: Double) {
        self.init(value)
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }
}
