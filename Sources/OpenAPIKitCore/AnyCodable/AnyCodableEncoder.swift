import Foundation

public extension AnyCodable {
    
    /// Creates a new instance from the given `Encodable` value.
    ///
    /// - Parameters:
    ///  - value: The value to encode.
    /// - valueEncodingStrategies: Value encoding strategies to use.
    /// - keyEncodingStrategy: The key encoding strategy to use.
    /// - Returns: A new instance of `AnyCodable` or `nil` if the given value cannot be encoded.
    static func encoded(
        _ value: Encodable,
        valueEncodingStrategies: [ValueEncodingStrategy] = [.Decimal.number, .URL.uri, .Data.base64],
        keyEncodingStrategy: KeyEncodingStrategy = .default
    ) throws -> AnyCodable {
        let newEncoder = AnyCodableEncoder(strategies: valueEncodingStrategies, keyEncodingStrategy: keyEncodingStrategy)
        return try newEncoder.encode(value)
    }
}

private final class AnyCodableEncoder: Encoder {
    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    private var result: AnyCodable
    let strategies: [ValueEncodingStrategy]
    let keyEncodingStrategy: KeyEncodingStrategy

    init(
        codingPath: [CodingKey] = [],
        strategies: [ValueEncodingStrategy],
        keyEncodingStrategy: KeyEncodingStrategy
    ) {
        self.codingPath = codingPath
        userInfo = [:]
        self.strategies = strategies
        self.keyEncodingStrategy = keyEncodingStrategy
        result = .object([:])
    }

    func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        let container = AnyCodableKeyedEncodingContainer<Key>(
            codingPath: codingPath,
            encoder: self,
            result: Ref(
                get: { [self] in
                    guard case let .object(value) = self.result else { return [:] }
                    return value
                }, set: { [self] newValue in
                    self.result = .object(newValue)
                }
            )
        )
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        AnyCodableUnkeyedEncodingContainer(
            codingPath: codingPath,
            encoder: self,
            result: Ref(
                get: { [self] in
                    if case let .array(value) = self.result {
                        return value
                    }
                    return []
                }, set: { [self] newValue in
                    self.result = .array(newValue)
                }
            )
        )
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        AnyCodableSingleValueEncodingContainer(
            codingPath: codingPath,
            encoder: self,
            result: Ref(self, \.result)
        )
    }

    func encode(_ value: Encodable) throws -> AnyCodable {
        switch value {
        case nil as Any?:
            result = .null

        default:
            for format in strategies {
                if try format.encode(value, self) {
                    return result
                }
            }
            try value.encode(to: self)
        }
        return result
    }
}

private struct AnyCodableSingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey]
    let encoder: AnyCodableEncoder
    @Ref var result: AnyCodable

    mutating func encodeNil() throws {}

    mutating func encode(_ value: Bool) throws {
        result = .bool(value)
    }

    mutating func encode(_ value: String) throws {
        result = .string(value)
    }

    mutating func encode(_ value: Double) throws {
        result = .double(value)
    }

    mutating func encode(_ value: Float) throws {
        result = .double(Double(value))
    }

    mutating func encode(_ value: Int) throws {
        result = .int(value)
    }

    mutating func encode(_ value: Int8) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: Int16) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: Int32) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: Int64) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: UInt) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: UInt8) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: UInt16) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: UInt32) throws {
        result = .int(Int(value))
    }

    mutating func encode(_ value: UInt64) throws {
        result = .int(Int(value))
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        let newEncoder = AnyCodableEncoder(codingPath: codingPath, strategies: encoder.strategies, keyEncodingStrategy: encoder.keyEncodingStrategy)
        result = try newEncoder.encode(value)
    }
}

private struct AnyCodableKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var codingPath: [CodingKey]
    let encoder: AnyCodableEncoder
    @Ref var result: [String: AnyCodable]

    @inline(__always)
    private func str(_ key: Key) -> String {
        encoder.keyEncodingStrategy.encode(key.stringValue)
    }

    mutating func encodeNil(forKey key: Key) throws {
        result[str(key)] = nil
    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        result[str(key)] = .bool(value)
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        result[str(key)] = .string(value)
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        result[str(key)] = .double(value)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        result[str(key)] = .double(Double(value))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        result[str(key)] = .int(value)
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        let newEncoder = AnyCodableEncoder(codingPath: nestedPath(for: key), strategies: encoder.strategies, keyEncodingStrategy: encoder.keyEncodingStrategy)
        result[str(key)] = try newEncoder.encode(value)
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let strKey = str(key)
        let container = AnyCodableKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath(for: key),
            encoder: encoder,
            result: Ref(
                get: { [$result] in
                    guard
                        case let .object(value) = $result.wrappedValue[strKey]
                    else { return [:] }
                    return value
                }, set: { [$result] newValue in
                    $result.wrappedValue[strKey] = .object(newValue)
                }
            )
        )
        result[strKey] = .object([:])
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let strKey = str(key)
        let container = AnyCodableUnkeyedEncodingContainer(
            codingPath: nestedPath(for: key),
            encoder: encoder,
            result: Ref(
                get: { [$result] in
                    guard
                        case let .array(value) = $result.wrappedValue[strKey]
                    else { return [] }
                    return value
                }, set: { [$result] newValue in
                    $result.wrappedValue[strKey] = .array(newValue)
                }
            )
        )
        result[strKey] = .array([])
        return container
    }

    mutating func superEncoder() -> Encoder {
        AnyCodableEncoder(codingPath: codingPath, strategies: encoder.strategies, keyEncodingStrategy: encoder.keyEncodingStrategy)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        result[str(key)] = .object([:])
        return AnyCodableEncoder(codingPath: nestedPath(for: key), strategies: encoder.strategies, keyEncodingStrategy: encoder.keyEncodingStrategy)
    }

    private func nestedPath(for key: Key) -> [CodingKey] {
        codingPath + [key]
    }
}

private struct AnyCodableUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var count: Int { result.count }
    let encoder: AnyCodableEncoder
    @Ref var result: [AnyCodable]

    private var nestedPath: [CodingKey] {
        codingPath + [IntKey(intValue: codingPath.count)]
    }

    mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        let index = result.count
        let container = AnyCodableKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath,
            encoder: encoder,
            result: Ref(
                get: { [$result] in
                    guard
                        $result.wrappedValue.indices.contains(index),
                        case let .object(value) = $result.wrappedValue[index]
                    else { return [:] }
                    return value
                }, set: { [$result] newValue in
                    guard $result.wrappedValue.indices.contains(index) else {
                        return
                    }
                    $result.wrappedValue[index] = .object(newValue)
                }
            )
        )
        result.append(.object([:]))
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let index = result.count
        let container = AnyCodableUnkeyedEncodingContainer(
            codingPath: nestedPath,
            encoder: encoder,
            result: Ref(
                get: { [$result] in
                    guard
                        $result.wrappedValue.indices.contains(index),
                        case let .array(value) = $result.wrappedValue[index]
                    else { return [] }
                    return value
                }, set: { [$result] newValue in
                    guard $result.wrappedValue.indices.contains(index) else {
                        return
                    }
                    $result.wrappedValue[index] = .array(newValue)
                }
            )
        )
        result.append(.array([]))
        return container
    }

    mutating func encodeNil() throws {}

    mutating func superEncoder() -> Encoder {
        AnyCodableEncoder(codingPath: codingPath, strategies: encoder.strategies, keyEncodingStrategy: encoder.keyEncodingStrategy)
    }

    mutating func encode(_ value: Bool) throws {
        result.append(.bool(value))
    }

    mutating func encode(_ value: String) throws {
        result.append(.string(value))
    }

    mutating func encode(_ value: Double) throws {
        result.append(.double(value))
    }

    mutating func encode(_ value: Float) throws {
        result.append(.double(Double(value)))
    }

    mutating func encode(_ value: Int) throws {
        result.append(.int(value))
    }

    mutating func encode(_ value: Int8) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: Int16) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: Int32) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: Int64) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: UInt) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: UInt8) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: UInt16) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: UInt32) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode(_ value: UInt64) throws {
        result.append(.int(Int(value)))
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        let newEncoder = AnyCodableEncoder(
            codingPath: nestedPath,
            strategies: encoder.strategies,
            keyEncodingStrategy: encoder.keyEncodingStrategy
        )
        try result.append(newEncoder.encode(value))
    }
}

private struct IntKey: CodingKey {
    let intValue: Int?
    let stringValue: String

    init(intValue: Int) {
        self.intValue = intValue
        stringValue = intValue.description
    }

    init?(stringValue: String) {
        intValue = Int(stringValue)
        self.stringValue = stringValue
    }
}
