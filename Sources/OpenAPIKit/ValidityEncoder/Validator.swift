//
//  Validator.swift
//
//
//  Created by Mathew Polzin on 6/2/20.
//

extension OpenAPI.Document {
    /// Validate this `OpenAPI.Document`.
    ///
    /// - parameter validator: Validator to use. By default,
    ///     a validator that just asserts requirements of the OpenAPI
    ///     Specification will be used.
    ///
    /// - throws: `ValidationErrors` if any validations failed.
    ///     `EncodingError` if encoding failed for a structural reason.
    public func validate(using validator: Validator = .default) throws {
        let validator = _Validator(document: self, validations: validator.validations)
        var container = validator.singleValueContainer()

        // we kick things off by applying validations to the root (OpenAPI.Document)
        // and then encoding with the single value container.
        // After this, validations are only applied by keyed/unkeyed containers and
        // by the leaf node methods of the single value container.
        validator.applyValidations(to: self)
        try container.encode(self)

        if !validator.errors.isEmpty {
            throw ValidationErrors(values: validator.errors)
        }
    }
}

/// `Codable`-style `Encoder` that can be used to encode an `Encodable` type to a `Validity` by applying
/// the specified validation checks.
public final class Validator {

    internal var validations: [AnyValidation]

    /// Creates a `Validator`.
    internal init(validations: [AnyValidation]) {
        self.validations = validations
    }

    /// Creates an empty `Validator`. Note that
    /// this Validator will not perform any validations
    /// that are not added to it. If you want to start with
    /// the validations required by the OpenAPI specifcation,
    /// use `Validator.default`.
    public convenience init() {
        self.init(validations: [])
    }

    /// The default Validator contians only
    /// validations required by the OpenAPI
    /// specification.
    public static var `default`: Self {
        Self.init(validations: []) // TODO: add default validations
    }

    /// Add a validation to be performed.
    ///
    /// - Parameters:
    ///     - validate: A function taking values of type `T` and validating
    ///         them. This function should return an array of all validation failures.
    ///         `ValidationError` is a good general purpose error for this use-case.
    ///
    public func validating<T: Encodable>(
        _ validate: @escaping (ValidationContext<T>) -> [ValidationError]
    ) -> Self {
        return validating(Validation(if: { _ in true }, validate: validate))
    }

    /// Add a validation to be performed.
    ///
    /// - Parameters:
    ///     - validate: A function taking values of type `T` and validating
    ///         them. This function should return an array of all validation failures.
    ///         `ValidationError` is a good general purpose error for this use-case.
    ///     - predicate: A function returning `true` if this validator
    ///         should run against the given value.
    ///
    public func validating<T: Encodable>(
        _ validate: @escaping (ValidationContext<T>) -> [ValidationError],
        where predicate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        return validating(Validation(if: predicate, validate: validate))
    }

    /// Add a validation to be performed.
    public func validating<T: Encodable>(_ validation: Validation<T>) -> Self {
        validations.append(AnyValidation(validation))
        return self
    }
}

/// Must be used with Encodable dict values and array elements only.
enum ValidityEncoderNode {
    case unused
    case single
    case unkeyed(count: Int)
    case keyed
}

class _Validator: Encoder {

    init(
        document: OpenAPI.Document,
        validations: [AnyValidation],
        userInfo: [CodingUserInfoKey: Any] = [:],
        codingPath: [CodingKey] = []
    ) {
        self.document = document
        self.validations = validations
        self.userInfo = userInfo
        self.codingPath = codingPath
    }

    let codingPath: [CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let document: OpenAPI.Document
    private(set) var validations: [AnyValidation]

    var errors: [ValidationError] = []
    var node: ValidityEncoderNode = .unused

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return .init(_KeyedEncodingContainer(referencing: self))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return _UnkeyedEncodingContainer(referencing: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }

    var unkeyedCount: Int {
        get {
            guard case .unkeyed(let count) = node else {
                return 0
            }
            return count
        }
        set {
            guard case .unkeyed = node else {
                fatalError()
            }
            node = .unkeyed(count: newValue)
        }
    }

    /// create a new `_ReferencingEncoder` instance as `key` inheriting `userInfo`
    func encoder(for key: CodingKey) -> _ReferencingValidator {
        return .init(referencing: self, key: key)
    }

    /// create a new `_ReferencingEncoder` instance at `index` inheriting `userInfo`
    func encoder(at index: Int) -> _ReferencingValidator {
        return .init(referencing: self, at: index)
    }

    private var canEncodeNewValue: Bool {
        guard case .unused = node else {
            return false
        }
        return true
    }
}

class _ReferencingValidator: _Validator {
    private enum Reference {
        case dictionary(String)
        case array(Int)
    }

    private let encoder: _Validator
    private let reference: Reference

    init(referencing encoder: _Validator, key: CodingKey) {
        self.encoder = encoder
        reference = .dictionary(key.stringValue)
        super.init(
            document: encoder.document,
            validations: encoder.validations,
            userInfo: encoder.userInfo,
            codingPath: encoder.codingPath + [key]
        )
    }

    init(referencing encoder: _Validator, at index: Int) {
        self.encoder = encoder
        reference = .array(index)
        super.init(
            document: encoder.document,
            validations: encoder.validations,
            userInfo: encoder.userInfo,
            codingPath: encoder.codingPath + [_CodingKey(index: index)]
        )
    }

    deinit {
        encoder.errors += errors
        switch reference {
        case .dictionary:
            switch encoder.node {
            case .keyed, .unused:
                break

            case .single, .unkeyed:
                fatalError()
            }
        case .array(let index):
            switch encoder.node {
            case .unkeyed(var count):
                if index == count {
                    count += 1
                }
                encoder.node = .unkeyed(count: count)
            case .unused:
                encoder.node = .unkeyed(count: 1)

            case .keyed, .single:
                fatalError()
            }
        }
    }
}

extension _Validator: SingleValueEncodingContainer {
    func encodeNil() {
        assertCanEncodeNewValue()
        node = .single
    }

    func encode(_ value: Bool) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: String) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Double) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Float) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Int) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Int8) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Int16) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Int32) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: Int64) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: UInt) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: UInt8) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: UInt16) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: UInt32) {
        applyValidations(to: value)
        node = .single
    }

    func encode(_ value: UInt64) {
        applyValidations(to: value)
        node = .single
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        assertCanEncodeNewValue()
        try value.encode(to: self)
    }

    /// Asserts that a single value can be encoded at the current coding path
    /// (i.e. that one has not already been encoded through this container).
    /// `preconditionFailure()`s if one cannot be encoded.
    private func assertCanEncodeNewValue() {
        precondition(
            canEncodeNewValue,
            "Attempt to encode value through single value container when previously value already encoded."
        )
    }

    fileprivate func applyValidations(to value: Encodable) {
        for idx in validations.indices {
            #if swift(>=5.2)
            errors += validations[idx](value, in: document, at: codingPath)
            #else
            errors += validations[idx].attempt(on: value, in: document, at: codingPath)
            #endif
        }
    }
}

struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let encoder: _Validator

    init(referencing encoder: _Validator) {
        self.encoder = encoder
    }

    var codingPath: [CodingKey] { encoder.codingPath }

    var count: Int { encoder.unkeyedCount }

    func encodeNil() {
        encoder.unkeyedCount += 1
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        encoder.applyValidations(to: value)
        try currentEncoder.encode(value)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        currentEncoder.container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        currentEncoder.unkeyedContainer()
    }

    func superEncoder() -> Encoder { currentEncoder }

    private var currentEncoder: _ReferencingValidator {
        return encoder.encoder(at: count)
    }
}

struct _KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {

    let encoder: _Validator

    init(referencing encoder: _Validator) {
        self.encoder = encoder
    }

    var codingPath: [CodingKey] { encoder.codingPath }

    func encodeNil(forKey key: Key) {}

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        encoder.applyValidations(to: value)
        try encoder(for: key).encode(value)
    }

    func encode(_ value: Bool, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: String, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Double, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Float, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Int, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Int8, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Int16, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Int32, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: Int64, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: UInt, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: UInt8, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: UInt16, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: UInt32, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func encode(_ value: UInt64, forKey key: Key) {
        encoder(for: key).encode(value)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        encoder(for: key).container(keyedBy: keyType)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        encoder(for: key).unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        encoder(for: _CodingKey.super)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        encoder(for: key)
    }

    private func encoder(for key: CodingKey) -> _ReferencingValidator { return encoder.encoder(for: key) }
}

struct _CodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    static let `super` = _CodingKey(stringValue: "super")
}
