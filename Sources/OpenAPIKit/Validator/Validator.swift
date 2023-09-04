//
//  Validator.swift
//
//
//  Created by Mathew Polzin on 6/2/20.
//

import OpenAPIKitCore

extension OpenAPI.Document {
    /// Validate this `OpenAPI.Document`.
    ///
    /// - parameters:
    ///     - validator: Validator to use. By default,
    ///         a validator that just asserts requirements of the OpenAPI
    ///         Specification will be used.
    ///     - strict: When true, warnings are thrown as errors. Set to false to
    ///         return warnings instead of throwing them. True by default.
    ///
    /// - throws: `ValidationErrors` if any validations failed.
    ///     `EncodingError` if encoding failed for a structural reason.
    /// - returns: Any warnings that did not cause validation to fail.
    ///
    /// Call without any arguments to validate some aspects of the OpenAPI
    /// Specification not guaranteed by the Swift types in OpenAPIKit.
    /// You can create a `Validator` of your own, adding additional steps
    /// to the validation (or starting from scratch), and then pass that
    /// `Validator` to the `validate(using:)` method to use custom validation
    /// criteria.
    @discardableResult
    public func validate(using validator: Validator = .init(), strict: Bool = true) throws -> [OpenAPI.Warning] {
        let validator = _Validator(document: self, validations: validator.validations)
        var container = validator.singleValueContainer()

        // we kick things off by applying validations to the root (OpenAPI.Document)
        // and then encoding with the single value container.
        // After this, validations are only applied by keyed/unkeyed containers and
        // by the leaf node methods of the single value container.
        validator.applyValidations(to: self)
        try container.encode(self)

        let errors: [ValidationError]
        if strict {
            let warningsAsErrors = validator.warnings.map { warning in
                return ValidationError(
                    reason: warning.localizedDescription,
                    at: warning.codingPath ?? []
                )
            }
            errors = validator.errors + warningsAsErrors
        } else {
            errors = validator.errors
        }

        if !errors.isEmpty {
            throw ValidationErrorCollection(values: errors)
        }
        return (strict ? [] : validator.warnings)
    }
}

/// A validator that works by traversing an `Encodable` object and validating
/// any values that match an included validation's type and pass that validation's
/// predicate.
///
/// The default Validator will perform a set of default validations
/// that catch OpenAPI Specification violations not possible (or inconvenient) to
/// prevent using the Swift type-system.
///
/// **Example**
///
///     let document = OpenAPI.Document(...)
///     let validator = Validator()
///     try document.validate(using: validator)
///
///     // or, equivalently for the default validator:
///     try document.validate()
///
/// The default validations are
/// - Operations must contain at least one response.
/// - Document-level tag names are unique.
/// - Parameters are unique within each Path Item.
/// - Parameters are unique within each Operation.
/// - Operation Ids are unique across the whole Document.
/// - All OpenAPI.References that refer to components in this
///     document can be found in the components dictionary.
///
/// If you want a Validator that won't perform any
/// validations except the ones you add, use
/// `Validator.blank`.
///
/// You can add validations to the validator using the
/// `validating()` instance methods.
///
/// There are a few default validations that ship with OpenAPIKit but
/// are not used unless explicitly added to a Validator. You can find these
/// validations as static members of the `Validation` type.
///
/// **Example**
///
///     let document = OpenAPI.Document(...)
///     let validator = Validator()
///         .validating(.documentContainsPaths)
///         .validating(.pathsContainOperations)
///     try document.validate(using: validator)
///
/// At their core, all validations are values of the `Validation`
/// type. You can create validations by initializing the `Validation`
/// type directly but it is generally more convenient to add validations
/// to a Validator using one of the convenience `validating()`
/// methods that know how to construct `Validation` on your behalf.
///
/// For example, you can construct validation methods for simple equalities
/// and inequalities by specifying the KeyPath from any OpenAPI type to
/// the value you want to validate and then writing the equality/inequality
/// that must succeed for the validation to pass.
///
/// **Example**
///
///     let validator = Validator()
///         .validating(
///             "API version is 2.0",
///             check: \OpenAPI.Document.Info.version == "2.0"
///     )
///
/// You can add a `where` clause to any validation as long as the `check` and
/// `where` clause both examine the same type (i.e. `OpenAPI.Document.Info`
/// from the previous example and `OpenAPI.Document` from the next example).
///
/// The next example also uses `take()`  in its `where` caluse. This allows you to
/// dig into a value based on its KeyPath just like the previous example but you can
/// use it for more complicated criteria than equality/inequality.
///
/// Finally, the next example also introduces the context access KayPath syntax in its
/// `check` clause. This syntax allows you to access the entire OpenAPI Document
/// that is being validated as `\.document`. It also gives you access to the current value
/// being validated as `\.subject` and the current key path as `\.codingPath`.
///
/// **Example**
///
///     let validator = Validator()
///         .validating(
///             "At least two servers are specified if one of them is the test server.",
///             check: \.document.servers.count >= 2,
///             when: take(\OpenAPI.Document.servers) { servers in
///                 servers.map { $0.url.absoluteString }.contains("https://test.server.com")
///             }
///     )
///
/// Context access, the `take()` method, and the inequality KeyPath syntax are all
/// allowed in both the `check` and `where` clauses. Just keep in mind that if you
/// omit information about the type of thing being validated in one clause (as you do
/// when you access `\.document`) then you need to indicate the type (perhaps with
/// a KeyPath that includes the full type as in `\OpenAPI.Document.servers` above) in the other clause
/// so the type system knows what you are validating.
///
public final class Validator {

    internal var validations: [AnyValidation]

    /// Creates a `Validator`.
    internal init(validations: [AnyValidation]) {
        self.validations = validations
    }

    /// Creates the default `Validator`. Note that
    /// this Validator will perform the default validations.
    /// If you want a Validator that won't perform any
    /// validations except the ones you add, use
    /// `Validator.blank`.
    ///
    /// The default validations are
    /// - Document-level tag names are unique.
    /// - Parameters are unique within each Path Item.
    /// - Parameters are unique within each Operation.
    /// - Operation Ids are unique across the whole Document.
    /// - All OpenAPI.References that refer to components in this
    ///     document can be found in the components dictionary.
    /// - `Enum` must not be empty in the document's
    ///     Server Variable.
    /// - `Default` must exist in the enum values in the document's
    ///     Server Variable.
    ///
    public convenience init() {
        self.init(validations: [
            .init(.documentTagNamesAreUnique),
            .init(.pathItemParametersAreUnique),
            .init(.operationParametersAreUnique),
            .init(.operationIdsAreUnique),
            .init(.schemaReferencesAreValid),
            .init(.responseReferencesAreValid),
            .init(.parameterReferencesAreValid),
            .init(.exampleReferencesAreValid),
            .init(.requestReferencesAreValid),
            .init(.headerReferencesAreValid),
            .init(.linkReferencesAreValid),
            .init(.pathItemReferencesAreValid),
            .init(.serverVarialbeEnumIsValid),
            .init(.serverVarialbeDefaultExistsInEnum)
        ])
    }

    /// A validator with no validation rules at all (not
    /// even the defaults).
    public static var blank: Validator {
        return Self.init(validations: [])
    }

    /// Add a validation to be performed.
    public func validating<T: Encodable>(_ validation: Validation<T>) -> Self {
        validations.append(AnyValidation(validation))
        return self
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
        return validating(Validation(check: validate, when: { _ in true }))
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
        when predicate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        return validating(Validation(check: validate, when: predicate))
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function and add it to the `Validator`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    public func validating<T: Encodable>(
        _ description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        return validating({ context in
            return validate(context)
                ? []
                : [ ValidationError(reason: "Failed to satisfy: \(description)", at: context.codingPath) ]
        })
    }

    /// Given the description of the correct & valid state being asserted,
    /// create a validation function and add it to the `Validator`.
    ///
    /// - Parameters:
    ///     - description: The description of the correct state described by the assertion.
    ///     - validate: The function called to assert a condition. The function should return `false`
    ///         if the validity check has failed or `true` if everything is valid.
    ///     - predicate: A condition that must be met for this validation to be applied.
    public func validating<T: Encodable>(
        _ description: String,
        check validate: @escaping (ValidationContext<T>) -> Bool,
        when predicate: @escaping (ValidationContext<T>) -> Bool
    ) -> Self {
        let validity: (ValidationContext<T>) -> [ValidationError] = { context in
            return validate(context)
                ? []
                : [ ValidationError(reason: "Failed to satisfy: \(description)", at: context.codingPath) ]
        }

        return validating(validity, when: predicate)
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

    var warnings: [OpenAPI.Warning] = []
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
            codingPath: encoder.codingPath + [Validator.CodingKey(index: index)]
        )
    }

    deinit {
        encoder.warnings += warnings
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
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: String) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Double) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Float) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Int) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Int8) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Int16) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Int32) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: Int64) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: UInt) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: UInt8) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: UInt16) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: UInt32) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode(_ value: UInt64) {
        applyValidations(to: value)
        collectWarnings(from: value)
        node = .single
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        assertCanEncodeNewValue()
        applyValidations(to: value)
        collectWarnings(from: value)
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

    fileprivate func applyValidations(to value: Encodable, atKey key: CodingKey? = nil) {
        let pathTail = key.map { [$0] } ?? []
        for idx in validations.indices {
            errors += validations[idx].apply(to: value, at: codingPath + pathTail, in: document)
        }
    }

    // take a warning that does not have a coding path associated and give it
    // a coding path (when possible).
    fileprivate func contextualize(at path: [CodingKey]) -> (OpenAPI.Warning) -> OpenAPI.Warning {
        return { warning in
            if path.isEmpty {
                return warning
            }
            switch warning {
            case .underlyingError: return warning
            case .message(let details): return .underlyingError(CodingPathError(details: details, codingPath: path))
            }
        }
    }

    fileprivate func collectWarnings(from value: Encodable, atKey key: CodingKey? = nil) {
        let pathTail = key.map { [$0] } ?? []
        if let warnable = value as? HasWarnings {
            warnings += warnable.warnings.map(contextualize(at: codingPath + pathTail))
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
        encoder(for: Validator.CodingKey.super)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        encoder(for: key)
    }

    private func encoder(for key: CodingKey) -> _ReferencingValidator { return encoder.encoder(for: key) }
}

extension Validator {
    public struct CodingKey: Swift.CodingKey {
        public var stringValue: String
        public var intValue: Int?

        public init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        public init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }

        init(index: Int) {
            self.stringValue = "Index \(index)"
            self.intValue = index
        }

        static let `super` = CodingKey(stringValue: "super")
    }
}
