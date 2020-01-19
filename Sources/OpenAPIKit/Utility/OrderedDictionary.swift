//
//  OrderedDictionary.swift
//  
//
//  Created by Mathew Polzin on 1/17/20.
//

import Foundation
import AnyCodable

/// A simple implementation of an Ordered Dictionary based
/// on the existing Foundation `Dictionary` and `Array` types.
/// Undoubtedly not the fastest performer, but should be sufficient
/// for the purposes of this library.
///
/// The Encoding/Decoding behavior of this type differs from that
/// of `Dictionary` both in that ordering is retained and also
/// in that an `OrderedDictionary` with any `Key` type that
/// is `LosslessStringConvertible` or `RawRepresentable`
/// as `String` will encode as a hash whereas non-`String`
/// keys result in `Dictionary` encoding as a list of alternating
/// keys and values.
public struct OrderedDictionary<Key, Value> where Key: Hashable {
    private var orderedKeys: [Key]
    private var unorderedHash: [Key: Value]

    public init() {
        orderedKeys = []
        unorderedHash = [:]
    }

    /// Get the value for the given key.
    public subscript(key: Key) -> Value? {
        get {
            return unorderedHash[key]
        }
        set {
            if let new = newValue {
                let old = unorderedHash.updateValue(new, forKey: key)
                if old == nil {
                    orderedKeys.append(key)
                }
                return
            }
            unorderedHash.removeValue(forKey: key)
            orderedKeys = orderedKeys.filter {$0 != key}
        }
    }

    /// Get the values in this dictionary in order.
    public var values: [Value] {
        return map { $0.1 }
    }
}

// MARK: - Dictionary Literal
extension OrderedDictionary: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        orderedKeys = []
        unorderedHash = [:]

        for (key, value) in elements {
            let old = unorderedHash.updateValue(value, forKey: key)
            if old == nil {
                orderedKeys.append(key)
            }
        }
    }
}

// MARK: - Collection
extension OrderedDictionary: Collection {
    public var startIndex: Int {
        orderedKeys.startIndex
    }

    public var endIndex: Int {
        orderedKeys.endIndex
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func makeIterator() -> Iterator {
        return Iterator(self)
    }

    /// Get the key/value pair at the given index.
    public subscript(position: Int) -> (key: Key, value: Value) {
        precondition(position < count)

        let key = orderedKeys[position]

        return (key, unorderedHash[key]!)
    }
}

// MARK: - Iterator
extension OrderedDictionary {
    public struct Iterator: Sequence, IteratorProtocol {
        private var idxReciprocal: Int
        private let dict: OrderedDictionary

        fileprivate init(_ dict: OrderedDictionary) {
            self.dict = dict
            self.idxReciprocal = dict.count
        }

        public mutating func next() -> (key: Key, value: Value)? {
            guard idxReciprocal > 0 else {
                return nil
            }

            defer { idxReciprocal -= 1 }
            let key = dict.orderedKeys[dict.orderedKeys.count - idxReciprocal]
            let value = dict.unorderedHash[key]

            return value.map { (key, $0) }
        }
    }
}

// MARK: - Equatable
extension OrderedDictionary: Equatable where Value: Equatable {}

// MARK: - Codable

internal struct AnyCodingKey: CodingKey {

    let stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    let intValue: Int? = nil

    init?(intValue: Int) {
        return nil
    }
}

// MARK: - Encodable
extension OrderedDictionary: Encodable where Key: Encodable, Value: Encodable {
    /// Encodes the contents of this dictionary into the given encoder.
    ///
    /// Much like `Dictionary`, if the key is `String` or `Int`, the contents are
    /// encoded in a keyed container. Otherwise, the contents are encoded as alternating
    /// key-value pairs in an unkeyed container.
    ///
    /// - Important: Unlike `Dictionary`, this will also encode all
    ///     `LosslessStringConvertible` and `RawRepresentable`
    ///     `String` keys into a keyed container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {

        // try for String
        if let encDict = self as? OrderedDictionary<String, Value> {
            try OpenAPIKit.encode(stringDict: encDict, to: encoder)
            return
        }

        // try for LosslessStringConvertible
        let losslessKVPairs = compactMap { (k, v) in (k as? LosslessStringConvertible).map { ($0, v) } }
        if losslessKVPairs.count == count {
            try OpenAPIKit.encode(keyValuePairs: losslessKVPairs, to: encoder)
            return
        }

        // try for RawRepresentable with String RawValues
        if let encDict = self as? StringRawKeyEncodable {
            let kvPairs = zip(encDict.orderedStringKeys, self.values)
            try OpenAPIKit.encode(keyValuePairs: kvPairs, to: encoder)
            return
        }

        // fallback to ordered list alternating key and value
        var container = encoder.unkeyedContainer()
        for (key, value) in self {
            try container.encode(key)
            try container.encode(value)
        }
    }
}

/// Encode a `String`-keyed OrderedDictionary as a hash.
internal func encode<Value: Encodable>(
    stringDict: OrderedDictionary<String, Value>,
    to encoder: Encoder
) throws {
    var container = encoder.container(keyedBy: AnyCodingKey.self)

    for (key, value) in stringDict {
        try container.encode(value, forKey: .init(stringValue: key))
    }
}

/// Encode a `LosslessStringConvertible`-keyed OrderedDictionary as a hash.
internal func encode<Value: Encodable>(
    keyValuePairs: [(LosslessStringConvertible, Value)],
    to encoder: Encoder
) throws {
    var container = encoder.container(keyedBy: AnyCodingKey.self)

    for (key, value) in keyValuePairs {
        try container.encode(value, forKey: .init(stringValue: key.description))
    }
}

/// Encode a sequence of `String`/`Value` pairs as a hash.
internal func encode<Value: Encodable>(
    keyValuePairs: Zip2Sequence<[String], [Value]>,
    to encoder: Encoder
) throws {
    var container = encoder.container(keyedBy: AnyCodingKey.self)

    for (key, value) in keyValuePairs {
        try container.encode(value, forKey: .init(stringValue: key))
    }
}

private protocol StringRawKeyEncodable {
    var orderedStringKeys: [String] { get }
}

extension OrderedDictionary: StringRawKeyEncodable where Key: RawRepresentable, Key.RawValue == String, Value: Encodable {

    var orderedStringKeys: [String] { map { $0.0.rawValue } }
}

// MARK: - Decodable
extension OrderedDictionary: Decodable where Key: Decodable, Value: Decodable {
    /// Decodes the contents of this dictionary from the given decoder.
    ///
    /// Much like `Dictionary`, if the key is `String` or `Int`, the contents are
    /// decoded from a keyed container. Otherwise, the contents are decoded from alternating
    /// key-value pairs in an unkeyed container.
    ///
    /// - Important: Unlike `Dictionary`, this will also decode all
    ///     `LosslessStringConvertible` and `RawRepresentable`
    ///     `String` keys from a keyed container.
    ///
    /// This function throws an error if any values are invalid for the given
    /// decoder's format.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {

        // try for String
        if Key.self == String.self {
            self = try Self.decodeStringDict(from: decoder) as! Self
            return
        }

        // try for LosslessStringConvertible
        if let decDictType = Self.self as? LosslessStringKeyDecodable.Type {
            self = try decDictType.decodeLosslessStringDict(from: decoder) as! Self
            return
        }

        // try for RawRepresentable with String RawValues
        if let decDictType = Self.self as? StringRawKeyDecodable.Type {
            self = try decDictType.decodeRawStringDict(from: decoder) as! Self
            return
        }

        // fallback to ordered list alternating key and value
        var container = try decoder.unkeyedContainer()
        var orderedKeys = [Key]()
        var unorderedHash = [Key:Value]()
        while !container.isAtEnd {
            let key = try container.decode(Key.self)
            let value = try container.decode(Value.self)

            let old = unorderedHash.updateValue(value, forKey: key)
            if old == nil {
                orderedKeys.append(key)
            }
        }
        self.orderedKeys = orderedKeys
        self.unorderedHash = unorderedHash
    }

    /// Decode a `String`-keyed OrderedDictionary from a hash.
    internal static func decodeStringDict(
        from decoder: Decoder
    ) throws -> OrderedDictionary<String, Value> {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var dict = OrderedDictionary<String, Value>()

        for key in container.allKeys {
            dict[key.stringValue] = try container.decode(Value.self, forKey: key)
        }

        return dict
    }
}

private protocol LosslessStringKeyDecodable {
    static func decodeLosslessStringDict(
        from decoder: Decoder
    ) throws -> Any
}

extension OrderedDictionary: LosslessStringKeyDecodable where Key: LosslessStringConvertible, Value: Decodable {
    /// Decode a `LosslessStringConvertible`-keyed OrderedDictionary from a hash.
    internal static func decodeLosslessStringDict(
        from decoder: Decoder
    ) throws -> Any {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var dict = OrderedDictionary<Key, Value>()

        for key in container.allKeys {
            guard let dictKey = Key(key.stringValue) else {
                // throw?
                continue
            }
            dict[dictKey] = try container.decode(Value.self, forKey: key)
        }

        return dict
    }
}

private protocol StringRawKeyDecodable {
    static func decodeRawStringDict(
        from decoder: Decoder
    ) throws -> Any
}

extension OrderedDictionary: StringRawKeyDecodable where Key: RawRepresentable, Key.RawValue == String, Value: Decodable {
    /// Decode a `RawRepresentable`-keyed OrderedDictionary from a hash.
    internal static func decodeRawStringDict(
        from decoder: Decoder
    ) throws -> Any {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var dict = OrderedDictionary<Key, Value>()

        for key in container.allKeys {
            guard let dictKey = Key(rawValue: key.stringValue) else {
                // throw?
                continue
            }
            dict[dictKey] = try container.decode(Value.self, forKey: key)
        }

        return dict
    }
}
